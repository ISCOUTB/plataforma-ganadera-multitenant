from sqlalchemy.orm import Session
from src.app.models.animal import Animal
from src.app.schemas.animal import AnimalCreate, AnimalUpdate

class AnimalRepository:
    def __init__(self, db: Session):
        self.db = db

    def create_animal(self, animal: AnimalCreate) -> Animal:
        db_animal = Animal(**animal.dict())
        self.db.add(db_animal)
        self.db.commit()
        self.db.refresh(db_animal)
        return db_animal

    def get_animal(self, animal_id: int) -> Animal:
        return self.db.query(Animal).filter(Animal.id == animal_id).first()

    def get_all_animals(self) -> list[Animal]:
        return self.db.query(Animal).all()

    def update_animal(self, animal_id: int, animal_data: AnimalUpdate) -> Animal:
        animal = self.get_animal(animal_id)
        if animal:
            for key, value in animal_data.dict(exclude_unset=True).items():
                setattr(animal, key, value)
            self.db.commit()
            self.db.refresh(animal)
        return animal

    def delete_animal(self, animal_id: int) -> bool:
        animal = self.get_animal(animal_id)
        if animal:
            self.db.delete(animal)
            self.db.commit()
            return True
        return False