import calendar
import datetime
from dataclasses import dataclass
from typing import Annotated, List

from fastapi import Depends
from sqlmodel import Session

from dates.business.issuer_rules import rule_for
from dates.dataaccess.dates_repository import DatesRepository
from models import Account, User


@dataclass(frozen=True)
class Cycle:
    """One billing cycle of a credit card."""

    due_date: datetime.date  # the due date printed on the statement
    payment_date: datetime.date  # the day autopay posts on the card
    statement_date: datetime.date  # the day the statement closes


class DateService:
    def __init__(self, repository: Annotated[DatesRepository, Depends()]):
        self.repository = repository

    def get_dates(self, session: Session, user: User, year: int, month: int):
        """Payment and statement dates of every account that fall into the given month."""
        result = {}
        accounts = (
            self.repository.get_all_accounts(session)
            if user.super_user
            else self.repository.get_accounts_of_user(session, user)
        )
        for account in accounts:
            if account.due_day is None:
                continue

            in_month = lambda date: date.year == year and date.month == month  # noqa: E731
            cycles = self._cycles_around(account, datetime.date(year, month, 1))
            result[account.id] = dict(
                color=(account.color if account.color else "black"),
                statement=[c.statement_date.isoformat() for c in cycles if in_month(c.statement_date)],
                due=[c.payment_date.isoformat() for c in cycles if in_month(c.payment_date)],
            )

        return result

    def get_cycle(self, account: Account, year: int, month: int) -> Cycle:
        """The cycle whose due date lies in the given month."""
        if account.due_day is None:
            raise ValueError("Account has no due day")

        # a due day of 29-31 falls on the last day of shorter months
        last_day = calendar.monthrange(year, month)[1]
        due_date = datetime.date(year, month, min(account.due_day, last_day))
        rule = rule_for(account.issuer)

        return Cycle(
            due_date=due_date,
            payment_date=rule.payment_date(due_date, account.autopay_offset or 0),
            statement_date=rule.statement_date(due_date),
        )

    def _cycles_around(self, account: Account, date: datetime.date) -> List[Cycle]:
        """The cycles due from two months before to two months after the date, oldest first."""
        cycles = []
        for offset in range(-2, 3):
            month_index = date.year * 12 + (date.month - 1) + offset
            cycles.append(self.get_cycle(account, month_index // 12, month_index % 12 + 1))
        return cycles

    def get_next_cycle(self, account: Account, today: datetime.date | None = None) -> Cycle:
        """The cycle that is paid next (a payment today still counts)."""
        today = today or datetime.date.today()
        return next(c for c in self._cycles_around(account, today) if c.payment_date >= today)

    def get_last_cycle(self, account: Account, today: datetime.date | None = None) -> Cycle:
        """The most recent cycle that was paid before today."""
        today = today or datetime.date.today()
        return [c for c in self._cycles_around(account, today) if c.payment_date < today][-1]

    def get_next_due_date(self, account: Account) -> datetime.date:
        return self.get_next_cycle(account).payment_date

    def get_last_due_date(self, account: Account) -> datetime.date:
        return self.get_last_cycle(account).payment_date

    def get_statement_date_for_due_date(self, account: Account, due_date: datetime.date) -> datetime.date:
        """The closing date of the statement that is paid on the given payment date."""
        for cycle in self._cycles_around(account, due_date):
            if cycle.payment_date == due_date:
                return cycle.statement_date
        raise ValueError("{} is not a payment date of account {}".format(due_date, account.id))
