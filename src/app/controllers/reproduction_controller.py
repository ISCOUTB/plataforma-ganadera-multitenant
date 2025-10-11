from fastapi import APIRouter, HTTPException
from app.schemas.animal import AnimalSchema
from app.services.reproduction_service import ReproductionService

router = APIRouter()
reproduction_service = ReproductionService()

@router.post("/reproduction/events", response_model=AnimalSchema)
async def register_reproduction_event(animal_id: int, event_type: str, date: str, result: str):
    try:
        return await reproduction_service.register_event(animal_id, event_type, date, result)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/reproduction/{animal_id}", response_model=AnimalSchema)
async def get_reproduction_history(animal_id: int):
    try:
        return await reproduction_service.get_history(animal_id)
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))