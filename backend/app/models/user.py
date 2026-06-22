from datetime import datetime
from pydantic import BaseModel, EmailStr
from typing import Optional

class User(BaseModel):
    id: Optional[str] = None
    name: str
    email: str
    language: str = "english"
    voice_preference: str = "nova"
    created_at: Optional[datetime] = None

class UserPreference(BaseModel):
    user_id: str
    haptic_intensity: float = 0.8
    screen_reader_mode: bool = False
    voice_speed: float = 1.0
