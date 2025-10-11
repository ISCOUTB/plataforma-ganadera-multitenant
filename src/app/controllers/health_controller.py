from fastapi import APIRouter, HTTPException
from ..services.health_service import HealthService
from ..schemas.animal import HealthRecordSchema

router = APIRouter()

@router.post("/health/check")
async def register_health_check(record: HealthRecordSchema):
    try:
        result = await HealthService.register_health_check(record)
        return {"message": "Health record registered successfully", "data": result}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/health/{animal_id}")
async def get_health_records(animal_id: int):
    try:
        records = await HealthService.get_health_records(animal_id)
        if not records:
            raise HTTPException(status_code=404, detail="No health records found for this animal")
        return {"data": records}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/health/{record_id}")
async def delete_health_record(record_id: int):
    try:
        result = await HealthService.delete_health_record(record_id)
        if not result:
            raise HTTPException(status_code=404, detail="Health record not found")
        return {"message": "Health record deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))