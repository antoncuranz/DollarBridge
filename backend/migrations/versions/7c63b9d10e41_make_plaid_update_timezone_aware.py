"""Store Plaid update timestamps with timezone information.

Revision ID: 7c63b9d10e41
Revises: d8b2a13e9f45
Create Date: 2026-10-31
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "7c63b9d10e41"
down_revision: Union[str, None] = "d8b2a13e9f45"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Old values lack a reliable timezone and will be refreshed on the next
    # successful Plaid import. Clear them instead of guessing their offset.
    op.execute("UPDATE plaidaccount SET last_successful_update = NULL")
    op.alter_column(
        "plaidaccount",
        "last_successful_update",
        existing_type=sa.DateTime(timezone=False),
        type_=sa.DateTime(timezone=True),
        existing_nullable=True,
    )


def downgrade() -> None:
    op.alter_column(
        "plaidaccount",
        "last_successful_update",
        existing_type=sa.DateTime(timezone=True),
        type_=sa.DateTime(timezone=False),
        existing_nullable=True,
        postgresql_using="last_successful_update AT TIME ZONE 'UTC'",
    )
