import logging
import base64
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from app.schemas.ai import AIQueryRequest, AIQueryResponse
from app.services.context_service import context_service
from app.services.vision_service import vision_service
from app.utils.helpers import wrap_api_response

logger = logging.getLogger("api_ai")
router = APIRouter(prefix="/ai", tags=["ai"])

@router.post("/ask", response_model=AIQueryResponse)
async def ask_assistant(payload: AIQueryRequest):
    """
    Receives voice command text query and returns conversational description.
    """
    # Construct current scene context dictionary
    scene_context = {
        "vision": payload.active_vision_context or [],
        "audio": [],
        "gps": payload.gps
    }
    
    response_text = context_service.ask_gemini_assistant(payload.query, scene_context)
    
    return AIQueryResponse(
        query=payload.query,
        response=response_text,
        voice_preference="nova"
    )

@router.post("/detect")
async def detect_frame_objects(frame: UploadFile = File(...)):
    """
    Direct REST endpoint for posting an image and returning priority threat logs.
    """
    try:
        content = await frame.read()
        
        # 1. Run detections
        vision_objs = vision_service.detect_objects(content)
        
        # 2. Extract alerts
        alerts = context_service.prioritize_and_generate_alerts(vision_objs, [])
        
        # 3. Format immediate response
        # Find high priority messages for speaker
        speech_announcements = [a["speech_text"] for a in alerts if a.get("speech_text")]
        
        return wrap_api_response({
            "detections": vision_objs,
            "alerts": alerts,
            "speech_announcement": " ".join(speech_announcements) if speech_announcements else None
        }, "Detections completed successfully.")
    except Exception as e:
        logger.error(f"Error processing frame upload: {e}")
        raise HTTPException(status_code=500, detail="Failed to parse frame.")
