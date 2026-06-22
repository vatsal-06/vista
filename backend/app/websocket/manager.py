import logging
from typing import Dict, Any, List
from fastapi import WebSocket
from app.services.vision_service import vision_service
from app.services.audio_service import audio_service
from app.services.context_service import context_service

logger = logging.getLogger("websocket_manager")

class ConnectionManager:
    def __init__(self):
        # Maps session_id -> WebSocket connection
        self.active_connections: Dict[str, WebSocket] = {}

    async def connect(self, websocket: WebSocket, session_id: str):
        await websocket.accept()
        self.active_connections[session_id] = websocket
        logger.info(f"WebSocket connected for walk session: {session_id}")

    def disconnect(self, session_id: str):
        if session_id in self.active_connections:
            del self.active_connections[session_id]
            logger.info(f"WebSocket disconnected for walk session: {session_id}")

    async def send_alert(self, session_id: str, alert: Dict[str, Any]):
        websocket = self.active_connections.get(session_id)
        if websocket:
            try:
                await websocket.send_json(alert)
            except Exception as e:
                logger.error(f"Error sending alert over WebSocket to session {session_id}: {e}")
                self.disconnect(session_id)

    async def process_binary_frame(self, session_id: str, frame_bytes: bytes):
        """
        Processes an incoming camera frame (binary payload) from a client.
        Runs object detection, filters context, and sends alerts back if any.
        """
        # 1. Run YOLOv8 detection on the camera frame
        vision_objs = vision_service.detect_objects(frame_bytes)
        
        # 2. Get any current audio events (normally streaming separately, or we fetch context)
        audio_events = [] # Simulated or buffered
        
        # 3. Compile context alerts
        alerts = context_service.prioritize_and_generate_alerts(vision_objs, audio_events)
        
        # 4. Broadcast alerts to client
        for alert in alerts:
            # Broadcast the alert to the socket client
            await self.send_alert(session_id, alert)

    async def process_json_telemetry(self, session_id: str, data: Dict[str, Any]):
        """
        Processes metadata (GPS, simulated test ticks, or config changes) sent as JSON.
        """
        packet_type = data.get("type", "")
        
        if packet_type == "telemetry":
            gps_data = data.get("gps", {})
            lat = gps_data.get("lat")
            lng = gps_data.get("lng")
            
            # Here we would do database checks or search nearby landmarks
            # and broadcast information if a bus stop or crossing is ahead.
            logger.debug(f"Received GPS for session {session_id}: ({lat}, {lng})")
            
        elif packet_type == "simulate_tick":
            # Very helpful for Flutter debug run: generates a simulated vision/audio frame tick
            # directly so the UI responds with high/medium/low priority cards dynamically.
            vision_objs = vision_service._simulate_detection()
            audio_evs = audio_service._simulate_audio_event()
            
            alerts = context_service.prioritize_and_generate_alerts(vision_objs, audio_evs)
            for alert in alerts:
                await self.send_alert(session_id, alert)

manager = ConnectionManager()
