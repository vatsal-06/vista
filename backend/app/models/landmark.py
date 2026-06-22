from pydantic import BaseModel
from typing import Optional

class Landmark(BaseModel):
    id: Optional[str] = None
    user_id: str
    name: str
    latitude: float
    longitude: float
    category: str
