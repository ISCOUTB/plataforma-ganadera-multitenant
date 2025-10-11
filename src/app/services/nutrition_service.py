from datetime import datetime
from typing import List, Dict, Any

class NutritionService:
    def __init__(self, feed_repository, animal_repository):
        self.feed_repository = feed_repository
        self.animal_repository = animal_repository

    def register_nutrition_plan(self, animal_id: int, feed_type: str, ration: float, frequency: str) -> Dict[str, Any]:
        animal = self.animal_repository.get_animal_by_id(animal_id)
        if not animal:
            raise ValueError("Animal not found")

        nutrition_plan = {
            "animal_id": animal_id,
            "feed_type": feed_type,
            "ration": ration,
            "frequency": frequency,
            "created_at": datetime.now()
        }
        
        # Save the nutrition plan to the database
        self.feed_repository.save_nutrition_plan(nutrition_plan)
        return nutrition_plan

    def get_nutrition_plan(self, animal_id: int) -> List[Dict[str, Any]]:
        return self.feed_repository.get_nutrition_plans_by_animal_id(animal_id)

    def update_nutrition_plan(self, plan_id: int, updated_data: Dict[str, Any]) -> Dict[str, Any]:
        existing_plan = self.feed_repository.get_nutrition_plan_by_id(plan_id)
        if not existing_plan:
            raise ValueError("Nutrition plan not found")

        # Update the nutrition plan with new data
        updated_plan = {**existing_plan, **updated_data}
        self.feed_repository.update_nutrition_plan(plan_id, updated_plan)
        return updated_plan

    def delete_nutrition_plan(self, plan_id: int) -> None:
        existing_plan = self.feed_repository.get_nutrition_plan_by_id(plan_id)
        if not existing_plan:
            raise ValueError("Nutrition plan not found")

        self.feed_repository.delete_nutrition_plan(plan_id)