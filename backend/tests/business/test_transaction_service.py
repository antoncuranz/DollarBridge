import datetime
from decimal import Decimal
from unittest.mock import Mock

from core.business.transaction_service import TransactionService
from models import Transaction


def make_transaction():
    transaction = Mock()
    transaction.id = 42
    transaction.date = datetime.date(2026, 10, 24)
    transaction.amount_usd = 1234
    transaction.amount_eur = 999
    transaction.status_enum = Transaction.Status.POSTED
    transaction.actual_id = None
    return transaction


def test_mark_cashback_creates_a_dedicated_linked_exchange():
    session = Mock()
    store = Mock()
    transaction = make_transaction()
    store.get_transaction.return_value = transaction
    store.get_cashback_exchange.return_value = None
    service = TransactionService(store, Mock(), Mock())

    service.mark_cashback(session, Mock(), transaction.id)

    store.create_exchange.assert_called_once_with(
        session,
        date=transaction.date,
        amount_usd=transaction.amount_usd,
        exchange_rate=Decimal(0),
        amount_eur=0,
        paid_eur=0,
        fees_eur=0,
        cashback_transaction_id=transaction.id,
    )
    assert transaction.amount_eur == 0
    session.add.assert_called_once_with(transaction)
    session.commit.assert_called_once()


def test_undo_cashback_clears_the_amount_and_deletes_the_linked_exchange():
    session = Mock()
    store = Mock()
    transaction = make_transaction()
    transaction.amount_eur = 0
    exchange = Mock(id=99)
    store.get_transaction.return_value = transaction
    store.get_cashback_exchange.return_value = exchange
    store.get_exchange_payments_by_exchange.return_value = []
    service = TransactionService(store, Mock(), Mock())

    service.undo_cashback(session, Mock(), transaction.id)

    assert transaction.amount_eur is None
    session.add.assert_called_once_with(transaction)
    session.delete.assert_called_once_with(exchange)
    session.commit.assert_called_once()
