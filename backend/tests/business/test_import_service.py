import datetime

from data_import.business.import_service import ImportService
from models import Account, BankAccount, PlaidAccount, User


def test_import_transactions_all_accounts_skips_accounts_without_plaid(mocker, capsys):
    session = mocker.Mock()
    user = User(id=1, name="alice", super_user=True)
    linked_plaid_account = PlaidAccount(id=1, name="Plaid", plaid_account_id="plaid-1", connection_id=1,
                                        last_successful_update=datetime.datetime.now())
    linked_account = Account(id=1, user_id=1, user=user, name="Linked", institution="Institution 1",
                             plaid_account_id=1, plaid_account=linked_plaid_account, actual_id=None)
    unlinked_account = Account(id=2, user_id=1, user=user, name="Unlinked", institution="Institution 2",
                               plaid_account_id=None, plaid_account=None, actual_id=None)

    importer = mocker.Mock()
    repository = mocker.Mock()
    repository.get_all_accounts.return_value = [unlinked_account, linked_account]
    repository.get_all_bank_accounts.return_value = []
    repository.get_pending_payment.return_value = None
    exchangerate = mocker.Mock()
    dates = mocker.Mock()
    dates.get_next_due_date.return_value = datetime.date.today()
    dates.get_last_due_date.return_value = datetime.date.today()
    dates.get_statement_date_for_due_date.return_value = datetime.date.today()
    data_export = mocker.Mock()

    under_test = ImportService(importer, repository, exchangerate, dates, data_export)

    under_test.import_transactions_all_accounts(session)

    assert importer.import_transactions.call_count == 1
    assert importer.import_transactions.call_args.args[1] == linked_account
    assert exchangerate.fetch_exchange_rates.call_count == 1
    assert exchangerate.fetch_exchange_rates.call_args.args[1] == linked_account
    assert "Skipping Account Institution 2 Unlinked (2): not linked to Plaid" in capsys.readouterr().out


def test_import_transactions_all_accounts_skips_bank_accounts_without_plaid(mocker, capsys):
    session = mocker.Mock()
    linked_plaid_account = PlaidAccount(id=1, name="Plaid", plaid_account_id="plaid-1", connection_id=1)
    linked_bank_account = BankAccount(id=1, user_id=1, name="Linked Bank", institution="Institution 1",
                                      plaid_account_id=1, plaid_account=linked_plaid_account, balance=1000)
    unlinked_bank_account = BankAccount(id=2, user_id=1, name="Unlinked Bank", institution="Institution 2",
                                        plaid_account_id=None, plaid_account=None, balance=1000)

    importer = mocker.Mock()
    repository = mocker.Mock()
    repository.get_all_accounts.return_value = []
    repository.get_all_bank_accounts.return_value = [unlinked_bank_account, linked_bank_account]
    repository.get_pending_payments_between.return_value = []
    exchangerate = mocker.Mock()
    dates = mocker.Mock()
    data_export = mocker.Mock()

    under_test = ImportService(importer, repository, exchangerate, dates, data_export)

    under_test.import_transactions_all_accounts(session)

    assert importer.update_bank_account_balance.call_count == 1
    assert importer.update_bank_account_balance.call_args.args[1] == linked_bank_account
    assert "Skipping BankAccount Unlinked Bank (2): not linked to Plaid" in capsys.readouterr().out
