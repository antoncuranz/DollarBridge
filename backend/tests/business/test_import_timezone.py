from datetime import date, datetime, timedelta, timezone

from data_import.business.import_service import ImportService
from data_import.business.plaid_service import PlaidService
from models import Account, PlaidAccount, PlaidConnection, User


def test_import_uses_utc_cutoff_for_aware_plaid_update(mocker):
    statement_date = date.today() - timedelta(days=2)
    due_date = date.today() + timedelta(days=2)
    plaid_account = PlaidAccount(
        id=1, name="Card", plaid_account_id="plaid-1", connection_id=1,
        last_successful_update=datetime.combine(
            statement_date + timedelta(days=1), datetime.min.time(),
            tzinfo=timezone.utc,
        ) + timedelta(hours=1),
    )
    account = Account(
        id=1, user_id=1, name="Card", institution="Bank",
        plaid_account_id=1, plaid_account=plaid_account, actual_id=None,
    )
    repository = mocker.Mock()
    repository.get_all_accounts.return_value = [account]
    repository.get_all_bank_accounts.return_value = []
    repository.get_pending_payment.return_value = None
    repository.create_pending_payment.return_value.amount_usd = 100
    dates = mocker.Mock()
    dates.get_next_due_date.return_value = due_date
    dates.get_last_due_date.return_value = statement_date - timedelta(days=25)
    dates.get_statement_date_for_due_date.return_value = statement_date
    service = ImportService(mocker.Mock(), repository, mocker.Mock(), dates, mocker.Mock())
    mocker.patch.object(service, "_send_notification")

    service.import_transactions_all_accounts(mocker.Mock())

    repository.create_pending_payment.assert_called_once()


def test_plaid_update_preserves_instant_from_non_utc_offset(mocker):
    service = PlaidService(mocker.Mock())
    gauge = mocker.Mock()
    mocker.patch.object(service, "_get_gauge", return_value=gauge)
    plaid_account = PlaidAccount(id=1, name="Card", plaid_account_id="plaid-1", connection_id=1)
    update = datetime(2026, 10, 31, 12, tzinfo=timezone(timedelta(hours=-4)))

    service._set_last_successful_update(plaid_account, update)

    assert plaid_account.last_successful_update == datetime(2026, 10, 31, 16, tzinfo=timezone.utc)
    gauge.set.assert_called_once_with(update.timestamp())


def test_plaid_update_remains_aware_after_postgres_reload(session):
    update = datetime(2026, 10, 31, 12, tzinfo=timezone(timedelta(hours=-4)))
    user = User(id=1, name="alice", super_user=True)
    connection = PlaidConnection(
        id=1, user_id=1, name="Bank", plaid_item_id="item-1", plaid_access_token="token"
    )
    plaid_account = PlaidAccount(
        id=1, name="Card", plaid_account_id="plaid-1", connection_id=1,
        last_successful_update=update,
    )
    session.add_all([user, connection, plaid_account])
    session.commit()
    session.expunge_all()

    reloaded = session.get(PlaidAccount, 1).last_successful_update

    assert reloaded.utcoffset() == timedelta(0)
    assert reloaded == update
