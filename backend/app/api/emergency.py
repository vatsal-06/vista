import logging
from fastapi import APIRouter, Depends, HTTPException
from app.schemas.emergency import SOSRequest, LocationShareRequest, SOSResponse, SOSContactNotify
from app.services.emergency_service import emergency_service
from app.utils.helpers import wrap_api_response

logger = logging.getLogger("api_emergency")
router = APIRouter(prefix="/emergency", tags=["emergency"])

@router.post("/sos")
async def trigger_emergency_sos(payload: SOSRequest):
    """
    Triggers panic workflow. Sends Twilio SMS and logs location coordinates.
    """
    res = emergency_service.trigger_sos(
        user_id=payload.user_id,
        latitude=payload.latitude,
        longitude=payload.longitude
    )
    
    if res.get("success"):
        notified = []
        for item in res.get("contacts_notified", []):
            notified.append(SOSContactNotify(
                contact_name=item["contact"],
                phone=item["phone"],
                sms_sent=item["sent"]
            ))
            
        return SOSResponse(
            success=True,
            timestamp=res["timestamp"],
            notified_contacts=notified,
            location=res["location"]
        )
    else:
        raise HTTPException(status_code=500, detail="SOS workflow failed.")

@router.post("/share-location")
async def update_emergency_location(payload: LocationShareRequest):
    """
    Publishes real-time tracker signals of the user's location.
    """
    res = emergency_service.share_live_location(
        user_id=payload.user_id,
        latitude=payload.latitude,
        longitude=payload.longitude
    )
    return wrap_api_response(res, "Emergency location tracking updated.")
