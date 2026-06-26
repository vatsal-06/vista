import 'package:flutter/foundation.dart';

import '../services/backend_service.dart';

class RoutesViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isStatusLoading = false;
  String? _errorMessage;

  List<dynamic> _savedRoutes = [];
  List<dynamic> _landmarks = [];
  List<dynamic> _walkHistory = [];
  Map<String, dynamic>? _walkStatus;

  bool get isLoading => _isLoading;
  bool get isStatusLoading => _isStatusLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get savedRoutes => _savedRoutes;
  List<dynamic> get landmarks => _landmarks;
  List<dynamic> get walkHistory => _walkHistory;
  Map<String, dynamic>? get walkStatus => _walkStatus;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = BackendService.instance.defaultUserId;
      final results = await Future.wait([
        BackendService.instance.getSavedRoutes(userId),
        BackendService.instance.getLandmarks(userId),
        BackendService.instance.getWalkHistory(userId),
      ]);

      _savedRoutes = results[0];
      _landmarks = results[1];
      _walkHistory = results[2];
    } catch (_) {
      _errorMessage = 'Unable to load route intelligence right now.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWalkStatus(String sessionId) async {
    if (sessionId.trim().isEmpty) {
      _errorMessage = 'Please enter a valid session ID.';
      notifyListeners();
      return;
    }

    _isStatusLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await BackendService.instance.getWalkStatus(sessionId.trim());
    _isStatusLoading = false;

    if (response == null) {
      _errorMessage = 'No status found for this session.';
      notifyListeners();
      return;
    }

    _walkStatus = response;
    notifyListeners();
  }
}
