from fastapi.testclient import TestClient
from sqlmodel import Session, select

from models import Account, BankAccount, Exchange, ExchangePayment, Payment, Transaction, User
from tests.fixtures import (
    ACCOUNT_1, ACCOUNT_2, ALICE_AUTH, ALICE_USER, BANK_ACCOUNT_1,
    PAYMENT_1, PAYMENT_2, PAYMENT_3, TX_1,
)


def test_cashback_exchange_can_be_linked_and_unlinked_from_payment(
    sqlite_session: Session, sqlite_client: TestClient
):
    sqlite_session.add_all([User(**ALICE_USER), BankAccount(**BANK_ACCOUNT_1), Account(**ACCOUNT_1)])
    transaction = Transaction(**TX_1)
    payment = Payment(**(PAYMENT_1 | {"amount_usd": transaction.amount_usd}))
    sqlite_session.add_all([transaction, payment])
    sqlite_session.commit()

    response = sqlite_client.post(f"/api/transactions/{transaction.id}/cashback", headers=ALICE_AUTH)
    assert response.status_code == 204
    exchange = sqlite_session.exec(select(Exchange)).one()
    assert exchange.cashback_transaction_id == transaction.id
    assert exchange.paid_eur == 0

    response = sqlite_client.put(
        f"/api/exchanges/{exchange.id}?payment={payment.id}&amount={transaction.amount_usd}",
        headers=ALICE_AUTH,
    )
    assert response.status_code == 204
    link = sqlite_session.exec(select(ExchangePayment)).one()
    assert link.exchange_id == exchange.id
    assert link.payment_id == payment.id
    assert link.amount == transaction.amount_usd

    response = sqlite_client.post(f"/api/transactions/{transaction.id}/undo-cashback", headers=ALICE_AUTH)
    assert response.status_code == 409

    response = sqlite_client.put(
        f"/api/exchanges/{exchange.id}?payment={payment.id}&amount=0", headers=ALICE_AUTH
    )
    assert response.status_code == 204
    assert sqlite_session.exec(select(ExchangePayment)).first() is None

    response = sqlite_client.post(f"/api/transactions/{transaction.id}/undo-cashback", headers=ALICE_AUTH)
    assert response.status_code == 204


def test_cashback_exchange_requires_same_account_and_a_single_full_assignment(
    sqlite_session: Session, sqlite_client: TestClient
):
    sqlite_session.add_all([
        User(**ALICE_USER), BankAccount(**BANK_ACCOUNT_1),
        Account(**ACCOUNT_1), Account(**ACCOUNT_2),
    ])
    transaction = Transaction(**TX_1)
    payment = Payment(**(PAYMENT_1 | {"amount_usd": transaction.amount_usd}))
    other_account_payment = Payment(**(PAYMENT_2 | {
        "account_id": ACCOUNT_2["id"], "amount_usd": transaction.amount_usd,
    }))
    second_payment = Payment(**(PAYMENT_3 | {"amount_usd": transaction.amount_usd}))
    sqlite_session.add_all([transaction, payment, other_account_payment, second_payment])
    sqlite_session.commit()

    response = sqlite_client.post(f"/api/transactions/{transaction.id}/cashback", headers=ALICE_AUTH)
    assert response.status_code == 204
    exchange = sqlite_session.exec(select(Exchange)).one()

    response = sqlite_client.put(
        f"/api/exchanges/{exchange.id}?payment={other_account_payment.id}&amount={exchange.amount_usd}",
        headers=ALICE_AUTH,
    )
    assert response.status_code == 409

    response = sqlite_client.put(
        f"/api/exchanges/{exchange.id}?payment={payment.id}&amount={exchange.amount_usd - 1}",
        headers=ALICE_AUTH,
    )
    assert response.status_code == 400
    assert sqlite_session.exec(select(ExchangePayment)).first() is None

    response = sqlite_client.put(
        f"/api/exchanges/{exchange.id}?payment={payment.id}&amount={exchange.amount_usd}",
        headers=ALICE_AUTH,
    )
    assert response.status_code == 204

    response = sqlite_client.put(
        f"/api/exchanges/{exchange.id}?payment={second_payment.id}&amount={exchange.amount_usd}",
        headers=ALICE_AUTH,
    )
    assert response.status_code == 409
    assert [(link.payment_id, link.amount) for link in sqlite_session.exec(select(ExchangePayment))] == [
        (payment.id, exchange.amount_usd)
    ]
