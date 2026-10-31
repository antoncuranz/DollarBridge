from typing import List
from sqlmodel import Session, col, select

from models import Account, User


class DatesRepository:
    def get_all_accounts(self, session: Session) -> List[Account]:
        stmt = select(Account).where(col(Account.active).is_(True)).order_by(col(Account.id))
        return list(session.exec(stmt).all())
    
    def get_accounts_of_user(self, session: Session, user: User) -> List[Account]:
        stmt = select(Account).where((col(Account.user_id) == user.id) & col(Account.active).is_(True)).order_by(col(Account.id))
        return list(session.exec(stmt).all())
