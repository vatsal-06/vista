from datetime import datetime
from pydantic import BaseModel
from typing import Optional, List, Dict, Any

class WalkSession(BaseModel):
    id: Optional[str] = None
    user_id: str
    started_at: datetime
    ended_at: Optional[datetime] = None
    distance: float = 0.0
    hazards_detected: List[Dict[str, Any]] = []
