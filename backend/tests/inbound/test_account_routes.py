from models import Account, User, BankAccount
from tests.fixtures import ACCOUNT_1, ALICE_AUTH, ALICE_USER, BANK_ACCOUNT_1

from sqlmodel import Session
from fastapi.testclient import TestClient

def test_get_accounts(session: Session, client: TestClient):
    # Arrange
    session.add_all([User(**ALICE_USER), BankAccount(**BANK_ACCOUNT_1), Account(**ACCOUNT_1)])
    session.commit()

    # Act
    response = client.get("/api/accounts", headers=ALICE_AUTH)
    parsed = response.json()

    # Assert
    print(parsed)
    assert len(parsed) == 1
    assert parsed[0]["actual_id"] == ACCOUNT_1["actual_id"]
    assert parsed[0]["name"] == ACCOUNT_1["name"]
    assert parsed[0]["institution"] == ACCOUNT_1["institution"]
    assert parsed[0]["active"] is True


def test_modify_account_can_deactivate_and_reactivate(session: Session, client: TestClient):
    session.add_all([User(**ALICE_USER), BankAccount(**BANK_ACCOUNT_1), Account(**ACCOUNT_1)])
    session.commit()

    payload = {
        "name": ACCOUNT_1["name"],
        "institution": ACCOUNT_1["institution"],
        "due_day": None,
        "autopay_offset": None,
        "icon": None,
        "color": None,
        "target_spend": None,
        "bank_account_id": BANK_ACCOUNT_1["id"],
        "plaid_account_id": None,
        "actual_id": ACCOUNT_1["actual_id"],
        "active": False,
    }

    response = client.put("/api/accounts/1", headers=ALICE_AUTH, json=payload)

    assert response.status_code == 204
    assert client.get("/api/accounts", headers=ALICE_AUTH).json()[0]["active"] is False

    payload["active"] = True
    response = client.put("/api/accounts/1", headers=ALICE_AUTH, json=payload)

    assert response.status_code == 204
    assert client.get("/api/accounts", headers=ALICE_AUTH).json()[0]["active"] is True
