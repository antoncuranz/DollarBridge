import datetime
from decimal import Decimal
from typing import Dict, List, Optional

from sqlmodel import Session, select, func

from models import Payment, ExchangePayment, Exchange, Transaction


class ExchangeRepository:
    def get_exchanges(self, session: Session, usable=None) -> List[Exchange]:
        query = True
        if usable is True:
            amount_used = (
                select(func.sum(ExchangePayment.amount)).join(Payment)
                .where(
                    (ExchangePayment.exchange_id == Exchange.id) & (Payment.status == Payment.Status.PROCESSED.value)
                ).scalar_subquery()
            )
            query = Exchange.amount_usd > func.coalesce(amount_used, 0)

        stmt = select(Exchange).where(query).order_by(Exchange.date.desc())
        return session.exec(stmt).all()

    def get_exchange(self, session: Session, exchange_id: int) -> Optional[Exchange]:
        stmt = select(Exchange).where(Exchange.id == exchange_id)
        return session.exec(stmt).first()

    def create_exchange(self, session: Session, date: datetime.date, amount_usd: int, exchange_rate: Decimal,
                        amount_eur: int, paid_eur: int, fees_eur: int,
                        cashback_transaction_id: int | None = None) -> Exchange:
        exchange = Exchange(
            date=date, amount_usd=amount_usd, exchange_rate=exchange_rate, amount_eur=amount_eur,
            paid_eur=paid_eur, fees_eur=fees_eur, cashback_transaction_id=cashback_transaction_id
        )
        session.add(exchange)
        return exchange

    def get_cashback_exchange(self, session: Session, transaction_id: int) -> Optional[Exchange]:
        stmt = select(Exchange).where(Exchange.cashback_transaction_id == transaction_id)
        return session.exec(stmt).first()

    def get_cashback_exchange_ids(self, session: Session, transaction_ids: List[int]) -> Dict[int, int]:
        if not transaction_ids:
            return {}
        stmt = select(Exchange.cashback_transaction_id, Exchange.id).where(
            Exchange.cashback_transaction_id.in_(transaction_ids)
        )
        return {transaction_id: exchange_id for transaction_id, exchange_id in session.exec(stmt).all()}

    def get_cashback_transaction_descriptions(self, session: Session, exchange_ids: List[int]) -> Dict[int, str]:
        if not exchange_ids:
            return {}
        stmt = select(Exchange.id, Transaction.description).join(
            Transaction, Transaction.id == Exchange.cashback_transaction_id
        ).where(Exchange.id.in_(exchange_ids))
        return {exchange_id: description for exchange_id, description in session.exec(stmt).all()}

    #### EXCHANGE PAYMENTS ####
    
    def get_exchange_payment(self, session: Session, exchange_id: int, payment_id: int) -> Optional[ExchangePayment]:
        stmt = select(ExchangePayment).where(
            (ExchangePayment.exchange_id == exchange_id) & (ExchangePayment.payment_id == payment_id)
        )
        return session.exec(stmt).first()

    def get_exchange_payments_by_exchange(self, session: Session, exchange_id: int) -> List[ExchangePayment]:
        stmt = select(ExchangePayment).where(ExchangePayment.exchange_id == exchange_id)
        return session.exec(stmt).all()

    def get_exchange_payments_by_payment(self, session: Session, payment_id: int) -> List[ExchangePayment]:
        stmt = select(ExchangePayment).where(ExchangePayment.payment_id == payment_id)
        return session.exec(stmt).all()

    def get_exchange_payment_amount(self, session: Session, exchange_id: int, payment_id: int) -> int:
        ep = self.get_exchange_payment(session, exchange_id, payment_id)
        return 0 if not ep else ep.amount

    def delete_exchange_payment(self, session: Session, exchange_id: int, payment_id: int):
        ep = self.get_exchange_payment(session, exchange_id, payment_id)
        if not ep:
            raise RuntimeError(f"Exchange payment not found!")
        session.delete(ep)

    def get_or_create_exchange_payment(self, session: Session, exchange_id: int, payment_id: int, amount: int)\
            -> tuple[ExchangePayment, bool]:
        model = self.get_exchange_payment(session, exchange_id, payment_id)
        created = not model
        
        if created:
            model = ExchangePayment(exchange_id=exchange_id, payment_id=payment_id, amount=amount)
        session.add(model)
        
        return model, created
