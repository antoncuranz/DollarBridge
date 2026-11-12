import pytest
from fastapi.testclient import TestClient
from sqlmodel import Session, select

from models import Account, BankAccount, Payment, Transaction, User
from tests.fixtures import (ACCOUNT_1, ACCOUNT_2, ALICE_AUTH, ALICE_USER, BANK_ACCOUNT_1, BOB_AUTH, BOB_USER,
                            PAYMENT_1, PAYMENT_2, TX_1, TX_2, TX_3, TX_4)
from tests.mockclients.actual import MockActualClient

JANUARY = dict(PAYMENT_1, status=3, date="2024-01-30", amount_eur=1500)
FEBRUARY = dict(PAYMENT_2, status=3, date="2024-02-28", amount_eur=2000)

PAID_JANUARY_1 = dict(TX_1, status=3, payment_id=1, fees_and_risk_eur=10)
PAID_JANUARY_2 = dict(TX_2, status=3, payment_id=1, fees_and_risk_eur=-3)
PAID_FEBRUARY = dict(TX_3, status=3, payment_id=2, fees_and_risk_eur=20)


@pytest.fixture(autouse=True)
def setup(session: Session):
    MockActualClient.reset()
    session.add_all([User(**ALICE_USER), User(**BOB_USER), BankAccount(**BANK_ACCOUNT_1),
                     Account(**ACCOUNT_1), Account(**ACCOUNT_2)])
    session.commit()


def add_archive(session: Session):
    session.add_all([Payment(**JANUARY), Payment(**FEBRUARY)])
    session.commit()
    session.add_all([Transaction(**PAID_JANUARY_1), Transaction(**PAID_JANUARY_2), Transaction(**PAID_FEBRUARY)])
    session.commit()


def test_paid_transactions_are_filtered_by_payment_date(session: Session, client: TestClient):
    add_archive(session)

    response = client.get("/api/transactions?paid=true&from=2024-01-01&to=2024-01-31", headers=ALICE_AUTH)

    assert response.status_code == 200
    assert sorted(tx["id"] for tx in response.json()) == [1, 2]


def test_paid_transactions_without_range_are_unchanged(session: Session, client: TestClient):
    add_archive(session)

    response = client.get("/api/transactions?paid=true", headers=ALICE_AUTH)

    assert sorted(tx["id"] for tx in response.json()) == [1, 2, 3]


def test_payments_are_filtered_by_date(session: Session, client: TestClient):
    add_archive(session)

    response = client.get("/api/payments?processed=true&from=2024-02-01&to=2024-02-29", headers=ALICE_AUTH)

    assert response.status_code == 200
    assert [payment["id"] for payment in response.json()] == [2]


def test_fee_summary_for_date_range(session: Session, client: TestClient):
    add_archive(session)

    january = client.get("/api/balance/fees?from=2024-01-01&to=2024-01-31", headers=ALICE_AUTH).json()
    all_time = client.get("/api/balance/fees", headers=ALICE_AUTH).json()
    empty = client.get("/api/balance/fees?from=2023-01-01&to=2023-01-31", headers=ALICE_AUTH).json()

    assert january == {"fees_and_risk_eur": 7, "paid_eur": 1500}
    assert all_time == {"fees_and_risk_eur": 27, "paid_eur": 3500}
    assert empty == {"fees_and_risk_eur": 0, "paid_eur": 0}


def test_save_amounts_in_one_request(session: Session, client: TestClient):
    session.add_all([Transaction(**TX_1), Transaction(**TX_2), Transaction(**TX_4)])
    session.commit()

    response = client.put("/api/transactions/amounts", headers=ALICE_AUTH, json=[
        {"id": 1, "amount_eur": 1111}, {"id": 2, "amount_eur": None}, {"id": 4, "amount_eur": 4444},
    ])

    assert response.status_code == 200
    assert response.json() == {"saved": [1, 2, 4], "actual_failed": []}
    amounts = {tx.id: tx.amount_eur for tx in session.exec(select(Transaction)).all()}
    assert amounts == {1: 1111, 2: None, 4: 4444}
    assert MockActualClient.patch_calls == []  # nothing exported to Actual yet


def test_save_amounts_is_atomic_for_unknown_transaction(session: Session, client: TestClient):
    session.add(Transaction(**TX_1))
    session.commit()

    response = client.put("/api/transactions/amounts", headers=ALICE_AUTH, json=[
        {"id": 1, "amount_eur": 1111}, {"id": 99, "amount_eur": 1},
    ])

    assert response.status_code == 404
    assert session.exec(select(Transaction).where(Transaction.id == 1)).one().amount_eur == TX_1["amount_eur"]


def test_save_amounts_rejects_foreign_transaction(session: Session, client: TestClient):
    session.add(Transaction(**TX_1))
    session.commit()

    response = client.put("/api/transactions/amounts", headers=BOB_AUTH, json=[{"id": 1, "amount_eur": 1}])

    assert response.status_code == 404
    assert session.exec(select(Transaction).where(Transaction.id == 1)).one().amount_eur == TX_1["amount_eur"]


def test_save_amounts_reports_actual_failures_but_keeps_amounts(session: Session, client: TestClient):
    session.add_all([Transaction(**dict(TX_1, actual_id="actual_1")), Transaction(**dict(TX_4, actual_id="actual_4"))])
    session.commit()
    MockActualClient.fail_on_patch_call = 1

    response = client.put("/api/transactions/amounts", headers=ALICE_AUTH, json=[
        {"id": 1, "amount_eur": 1111}, {"id": 4, "amount_eur": 4444},
    ])

    assert response.status_code == 200
    result = response.json()
    assert result["saved"] == [1, 4]
    assert len(result["actual_failed"]) == 1
    amounts = {tx.id: tx.amount_eur for tx in session.exec(select(Transaction)).all()}
    assert amounts == {1: 1111, 4: 4444}


def test_bank_accounts_do_not_expose_user_secrets(session: Session, client: TestClient):
    response = client.get("/api/bank_accounts", headers=ALICE_AUTH)

    assert response.status_code == 200
    assert set(response.json()[0]["user"].keys()) == {"id", "name", "super_user"}
