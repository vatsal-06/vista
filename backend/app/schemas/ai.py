from pydantic import BaseModel
from typing import Optional, Dict, Any, List

class AIQueryRequest(BaseModel):
    query: str
    user_id: Optional[str] = "default_user"
    gps: Optional[Dict[str, float]] = None # {"lat": 12.9, "lng": 77.5}
    active_vision_context: Optional[List[Dict[str, Any]]] = None

class AIQueryResponse(BaseModel):
    query: str
    response: str
    voice_preference: str = "nova"
