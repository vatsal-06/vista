import math
from typing import Tuple

def calculate_haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calculate the great-circle distance between two points on the Earth's surface
    specified in decimal degrees. Returns distance in METERS.
    """
    # Convert decimal degrees to radians
    r_lat1, r_lon1, r_lat2, r_lon2 = map(math.radians, [lat1, lon1, lat2, lon2])

    # Haversine formula
    d_lat = r_lat2 - r_lat1
    d_lon = r_lon2 - r_lon1
    a = math.sin(d_lat / 2.0) ** 2 + math.cos(r_lat1) * math.cos(r_lat2) * math.sin(d_lon / 2.0) ** 2
    c = 2.0 * math.asin(math.sqrt(a))
    
    # Radius of earth in meters
    r = 6371000.0
    return c * r

def is_within_bounding_box(point: Tuple[float, float], min_point: Tuple[float, float], max_point: Tuple[float, float]) -> bool:
    """
    Checks if a point (lat, lon) lies inside a bounding box.
    """
    lat, lon = point
    min_lat, min_lon = min_point
    max_lat, max_lon = max_point
    return min_lat <= lat <= max_lat and min_lon <= lon <= max_lon
