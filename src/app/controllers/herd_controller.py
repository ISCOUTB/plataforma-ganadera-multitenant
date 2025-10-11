from fastapi import APIRouter, HTTPException
from app.schemas.animal import AnimalCreate, AnimalUpdate
from app.services.herd_service import HerdService

router = APIRouter()
herd_service = HerdService()

@router.post("/herd", response_model=AnimalCreate)
async def register_animal(animal: AnimalCreate):
    try:
        return await herd_service.register_animal(animal)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/herd/{animal_id}", response_model=AnimalCreate)
async def get_animal(animal_id: int):
    animal = await herd_service.get_animal(animal_id)
    if not animal:
        raise HTTPException(status_code=404, detail="Animal not found")
    return animal

@router.put("/herd/{animal_id}", response_model=AnimalUpdate)
async def update_animal(animal_id: int, animal: AnimalUpdate):
    try:
        return await herd_service.update_animal(animal_id, animal)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/herd/{animal_id}")
async def delete_animal(animal_id: int):
    try:
        await herd_service.delete_animal(animal_id)
        return {"detail": "Animal deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))