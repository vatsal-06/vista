import logging
from datetime import datetime
from typing import List, Dict, Any
from app.database.supabase import get_db
from app.utils.gps import calculate_haversine_distance

logger = logging.getLogger("community_service")

class CommunityService:
    def __init__(self):
        self.db = get_db()
        
        # Populate mock community reports to have data out-of-the-box
        self._seed_mock_reports()

    def _seed_mock_reports(self):
        try:
            # Check if there are already records
            res = self.db.table("community_reports").select("id").execute()
            data = res.data if hasattr(res, "data") else res
            if not data or len(data) == 0:
                mock_reports = [
                    {"hazard_type": "open drain", "latitude": 12.9715, "longitude": 77.5942, "description": "Uncovered drain on footpath near signal"},
                    {"hazard_type": "construction roadblock", "latitude": 12.9725, "longitude": 77.5955, "description": "Footpath completely blocked by building materials"},
                    {"hazard_type": "broken pavement", "latitude": 12.9708, "longitude": 77.5932, "description": "Loose tiles and deep cracks"}
                ]
                for r in mock_reports:
                    self.db.table("community_reports").insert(r).execute()
        except Exception as e:
            logger.error(f"Error seeding mock community reports: {e}")

    def report_hazard(
        self, 
        hazard_type: str, 
        latitude: float, 
        longitude: float, 
        reported_by: str = None, 
        description: str = None
    ) -> Dict[str, Any]:
        """
        Submits a new community reported hazard.
        """
        data = {
            "hazard_type": hazard_type.lower(),
            "latitude": latitude,
            "longitude": longitude,
            "reported_by": reported_by,
            "description": description,
            "created_at": datetime.utcnow().isoformat()
        }
        
        try:
            res = self.db.table("community_reports").insert(data).execute()
            result_data = res.data if hasattr(res, "data") else res
            return {"success": True, "data": result_data}
        except Exception as e:
            logger.error(f"Failed to submit community report: {e}")
            return {"success": False, "error": str(e)}

    def get_nearby_hazards(self, latitude: float, longitude: float, radius_meters: float = 500) -> List[Dict[str, Any]]:
        """
        Finds all community hazard reports within radius_meters of the coordinates.
        """
        try:
            res = self.db.table("community_reports").select("*").execute()
            reports = res.data if hasattr(res, "data") else res
            if not reports or not isinstance(reports, list):
                return []
                
            nearby = []
            for r in reports:
                lat = r.get("latitude")
                lng = r.get("longitude")
                if lat is None or lng is None:
                    continue
                    
                dist = calculate_haversine_distance(latitude, longitude, lat, lng)
                if dist <= radius_meters:
                    r_copy = r.copy()
                    r_copy["distance"] = round(dist)
                    nearby.append(r_copy)
            
            # Sort by distance ascending
            nearby.sort(key=lambda x: x["distance"])
            return nearby
        except Exception as e:
            logger.error(f"Failed to query nearby community hazards: {e}")
            return []

community_service = CommunityService()
