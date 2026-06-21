import 'package:flutter/foundation.dart';
import '../models/models.dart';

class SpeakViewModel extends ChangeNotifier {
  bool _isListening = false;
  String _statusText = 'Listening...';
  final String _statusSubtitle = 'Ask anything about your surroundings';

  final List<VoiceSuggestion> _suggestions = const [
    VoiceSuggestion(query: 'Nearby cafes?', iconType: 'food'),
    VoiceSuggestion(query: 'Any obstacles ahead?', iconType: 'warning'),
  ];

  bool get isListening => _isListening;
  String get statusText => _statusText;
  String get statusSubtitle => _statusSubtitle;
  List<VoiceSuggestion> get suggestions => _suggestions;

  // Bottom nav state
  int _selectedNavIndex = 1; // Active tab selected by default
  int get selectedNavIndex => _selectedNavIndex;

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  void startListening() {
    _isListening = true;
    _statusText = 'Listening...';
    notifyListeners();
  }

  void stopListening() {
    _isListening = false;
    _statusText = 'Tap to speak';
    notifyListeners();
  }

  void onSuggestionTap(VoiceSuggestion suggestion) {
    debugPrint('SpeakViewModel: Suggestion tapped — ${suggestion.query}');
  }
}
