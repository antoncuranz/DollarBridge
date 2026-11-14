import datetime
from typing import List, Optional

from sqlmodel import Session, and_, col, select, func, true

from models import Transaction, User, Account, Payment


class TransactionRepository:
    def get_transaction(self, session: Session, user: User, tx_id: int) -> Optional[Transaction]:
        stmt = select(Transaction).where(Transaction.id == tx_id)
        return session.exec(stmt).first()  # TODO: check user!

    def get_transaction_account_id(self, session: Session, tx_id: int) -> int | None:
        return session.exec(select(Transaction.account_id).where(Transaction.id == tx_id)).first()

    def get_transactions_by_ids(self, session: Session, tx_ids: List[int]) -> List[Transaction]:
        if not tx_ids:
            return []
        stmt = select(Transaction).where(col(Transaction.id).in_(tx_ids))
        return list(session.exec(stmt).all())

    def get_transactions(
        self,
        session: Session,
        user: User,
        account_id: int | None = None,
        paid: bool | None = None,
        paid_from: datetime.date | None = None,
        paid_to: datetime.date | None = None,
    ) -> List[Transaction]:
        query = Account.user_id == user.id

        if paid is True:
            query = query & (Transaction.status == Transaction.Status.PAID.value)
        elif paid is False:
            query = query & (Transaction.status != Transaction.Status.PAID.value)

        if account_id is not None:
            query = query & (Transaction.account_id == account_id)

        stmt = select(Transaction).join(Account)
        if paid_from is not None or paid_to is not None:
            # the range refers to the date of the payment that settled the transaction
            stmt = stmt.join(Payment, col(Transaction.payment_id) == col(Payment.id))
            query = query & _payment_date_in_range(paid_from, paid_to)

        stmt = stmt.where(query).order_by(col(Transaction.date).desc(), col(Transaction.id).desc())
        return list(session.exec(stmt).all())

    def get_paid_transactions_by_payment(self, session: Session, payment_id: int) -> List[Transaction]:
        stmt = (
            select(Transaction)
            .join(Account)
            .where((Transaction.payment_id == payment_id) & (Transaction.status == Transaction.Status.PAID.value))
        )
        return list(session.exec(stmt).all())

    def get_posted_transactions_by_account(self, session: Session, account_id: int) -> List[Transaction]:
        stmt = (
            select(Transaction)
            .where((Transaction.status == Transaction.Status.POSTED.value) & (Transaction.account_id == account_id))
            .order_by(col(Transaction.date), col(Transaction.id))
        )
        return list(session.exec(stmt).all())

    def get_posted_transactions_missing_amount_eur_by_account(
        self, session: Session, account_id: int
    ) -> List[Transaction]:
        stmt = (
            select(Transaction)
            .where(
                (col(Transaction.status) == Transaction.Status.POSTED.value)
                & (col(Transaction.account_id) == account_id)
                & col(Transaction.amount_eur).is_(None)
            )
            .order_by(col(Transaction.date), col(Transaction.id))
        )
        return list(session.exec(stmt).all())

    def get_posted_transaction_amount(self, session: Session, account_id: int) -> int:
        stmt = select(func.sum(Transaction.amount_usd)).where(
            (Transaction.account_id == account_id) & (Transaction.status != Transaction.Status.PENDING.value)
        )
        return session.exec(stmt).first() or 0

    def get_pending_transaction_amount(self, session: Session, account_id: int) -> int:
        stmt = select(func.sum(Transaction.amount_usd)).where(
            (col(Transaction.account_id) == account_id)
            & (col(Transaction.status) == Transaction.Status.PENDING.value)
            & col(Transaction.ignore).is_not(True)
        )
        return session.exec(stmt).first() or 0

    def get_all_posted_transactions(self, session: Session) -> List[Transaction]:
        stmt = select(Transaction).where(Transaction.status == Transaction.Status.POSTED.value)
        return list(session.exec(stmt).all())

    def get_all_pending_transactions(self, session: Session) -> List[Transaction]:
        stmt = select(Transaction).where(Transaction.status == Transaction.Status.PENDING.value)
        return list(session.exec(stmt).all())

    def get_balance_pending(self, session: Session) -> int:
        stmt = select(func.sum(Transaction.amount_usd)).where(
            (col(Transaction.status) == Transaction.Status.PENDING.value) & col(Transaction.ignore).is_not(True)
        )
        return session.exec(stmt).first() or 0

    def get_fees_and_risk_eur(
        self, session: Session, paid_from: datetime.date | None = None, paid_to: datetime.date | None = None
    ) -> int:
        return self._sum_paid(session, col(Transaction.fees_and_risk_eur), paid_from, paid_to)

    def get_paid_amount_eur(
        self, session: Session, paid_from: datetime.date | None = None, paid_to: datetime.date | None = None
    ) -> int:
        return self._sum_paid(session, col(Transaction.amount_eur), paid_from, paid_to)

    @staticmethod
    def _sum_paid(session: Session, column, paid_from: datetime.date | None, paid_to: datetime.date | None) -> int:
        stmt = select(func.sum(column)).where(Transaction.status == Transaction.Status.PAID.value)
        if paid_from is not None or paid_to is not None:
            stmt = stmt.join(Payment, col(Transaction.payment_id) == col(Payment.id)).where(
                _payment_date_in_range(paid_from, paid_to)
            )
        return session.exec(stmt).first() or 0


def _payment_date_in_range(date_from: datetime.date | None, date_to: datetime.date | None):
    conditions = []
    if date_from is not None:
        conditions.append(col(Payment.date) >= date_from)
    if date_to is not None:
        conditions.append(col(Payment.date) <= date_to)
    return and_(true(), *conditions)
