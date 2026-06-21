import 'package:flutter/foundation.dart';
import '../models/models.dart';

class SettingsViewModel extends ChangeNotifier {
  AppSettings _settings = AppSettings(
    language: AppLanguage.english,
    voiceProfile: VoiceProfile.nova,
    hapticIntensity: 0.80,
    screenReaderMode: false,
    voiceSpeed: 1.0,
    emergencyContacts: const [
      EmergencyContact(name: 'Rahul', phone: '+91 98765 43210', isPrimary: true),
      EmergencyContact(name: 'Priya', phone: '+91 91234 56789'),
      EmergencyContact(name: 'Amit', phone: '+91 80012 34567'),
    ],
  );

  AppSettings get settings => _settings;

  String get languageDisplayName {
    switch (_settings.language) {
      case AppLanguage.english:
        return 'ENGLISH (US)';
      case AppLanguage.hindi:
        return 'HINDI';
      case AppLanguage.hinglish:
        return 'HINGLISH';
    }
  }

  String get voiceDisplayName {
    switch (_settings.voiceProfile) {
      case VoiceProfile.nova:
        return 'NOVA (ALTO)';
      case VoiceProfile.aria:
        return 'ARIA (SOPRANO)';
      case VoiceProfile.echo:
        return 'ECHO (BASS)';
    }
  }

  String get hapticPercentage =>
      '${(_settings.hapticIntensity * 100).round()}%';

  String get contactCountLabel =>
      '${_settings.emergencyContacts.length} TRUSTED PEOPLE';

  void updateLanguage(AppLanguage lang) {
    _settings = _settings.copyWith(language: lang);
    notifyListeners();
  }

  void updateVoiceProfile(VoiceProfile profile) {
    _settings = _settings.copyWith(voiceProfile: profile);
    notifyListeners();
  }

  void updateHapticIntensity(double value) {
    _settings = _settings.copyWith(hapticIntensity: value);
    notifyListeners();
  }

  void toggleScreenReader(bool value) {
    _settings = _settings.copyWith(screenReaderMode: value);
    notifyListeners();
  }

  void updateVoiceSpeed(double value) {
    _settings = _settings.copyWith(voiceSpeed: value);
    notifyListeners();
  }
}
