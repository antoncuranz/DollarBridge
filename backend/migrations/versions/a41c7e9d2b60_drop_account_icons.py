"""Drop the unused icon columns of credit cards and bank accounts.

Revision ID: a41c7e9d2b60
Revises: 7c63b9d10e41
Create Date: 2026-11-13
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "a41c7e9d2b60"
down_revision: Union[str, None] = "7c63b9d10e41"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.drop_column("account", "icon")
    op.drop_column("bankaccount", "icon")


def downgrade() -> None:
    # the columns come back empty: the icon URLs are not restored
    op.add_column("bankaccount", sa.Column("icon", sa.String(), nullable=True))
    op.add_column("account", sa.Column("icon", sa.String(), nullable=True))
