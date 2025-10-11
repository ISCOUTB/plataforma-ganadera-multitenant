from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.user import UserCreate, UserUpdate
from app.repositories.user_repository import UserRepository

class UserService:
    def __init__(self, db: Session):
        self.db = db
        self.user_repository = UserRepository(db)

    def create_user(self, user: UserCreate) -> User:
        db_user = self.user_repository.get_user_by_email(user.email)
        if db_user:
            raise ValueError("Email already registered")
        return self.user_repository.create_user(user)

    def get_user(self, user_id: int) -> User:
        return self.user_repository.get_user(user_id)

    def update_user(self, user_id: int, user: UserUpdate) -> User:
        return self.user_repository.update_user(user_id, user)

    def delete_user(self, user_id: int) -> None:
        self.user_repository.delete_user(user_id)

    def list_users(self):
        return self.user_repository.get_all_users()