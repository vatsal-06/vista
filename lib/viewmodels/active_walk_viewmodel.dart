import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/models.dart';
import '../services/backend_service.dart';

class ActiveWalkViewModel extends ChangeNotifier {
  bool _isActive = true;
  bool _isDisposed = false;
  WalkAlert? _currentAlert;
  String _stayInstruction = 'STAY CENTERED';
  String _currentDirection = 'center';

  String? _sessionId;
  WebSocketChannel? _wsChannel;
  StreamSubscription? _wsSubscription;
  Timer? _simTimer;
  double _distanceWalked = 0.0;
  double _serverDistanceWalked = 0.0;
  int _serverHazardsLogged = 0;

  bool get isActive => _isActive;
  WalkAlert? get currentAlert => _currentAlert;
  String get stayInstruction => _stayInstruction;
  String get currentDirection => _currentDirection;
  String? get sessionId => _sessionId;
  double get serverDistanceWalked => _serverDistanceWalked;
  int get serverHazardsLogged => _serverHazardsLogged;

  ActiveWalkViewModel() {
    _initSessionAndWs();
  }

  Future<void> _initSessionAndWs() async {
    if (_isDisposed) {
      return;
    }

    // 1. Create a session ID
    _sessionId = await BackendService.instance.startWalkSession(
      BackendService.instance.defaultUserId,
    );
    if (_sessionId == null || !_isActive || _isDisposed) return;

    await refreshWalkStatus();
    if (_isDisposed) {
      return;
    }

    // 2. Connect WebSocket
    try {
      _wsChannel = BackendService.instance.connectToWalkStream(_sessionId!);
      _wsSubscription = _wsChannel!.stream.listen(
        (message) {
          _handleWsMessage(message);
        },
        onError: (err) {
          debugPrint('ActiveWalkViewModel: WebSocket error: $err');
          _loadFallbackMockAlert();
        },
        onDone: () {
          debugPrint('ActiveWalkViewModel: WebSocket closed');
        },
      );

      // 3. Start a simulation timer sending ticks to backend to feed us obstacles
      _simTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_isActive && !_isDisposed && _wsChannel != null) {
          _distanceWalked += 0.01; // simulate distance accumulation
          _wsChannel!.sink.add(jsonEncode({'type': 'simulate_tick'}));
          if (timer.tick % 2 == 0) {
            refreshWalkStatus();
          }
        }
      });
    } catch (e) {
      debugPrint('ActiveWalkViewModel: WebSocket init error: $e');
      _loadFallbackMockAlert();
    }
  }

  void _handleWsMessage(dynamic message) {
    if (_isDisposed) {
      return;
    }

    try {
      final data = jsonDecode(message as String);
      if (data['type'] == 'hazard') {
        final title = data['title'] as String? ?? 'OBSTACLE';
        final subtitle = data['subtitle'] as String?;
        final distance = data['distance'] as String?;
        final priorityStr = data['priority'] as String? ?? 'low';
        final direction = (data['direction'] as String? ?? 'center').toLowerCase();

        AlertPriority priority;
        if (priorityStr.toLowerCase() == 'high') {
          priority = AlertPriority.high;
          _stayInstruction =
              'STEP RIGHT'; // Dynamic alert direction instruction
        } else if (priorityStr.toLowerCase() == 'medium') {
          priority = AlertPriority.medium;
          _stayInstruction = 'WATCH STEP';
        } else {
          priority = AlertPriority.low;
          _stayInstruction = 'STAY CENTERED';
        }

        _currentDirection = _normalizeDirection(direction);

        _currentAlert = WalkAlert(
          title: title,
          subtitle: subtitle,
          distance: distance,
          priority: priority,
          timestamp: DateTime.now(),
        );
        _notifyIfActive();
      } else if (data['type'] == 'clear_path') {
        _currentAlert = null;
        _stayInstruction = 'STAY CENTERED';
        _currentDirection = 'center';
        _notifyIfActive();
      }
    } catch (e) {
      debugPrint('ActiveWalkViewModel: Failed parsing WS message: $e');
    }
  }

  void _loadFallbackMockAlert() {
    if (_isDisposed) {
      return;
    }

    _currentAlert = WalkAlert(
      title: 'POTHOLE\nAHEAD',
      distance: '5 Meters',
      priority: AlertPriority.high,
      timestamp: DateTime.now(),
    );
    _notifyIfActive();
  }

  void stopWalk() {
    _isActive = false;
    _simTimer?.cancel();
    _wsSubscription?.cancel();
    _wsChannel?.sink.close();

    if (_sessionId != null) {
      BackendService.instance.stopWalkSession(_sessionId!, _distanceWalked);
    }

    _notifyIfActive();
  }

  Future<void> refreshWalkStatus() async {
    if (_sessionId == null || _isDisposed) {
      return;
    }

    final status = await BackendService.instance.getWalkStatus(_sessionId!);
    if (status != null && !_isDisposed) {
      final distance = status['distance_walked'];
      final hazards = status['hazards_logged'];

      if (distance is num) {
        _serverDistanceWalked = distance.toDouble();
      }
      if (hazards is num) {
        _serverHazardsLogged = hazards.toInt();
      }
      _notifyIfActive();
    }
  }

  void _notifyIfActive() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  String _normalizeDirection(String direction) {
    switch (direction) {
      case 'left':
      case 'right':
      case 'center':
        return direction;
      default:
        return 'center';
    }
  }

  void onSpeakToAI() {
    debugPrint('ActiveWalkViewModel: Opening speak-to-AI overlay');
  }

  void dismissAlert() {
    _currentAlert = null;
    _notifyIfActive();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isActive = false;
    _simTimer?.cancel();
    _wsSubscription?.cancel();
    _wsChannel?.sink.close();
    super.dispose();
  }

  String get alertPriorityLabel {
    switch (_currentAlert?.priority) {
      case AlertPriority.high:
        return 'HIGH PRIORITY';
      case AlertPriority.medium:
        return 'MEDIUM PRIORITY';
      case AlertPriority.low:
        return 'LOW PRIORITY';
      default:
        return '';
    }
  }
}
