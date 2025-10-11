from sqlalchemy import Column, Integer, String, Float
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class Cost(Base):
    __tablename__ = 'costs'

    id = Column(Integer, primary_key=True, index=True)
    type = Column(String, index=True)
    amount = Column(Float, nullable=False)
    date = Column(String, nullable=False)
    category = Column(String, index=True)

    def __repr__(self):
        return f"<Cost(id={self.id}, type='{self.type}', amount={self.amount}, date='{self.date}', category='{self.category}')>"