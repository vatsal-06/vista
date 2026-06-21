import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  bool _isReady = true;
  String _statusText = 'READY';
  String _statusSubtitle = 'Standing by for your command';

  bool get isReady => _isReady;
  String get statusText => _statusText;
  String get statusSubtitle => _statusSubtitle;

  void startWalk() {
    // In real app: initialize camera, microphone, AI pipeline
    debugPrint('HomeViewModel: Starting walk mode');
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
