from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List

router = APIRouter()

class NutritionPlan(BaseModel):
    animal_id: int
    feed_type: str
    ration: float
    frequency: str

class NutritionAlert(BaseModel):
    animal_id: int
    message: str

nutrition_plans = []
nutrition_alerts = []

@router.post("/nutrition/plans", response_model=NutritionPlan)
def create_nutrition_plan(plan: NutritionPlan):
    nutrition_plans.append(plan)
    return plan

@router.get("/nutrition/plans", response_model=List[NutritionPlan])
def get_nutrition_plans():
    return nutrition_plans

@router.post("/nutrition/alerts", response_model=NutritionAlert)
def create_nutrition_alert(alert: NutritionAlert):
    nutrition_alerts.append(alert)
    return alert

@router.get("/nutrition/alerts", response_model=List[NutritionAlert])
def get_nutrition_alerts():
    return nutrition_alerts

@router.delete("/nutrition/plans/{animal_id}")
def delete_nutrition_plan(animal_id: int):
    global nutrition_plans
    nutrition_plans = [plan for plan in nutrition_plans if plan.animal_id != animal_id]
    return {"message": "Nutrition plan deleted successfully."}