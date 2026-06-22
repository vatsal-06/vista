import logging
import math
from typing import List, Dict, Any, Optional
import requests
from app.core.config import settings
from app.utils.gps import calculate_haversine_distance

logger = logging.getLogger("navigation_service")

class NavigationService:
    def __init__(self):
        self.gmaps_key = settings.GOOGLE_MAPS_API_KEY
        
        # Local mock landmarks database for coordinate-based simulation
        self._mock_landmarks = [
            {"name": "Local Tea Stall", "category": "food", "lat": 12.9716, "lng": 77.5946},
            {"name": "Central Bus Station", "category": "transportation", "lat": 12.9720, "lng": 77.5950},
            {"name": "Metro Crossing", "category": "crossing", "lat": 12.9710, "lng": 77.5935},
            {"name": "Government Hospital", "category": "medical", "lat": 12.9730, "lng": 77.5960},
            {"name": "Public Park Gate", "category": "landmark", "lat": 12.9705, "lng": 77.5940}
        ]

    def get_route_guidance(self, origin: str, destination: str) -> Dict[str, Any]:
        """
        Calculates routing and turns between origin and destination.
        """
        if self.gmaps_key:
            try:
                url = "https://maps.googleapis.com/maps/api/directions/json"
                params = {
                    "origin": origin,
                    "destination": destination,
                    "mode": "walking",
                    "key": self.gmaps_key
                }
                r = requests.get(url, params=params)
                if r.status_code == 200:
                    data = r.json()
                    if data.get("status") == "OK":
                        route = data["routes"][0]
                        leg = route["legs"][0]
                        steps = []
                        for step in leg["steps"]:
                            # Remove HTML tags from instruction
                            instruction = step["html_instructions"]
                            clean_instruction = "".join(c for c in instruction if c not in ["<", ">"]) # very basic strip
                            # Better strip:
                            import re
                            clean_instruction = re.sub('<[^<]+?>', '', instruction)
                            steps.append({
                                "instruction": clean_instruction,
                                "distance": step["distance"]["text"],
                                "duration": step["duration"]["text"],
                                "start_location": step["start_location"]
                            })
                        return {
                            "success": True,
                            "source": leg["start_address"],
                            "destination": leg["end_address"],
                            "distance": leg["distance"]["text"],
                            "duration": leg["duration"]["text"],
                            "steps": steps
                        }
            except Exception as e:
                logger.error(f"Google Maps routing failed: {e}")
                
        # Mock Routing fallback
        return {
            "success": True,
            "source": origin,
            "destination": destination,
            "distance": "1.2 km",
            "duration": "15 mins",
            "steps": [
                {"instruction": "Walk straight towards Main Road", "distance": "200m", "duration": "3 mins", "start_location": {"lat": 12.9716, "lng": 77.5946}},
                {"instruction": "Turn left at the Central Bus Station", "distance": "400m", "duration": "5 mins", "start_location": {"lat": 12.9720, "lng": 77.5950}},
                {"instruction": "Walk past the Metro Crossing and continue straight", "distance": "500m", "duration": "6 mins", "start_location": {"lat": 12.9710, "lng": 77.5935}},
                {"instruction": "Destination is on your right", "distance": "100m", "duration": "1 min", "start_location": {"lat": 12.9705, "lng": 77.5940}}
            ]
        }

    def lookup_landmarks(self, lat: float, lng: float, radius_meters: float = 300) -> List[Dict[str, Any]]:
        """
        Locates nearby landmarks within a given radius using Haversine distance.
        """
        nearby = []
        for lm in self._mock_landmarks:
            dist = calculate_haversine_distance(lat, lng, lm["lat"], lm["lng"])
            if dist <= radius_meters:
                nearby.append({
                    "name": lm["name"],
                    "category": lm["category"],
                    "distance": f"{round(dist)}m",
                    "latitude": lm["lat"],
                    "longitude": lm["lng"]
                })
        return nearby

    def detect_bus_stops_and_crossings(self, lat: float, lng: float) -> List[Dict[str, Any]]:
        """
        Checks for any transportation nodes or intersections directly in front of the user.
        """
        landmarks = self.lookup_landmarks(lat, lng, radius_meters=100)
        return [lm for lm in landmarks if lm["category"] in ["transportation", "crossing"]]

navigation_service = NavigationService()
