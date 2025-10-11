from pydantic import BaseModel
from typing import List, Optional

class ReportBase(BaseModel):
    title: str
    description: str
    created_at: str

class ReportCreate(ReportBase):
    pass

class ReportUpdate(ReportBase):
    pass

class Report(ReportBase):
    id: int

    class Config:
        orm_mode = True

class ReportList(BaseModel):
    reports: List[Report]