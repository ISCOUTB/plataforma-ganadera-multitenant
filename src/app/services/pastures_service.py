from sqlalchemy.orm import Session
from app.repositories.pasture_repository import PastureRepository
from app.models.pasture import Pasture
from app.schemas.pasture import PastureCreate, PastureUpdate

class PasturesService:
    def __init__(self, db: Session):
        self.db = db
        self.pasture_repository = PastureRepository(db)

    def create_pasture(self, pasture_data: PastureCreate) -> Pasture:
        return self.pasture_repository.create(pasture_data)

    def get_pasture(self, pasture_id: int) -> Pasture:
        return self.pasture_repository.get(pasture_id)

    def update_pasture(self, pasture_id: int, pasture_data: PastureUpdate) -> Pasture:
        return self.pasture_repository.update(pasture_id, pasture_data)

    def delete_pasture(self, pasture_id: int) -> None:
        self.pasture_repository.delete(pasture_id)

    def list_pastures(self):
        return self.pasture_repository.list_all()