import 'package:flutter/foundation.dart';
import '../models/models.dart';

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

  void triggerSOS() {
    _isSOSActive = true;
    notifyListeners();
    debugPrint('SOSViewModel: SOS triggered — alerting contacts');
  }

  void callPrimaryContact() {
    debugPrint('SOSViewModel: Calling ${primaryContact?.name}');
  }

  void shareLocation() {
    _isLocationSharing = true;
    notifyListeners();
    debugPrint('SOSViewModel: Sharing live location');
  }

  void cancelSOS() {
    _isSOSActive = false;
    notifyListeners();
  }
}
