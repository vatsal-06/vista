import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class BackendService {
  // Use 10.0.2.2 for Android emulator to hit localhost of development machine,
  // fallback to localhost for web/iOS/desktop testing.
  static const String _host = kIsWeb ? 'localhost:8000' : '10.0.2.2:8000';
  static const String baseUrl = 'http://$_host/api';
  static const String wsUrl = 'ws://$_host/ws';

  static final BackendService instance = BackendService._internal();
  BackendService._internal();

  // ── WALK SESSIONS ──────────────────────────────────────────────────────────
  Future<String?> startWalkSession(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/walk/start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'latitude': 12.9716, // Default location for setup/simulation
          'longitude': 77.5946,
        }),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return body['data']['session_id'] as String;
        }
      }
    } catch (e) {
      debugPrint('BackendService: startWalkSession error: $e');
    }
    return null;
  }

  Future<void> stopWalkSession(String sessionId, double distance) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/walk/stop'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'session_id': sessionId,
          'distance': distance,
          'ended_at': DateTime.now().toUtc().toIso8601String(),
        }),
      );
    } catch (e) {
      debugPrint('BackendService: stopWalkSession error: $e');
    }
  }

  // ── WEBSOCKET PIPELINE ──────────────────────────────────────────────────────
  WebSocketChannel connectToWalkStream(String sessionId) {
    debugPrint('BackendService: Connecting walk stream WebSocket for session: $sessionId');
    return WebSocketChannel.connect(Uri.parse('$wsUrl/$sessionId'));
  }

  // ── VOICE ASSISTANT (AI) ────────────────────────────────────────────────────
  Future<String> askAI(String query, String userId, {List<Map<String, dynamic>>? activeContext}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/ask'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': query,
          'user_id': userId,
          'gps': {'lat': 12.9716, 'lng': 77.5946},
          'active_vision_context': activeContext,
        }),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['response'] as String;
      }
    } catch (e) {
      debugPrint('BackendService: askAI error: $e');
    }
    return "I'm having trouble connecting to the network right now. Please verify your connection.";
  }

  // ── EMERGENCY ACTIONS ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> triggerSOS(String userId, double lat, double lng) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/emergency/sos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'latitude': lat,
          'longitude': lng,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('BackendService: triggerSOS error: $e');
    }
    return null;
  }

  Future<void> shareLocation(String userId, double lat, double lng) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/emergency/share-location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'latitude': lat,
          'longitude': lng,
          'is_active': true,
        }),
      );
    } catch (e) {
      debugPrint('BackendService: shareLocation error: $e');
    }
  }

  // ── MEMORIES & HISTORY ──────────────────────────────────────────────────────
  Future<List<dynamic>> getSavedRoutes(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/memory/routes?user_id=$userId'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] as List<dynamic>;
      }
    } catch (e) {
      debugPrint('BackendService: getSavedRoutes error: $e');
    }
    return [];
  }

  Future<List<dynamic>> getLandmarks(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/memory/landmarks?user_id=$userId'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] as List<dynamic>;
      }
    } catch (e) {
      debugPrint('BackendService: getLandmarks error: $e');
    }
    return [];
  }

  Future<List<dynamic>> getWalkHistory(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/memory/history?user_id=$userId'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] as List<dynamic>;
      }
    } catch (e) {
      debugPrint('BackendService: getWalkHistory error: $e');
    }
    return [];
  }

  // ── COMMUNITY MAP ──────────────────────────────────────────────────────────
  Future<List<dynamic>> getNearbyCommunityHazards(double lat, double lng) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/community/nearby-hazards?latitude=$lat&longitude=$lng'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] as List<dynamic>;
      }
    } catch (e) {
      debugPrint('BackendService: getNearbyCommunityHazards error: $e');
    }
    return [];
  }
}
