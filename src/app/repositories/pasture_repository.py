from sqlalchemy.orm import Session
from app.models.pasture import Pasture
from app.schemas.pasture import PastureCreate, PastureUpdate

class PastureRepository:
    def __init__(self, db: Session):
        self.db = db

    def create_pasture(self, pasture: PastureCreate) -> Pasture:
        db_pasture = Pasture(**pasture.dict())
        self.db.add(db_pasture)
        self.db.commit()
        self.db.refresh(db_pasture)
        return db_pasture

    def get_pasture(self, pasture_id: int) -> Pasture:
        return self.db.query(Pasture).filter(Pasture.id == pasture_id).first()

    def get_all_pastures(self) -> list[Pasture]:
        return self.db.query(Pasture).all()

    def update_pasture(self, pasture_id: int, pasture: PastureUpdate) -> Pasture:
        db_pasture = self.get_pasture(pasture_id)
        if db_pasture:
            for key, value in pasture.dict(exclude_unset=True).items():
                setattr(db_pasture, key, value)
            self.db.commit()
            self.db.refresh(db_pasture)
        return db_pasture

    def delete_pasture(self, pasture_id: int) -> bool:
        db_pasture = self.get_pasture(pasture_id)
        if db_pasture:
            self.db.delete(db_pasture)
            self.db.commit()
            return True
        return False