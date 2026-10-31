from datetime import date
from unittest.mock import Mock

from exchangerate.adapter.exchangerates_client import MastercardClient


def test_mastercard_uses_browser_transport(monkeypatch):
    response = Mock()
    response.json.return_value = {"data": {"conversionRate": "1.1144992"}}
    get = Mock(return_value=response)
    monkeypatch.setattr("exchangerate.adapter.exchangerates_client.browser_requests.get", get)

    rate = MastercardClient().get_conversion_rate(date(2026, 10, 28))

    assert rate == "1.1144992"
    get.assert_called_once_with(
        MastercardClient._URL,
        params={
            "exchange_date": "2026-10-28",
            "transaction_currency": "EUR",
            "cardholder_billing_currency": "USD",
            "bank_fee": 0,
            "transaction_amount": 100,
        },
        impersonate="chrome",
        timeout=20,
    )
    response.raise_for_status.assert_called_once_with()


def test_mastercard_checks_status_before_parsing(monkeypatch, capsys):
    response = Mock()
    response.raise_for_status.side_effect = RuntimeError("403 Access Denied")
    monkeypatch.setattr(
        "exchangerate.adapter.exchangerates_client.browser_requests.get",
        Mock(return_value=response),
    )

    assert MastercardClient().get_conversion_rate(date(2026, 10, 28)) is None
    response.json.assert_not_called()
    assert "403 Access Denied" in capsys.readouterr().out
