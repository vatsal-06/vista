// ─── Alert Model ───────────────────────────────────────────────────────────────
enum AlertPriority { low, medium, high }

class WalkAlert {
  final String title;
  final String? subtitle;
  final String? distance;
  final AlertPriority priority;
  final DateTime timestamp;

  const WalkAlert({
    required this.title,
    this.subtitle,
    this.distance,
    required this.priority,
    required this.timestamp,
  });
}

// ─── Route Model ───────────────────────────────────────────────────────────────
class SavedRoute {
  final String name;
  final int walkCount;
  final int landmarkCount;
  final String lastUsed;

  const SavedRoute({
    required this.name,
    required this.walkCount,
    required this.landmarkCount,
    required this.lastUsed,
  });
}

// ─── Emergency Contact Model ────────────────────────────────────────────────────
class EmergencyContact {
  final String name;
  final String phone;
  final bool isPrimary;

  const EmergencyContact({
    required this.name,
    required this.phone,
    this.isPrimary = false,
  });
}

// ─── Settings Model ─────────────────────────────────────────────────────────────
enum AppLanguage { english, hindi, hinglish }

enum VoiceProfile { nova, aria, echo }

class AppSettings {
  final AppLanguage language;
  final VoiceProfile voiceProfile;
  final double hapticIntensity;
  final List<EmergencyContact> emergencyContacts;
  final bool screenReaderMode;
  final double voiceSpeed;

  const AppSettings({
    this.language = AppLanguage.english,
    this.voiceProfile = VoiceProfile.nova,
    this.hapticIntensity = 0.8,
    this.emergencyContacts = const [],
    this.screenReaderMode = false,
    this.voiceSpeed = 1.0,
  });

  AppSettings copyWith({
    AppLanguage? language,
    VoiceProfile? voiceProfile,
    double? hapticIntensity,
    List<EmergencyContact>? emergencyContacts,
    bool? screenReaderMode,
    double? voiceSpeed,
  }) {
    return AppSettings(
      language: language ?? this.language,
      voiceProfile: voiceProfile ?? this.voiceProfile,
      hapticIntensity: hapticIntensity ?? this.hapticIntensity,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      screenReaderMode: screenReaderMode ?? this.screenReaderMode,
      voiceSpeed: voiceSpeed ?? this.voiceSpeed,
    );
  }
}

// ─── Speak/Voice Suggestion Model ──────────────────────────────────────────────
class VoiceSuggestion {
  final String query;
  final String iconType; // 'food', 'warning', 'direction', 'info'

  const VoiceSuggestion({required this.query, required this.iconType});
}
