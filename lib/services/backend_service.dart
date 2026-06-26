import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class BackendService {
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'VISTA_API_BASE_URL',
    defaultValue: '',
  );
  static const String _userIdOverride = String.fromEnvironment(
    'VISTA_USER_ID',
    defaultValue: 'default_user_123',
  );
  static const String _authToken = String.fromEnvironment(
    'VISTA_AUTH_TOKEN',
    defaultValue: '',
  );
  static const String _latitudeOverride = String.fromEnvironment(
    'VISTA_DEFAULT_LATITUDE',
    defaultValue: '12.9716',
  );
  static const String _longitudeOverride = String.fromEnvironment(
    'VISTA_DEFAULT_LONGITUDE',
    defaultValue: '77.5946',
  );

  static final Uri _defaultApiBaseUri = _buildDefaultApiBaseUri();
  static final BackendService instance = BackendService._internal();

  static final Duration _timeout = const Duration(seconds: 15);

  BackendService._internal();

  String get defaultUserId => _userIdOverride;

  double get defaultLatitude => double.tryParse(_latitudeOverride) ?? 12.9716;

  double get defaultLongitude => double.tryParse(_longitudeOverride) ?? 77.5946;

  Uri get apiBaseUri => _configuredApiBaseUri ?? _defaultApiBaseUri;

  Uri get websocketUri {
    final apiUri = apiBaseUri;
    final websocketScheme = apiUri.scheme == 'https' ? 'wss' : 'ws';
    final apiPath = apiUri.path;
    final websocketPath = apiPath.endsWith('/api')
        ? '${apiPath.substring(0, apiPath.length - 4)}/ws'
        : (apiPath.isEmpty || apiPath == '/')
        ? '/ws'
        : (apiPath.endsWith('/') ? '${apiPath}ws' : '$apiPath/ws');
    return apiUri.replace(scheme: websocketScheme, path: websocketPath);
  }

  static Uri? get _configuredApiBaseUri {
    final value = _apiBaseUrlOverride.trim();
    if (value.isEmpty) {
      return null;
    }

    final parsed = Uri.parse(value);
    if (parsed.path.endsWith('/api')) {
      return parsed;
    }

    final path = parsed.path.isEmpty || parsed.path == '/'
        ? '/api'
        : (parsed.path.endsWith('/')
              ? '${parsed.path}api'
              : '${parsed.path}/api');
    return parsed.replace(path: path);
  }

  static Uri _buildDefaultApiBaseUri() {
    if (kIsWeb) {
      return Uri.parse('http://localhost:8000/api');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return Uri.parse('http://10.0.2.2:8000/api');
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return Uri.parse('http://127.0.0.1:8000/api');
      case TargetPlatform.fuchsia:
        return Uri.parse('http://127.0.0.1:8000/api');
    }
  }

  Map<String, String> get _jsonHeaders {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Uri _apiUri(String path) {
    final normalizedBase = apiBaseUri.toString().replaceAll(RegExp(r'/$'), '');
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$normalizedBase/$normalizedPath');
  }

  static final Uint8List _sampleFrameBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO8YkX4AAAAASUVORK5CYII=',
  );

  Future<Map<String, dynamic>?> _postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(_apiUri(path), headers: _jsonHeaders, body: jsonEncode(body))
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
    } catch (e) {
      debugPrint('BackendService: POST $path error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _getJson(String path) async {
    try {
      final response = await http
          .get(_apiUri(path), headers: _jsonHeaders)
          .timeout(_timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
    } catch (e) {
      debugPrint('BackendService: GET $path error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _postMultipart(
    String path, {
    required String fieldName,
    required Uint8List bytes,
    String filename = 'frame.png',
  }) async {
    try {
      final request = http.MultipartRequest('POST', _apiUri(path));
      request.headers.addAll(_jsonHeaders..remove('Content-Type'));
      request.files.add(http.MultipartFile.fromBytes(fieldName, bytes, filename: filename));

      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed).timeout(_timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
    } catch (e) {
      debugPrint('BackendService: multipart POST $path error: $e');
    }
    return null;
  }

  // ── WALK SESSIONS ──────────────────────────────────────────────────────────
  Future<String?> startWalkSession(String userId) async {
    final body = await _postJson('/walk/start', {
      'user_id': userId,
      'latitude': defaultLatitude,
      'longitude': defaultLongitude,
    });
    if (body != null && body['success'] == true) {
      return body['data']?['session_id'] as String?;
    }
    return null;
  }

  Future<void> stopWalkSession(String sessionId, double distance) async {
    await _postJson('/walk/stop', {
      'session_id': sessionId,
      'distance': distance,
      'ended_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getWalkStatus(String sessionId) async {
    final body = await _getJson('/walk/status/$sessionId');
    if (body != null) {
      return body;
    }
    return null;
  }

  // ── WEBSOCKET PIPELINE ──────────────────────────────────────────────────────
  WebSocketChannel connectToWalkStream(String sessionId) {
    debugPrint(
      'BackendService: Connecting walk stream WebSocket for session: $sessionId',
    );
    return WebSocketChannel.connect(
      Uri.parse(
        '${websocketUri.toString().replaceAll(RegExp(r'/$'), '')}/$sessionId',
      ),
    );
  }

  // ── VOICE ASSISTANT (AI) ────────────────────────────────────────────────────
  Future<String> askAI(
    String query,
    String userId, {
    List<Map<String, dynamic>>? activeContext,
  }) async {
    final body = await _postJson('/ai/ask', {
      'query': query,
      'user_id': userId,
      'gps': {'lat': defaultLatitude, 'lng': defaultLongitude},
      'active_vision_context': activeContext,
    });
    if (body != null) {
      final response = body['response'];
      if (response is String && response.isNotEmpty) {
        return response;
      }
    }
    return "I'm having trouble connecting to the network right now. Please verify your connection.";
  }

  Future<String?> detectSceneWithSampleFrame() async {
    final body = await _postMultipart(
      '/ai/detect',
      fieldName: 'frame',
      bytes: _sampleFrameBytes,
    );
    final message = body?['data']?['speech_announcement'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
    return null;
  }

  // ── EMERGENCY ACTIONS ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> triggerSOS(
    String userId,
    double lat,
    double lng,
  ) async {
    final body = await _postJson('/emergency/sos', {
      'user_id': userId,
      'latitude': lat,
      'longitude': lng,
    });
    if (body != null) {
      return body;
    }
    return null;
  }

  Future<void> shareLocation(String userId, double lat, double lng) async {
    await _postJson('/emergency/share-location', {
      'user_id': userId,
      'latitude': lat,
      'longitude': lng,
      'is_active': true,
    });
  }

  // ── MEMORIES & HISTORY ──────────────────────────────────────────────────────
  Future<List<dynamic>> getSavedRoutes(String userId) async {
    final body = await _getJson('/memory/routes?user_id=$userId');
    final data = body?['data'];
    if (data is List) {
      return data;
    }
    return [];
  }

  Future<List<dynamic>> getLandmarks(String userId) async {
    final body = await _getJson('/memory/landmarks?user_id=$userId');
    final data = body?['data'];
    if (data is List) {
      return data;
    }
    return [];
  }

  Future<List<dynamic>> getWalkHistory(String userId) async {
    final body = await _getJson('/memory/history?user_id=$userId');
    final data = body?['data'];
    if (data is List) {
      return data;
    }
    return [];
  }

  // ── COMMUNITY MAP ──────────────────────────────────────────────────────────
  Future<List<dynamic>> getNearbyCommunityHazards(
    double lat,
    double lng,
    {double radius = 500.0,}
  ) async {
    final body = await _getJson(
      '/community/nearby-hazards?latitude=$lat&longitude=$lng&radius=$radius',
    );
    final data = body?['data'];
    if (data is List) {
      return data;
    }
    return [];
  }

  Future<bool> reportCommunityHazard({
    required String hazardType,
    required double latitude,
    required double longitude,
    String? description,
  }) async {
    final body = await _postJson('/community/report-hazard', {
      'hazard_type': hazardType,
      'latitude': latitude,
      'longitude': longitude,
      'reported_by': defaultUserId,
      'description': description,
    });
    return body?['success'] == true;
  }
}
