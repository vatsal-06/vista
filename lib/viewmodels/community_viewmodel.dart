import 'package:flutter/foundation.dart';

import '../services/backend_service.dart';

class CommunityViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isReporting = false;
  String? _statusMessage;

  List<dynamic> _nearbyHazards = [];

  bool get isLoading => _isLoading;
  bool get isReporting => _isReporting;
  String? get statusMessage => _statusMessage;
  List<dynamic> get nearbyHazards => _nearbyHazards;

  Future<void> loadNearbyHazards() async {
    _isLoading = true;
    _statusMessage = null;
    notifyListeners();

    final hazards = await BackendService.instance.getNearbyCommunityHazards(
      BackendService.instance.defaultLatitude,
      BackendService.instance.defaultLongitude,
    );

    _nearbyHazards = hazards;
    _isLoading = false;
    if (hazards.isEmpty) {
      _statusMessage = 'No hazards reported nearby yet.';
    }
    notifyListeners();
  }

  Future<void> reportHazard({
    required String hazardType,
    required String description,
  }) async {
    _isReporting = true;
    _statusMessage = null;
    notifyListeners();

    final success = await BackendService.instance.reportCommunityHazard(
      hazardType: hazardType,
      latitude: BackendService.instance.defaultLatitude,
      longitude: BackendService.instance.defaultLongitude,
      description: description.trim().isEmpty ? null : description.trim(),
    );

    _isReporting = false;
    if (!success) {
      _statusMessage = 'Hazard report failed. Please try again.';
      notifyListeners();
      return;
    }

    _statusMessage = 'Hazard reported. Thank you for helping the community.';
    await loadNearbyHazards();
  }
}
