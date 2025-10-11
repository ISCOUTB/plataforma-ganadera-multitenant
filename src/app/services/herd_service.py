from sqlalchemy.orm import Session
from app.repositories.animal_repository import AnimalRepository
from app.models.animal import Animal
from app.schemas.animal import AnimalCreate, AnimalUpdate

class HerdService:
    def __init__(self, db: Session):
        self.db = db
        self.animal_repository = AnimalRepository(db)

    def register_animal(self, animal_data: AnimalCreate) -> Animal:
        return self.animal_repository.create_animal(animal_data)

    def get_all_animals(self):
        return self.animal_repository.get_all_animals()

    def get_animal_by_id(self, animal_id: int) -> Animal:
        return self.animal_repository.get_animal_by_id(animal_id)

    def update_animal(self, animal_id: int, animal_data: AnimalUpdate) -> Animal:
        return self.animal_repository.update_animal(animal_id, animal_data)

    def delete_animal(self, animal_id: int) -> bool:
        return self.animal_repository.delete_animal(animal_id)