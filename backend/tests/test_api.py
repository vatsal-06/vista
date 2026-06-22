import os
import sys

# Ensure the backend directory is in the path for imports
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["status"] == "online"

def test_walk_workflow():
    # Start session
    start_payload = {
        "user_id": "test_user_456",
        "latitude": 12.9716,
        "longitude": 77.5946
    }
    response = client.post("/api/walk/start", json=start_payload)
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    session_id = data["data"]["session_id"]
    assert session_id is not None
    
    # Status check
    response = client.get(f"/api/walk/status/{session_id}")
    assert response.status_code == 200
    assert response.json()["session_id"] == session_id
    
    # Stop session
    stop_payload = {
        "session_id": session_id,
        "distance": 0.35
    }
    response = client.post("/api/walk/stop", json=stop_payload)
    assert response.status_code == 200
    assert response.json()["success"] is True

def test_ai_ask():
    ask_payload = {
        "query": "Is there any obstacle around?",
        "user_id": "test_user",
        "gps": {"lat": 12.9716, "lng": 77.5946},
        "active_vision_context": [
            {"object": "pothole", "distance": 1.5, "direction": "center"}
        ]
    }
    response = client.post("/api/ai/ask", json=ask_payload)
    assert response.status_code == 200
    data = response.json()
    assert data["query"] == ask_payload["query"]
    assert len(data["response"]) > 0

def test_emergency_sos():
    sos_payload = {
        "user_id": "test_user_999",
        "latitude": 12.9716,
        "longitude": 77.5946
    }
    response = client.post("/api/emergency/sos", json=sos_payload)
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert len(data["notified_contacts"]) > 0
    assert data["location"]["lat"] == 12.9716
