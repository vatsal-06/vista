from datetime import datetime
from pydantic import BaseModel
from typing import Optional

class Hazard(BaseModel):
    id: Optional[str] = None
    session_id: str
    hazard_type: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    distance: Optional[float] = None
    direction: Optional[str] = None
    created_at: Optional[datetime] = None

class CommunityReport(BaseModel):
    id: Optional[str] = None
    hazard_type: str
    latitude: float
    longitude: float
    reported_by: Optional[str] = None
    description: Optional[str] = None
    created_at: Optional[datetime] = None
