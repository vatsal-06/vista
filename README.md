# Saath Chalo - Frontend Developer Integration Guide

Welcome to the **Saath Chalo** integration repository. This document outlines the API endpoints, real-time WebSocket communication protocols, and production guidelines for integrating the Flutter application with the FastAPI backend.

---

## 🚀 Running the Backend Locally

1. **Install Python 3.11+**
2. **Install Dependencies**:
   ```bash
   pip install -r backend/requirements.txt
   ```
3. **Launch the Server**:
   ```bash
   uvicorn backend.app.main:app --reload --host 0.0.0.0 --port 8000
   ```
   *The interactive API documentation will be available at: http://127.0.0.1:8000/docs*

---

## 📡 REST API Reference

All REST endpoints are prefixed with `/api`.

### 1. Walk Sessions (`/walk`)

#### Start Walk Session
* **Route**: `POST /api/walk/start`
* **Content-Type**: `application/json`
* **Request Payload**:
  ```json
  {
    "user_id": "string",
    "latitude": 12.9716,   // optional
    "longitude": 77.5946   // optional
  }
  ```
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Walk session started successfully.",
    "data": {
      "session_id": "d3b235bb-be68-40f6-9011-d7d9ec8893be",
      "started_at": "2026-06-22T10:00:00Z"
    }
  }
  ```

#### Stop Walk Session
* **Route**: `POST /api/walk/stop`
* **Content-Type**: `application/json`
* **Request Payload**:
  ```json
  {
    "session_id": "string",
    "distance": 0.35,      // in km
    "ended_at": "2026-06-22T10:20:00Z"
  }
  ```
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Walk session stopped.",
    "data": {
      "session_id": "d3b235bb-be68-40f6-9011-d7d9ec8893be",
      "ended_at": "2026-06-22T10:20:00Z"
    }
  }
  ```

#### Get Walk Session Status
* **Route**: `GET /api/walk/status/{session_id}`
* **Success Response (200 OK)**:
  ```json
  {
    "session_id": "d3b235bb-be68-40f6-9011-d7d9ec8893be",
    "user_id": "test_user_123",
    "started_at": "2026-06-22T10:00:00Z",
    "is_active": true,
    "distance_walked": 0.0,
    "hazards_logged": 0
  }
  ```

---

### 2. AI Voice Assistant (`/ai`)

#### Ask Voice Assistant
* **Route**: `POST /api/ai/ask`
* **Content-Type**: `application/json`
* **Request Payload**:
  ```json
  {
    "query": "What's around me?",
    "user_id": "default_user",
    "gps": { "lat": 12.9716, "lng": 77.5946 },
    "active_vision_context": [
      { "object": "pothole", "distance": 1.5, "direction": "center" }
    ]
  }
  ```
* **Success Response (200 OK)**:
  ```json
  {
    "query": "What's around me?",
    "response": "There is a pothole straight ahead, 1.5 meters away. Watch your step.",
    "voice_preference": "nova"
  }
  ```

#### Detect Objects in Image Frame (REST Fallback)
* **Route**: `POST /api/ai/detect`
* **Content-Type**: `multipart/form-data`
* **Payload**: Form-data with file field `frame` (image file bytes).
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Detections completed successfully.",
    "data": {
      "detections": [
        { "object": "pothole", "distance": 2.0, "direction": "center" }
      ],
      "alerts": [
        {
          "type": "hazard",
          "title": "POTHOLE\nAHEAD",
          "subtitle": "Pothole ahead, 2.0 meters away.",
          "distance": "2.0 Meters",
          "direction": "center",
          "priority": "HIGH",
          "speech_text": "Pothole ahead, 2.0 meters away."
        }
      ],
      "speech_announcement": "Pothole ahead, 2.0 meters away."
    }
  }
  ```

---

### 3. Personal AI Memory & Route History (`/memory`)

#### Retrieve Saved Routes
* **Route**: `GET /api/memory/routes?user_id={user_id}`
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Saved routes retrieved.",
    "data": [
      {
        "name": "Home to Tea Stall",
        "source": "Home",
        "destination": "Chai Shop",
        "frequency": 12,
        "last_used": "2026-06-21T18:30:00Z"
      }
    ]
  }
  ```

#### Retrieve Learned Landmarks
* **Route**: `GET /api/memory/landmarks?user_id={user_id}`
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Landmarks retrieved.",
    "data": [
      {
        "name": "Crossing near gate",
        "latitude": 12.9710,
        "longitude": 77.5935,
        "category": "crossing"
      }
    ]
  }
  ```

#### Retrieve Walk Session History
* **Route**: `GET /api/memory/history?user_id={user_id}`
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Walk history retrieved.",
    "data": [
      {
        "id": "session_id_xyz",
        "started_at": "2026-06-20T10:00:00Z",
        "ended_at": "2026-06-20T10:25:00Z",
        "distance": 1.1,
        "hazards_detected": [{ "type": "pothole" }]
      }
    ]
  }
  ```

---

### 4. Community Hazard Maps (`/community`)

#### Report Local Hazard
* **Route**: `POST /api/community/report-hazard`
* **Content-Type**: `application/json`
* **Request Payload**:
  ```json
  {
    "hazard_type": "open drain",
    "latitude": 12.9715,
    "longitude": 77.5942,
    "reported_by": "user_id_uuid",  // optional
    "description": "Uncovered drain next to bus stop shelter"  // optional
  }
  ```

#### Fetch Nearby Hazards
* **Route**: `GET /api/community/nearby-hazards?latitude={lat}&longitude={lng}&radius={meters}`
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Found 1 hazards nearby.",
    "data": [
      {
        "hazard_type": "open drain",
        "latitude": 12.9715,
        "longitude": 77.5942,
        "description": "Uncovered drain next to bus stop shelter",
        "distance": 15
      }
    ]
  }
  ```

---

### 5. Panic Emergencies (`/emergency`)

#### Trigger Emergency SOS
* **Route**: `POST /api/emergency/sos`
* **Content-Type**: `application/json`
* **Request Payload**:
  ```json
  {
    "user_id": "test_user_id",
    "latitude": 12.9716,
    "longitude": 77.5946
  }
  ```
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "timestamp": "2026-06-22T10:30:00Z",
    "notified_contacts": [
      {
        "contact_name": "Rahul",
        "phone": "+91 98765 43210",
        "sms_sent": true
      }
    ],
    "location": { "lat": 12.9716, "lng": 77.5946 }
  }
  ```

---

## ⚡ WebSocket Real-Time Channel

* **Endpoint**: `ws://<host>:<port>/ws/{session_id}`
* **Protocol Flow**: Keep the connection alive as long as "Active Walk Screen" is mounted.

### Inbound Packets (Flutter -> Backend)
1. **Camera Frames (Binary Stream)**: Send raw camera frame JPEG/PNG byte streams.
2. **GPS Updates (JSON)**: Send periodic user location packet.
   ```json
   {
     "type": "telemetry",
     "gps": { "lat": 12.9716, "lng": 77.5946 }
   }
   ```
3. **Simulation Heartbeat (JSON)**: To trigger mock hazard warnings from the backend during simulator runs:
   ```json
   {
     "type": "simulate_tick"
   }
   ```

### Outbound Packets (Backend -> Flutter)
Whenever hazards are detected or cleared, the backend pushes warnings:
* **Hazard Alert**:
  ```json
  {
    "type": "hazard",
    "title": "POTHOLE\nAHEAD",
    "subtitle": "Pothole ahead, 2.5 meters away.",
    "distance": "2.5 Meters",
    "direction": "center",
    "priority": "HIGH"  // "HIGH", "MEDIUM", "LOW"
  }
  ```
* **Path Cleared**:
  ```json
  {
    "type": "clear_path"
  }
  ```

---

## 🛡️ Production Level Integration Requirements

For a release-ready production app, follow these architectural constraints:

### 1. Telemetry Ingestion Throttling
* **Constraint**: Do NOT stream camera frames at 30fps. In mobile environments, this causes device overheating, battery drain, and server socket bottlenecking.
* **Production Policy**:
  * Limit frame transmission to **2 to 3 frames per second** (one frame every 330ms to 500ms).
  * Reduce camera resolution to **VGA (640x480)** or **QVGA (320x240)** before uploading. YOLOv8 works perfectly on low resolutions.

### 2. Audio & Haptic Patterns (Screen Reader Etiquette)
* **Screen Reader Interactions**:
  * Only immediately trigger text-to-speech (TTS) announcements for **HIGH** priority alerts.
  * For **MEDIUM** or **LOW** priority warnings, silently update the UI display card or read only on user inquiry to prevent cognitive overload.
* **Haptic Codes**:
  * **HIGH Priority**: Intense double pulse vibration.
  * **MEDIUM Priority**: Short single pulse vibration.
  * **LOW Priority / Clear Path**: No vibration.

### 3. Graceful Offline Handling
* Maintain a local storage queue of reported community hazards. If a user submits a report offline, save the GPS coordinates and details, and auto-sync when HTTP status reports a connection.
* If a WebSocket connection drops during a walk, immediately shift the UI to **Fallback Simulation Mode**, showing local GPS status and playing a chime: *"Connection lost. Operating on local cane sensor mode."*

### 4. Production Security
* **Network Protocol**: Upgrade raw HTTP and WebSocket endpoints to secure HTTPS and WSS protocols (`https://...` and `wss://...`).
* **Authorization**: Include an `Authorization: Bearer <Supabase_JWT_Token>` token in all API headers.

---

## 🛠️ Current Development Mode (Hardcoded & Simulation Fallbacks)

To allow offline testing and rapid frontend prototyping, the backend runs in a fully functional **Simulation Mode** if third-party credentials or hardware dependencies are missing:

| Component | Active Production Setup | Simulated Fallback State (Active by Default) |
|---|---|---|
| **Database** | Supabase REST Client | `MockSupabaseClient` writes and reads to in-memory dictionaries. |
| **Object Detection** | OpenCV + YOLOv8 (`ultralytics` model) | Automatically feeds random sequence of objects (cars, potholes, bikes) at 4s intervals. |
| **Audio Classification** | TensorFlow + YAMNet | Returns simulated sirens and emergency vehicle warning sounds at 8% probability. |
| **AI Text Queries** | Gemini API (`gemini-1.5-flash`) | Rule-based parser mapping keywords like "around", "obstacle", and "location" to static responses. |
| **SOS Notifications** | Twilio SMS API | Logs warning text messages to the FastAPI console. |
| **GPS Telemetry** | Active mobile location streams | Feeds a default latitude (`12.9716`) and longitude (`77.5946`) for nearby hazard lookups. |

---

## 🗺️ Project Blueprint & Remaining Milestones

### Phase 2: Audio & Navigation Tuning (High Priority)
* [ ] **Local Inference Weight Optimization**: Enable mobile-optimized TF Lite / ONNX runtimes for YOLOv8 and YAMNet to eliminate external latency.
* [ ] **Google Places / OSM Live Sync**: Integrate active mapping servers to retrieve precise pedestrian crosswalk directions.
* [ ] **Supabase Authentication**: Connect FastAPI security middlewares with Supabase user auth tables.

### Phase 3: Accessibility Maps & Community Reporting
* [ ] **Accessibility Rating & Heatmap**: Construct a geographical coordinate rating system calculating path safety indexes.
* [ ] **SMS Auto-Retry Queue**: Save outgoing Twilio alerts to local DB and dispatch immediately when cellular signal is recovered.

### Phase 4: Smart Hardware Extensions
* [ ] **Smart Cane BLE Link**: Listen for tactile pressure measurements and ultrasonic distance signals via Bluetooth Low Energy (BLE).
* [ ] **Audio Haptic Feedback Unit**: Synchronize collar haptic devices with high-priority backend warning packets.

---

## 🤝 Code of Conduct

We are committed to providing a welcoming, safe, and collaborative environment. All contributors and maintainers are expected to adhere to the following values:

1. **Be Respectful**: Treat everyone with respect and kindness. Focus on constructive feedback rather than criticism.
2. **Prioritize Accessibility**: Keep visually impaired accessibility at the core of all architectural decisions. Code should not prioritize aesthetic novelty over raw usability and safety.
3. **Collaboration & Open Communication**: Discuss changes in open issues. Ask clarifying questions rather than assuming intent.
4. **Safety & Security First**: Avoid merging incomplete emergency features (SOS / GPS routing) without rigorous simulated unit tests.

---

## 📝 Contributing Guidelines

1. **Feature Branches**: Never commit directly to `main`. Create descriptive branch names, e.g., `feat/vision-yolo` or `fix/sos-phone-format`.
2. **Strict Type Safety**: All Python code must include typing hints. All Dart viewmodels must use explicit models and handle API request exceptions gracefully.
3. **Unit Tests**: Ensure all REST controllers are mapped in `tests/test_api.py`. Verify that the manual runner script `python backend/tests/run.py` prints `STATUS: ALL TESTS PASSED SUCCESSFULLY!` before pushing.

