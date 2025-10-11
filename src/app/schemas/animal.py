from pydantic import BaseModel
from typing import Optional

class AnimalBase(BaseModel):
    id: int
    age: int
    breed: str
    weight: float
    productive_status: str

class AnimalCreate(AnimalBase):
    pass

class AnimalUpdate(BaseModel):
    age: Optional[int] = None
    breed: Optional[str] = None
    weight: Optional[float] = None
    productive_status: Optional[str] = None

class Animal(AnimalBase):
    class Config:
        orm_mode = True