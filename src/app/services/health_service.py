from datetime import datetime
from typing import List, Dict, Any

class HealthService:
    def __init__(self, health_repository):
        self.health_repository = health_repository

    def register_health_check(self, animal_id: int, procedure_type: str, date: datetime, supplies_used: List[str]) -> Dict[str, Any]:
        if not animal_id or not procedure_type or not date:
            raise ValueError("Missing required fields for health check registration.")
        
        health_record = {
            "animal_id": animal_id,
            "procedure_type": procedure_type,
            "date": date,
            "supplies_used": supplies_used
        }
        
        return self.health_repository.save_health_record(health_record)

    def get_health_history(self, animal_id: int) -> List[Dict[str, Any]]:
        if not animal_id:
            raise ValueError("Animal ID is required to retrieve health history.")
        
        return self.health_repository.get_health_records_by_animal(animal_id)

    def get_upcoming_vaccinations(self, animal_id: int) -> List[Dict[str, Any]]:
        if not animal_id:
            raise ValueError("Animal ID is required to retrieve upcoming vaccinations.")
        
        return self.health_repository.get_upcoming_vaccinations(animal_id)