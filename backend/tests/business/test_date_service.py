import datetime

from dates.business.date_service import DateService
from dates.dataaccess.dates_repository import DatesRepository
from models import Account, User


def test_dates_exclude_inactive_accounts(sqlite_session):
    user = User(id=1, name="alice")
    active_account = Account(id=1, user_id=1, name="Active", institution="Bank", due_day=15, active=True)
    inactive_account = Account(id=2, user_id=1, name="Inactive", institution="Bank", due_day=20, active=False)
    sqlite_session.add_all([user, active_account, inactive_account])
    sqlite_session.commit()

    dates = DateService(DatesRepository()).get_dates(sqlite_session, user, 2026, 10)

    assert set(dates) == {1}
    assert dates[1]["due"] == datetime.date(2026, 10, 15).isoformat()
