import logging
import json
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api import walk, ai, memory, community, emergency
from app.websocket.manager import manager

# Configure logs
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
)
logger = logging.getLogger("main")

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Backend API for Saath Chalo Visually Impaired Assistant",
    version="1.0.0"
)

# CORS middleware for local Flutter web or developer tests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register REST Routes
app.include_router(walk.router, prefix=settings.API_V1_STR)
app.include_router(ai.router, prefix=settings.API_V1_STR)
app.include_router(memory.router, prefix=settings.API_V1_STR)
app.include_router(community.router, prefix=settings.API_V1_STR)
app.include_router(emergency.router, prefix=settings.API_V1_STR)

@app.get("/")
async def root():
    return {
        "status": "online",
        "project": settings.PROJECT_NAME,
        "docs": "/docs"
    }

# ── WEBSOCKET ENDPOINT ────────────────────────────────────────────────────────
@app.websocket("/ws/{session_id}")
async def websocket_endpoint(websocket: WebSocket, session_id: str):
    """
    Main WebSocket pipeline connecting the Flutter app during walks.
    Inbound: Camera binary frames or JSON telemetry metadata/ticks.
    Outbound: Instantly pushed hazard alarms.
    """
    await manager.connect(websocket, session_id)
    try:
        while True:
            # We check type of receive payload: text (JSON) or bytes (image frame)
            message = await websocket.receive()
            
            if "bytes" in message:
                frame_bytes = message["bytes"]
                if frame_bytes:
                    await manager.process_binary_frame(session_id, frame_bytes)
                    
            elif "text" in message:
                text_data = message["text"]
                if text_data:
                    try:
                        data = json.loads(text_data)
                        await manager.process_json_telemetry(session_id, data)
                    except json.JSONDecodeError:
                        logger.warning(f"WebSocket invalid json text received: {text_data}")
                        
    except WebSocketDisconnect:
        manager.disconnect(session_id)
    except Exception as e:
        logger.error(f"WebSocket error in walk session {session_id}: {e}")
        manager.disconnect(session_id)
