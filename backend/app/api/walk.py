import logging
from datetime import datetime
from uuid import uuid4
from fastapi import APIRouter, Depends, HTTPException, status
from app.database.supabase import get_db
from app.schemas.walk import WalkStartRequest, WalkStopRequest, WalkStatusResponse
from app.utils.helpers import wrap_api_response

logger = logging.getLogger("api_walk")
router = APIRouter(prefix="/walk", tags=["walk"])

# In-memory backup state for quick reference
active_walks = {}

@router.post("/start")
async def start_walk(payload: WalkStartRequest, db=Depends(get_db)):
    """
    Creates a new walk session.
    """
    session_id = str(uuid4())
    started_at = datetime.utcnow().isoformat()
    
    session_data = {
        "id": session_id,
        "user_id": payload.user_id,
        "started_at": started_at,
        "distance": 0.0,
        "hazards_detected": []
    }
    
    try:
        res = db.table("walk_sessions").insert(session_data).execute()
        active_walks[session_id] = {
            "user_id": payload.user_id,
            "started_at": started_at,
            "distance": 0.0,
            "hazards_logged": 0
        }
        return wrap_api_response({"session_id": session_id, "started_at": started_at}, "Walk session started successfully.")
    except Exception as e:
        logger.error(f"Failed to start walk session: {e}")
        # Return fallback simulation success to keep the app working offline
        active_walks[session_id] = {
            "user_id": payload.user_id,
            "started_at": started_at,
            "distance": 0.0,
            "hazards_logged": 0
        }
        return wrap_api_response({"session_id": session_id, "started_at": started_at}, "Walk session started successfully (Fallback mode).")

@router.post("/stop")
async def stop_walk(payload: WalkStopRequest, db=Depends(get_db)):
    """
    Terminates an active walk session and writes logs.
    """
    ended_at = payload.ended_at or datetime.utcnow()
    ended_at_str = ended_at.isoformat()
    
    update_data = {
        "ended_at": ended_at_str,
        "distance": payload.distance
    }
    
    try:
        db.table("walk_sessions").update(update_data).eq("id", payload.session_id).execute()
    except Exception as e:
        logger.error(f"Failed to write end-session log: {e}")
        
    if payload.session_id in active_walks:
        del active_walks[payload.session_id]
        
    return wrap_api_response({"session_id": payload.session_id, "ended_at": ended_at_str}, "Walk session stopped.")

@router.get("/status/{session_id}", response_model=WalkStatusResponse)
async def get_walk_status(session_id: str, db=Depends(get_db)):
    """
    Fetches the status of a specific session.
    """
    if session_id in active_walks:
        walk = active_walks[session_id]
        return WalkStatusResponse(
            session_id=session_id,
            user_id=walk["user_id"],
            started_at=datetime.fromisoformat(walk["started_at"]),
            is_active=True,
            distance_walked=walk["distance"],
            hazards_logged=walk["hazards_logged"]
        )
        
    try:
        res = db.table("walk_sessions").select("*").eq("id", session_id).execute()
        data = res.data if hasattr(res, "data") else res
        if not data:
            raise HTTPException(status_code=404, detail="Walk session not found.")
            
        session = data[0]
        return WalkStatusResponse(
            session_id=session["id"],
            user_id=session["user_id"],
            started_at=datetime.fromisoformat(session["started_at"]),
            is_active=session.get("ended_at") is None,
            distance_walked=session.get("distance", 0.0),
            hazards_logged=len(session.get("hazards_detected", []))
        )
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        logger.error(f"Failed to fetch walk status: {e}")
        raise HTTPException(status_code=404, detail="Walk session status unavailable.")
