from sqlalchemy import Column, Integer, String, Float, Date
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class Animal(Base):
    __tablename__ = 'animals'

    id = Column(Integer, primary_key=True, index=True)
    identification = Column(String, unique=True, index=True)
    age = Column(Integer)
    breed = Column(String)
    weight = Column(Float)
    productive_status = Column(String)
    registration_date = Column(Date)

    def __repr__(self):
        return f"<Animal(id={self.id}, identification={self.identification}, age={self.age}, breed={self.breed}, weight={self.weight}, productive_status={self.productive_status})>"