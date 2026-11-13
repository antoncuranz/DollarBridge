import datetime

import pytest

from dates.business.date_service import DateService
from dates.dataaccess.dates_repository import DatesRepository
from models import Account, User

D = datetime.date


def account(issuer: str | None, due_day: int, autopay_offset: int | None = 0) -> Account:
    return Account(id=1, user_id=1, name="Card", institution="Bank", issuer=issuer,
                   due_day=due_day, autopay_offset=autopay_offset)


def service() -> DateService:
    return DateService(DatesRepository())


# Payment dates as they posted on the real cards.
@pytest.mark.parametrize("issuer,due_day,offset,year,month,expected", [
    # Capital One pays on the due date; a Sunday moves to Monday, a Saturday stays
    ("capital_one", 2, 0, 2026, 6, D(2026, 6, 2)),    # Tuesday
    ("capital_one", 2, 0, 2026, 5, D(2026, 5, 2)),    # Saturday
    ("capital_one", 2, 0, 2025, 11, D(2025, 11, 3)),  # Sunday -> Monday
    ("capital_one", 2, 0, 2026, 8, D(2026, 8, 3)),    # Sunday -> Monday
    ("capital_one", 3, 0, 2025, 8, D(2025, 8, 4)),    # Sunday -> Monday
    # Amex pays 10 days before the due date; a Sunday moves to Saturday, a Saturday stays
    ("amex", 1, 10, 2025, 12, D(2025, 11, 21)),
    ("amex", 1, 10, 2026, 3, D(2026, 2, 19)),
    ("amex", 1, 10, 2026, 4, D(2026, 3, 21)),         # Sunday -> Saturday
    ("amex", 1, 10, 2026, 7, D(2026, 6, 20)),         # Sunday -> Saturday
    ("amex", 4, 10, 2026, 1, D(2025, 12, 25)),        # posted on Christmas Day
    ("amex", 4, 10, 2026, 2, D(2026, 1, 24)),         # Sunday -> Saturday
    ("amex", 4, 10, 2026, 11, D(2026, 10, 24)),       # Sunday -> Saturday
    ("amex", 3, 10, 2026, 2, D(2026, 1, 24)),         # Saturday stays
    # Chase pays on the due date; a Saturday moves to Friday, a Sunday stays
    ("chase", 5, None, 2026, 5, D(2026, 5, 5)),
    ("chase", 5, None, 2026, 4, D(2026, 4, 5)),       # Sunday
    ("chase", 5, None, 2026, 9, D(2026, 9, 4)),       # Saturday -> Friday
    ("chase", 1, 0, 2026, 8, D(2026, 7, 31)),         # Saturday -> Friday, into the previous month
    ("chase", 1, 0, 2026, 11, D(2026, 11, 1)),        # Sunday
    # no issuer: no weekend handling
    (None, 2, 0, 2026, 8, D(2026, 8, 2)),
])
def test_payment_date(issuer, due_day, offset, year, month, expected):
    assert service().get_cycle(account(issuer, due_day, offset), year, month).payment_date == expected


@pytest.mark.parametrize("issuer,due_day,year,month,expected", [
    # Capital One and Amex: 25 days before the due date
    ("capital_one", 2, 2026, 6, D(2026, 5, 8)),
    ("capital_one", 2, 2026, 3, D(2026, 2, 5)),
    ("capital_one", 12, 2026, 10, D(2026, 9, 17)),
    ("amex", 4, 2026, 4, D(2026, 3, 10)),
    ("amex", 1, 2026, 1, D(2025, 12, 7)),
    # Chase: three days after the due day, one month earlier
    ("chase", 5, 2026, 4, D(2026, 3, 8)),
    ("chase", 5, 2026, 3, D(2026, 2, 8)),
    ("chase", 1, 2026, 7, D(2026, 6, 4)),
    ("chase", 1, 2026, 1, D(2025, 12, 4)),
    (None, 15, 2026, 10, D(2026, 9, 20)),
])
def test_statement_date(issuer, due_day, year, month, expected):
    assert service().get_cycle(account(issuer, due_day), year, month).statement_date == expected


def test_due_day_after_the_end_of_a_short_month():
    cycle = service().get_cycle(account("capital_one", 31), 2026, 2)

    assert cycle.due_date == D(2026, 2, 28)
    assert cycle.payment_date == D(2026, 2, 28)


def test_next_and_last_cycle():
    amex = account("amex", 1, 10)

    # the payment for the 1 Dec due date posts on Sat 21 Nov
    assert service().get_next_cycle(amex, D(2026, 11, 13)).payment_date == D(2026, 11, 21)
    assert service().get_next_cycle(amex, D(2026, 11, 21)).payment_date == D(2026, 11, 21)
    assert service().get_next_cycle(amex, D(2026, 11, 22)).payment_date == D(2026, 12, 22)
    assert service().get_last_cycle(amex, D(2026, 11, 21)).payment_date == D(2026, 10, 22)


def test_statement_date_for_a_payment_date():
    chase = account("chase", 5, None)

    # Sat 5 Sep is paid on Fri 4 Sep; that statement closed on 8 Aug
    assert service().get_statement_date_for_due_date(chase, D(2026, 9, 4)) == D(2026, 8, 8)
    with pytest.raises(ValueError):
        service().get_statement_date_for_due_date(chase, D(2026, 9, 5))


def test_dates_exclude_inactive_accounts(sqlite_session):
    user = User(id=1, name="alice")
    active_account = Account(id=1, user_id=1, name="Active", institution="Bank", due_day=15, active=True)
    inactive_account = Account(id=2, user_id=1, name="Inactive", institution="Bank", due_day=20, active=False)
    sqlite_session.add_all([user, active_account, inactive_account])
    sqlite_session.commit()

    dates = DateService(DatesRepository()).get_dates(sqlite_session, user, 2026, 10)

    assert set(dates) == {1}
    assert dates[1]["due"] == ["2026-10-15"]
    assert dates[1]["statement"] == ["2026-10-21"]


def test_dates_of_a_month_can_hold_two_payments(sqlite_session):
    user = User(id=1, name="alice")
    sqlite_session.add_all([user, Account(id=1, user_id=1, name="Sapphire", institution="Chase", issuer="chase", due_day=1)])
    sqlite_session.commit()

    july = DateService(DatesRepository()).get_dates(sqlite_session, user, 2026, 7)
    august = DateService(DatesRepository()).get_dates(sqlite_session, user, 2026, 8)

    # the payment due on Sat 1 Aug posts on Fri 31 Jul
    assert july[1]["due"] == ["2026-07-01", "2026-07-31"]
    assert august[1]["due"] == []
