"""Add an activity flag to credit-card accounts.

Revision ID: d8b2a13e9f45
Revises: c7a8e3b1d92f
Create Date: 2026-10-25
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "d8b2a13e9f45"
down_revision: Union[str, None] = "c7a8e3b1d92f"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "account",
        sa.Column("active", sa.Boolean(), nullable=False, server_default=sa.true()),
    )
    op.alter_column("account", "active", server_default=None)


def downgrade() -> None:
    op.drop_column("account", "active")
