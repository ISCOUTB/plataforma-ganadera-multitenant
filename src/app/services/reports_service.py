from datetime import datetime
from typing import List, Dict, Any

class ReportsService:
    def __init__(self, repository):
        self.repository = repository

    def generate_productivity_report(self, start_date: str, end_date: str) -> Dict[str, Any]:
        # Logic to generate productivity report
        report_data = self.repository.get_productivity_data(start_date, end_date)
        report = {
            "start_date": start_date,
            "end_date": end_date,
            "data": report_data,
            "generated_at": datetime.now().isoformat()
        }
        return report

    def generate_health_report(self, animal_id: int) -> Dict[str, Any]:
        # Logic to generate health report for a specific animal
        health_data = self.repository.get_health_data(animal_id)
        report = {
            "animal_id": animal_id,
            "health_data": health_data,
            "generated_at": datetime.now().isoformat()
        }
        return report

    def generate_nutrition_report(self, animal_id: int) -> Dict[str, Any]:
        # Logic to generate nutrition report for a specific animal
        nutrition_data = self.repository.get_nutrition_data(animal_id)
        report = {
            "animal_id": animal_id,
            "nutrition_data": nutrition_data,
            "generated_at": datetime.now().isoformat()
        }
        return report

    def generate_financial_report(self, start_date: str, end_date: str) -> Dict[str, Any]:
        # Logic to generate financial report
        financial_data = self.repository.get_financial_data(start_date, end_date)
        report = {
            "start_date": start_date,
            "end_date": end_date,
            "financial_data": financial_data,
            "generated_at": datetime.now().isoformat()
        }
        return report

    def generate_custom_report(self, filters: Dict[str, Any]) -> List[Dict[str, Any]]:
        # Logic to generate a custom report based on provided filters
        custom_data = self.repository.get_custom_data(filters)
        return custom_data