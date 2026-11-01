from decimal import Decimal
from typing import Annotated, Iterable, List

from fastapi import Depends, HTTPException
from sqlmodel import Session
from typing_extensions import Optional

from core.business.balance_service import BalanceService
from core.business.exchange_service import ExchangeService
from core.dataaccess.store import Store
from data_export.facade import DataExportFacade
from models import Transaction, ExchangePayment, Payment, User, PaymentWithAmounts
from persistence import require_persisted_id


class PaymentService:
    def __init__(self, store: Annotated[Store, Depends()],
                 balance_service: Annotated[BalanceService, Depends()],
                 exchange_service: Annotated[ExchangeService, Depends()],
                 data_export: Annotated[DataExportFacade, Depends()]):
        self.store = store
        self.balance_service = balance_service
        self.exchange_service = exchange_service
        self.data_export = data_export
    
    def get_payments(self, session: Session, user: User, account_id: int | None, processed: bool | None = None):
        payments = self.store.get_payments(session, user, account_id, processed)

        def map_payment(payment: Payment):
            return PaymentWithAmounts.model_validate(payment, update={
                "amount_eur_with_fx": payment.amount_eur,
                "amount_eur_without_fx": self._calc_amount_eur_without_fx(session, payment)
            })

        return [map_payment(payment) for payment in payments]

    def _calc_amount_eur_without_fx(self, session: Session, payment: Payment) -> Optional[int]:
        if payment.status == Payment.Status.PENDING.value:
            try:
                guessed_transactions = self._guess_transactions_to_process(session, payment)
                return self._sum_eur_amounts(guessed_transactions)
            except Exception as e:
                print("Unable to calculate amount_eur (probably some tx.amount_eur is missing): " + str(e))
                return None

        return self._sum_eur_amounts(payment.transactions)

    @staticmethod
    def _sum_eur_amounts(transactions: Iterable[Transaction]) -> int | None:
        total = 0
        for transaction in transactions:
            if transaction.amount_eur is None:
                return None
            total += transaction.amount_eur
        return total

    def process_payment(self, session: Session, super_user: User, payment_id: int, transaction_ids: list[int] | None = None):
        if not super_user.super_user:
            raise HTTPException(status_code=403)
        
        payment = self.store.get_payment_unsafe(session, payment_id)
        if not payment:
            raise HTTPException(status_code=404)

        if transaction_ids:
            transactions = []
            for tx_id in transaction_ids:
                transaction = self.store.get_transaction(session, super_user, tx_id)
                if transaction is None:
                    raise HTTPException(status_code=404, detail=f"Transaction {tx_id} not found")
                transactions.append(transaction)
        else:
            transactions = self._guess_transactions_to_process(session, payment)

        account_id = require_persisted_id(payment.account)
        actual_payment_id = None
        original_actual_ids = {
            require_persisted_id(tx): tx.actual_id for tx in transactions
        }

        try:
            self._process_payment(session, payment, transactions)

            if super_user == payment.account.user:
                self.data_export.update_transactions(session, super_user, account_id, transactions)
            actual_payment_id = self.data_export.export_payment(session, super_user, account_id, payment)
            session.commit()
        except Exception:
            created_transaction_actual_ids = {
                tx.id: tx.actual_id for tx in transactions
                if tx.id is not None and original_actual_ids.get(tx.id) is None and tx.actual_id is not None
            }
            session.rollback()
            self._persist_transaction_actual_ids(session, created_transaction_actual_ids)

            if actual_payment_id is not None:
                try:
                    self.data_export.delete_payment(super_user, actual_payment_id)
                except Exception:
                    pass

            raise
    
    def unprocess_payment(self, session: Session, super_user: User, payment_id: int):
        if not super_user.super_user:
            raise HTTPException(status_code=403)
        
        payment = self.store.get_payment_unsafe(session, payment_id)
        if not payment:
            raise HTTPException(status_code=404)

        if payment.status_enum != Payment.Status.PROCESSED:
            raise HTTPException(status_code=400, detail="Only processed payments can be unprocessed")

        transactions = self.store.get_paid_transactions_by_payment(session, payment_id)
        
        payment.status_enum = Payment.Status.POSTED
        payment.amount_eur = None
        session.add(payment)

        for tx in transactions:
            tx.status_enum = Transaction.Status.POSTED
            tx.payment = None
            tx.fees_and_risk_eur = None
            session.add(tx)
        session.commit()

        if super_user == payment.account.user:
            account_id = require_persisted_id(payment.account)
            self.data_export.update_transactions(session, super_user, account_id, transactions)

        if payment.actual_id is not None:
            self.data_export.delete_payment(super_user, payment.actual_id)
            payment.actual_id = None
            session.add(payment)
            session.commit()

    def delete_payment(self, session: Session, super_user: User, payment_id: int):
        if not super_user.super_user:
            raise HTTPException(status_code=403)

        payment = self.store.get_payment_unsafe(session, payment_id)
        if not payment:
            raise HTTPException(status_code=404)

        if payment.status_enum != Payment.Status.PENDING:
            raise HTTPException(status_code=400, detail="Only pending payments can be deleted")

        session.delete(payment)
        session.commit()

    def _guess_transactions_to_process(self, session: Session, payment: Payment):
        account_id = require_persisted_id(payment.account)
        transactions = self.store.get_posted_transactions_by_account(session, account_id)

        process_tx = []
        amount = payment.amount_usd

        for tx in transactions:
            tx_remaining = self.balance_service.calc_transaction_remaining(session, tx)
            if 0 < amount < tx_remaining:
                raise Exception("Error finding transactions automatically.")

            if amount > 0:
                process_tx.append(tx)
                amount -= tx_remaining
            else:
                break

        return process_tx

    def _persist_transaction_actual_ids(self, session: Session, actual_ids: dict[int, str]):
        if not actual_ids:
            return

        with Session(session.get_bind()) as persist_session:
            for tx_id, actual_id in actual_ids.items():
                tx = persist_session.get(Transaction, tx_id)
                if tx is None or tx.actual_id is not None:
                    continue

                tx.actual_id = actual_id
                persist_session.add(tx)

            persist_session.commit()

    def _process_payment(self, session: Session, payment: Payment, transactions: List[Transaction]):
        if any(tx.amount_eur is None for tx in transactions):
            raise Exception("Error: All transactions must have amount_eur set!")
        
        if payment.status_enum == Payment.Status.PENDING:
            raise Exception("Error: Payment is still pending!")

        if payment.status_enum == Payment.Status.PROCESSED or len(payment.transactions) > 0:
            raise Exception("Error: Payment was already processed!")

        tx_remaining_sum = sum([self.balance_service.calc_transaction_remaining(session, tx) for tx in transactions])
        if payment.amount_usd != tx_remaining_sum:
            raise Exception("Error: Payment amount does not match sum of transactions!")

        payment_id = require_persisted_id(payment)
        exchange_payments = self.store.get_exchange_payments_by_payment(session, payment_id)
        amount_eur = self._calc_payment_amount_eur(exchange_payments)

        for tx in transactions:
            tx.fees_and_risk_eur = self._calc_fees_and_risk(session, tx, payment, exchange_payments, amount_eur)
            tx.payment_id = payment_id
            tx.status_enum = Transaction.Status.PAID
            session.add(tx)

        # Reconcile against the exact rounded amount stored on the payment.
        rounded_amount_eur = round(amount_eur)
        payment.amount_eur = rounded_amount_eur
        payment.status_enum = Payment.Status.PROCESSED
        session.add(payment)

        eur_sum = 0
        for tx in transactions:
            if tx.amount_eur is None or tx.fees_and_risk_eur is None:
                raise ValueError("Processed transaction is missing a EUR amount or fees")
            eur_sum += tx.amount_eur + tx.fees_and_risk_eur
        eur_err = rounded_amount_eur - eur_sum
        print("Calculated eur_err of " + str(eur_err)) # TODO: send notification or display in frontend

        # apply error to largest transaction
        largest_tx = max(transactions, key=lambda tx: tx.amount_eur or 0)
        if largest_tx.fees_and_risk_eur is None:
            raise ValueError("Processed transaction is missing fees")
        largest_tx.fees_and_risk_eur = largest_tx.fees_and_risk_eur + eur_err
        session.add(largest_tx)
    def _calc_fees_and_risk(self, session: Session, tx: Transaction, payment: Payment, exchange_payments: List[ExchangePayment], payment_amount_eur: Decimal) -> int:
        if tx.amount_eur == 0:
            return 0
        if tx.amount_eur is None:
            raise ValueError("Transaction is missing a EUR amount")

        neutral_sum = self._calc_neutral_sum(exchange_payments)
        eur_usd_exchanged = Decimal(payment.amount_usd - neutral_sum) / payment_amount_eur

        amount_usd = self.balance_service.calc_transaction_remaining(session, tx)
        value_eur_exchanged = amount_usd / eur_usd_exchanged
        effective_fees_total = value_eur_exchanged - tx.amount_eur

        return round(effective_fees_total)


    def _calc_payment_amount_eur(self, exchange_payments: List[ExchangePayment]) -> Decimal:
        amount_eur = Decimal(0)
        for ep in exchange_payments:
            if ep.exchange.paid_eur != 0:  # ignore neutral exchanges
                amount_eur += (Decimal(ep.amount) / Decimal(ep.exchange.amount_usd)) * ep.exchange.amount_eur

        return amount_eur
    
    
    def _calc_neutral_sum(self, exchange_payments: List[ExchangePayment]) -> int:
        # Ignore "neutral" exchanges (i.e. exchange.paid_eur == 0). Ignored exchanges won't affect the avg rate.

        neutral_sum = 0
        for ep in exchange_payments:
            if ep.exchange.paid_eur == 0:
                neutral_sum += ep.amount

        return neutral_sum
