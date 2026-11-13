import datetime
from dataclasses import dataclass
from enum import Enum


class Issuer(str, Enum):
    AMEX = "amex"
    CAPITAL_ONE = "capital_one"
    CHASE = "chase"
    OTHER = "other"


class WeekendShift(Enum):
    NONE = "none"
    SUNDAY_TO_MONDAY = "sunday_to_monday"
    SUNDAY_TO_SATURDAY = "sunday_to_saturday"
    SATURDAY_TO_FRIDAY = "saturday_to_friday"


@dataclass(frozen=True)
class IssuerRule:
    """How an issuer derives the autopay date and the statement closing date from the due date.

    The rules were read off real payments (see tests/business/test_date_service.py)."""
    weekend_shift: WeekendShift
    # exactly one of the two is set
    statement_days_before_due: int | None = None
    statement_days_after_due_day: int | None = None

    def payment_date(self, due_date: datetime.date, autopay_offset: int) -> datetime.date:
        date = due_date - datetime.timedelta(days=autopay_offset)
        weekday = date.weekday()  # Monday is 0

        if weekday == 6 and self.weekend_shift == WeekendShift.SUNDAY_TO_MONDAY:
            return date + datetime.timedelta(days=1)
        if weekday == 6 and self.weekend_shift == WeekendShift.SUNDAY_TO_SATURDAY:
            return date - datetime.timedelta(days=1)
        if weekday == 5 and self.weekend_shift == WeekendShift.SATURDAY_TO_FRIDAY:
            return date - datetime.timedelta(days=1)
        return date

    def statement_date(self, due_date: datetime.date) -> datetime.date:
        if self.statement_days_after_due_day is not None:
            # the statement closes a fixed number of days after the due day, one month earlier
            return same_day_previous_month(due_date) + datetime.timedelta(days=self.statement_days_after_due_day)
        return due_date - datetime.timedelta(days=self.statement_days_before_due or 0)


def same_day_previous_month(date: datetime.date) -> datetime.date:
    last_of_previous = date.replace(day=1) - datetime.timedelta(days=1)
    return last_of_previous.replace(day=min(date.day, last_of_previous.day))


RULES: dict[Issuer, IssuerRule] = {
    # autopay runs on the due date, a Sunday moves to Monday; due date is 25 days after closing
    Issuer.CAPITAL_ONE: IssuerRule(WeekendShift.SUNDAY_TO_MONDAY, statement_days_before_due=25),
    # autopay is set some days before the due date, a Sunday moves to Saturday; due date is 25 days after closing
    Issuer.AMEX: IssuerRule(WeekendShift.SUNDAY_TO_SATURDAY, statement_days_before_due=25),
    # autopay runs on the due date, a Saturday moves to Friday; the statement closes 3 days after the due day
    Issuer.CHASE: IssuerRule(WeekendShift.SATURDAY_TO_FRIDAY, statement_days_after_due_day=3),
    Issuer.OTHER: IssuerRule(WeekendShift.NONE, statement_days_before_due=25),
}


def rule_for(issuer: str | None) -> IssuerRule:
    try:
        return RULES[Issuer(issuer)]
    except ValueError:
        return RULES[Issuer.OTHER]
