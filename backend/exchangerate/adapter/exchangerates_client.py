import requests
from curl_cffi import requests as browser_requests

from config import config


class IExchangeRateClient:
    def get_conversion_rate(self, date):
        raise NotImplementedError


class ExchangeratesApiIoClient(IExchangeRateClient):
    def __init__(self):
        self.access_key = config.exchangeratesio_access_key

    def get_conversion_rate(self, date):
        url = f"http://api.exchangeratesapi.io/v1/{date}?access_key={self.access_key}&base=EUR&symbols=USD"

        response = requests.get(url).json()
        return response["rates"]["USD"]


class MastercardClient(IExchangeRateClient):
    _URL = "https://www.mastercard.com/marketingservices/public/mccom-services/currency-conversions/conversion-rates"

    def get_conversion_rate(self, date):
        print("Retrieving Conversion Rate for date " + str(date))
        params = {
            "exchange_date": str(date),
            "transaction_currency": "EUR",
            "cardholder_billing_currency": "USD",
            "bank_fee": 0,
            "transaction_amount": 100
        }

        try:
            response = browser_requests.get(self._URL, params=params, impersonate="chrome", timeout=20)
            response.raise_for_status()
            return response.json()["data"]["conversionRate"]
        except Exception as error:
            print("Error retrieving conversion rate: ", error)
            return None  # TODO: raise?
