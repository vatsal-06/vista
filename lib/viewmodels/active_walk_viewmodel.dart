import 'package:flutter/foundation.dart';
import '../models/models.dart';

class ActiveWalkViewModel extends ChangeNotifier {
  bool _isActive = true;
  WalkAlert? _currentAlert;
  final String _stayInstruction = 'STAY CENTERED';

  bool get isActive => _isActive;
  WalkAlert? get currentAlert => _currentAlert;
  String get stayInstruction => _stayInstruction;

  ActiveWalkViewModel() {
    _loadMockAlert();
  }

  void _loadMockAlert() {
    // Hardcoded mock alert matching wireframe exactly
    _currentAlert = WalkAlert(
      title: 'POTHOLE\nAHEAD',
      distance: '5 Meters',
      priority: AlertPriority.high,
      timestamp: DateTime.now(),
    );
  }

  void stopWalk() {
    _isActive = false;
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
