from datetime import date
from decimal import Decimal
from typing import Annotated, List

from fastapi import Depends, HTTPException
from sqlmodel import Session, SQLModel

from core.business.balance_service import BalanceService
from core.dataaccess.store import Store
from models import Exchange


class CreateExchange(SQLModel):
    date: date
    amount_usd: int
    exchange_rate: int
    paid_eur: int


class ExchangeService:
    def __init__(self, store: Annotated[Store, Depends()],
                 balance_service: Annotated[BalanceService, Depends()]):
        self.store = store
        self.balance_service = balance_service

    def get_exchanges(self, session: Session, usable: bool | None = None) -> List[Exchange]:
        return self.store.get_exchanges(session, usable)

    def get_cashback_transaction_descriptions(self, session: Session, exchanges: List[Exchange]) -> dict[int, str]:
        return self.store.get_cashback_transaction_descriptions(
            session, [exchange.id for exchange in exchanges if exchange.id is not None]
        )

    def create_exchange(self, session: Session, exchange: CreateExchange) -> Exchange:
        if exchange.paid_eur == 0:  # neutral Exchange => won't affect avg. exchange rate of Payment
            created_exchange = self.store.create_exchange(
                session, date=exchange.date, amount_usd=exchange.amount_usd, exchange_rate=Decimal(0),
                amount_eur=0, paid_eur=0, fees_eur=0
            )
            session.commit()
            return created_exchange

        exchange_rate = Decimal(exchange.exchange_rate) / 10000000
        amount_eur = round(Decimal(exchange.amount_usd) / exchange_rate)
        fees_eur = exchange.paid_eur - amount_eur

        created_exchange = self.store.create_exchange(
            session, date=exchange.date, amount_usd=exchange.amount_usd, exchange_rate=exchange_rate,
            amount_eur=amount_eur, paid_eur=exchange.paid_eur, fees_eur=fees_eur
        )
        session.commit()
        return created_exchange
    
    def delete_exchange(self, session: Session, exchange_id: int):
        exchange = self.store.get_exchange(session, exchange_id)
        if not exchange:
            raise HTTPException(status_code=404)

        if exchange.cashback_transaction_id is not None:
            raise HTTPException(status_code=409, detail="Undo cashback on the linked transaction instead")

        if not self.store.get_exchange_payments_by_exchange(session, exchange_id):
            session.delete(exchange)
            session.commit()
        else:
            raise HTTPException(status_code=500, detail="Exchange is still in use")
    
    def update_exchange(self, session: Session, exchange_id: int, amount: int, payment_id: int):
        payment = self.store.get_unprocessed_payment(session, payment_id)
        exchange = self.store.get_exchange(session, exchange_id)
        if not payment or not exchange:
            raise HTTPException(status_code=404)
        if amount == 0:
            self.store.delete_exchange_payment(session, exchange_id, payment_id)
            session.commit()
            return

        if exchange.cashback_transaction_id is not None:
            if self.store.get_transaction_account_id(session, exchange.cashback_transaction_id) != payment.account_id:
                raise HTTPException(status_code=409, detail="Cashback exchange and payment must belong to the same account")
            if amount != exchange.amount_usd:
                raise HTTPException(status_code=400, detail="Cashback exchange must be assigned in full")
            if any(link.payment_id != payment_id for link in self.store.get_exchange_payments_by_exchange(session, exchange_id)):
                raise HTTPException(status_code=409, detail="Cashback exchange is already assigned to another payment")

        current_amount = self.store.get_exchange_payment_amount(session, exchange_id, payment_id)

        if self.balance_service.calc_exchange_remaining(session, exchange, include_pending=True, include_posted=True) + current_amount < amount:
            raise HTTPException(status_code=500, detail=f"Error: Exchange {exchange_id} has not enough balance!")

        if self.balance_service.calc_payment_remaining(session, payment) + current_amount < amount:
            raise HTTPException(status_code=500, detail=f"Error: Exchange {exchange_id} has not enough balance!")

        model, created = self.store.get_or_create_exchange_payment(session, exchange_id, payment_id, amount)

        if not created:
            model.amount = amount
            session.add(model)
        session.commit()
