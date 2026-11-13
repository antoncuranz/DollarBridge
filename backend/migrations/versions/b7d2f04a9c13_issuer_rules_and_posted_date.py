"""Per-issuer date rules for accounts and the posting date of transactions and credits.

Revision ID: b7d2f04a9c13
Revises: a41c7e9d2b60
Create Date: 2026-11-13
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "b7d2f04a9c13"
down_revision: Union[str, None] = "a41c7e9d2b60"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("account", sa.Column("issuer", sa.String(), nullable=True))
    op.execute("UPDATE account SET issuer = 'amex' WHERE institution ILIKE '%american express%' OR institution ILIKE '%amex%'")
    op.execute("UPDATE account SET issuer = 'capital_one' WHERE institution ILIKE '%capital one%'")
    op.execute("UPDATE account SET issuer = 'chase' WHERE institution ILIKE '%chase%'")

    # stays empty for existing rows: their statement is decided by the purchase date as before
    op.add_column("transaction", sa.Column("posted_date", sa.Date(), nullable=True))
    op.add_column("credit", sa.Column("posted_date", sa.Date(), nullable=True))


def downgrade() -> None:
    op.drop_column("credit", "posted_date")
    op.drop_column("transaction", "posted_date")
    op.drop_column("account", "issuer")
