import 'package:flutter/foundation.dart';
import '../services/backend_service.dart';


class HomeViewModel extends ChangeNotifier {
  bool _isReady = true;
  String _statusText = 'READY';
  String _statusSubtitle = 'Standing by for your command';

  bool get isReady => _isReady;
  String get statusText => _statusText;
  String get statusSubtitle => _statusSubtitle;

  Future<void> startWalk() async {
    _statusText = 'CONNECTING';
    _statusSubtitle = 'Initializing AI navigation pipeline...';
    notifyListeners();
    
    // Trigger session creation on backend
    final sessionId = await BackendService.instance.startWalkSession('default_user_123');
    if (sessionId != null) {
      debugPrint('HomeViewModel: Active session started: $sessionId');
    }
  }

  void activateSpeakMode() {
    debugPrint('HomeViewModel: Activating speak/voice mode');
  }

  void activateSOS() {
    debugPrint('HomeViewModel: SOS activated');
  }

  void setReady() {
    _isReady = true;
    _statusText = 'READY';
    _statusSubtitle = 'Standing by for your command';
    notifyListeners();
  }
}
