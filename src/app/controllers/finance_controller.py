from fastapi import APIRouter, HTTPException, Depends
from ..services.finance_service import FinanceService
from ..schemas.reports import ReportSchema
from ..dependencies import get_finance_service

router = APIRouter()

@router.post("/finance/income")
async def record_income(amount: float, category: str, finance_service: FinanceService = Depends(get_finance_service)):
    try:
        result = await finance_service.record_income(amount, category)
        return {"message": "Income recorded successfully", "data": result}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/finance/expense")
async def record_expense(amount: float, category: str, finance_service: FinanceService = Depends(get_finance_service)):
    try:
        result = await finance_service.record_expense(amount, category)
        return {"message": "Expense recorded successfully", "data": result}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/finance/report")
async def generate_report(report_schema: ReportSchema, finance_service: FinanceService = Depends(get_finance_service)):
    try:
        report = await finance_service.generate_report(report_schema)
        return {"message": "Report generated successfully", "data": report}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))