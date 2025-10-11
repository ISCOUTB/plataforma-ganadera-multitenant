from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.auth import UserCreate, UserLogin
from app.utils.hashing import Hash
from fastapi import HTTPException, status

class AuthService:
    def __init__(self, db: Session):
        self.db = db

    def register_user(self, user: UserCreate):
        existing_user = self.db.query(User).filter(User.email == user.email).first()
        if existing_user:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")
        
        new_user = User(
            email=user.email,
            password=Hash.bcrypt(user.password),
            role=user.role
        )
        self.db.add(new_user)
        self.db.commit()
        self.db.refresh(new_user)
        return new_user

    def login_user(self, user: UserLogin):
        existing_user = self.db.query(User).filter(User.email == user.email).first()
        if not existing_user or not Hash.verify(existing_user.password, user.password):
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
        
        return existing_user

    def recover_password(self, email: str, new_password: str):
        user = self.db.query(User).filter(User.email == email).first()
        if not user:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
        
        user.password = Hash.bcrypt(new_password)
        self.db.commit()
        return {"detail": "Password updated successfully"}