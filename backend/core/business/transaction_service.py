import datetime
from decimal import Decimal
from typing import Annotated, List

from fastapi import Depends, HTTPException
from sqlmodel import Session, SQLModel

from core.dataaccess.store import Store
from data_export.facade import DataExportFacade
from exchangerate.facade import ExchangeRateFacade
from models import Transaction, User, TransactionWithGuessedAmount
from persistence import require_persisted_id


class TransactionAmount(SQLModel):
    id: int
    amount_eur: int | None = None


class TransactionAmountsResult(SQLModel):
    saved: List[int]
    actual_failed: List[int]


class TransactionService:
    def __init__(
        self,
        store: Annotated[Store, Depends()],
        data_export: Annotated[DataExportFacade, Depends()],
        exchangerate: Annotated[ExchangeRateFacade, Depends()],
    ):
        self.store = store
        self.data_export = data_export
        self.exchangerate = exchangerate

    def get_transactions_with_guessed_amount(
        self,
        session: Session,
        user: User,
        account_id: int | None = None,
        paid: bool | None = None,
        paid_from: datetime.date | None = None,
        paid_to: datetime.date | None = None,
    ) -> List[TransactionWithGuessedAmount]:
        transactions = self.store.get_transactions(session, user, account_id, paid, paid_from, paid_to)
        cashback_exchange_ids = self.store.get_cashback_exchange_ids(
            session, [transaction.id for transaction in transactions if transaction.id is not None]
        )

        def map_transaction(transaction: Transaction):
            guessed_amount_eur = self.exchangerate.guess_amount_eur(session, transaction)
            amount_eur = transaction.amount_eur or guessed_amount_eur
            exchange_rate: Decimal | None = None
            if amount_eur is not None and amount_eur != 0:
                exchange_rate = (transaction.amount_usd / Decimal(amount_eur)).quantize(Decimal("0.00000001"))

            return TransactionWithGuessedAmount.model_validate(
                transaction,
                update={
                    "guessed_amount_eur": guessed_amount_eur,
                    "exchange_rate": exchange_rate,
                    "cashback_exchange_id": cashback_exchange_ids.get(transaction.id)
                    if transaction.id is not None
                    else None,
                },
            )

        return [map_transaction(tx) for tx in transactions]

    def update_transaction(self, session: Session, user: User, tx_id: int, amount_eur):
        transaction = self.store.get_transaction(session, user, tx_id)
        if not transaction:
            raise HTTPException(status_code=404)

        transaction.amount_eur = amount_eur
        session.add(transaction)
        session.commit()

        if transaction.actual_id is not None:
            account_id = require_persisted_id(transaction.account)
            self.data_export.update_transaction(session, user, account_id, transaction)

    def update_transaction_amounts(
        self, session: Session, user: User, amounts: List[TransactionAmount]
    ) -> TransactionAmountsResult:
        """Saves all amounts in one database transaction, then syncs them to Actual.

        The Actual sync is not part of the atomic save: transactions whose sync failed are
        reported in actual_failed, their amounts are saved nonetheless."""
        amount_by_id = {amount.id: amount.amount_eur for amount in amounts}
        transactions = self.store.get_transactions_by_ids(session, list(amount_by_id.keys()))

        if len(transactions) != len(amount_by_id):
            raise HTTPException(status_code=404)
        if not user.super_user and any(tx.account.user_id != user.id for tx in transactions):
            raise HTTPException(status_code=404)

        for transaction in transactions:
            transaction.amount_eur = amount_by_id[require_persisted_id(transaction)]
            session.add(transaction)
        session.commit()

        by_account: dict[int, List[Transaction]] = {}
        for transaction in transactions:
            if transaction.actual_id is not None:
                by_account.setdefault(transaction.account_id, []).append(transaction)

        actual_failed: List[int] = []
        for account_id, account_transactions in by_account.items():
            actual_failed += self.data_export.try_update_transactions(session, user, account_id, account_transactions)

        return TransactionAmountsResult(saved=sorted(amount_by_id.keys()), actual_failed=sorted(actual_failed))

    def mark_cashback(self, session: Session, user: User, tx_id: int):
        transaction = self.store.get_transaction(session, user, tx_id)
        if not transaction:
            raise HTTPException(status_code=404)

        if transaction.status_enum != Transaction.Status.POSTED or transaction.amount_usd <= 0:
            raise HTTPException(
                status_code=400, detail="Only posted transactions with a positive USD amount can be marked as cashback"
            )

        transaction_id = require_persisted_id(transaction)
        if self.store.get_cashback_exchange(session, transaction_id) is not None:
            return

        self.store.create_exchange(
            session,
            date=transaction.date,
            amount_usd=transaction.amount_usd,
            exchange_rate=Decimal(0),
            amount_eur=0,
            paid_eur=0,
            fees_eur=0,
            cashback_transaction_id=transaction_id,
        )

        amount_changed = transaction.amount_eur != 0
        transaction.amount_eur = 0
        session.add(transaction)
        try:
            session.commit()
        except Exception:
            session.rollback()
            raise

        if amount_changed and transaction.actual_id is not None:
            account_id = require_persisted_id(transaction.account)
            self.data_export.update_transaction(session, user, account_id, transaction)

    def undo_cashback(self, session: Session, user: User, tx_id: int):
        transaction = self.store.get_transaction(session, user, tx_id)
        if not transaction:
            raise HTTPException(status_code=404)

        transaction_id = require_persisted_id(transaction)
        exchange = self.store.get_cashback_exchange(session, transaction_id)
        if not exchange:
            raise HTTPException(status_code=400, detail="Transaction is not marked as cashback")
        exchange_id = require_persisted_id(exchange)
        if self.store.get_exchange_payments_by_exchange(session, exchange_id):
            raise HTTPException(status_code=409, detail="Cashback exchange is still assigned to payments")

        transaction.amount_eur = None
        session.add(transaction)
        session.delete(exchange)
        try:
            session.commit()
        except Exception:
            session.rollback()
            raise

        if transaction.actual_id is not None:
            account_id = require_persisted_id(transaction.account)
            self.data_export.update_transaction(session, user, account_id, transaction)
