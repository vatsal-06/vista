from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime

class WalkStartRequest(BaseModel):
    user_id: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None

class WalkStopRequest(BaseModel):
    session_id: str
    distance: float = 0.0
    ended_at: Optional[datetime] = None

class WalkStatusResponse(BaseModel):
    session_id: str
    user_id: str
    started_at: datetime
    is_active: bool
    distance_walked: float
    hazards_logged: int
