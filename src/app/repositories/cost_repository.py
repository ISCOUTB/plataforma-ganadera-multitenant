from sqlalchemy.orm import Session
from src.app.models.cost import Cost
from src.app.schemas.cost import CostCreate, CostUpdate

class CostRepository:
    def __init__(self, db: Session):
        self.db = db

    def create_cost(self, cost_data: CostCreate) -> Cost:
        new_cost = Cost(**cost_data.dict())
        self.db.add(new_cost)
        self.db.commit()
        self.db.refresh(new_cost)
        return new_cost

    def get_cost(self, cost_id: int) -> Cost:
        return self.db.query(Cost).filter(Cost.id == cost_id).first()

    def update_cost(self, cost_id: int, cost_data: CostUpdate) -> Cost:
        cost = self.get_cost(cost_id)
        if cost:
            for key, value in cost_data.dict(exclude_unset=True).items():
                setattr(cost, key, value)
            self.db.commit()
            self.db.refresh(cost)
        return cost

    def delete_cost(self, cost_id: int) -> bool:
        cost = self.get_cost(cost_id)
        if cost:
            self.db.delete(cost)
            self.db.commit()
            return True
        return False

    def get_all_costs(self):
        return self.db.query(Cost).all()