from fastapi import APIRouter, Depends
from app.services.reports_service import ReportsService
from app.schemas.reports import ReportCreate, ReportResponse

router = APIRouter()

@router.post("/reports", response_model=ReportResponse)
async def create_report(report: ReportCreate, reports_service: ReportsService = Depends()):
    return await reports_service.create_report(report)

@router.get("/reports/{report_id}", response_model=ReportResponse)
async def get_report(report_id: int, reports_service: ReportsService = Depends()):
    return await reports_service.get_report(report_id)

@router.get("/reports", response_model=list[ReportResponse])
async def list_reports(reports_service: ReportsService = Depends()):
    return await reports_service.list_reports()

@router.delete("/reports/{report_id}")
async def delete_report(report_id: int, reports_service: ReportsService = Depends()):
    await reports_service.delete_report(report_id)
    return {"message": "Report deleted successfully"}