from fastapi import Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..repositories.user_repository import UserRepository
from ..repositories.animal_repository import AnimalRepository
from ..repositories.pasture_repository import PastureRepository
from ..repositories.feed_repository import FeedRepository
from ..repositories.cost_repository import CostRepository

def get_user_repository(db: Session = Depends(get_db)) -> UserRepository:
    return UserRepository(db)

def get_animal_repository(db: Session = Depends(get_db)) -> AnimalRepository:
    return AnimalRepository(db)

def get_pasture_repository(db: Session = Depends(get_db)) -> PastureRepository:
    return PastureRepository(db)

def get_feed_repository(db: Session = Depends(get_db)) -> FeedRepository:
    return FeedRepository(db)

def get_cost_repository(db: Session = Depends(get_db)) -> CostRepository:
    return CostRepository(db)