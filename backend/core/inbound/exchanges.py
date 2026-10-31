from typing import Annotated, List

from fastapi import APIRouter, Depends, status
from sqlmodel import SQLModel, Session
import datetime
from decimal import Decimal

from auth import require_super_user
from core.business.exchange_service import CreateExchange, ExchangeService
from core.inbound.payments import ExchangePaymentTO
from models import get_session

router = APIRouter(prefix="/api/exchanges", tags=["Exchanges"], dependencies=[Depends(require_super_user)])


class ExchangeTO(SQLModel):
    id: int | None
    date: datetime.date
    amount_usd: int
    exchange_rate: Decimal
    amount_eur: int | None
    paid_eur: int
    fees_eur: int | None
    import_id: str | None
    actual_id: str | None
    cashback_transaction_id: int | None
    cashback_transaction_description: str | None = None
    payments: List[ExchangePaymentTO]


@router.get("", response_model=List[ExchangeTO])
def get_exchanges(session: Annotated[Session, Depends(get_session)],
                  exchange_service: Annotated[ExchangeService, Depends()],
                  usable: bool | None = None):
    exchanges = exchange_service.get_exchanges(session, usable)
    descriptions = exchange_service.get_cashback_transaction_descriptions(session, exchanges)
    return [
        ExchangeTO.model_validate(exchange, update={
            "cashback_transaction_description": descriptions.get(exchange.id) if exchange.id is not None else None,
        })
        for exchange in exchanges
    ]


@router.post("", response_model=ExchangeTO)
def post_exchange(session: Annotated[Session, Depends(get_session)],
                  exchange_service: Annotated[ExchangeService, Depends()],
                  exchange: CreateExchange):
    return exchange_service.create_exchange(session, exchange)


@router.delete("/{exchange_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_exchange(session: Annotated[Session, Depends(get_session)],
                    exchange_service: Annotated[ExchangeService, Depends()],
                    exchange_id: int):
    exchange_service.delete_exchange(session, exchange_id)


@router.put("/{exchange_id}", status_code=status.HTTP_204_NO_CONTENT)
def update_exchange(session: Annotated[Session, Depends(get_session)],
                    exchange_service: Annotated[ExchangeService, Depends()],
                    exchange_id: int, amount: int, payment: int):
    exchange_service.update_exchange(session, exchange_id, amount, payment)
