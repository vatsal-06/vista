from datetime import datetime
from pydantic import BaseModel
from typing import Optional

class Route(BaseModel):
    id: Optional[str] = None
    user_id: str
    source: str
    destination: str
    frequency: int = 1
    last_used: Optional[datetime] = None
