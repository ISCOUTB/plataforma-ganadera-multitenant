from sqlalchemy import Column, Integer, String, Float
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class Feed(Base):
    __tablename__ = 'feeds'

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    type = Column(String)
    quantity = Column(Float)
    nutritional_value = Column(String)

    def __repr__(self):
        return f"<Feed(id={self.id}, name={self.name}, type={self.type}, quantity={self.quantity}, nutritional_value={self.nutritional_value})>"