import logging
import json
from typing import List, Dict, Any, Optional
from app.core.config import settings

logger = logging.getLogger("context_service")

# Try to import Google Generative AI
try:
    import google.generativeai as genai
    HAS_GEMINI = True
except ImportError:
    HAS_GEMINI = False
    logger.warning("google-generativeai not installed. Gemini AI assistant will use rule-based fallbacks.")

class ContextService:
    def __init__(self):
        self.gemini_initialized = False
        if HAS_GEMINI and settings.GEMINI_API_KEY:
            try:
                genai.configure(api_key=settings.GEMINI_API_KEY)
                self.gemini_initialized = True
                logger.info("Gemini API initialized successfully.")
            except Exception as e:
                logger.error(f"Error configuring Gemini API: {e}")

    def prioritize_and_generate_alerts(
        self, 
        vision_detections: List[Dict[str, Any]], 
        audio_events: List[Dict[str, Any]], 
        gps_data: Optional[Dict[str, Any]] = None
    ) -> List[Dict[str, Any]]:
        """
        Filters and prioritizes raw sensor inputs.
        Decides which hazards are HIGH, MEDIUM, or LOW priority.
        Only HIGH priority should trigger immediate spoken audio alerts.
        """
        alerts = []
        
        # 1. Process Vision Detections
        for det in vision_detections:
            obj = det.get("object", "").upper()
            distance = det.get("distance", 99.0)
            direction = det.get("direction", "center")
            
            # Determine Priority based on distance and type
            if distance <= 2.5 or obj in ["CAR", "BIKE", "AUTO", "POTHOL"]:
                if distance <= 3.0:
                    priority = "HIGH"
                elif distance <= 6.0:
                    priority = "MEDIUM"
                else:
                    priority = "LOW"
            else:
                priority = "LOW"
                
            # Create clear natural language instructions
            direction_phrase = f"on your {direction}" if direction != "center" else "ahead"
            if obj == "POTHOLE":
                message = f"Pothole {direction_phrase}, {distance} meters away."
            elif obj in ["CAR", "BIKE", "AUTO"]:
                message = f"{obj.capitalize()} approaching {direction_phrase}, {distance} meters away."
            elif obj == "BARRICADE":
                message = f"Barricade {direction_phrase} at {distance} meters. Watch your step."
            elif obj == "PEOPLE":
                message = f"People {direction_phrase}, {distance} meters away."
            else:
                message = f"{obj.capitalize()} {direction_phrase} at {distance} meters."

            alerts.append({
                "type": "hazard",
                "title": f"{obj}\nAHEAD" if direction == "center" else f"{obj}\n{direction.upper()}",
                "subtitle": message,
                "distance": f"{distance} Meters",
                "direction": direction,
                "priority": priority,
                "speech_text": message if priority == "HIGH" else None
            })
            
        # 2. Process Audio Events
        for ev in audio_events:
            event_type = ev.get("event", "").upper()
            
            if event_type in ["HORN", "SIREN", "EMERGENCY_VEHICLE"]:
                priority = "HIGH"
                if event_type == "HORN":
                    message = "Loud horn detected nearby. Stay alert."
                elif event_type == "SIREN":
                    message = "Siren active nearby. Emergency vehicle in vicinity."
                else:
                    message = "Emergency vehicle approaching."
            else:
                priority = "LOW"
                message = "Traffic sounds detected."
                
            alerts.append({
                "type": "audio_warning",
                "title": f"{event_type} DETECTED",
                "subtitle": message,
                "distance": None,
                "direction": "around",
                "priority": priority,
                "speech_text": message if priority == "HIGH" else None
            })
            
        return alerts

    def ask_gemini_assistant(self, query: str, scene_context: Dict[str, Any]) -> str:
        """
        Uses Gemini to describe the scene or answer a voice command naturally.
        scene_context contains current vision, audio, GPS, and route data.
        """
        prompt = (
            f"You are Saath Chalo, a friendly AI mobility assistant for visually impaired users.\n"
            f"Given the user query: '{query}'\n"
            f"And the current environmental data:\n"
            f"- Vision objects: {json.dumps(scene_context.get('vision', []))}\n"
            f"- Audio events: {json.dumps(scene_context.get('audio', []))}\n"
            f"- GPS coordinate: {scene_context.get('gps', 'Unknown')}\n"
            f"- Current route: {scene_context.get('route', 'No active route guidance')}\n"
            f"Formulate a brief (1-2 sentences), highly clear, reassuring voice-first answer. "
            f"Do not use markdown formatting. Focus on helping the user navigate safely."
        )
        
        if self.gemini_initialized:
            try:
                model = genai.GenerativeModel("gemini-1.5-flash")
                response = model.generate_content(prompt)
                return response.text.strip()
            except Exception as e:
                logger.error(f"Gemini API call failed: {e}. Using fallback generator.")
                
        return self._generate_fallback_response(query, scene_context)

    def _generate_fallback_response(self, query: str, context: Dict[str, Any]) -> str:
        """
        Fallbacks to a smart, rules-based assistant description if Gemini is not configured.
        """
        q = query.lower()
        vision_objs = context.get("vision", [])
        
        if "around" in q or "what" in q:
            if not vision_objs:
                return "The path ahead is clear. There are no major obstacles or vehicles detected."
            
            descriptions = []
            for obj in vision_objs:
                name = obj.get("object", "obstacle")
                dist = obj.get("distance", 5)
                dir_ = obj.get("direction", "center")
                dir_str = f"on your {dir_}" if dir_ != "center" else "straight ahead"
                descriptions.append(f"a {name} {dir_str} at {dist} meters")
                
            return f"I see: {', and '.join(descriptions)}. Walk carefully."
            
        elif "obstacle" in q or "danger" in q or "hazard" in q:
            hazards = [o for o in vision_objs if o.get("object") in ["pothole", "car", "barricade"]]
            if hazards:
                return f"Caution. There is a {hazards[0]['object']} {hazards[0]['distance']} meters away."
            return "No immediate hazards detected. The path is clear."
            
        elif "where" in q or "location" in q or "gps" in q:
            gps = context.get("gps")
            if gps:
                return f"Your current location is latitude {gps.get('lat')}, longitude {gps.get('lng')}."
            return "GPS signal is currently weak. I am searching for your location."
            
        return "I am with you. Keep walking straight, and I will alert you of any obstacles."

context_service = ContextService()
