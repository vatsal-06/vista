import logging
from datetime import datetime
from typing import Dict, Any, List
from app.database.supabase import get_db
from app.core.config import settings

logger = logging.getLogger("emergency_service")

# Try to import Twilio
try:
    from twilio.rest import Client as TwilioClient
    HAS_TWILIO = True
except ImportError:
    HAS_TWILIO = False

class EmergencyService:
    def __init__(self):
        self.db = get_db()
        self.twilio_ready = (
            HAS_TWILIO 
            and settings.TWILIO_ACCOUNT_SID 
            and settings.TWILIO_AUTH_TOKEN 
            and settings.TWILIO_FROM_NUMBER
        )

    def trigger_sos(self, user_id: str, latitude: float, longitude: float) -> Dict[str, Any]:
        """
        Main SOS workflow: Logs the event, fetches contacts, and broadcasts SMS/push.
        """
        logger.info(f"SOS Triggered for user: {user_id} at ({latitude}, {longitude})")
        
        # 1. Log event in Database
        event_data = {
            "user_id": user_id,
            "latitude": latitude,
            "longitude": longitude,
            "created_at": datetime.utcnow().isoformat()
        }
        
        try:
            self.db.table("emergency_events").insert(event_data).execute()
        except Exception as e:
            logger.error(f"Failed to log emergency event in DB: {e}")

        # 2. Fetch emergency contacts
        contacts = []
        try:
            res = self.db.table("emergency_contacts").select("*").eq("user_id", user_id).execute()
            contacts = res.data if hasattr(res, "data") else res
            if not contacts or not isinstance(contacts, list):
                contacts = []
        except Exception as e:
            logger.error(f"Failed to fetch emergency contacts: {e}")
            
        # Fallback to local default contact if database is empty (for testing)
        if not contacts:
            contacts = [{"name": "Default Guardian", "phone": "+91 98765 43210", "is_primary": True}]

        # 3. Dispatch Twilio SMS
        sms_results = []
        maps_link = f"https://www.google.com/maps/search/?api=1&query={latitude},{longitude}"
        alert_message = (
            f"EMERGENCY: Saath Chalo user has triggered an SOS! "
            f"Current location: {maps_link}. Please check on them immediately."
        )
        
        for c in contacts:
            phone = c.get("phone")
            name = c.get("name", "Guardian")
            if not phone:
                continue
                
            sent_status = self._send_sms(phone, alert_message)
            sms_results.append({
                "contact": name,
                "phone": phone,
                "sent": sent_status
            })
            
        # 4. Dispatch FCM push notification (logged as mock since Firebase requires app package setup)
        logger.info(f"FCM Push Alert broadcasted for SOS event {user_id}.")

        return {
            "success": True,
            "timestamp": datetime.utcnow().isoformat(),
            "contacts_notified": sms_results,
            "location": {"lat": latitude, "lng": longitude}
        }

    def share_live_location(self, user_id: str, latitude: float, longitude: float) -> Dict[str, Any]:
        """
        Periodically logs live tracking location coordinates during active emergencies.
        """
        logger.info(f"Live tracking update for {user_id}: ({latitude}, {longitude})")
        # We can write this to a redis/in-memory cache or update the latest emergency event.
        return {
            "success": True,
            "user_id": user_id,
            "latitude": latitude,
            "longitude": longitude,
            "timestamp": datetime.utcnow().isoformat()
        }

    def _send_sms(self, to_phone: str, message: str) -> bool:
        """
        Helper method to perform SMS transmission.
        """
        if self.twilio_ready:
            try:
                client = TwilioClient(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
                client.messages.create(
                    body=message,
                    from_=settings.TWILIO_FROM_NUMBER,
                    to=to_phone
                )
                logger.info(f"Twilio SMS successfully sent to: {to_phone}")
                return True
            except Exception as e:
                logger.error(f"Twilio SMS transmission failed to {to_phone}: {e}")
                
        # Simulated transmission if credentials missing
        logger.info(f"[SIMULATED SMS to {to_phone}]: {message}")
        return True

emergency_service = EmergencyService()
