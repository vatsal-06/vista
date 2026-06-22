import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/models.dart';
import '../services/backend_service.dart';

class ActiveWalkViewModel extends ChangeNotifier {
  bool _isActive = true;
  WalkAlert? _currentAlert;
  String _stayInstruction = 'STAY CENTERED';
  
  String? _sessionId;
  WebSocketChannel? _wsChannel;
  StreamSubscription? _wsSubscription;
  Timer? _simTimer;
  double _distanceWalked = 0.0;

  bool get isActive => _isActive;
  WalkAlert? get currentAlert => _currentAlert;
  String get stayInstruction => _stayInstruction;

  ActiveWalkViewModel() {
    _initSessionAndWs();
  }

  Future<void> _initSessionAndWs() async {
    // 1. Create a session ID
    _sessionId = await BackendService.instance.startWalkSession('default_user_123');
    if (_sessionId == null || !_isActive) return;

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
        if (_isActive && _wsChannel != null) {
          _distanceWalked += 0.01; // simulate distance accumulation
          _wsChannel!.sink.add(jsonEncode({'type': 'simulate_tick'}));
        }
      });
    } catch (e) {
      debugPrint('ActiveWalkViewModel: WebSocket init error: $e');
      _loadFallbackMockAlert();
    }
  }

  void _handleWsMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      if (data['type'] == 'hazard') {
        final title = data['title'] as String? ?? 'OBSTACLE';
        final subtitle = data['subtitle'] as String?;
        final distance = data['distance'] as String?;
        final priorityStr = data['priority'] as String? ?? 'low';
        
        AlertPriority priority;
        if (priorityStr.toLowerCase() == 'high') {
          priority = AlertPriority.high;
          _stayInstruction = 'STEP RIGHT'; // Dynamic alert direction instruction
        } else if (priorityStr.toLowerCase() == 'medium') {
          priority = AlertPriority.medium;
          _stayInstruction = 'WATCH STEP';
        } else {
          priority = AlertPriority.low;
          _stayInstruction = 'STAY CENTERED';
        }

        _currentAlert = WalkAlert(
          title: title,
          subtitle: subtitle,
          distance: distance,
          priority: priority,
          timestamp: DateTime.now(),
        );
        notifyListeners();
      } else if (data['type'] == 'clear_path') {
        _currentAlert = null;
        _stayInstruction = 'STAY CENTERED';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('ActiveWalkViewModel: Failed parsing WS message: $e');
    }
  }

  void _loadFallbackMockAlert() {
    _currentAlert = WalkAlert(
      title: 'POTHOLE\nAHEAD',
      distance: '5 Meters',
      priority: AlertPriority.high,
      timestamp: DateTime.now(),
    );
    notifyListeners();
  }

  void stopWalk() {
    _isActive = false;
    _simTimer?.cancel();
    _wsSubscription?.cancel();
    _wsChannel?.sink.close();
    
    if (_sessionId != null) {
      BackendService.instance.stopWalkSession(_sessionId!, _distanceWalked);
    }
    
    notifyListeners();
  }

  void onSpeakToAI() {
    debugPrint('ActiveWalkViewModel: Opening speak-to-AI overlay');
  }

  void dismissAlert() {
    _currentAlert = null;
    notifyListeners();
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
