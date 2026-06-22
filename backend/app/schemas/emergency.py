from pydantic import BaseModel
from typing import Optional, List, Dict, Any

class SOSRequest(BaseModel):
    user_id: str
    latitude: float
    longitude: float

class LocationShareRequest(BaseModel):
    user_id: str
    latitude: float
    longitude: float
    is_active: bool = True

class SOSContactNotify(BaseModel):
    contact_name: str
    phone: str
    sms_sent: bool

class SOSResponse(BaseModel):
    success: bool
    timestamp: str
    notified_contacts: List[SOSContactNotify]
    location: Dict[str, float]
