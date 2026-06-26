import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/backend_service.dart';

class SOSViewModel extends ChangeNotifier {
  bool _isSOSActive = false;
  bool _isLocationSharing = true;
  final String _gpsStatus = 'STRONG';

  bool get isSOSActive => _isSOSActive;
  bool get isLocationSharing => _isLocationSharing;
  String get gpsStatus => _gpsStatus;

  final List<EmergencyContact> _contacts = const [
    EmergencyContact(name: 'Rahul', phone: '+91 98765 43210', isPrimary: true),
    EmergencyContact(name: 'Priya', phone: '+91 91234 56789'),
    EmergencyContact(name: 'Amit', phone: '+91 80012 34567'),
  ];

  List<EmergencyContact> get contacts => _contacts;

  EmergencyContact? get primaryContact {
    try {
      return _contacts.firstWhere((c) => c.isPrimary);
    } catch (_) {
      return _contacts.isNotEmpty ? _contacts.first : null;
    }
  }

  Future<void> triggerSOS() async {
    _isSOSActive = true;
    notifyListeners();
    debugPrint('SOSViewModel: SOS triggered — alerting contacts via backend');

    // Call backend API (Mock lat/lng for simulation)
    await BackendService.instance.triggerSOS(
      BackendService.instance.defaultUserId,
      BackendService.instance.defaultLatitude,
      BackendService.instance.defaultLongitude,
    );
  }

  void callPrimaryContact() {
    debugPrint('SOSViewModel: Calling ${primaryContact?.name}');
  }

  Future<void> shareLocation() async {
    _isLocationSharing = true;
    notifyListeners();
    debugPrint('SOSViewModel: Sharing live location via backend');

    await BackendService.instance.shareLocation(
      BackendService.instance.defaultUserId,
      BackendService.instance.defaultLatitude,
      BackendService.instance.defaultLongitude,
    );
  }

  void cancelSOS() {
    _isSOSActive = false;
    notifyListeners();
  }
}
