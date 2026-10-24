"""Link cashback exchanges to their transaction.

Revision ID: c7a8e3b1d92f
Revises: f4fa80f093a3
Create Date: 2026-10-24
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "c7a8e3b1d92f"
down_revision: Union[str, None] = "f4fa80f093a3"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("exchange", sa.Column("cashback_transaction_id", sa.Integer(), nullable=True))
    op.create_foreign_key(
        "fk_exchange_cashback_transaction",
        "exchange",
        "transaction",
        ["cashback_transaction_id"],
        ["id"],
    )
    op.create_unique_constraint(
        "uq_exchange_cashback_transaction_id",
        "exchange",
        ["cashback_transaction_id"],
    )
    # Convert only unambiguous legacy cashback pairs. The former implementation
    # identified them by this same zero-rate/date/USD heuristic, so ambiguous
    # pairs are intentionally left unlinked for manual review.
    op.execute("""
        WITH candidates AS (
            SELECT e.id AS exchange_id, t.id AS transaction_id
            FROM exchange e
            JOIN "transaction" t
              ON t.date = e.date
             AND t.amount_usd = e.amount_usd
             AND t.amount_eur = 0
            WHERE e.exchange_rate = 0
              AND e.amount_eur = 0
              AND e.paid_eur = 0
              AND e.fees_eur = 0
              AND NOT EXISTS (
                  SELECT 1 FROM exchangepayment ep WHERE ep.exchange_id = e.id
              )
        ),
        unique_exchanges AS (
            SELECT exchange_id, min(transaction_id) AS transaction_id
            FROM candidates
            GROUP BY exchange_id
            HAVING count(*) = 1
        ),
        unique_transactions AS (
            SELECT transaction_id, min(exchange_id) AS exchange_id
            FROM candidates
            GROUP BY transaction_id
            HAVING count(*) = 1
        )
        UPDATE exchange e
        SET cashback_transaction_id = ue.transaction_id
        FROM unique_exchanges ue
        JOIN unique_transactions ut
          ON ut.transaction_id = ue.transaction_id
         AND ut.exchange_id = ue.exchange_id
        WHERE e.id = ue.exchange_id
    """)


def downgrade() -> None:
    op.drop_constraint("uq_exchange_cashback_transaction_id", "exchange", type_="unique")
    op.drop_constraint("fk_exchange_cashback_transaction", "exchange", type_="foreignkey")
    op.drop_column("exchange", "cashback_transaction_id")
