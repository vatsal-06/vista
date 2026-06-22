import logging
from fastapi import APIRouter, Depends, Query, HTTPException
from pydantic import BaseModel
from typing import Optional
from app.services.community_service import community_service
from app.utils.helpers import wrap_api_response

logger = logging.getLogger("api_community")
router = APIRouter(prefix="/community", tags=["community"])

class ReportHazardRequest(BaseModel):
    hazard_type: str
    latitude: float
    longitude: float
    reported_by: Optional[str] = None
    description: Optional[str] = None

@router.post("/report-hazard")
async def report_new_hazard(payload: ReportHazardRequest):
    """
    Submits a community reported road obstruction.
    """
    res = community_service.report_hazard(
        hazard_type=payload.hazard_type,
        latitude=payload.latitude,
        longitude=payload.longitude,
        reported_by=payload.reported_by,
        description=payload.description
    )
    if res.get("success"):
        return wrap_api_response(res.get("data"), "Hazard reported successfully.")
    else:
        raise HTTPException(status_code=400, detail=res.get("error", "Failed to register report."))

@router.get("/nearby-hazards")
async def get_nearby_community_hazards(
    latitude: float = Query(..., description="User latitude"),
    longitude: float = Query(..., description="User longitude"),
    radius: float = Query(500.0, description="Search radius in meters")
):
    """
    Retrieves reported hazards around GPS coordinates.
    """
    hazards = community_service.get_nearby_hazards(latitude, longitude, radius)
    return wrap_api_response(hazards, f"Found {len(hazards)} hazards nearby.")
