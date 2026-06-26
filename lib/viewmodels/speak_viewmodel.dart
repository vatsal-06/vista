import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/backend_service.dart';

class SpeakViewModel extends ChangeNotifier {
  bool _isListening = false;
  bool _isSceneScanLoading = false;
  String _statusText = 'Listening...';
  String _statusSubtitle = 'Ask anything about your surroundings';

  final List<VoiceSuggestion> _suggestions = const [
    VoiceSuggestion(query: 'Nearby cafes?', iconType: 'food'),
    VoiceSuggestion(query: 'Any obstacles ahead?', iconType: 'warning'),
    VoiceSuggestion(query: 'What\'s around me?', iconType: 'direction'),
  ];

  bool get isListening => _isListening;
  bool get isSceneScanLoading => _isSceneScanLoading;
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
    _statusSubtitle = 'Speak now';
    notifyListeners();
  }

  Future<void> stopListening() async {
    _isListening = false;
    _statusText = 'Thinking...';
    notifyListeners();
    await askQuery('What is around me?');
  }

  void onSuggestionTap(VoiceSuggestion suggestion) {
    debugPrint('SpeakViewModel: Suggestion tapped — ${suggestion.query}');
    askQuery(suggestion.query);
  }

  Future<void> askQuery(String query) async {
    _isListening = false;
    _statusText = 'Thinking...';
    _statusSubtitle = 'Querying Saath Chalo AI...';
    notifyListeners();

    final response = await BackendService.instance.askAI(
      query,
      BackendService.instance.defaultUserId,
    );
    _statusText = 'AI RESPONSE';
    _statusSubtitle = response;
    notifyListeners();
  }

  Future<void> runSceneScan() async {
    _isSceneScanLoading = true;
    _statusText = 'SCANNING...';
    _statusSubtitle = 'Processing frame for hazard detection';
    notifyListeners();

    final announcement = await BackendService.instance.detectSceneWithSampleFrame();
    _isSceneScanLoading = false;

    if (announcement != null && announcement.isNotEmpty) {
      _statusText = 'SCENE RESULT';
      _statusSubtitle = announcement;
    } else {
      _statusText = 'SCENE RESULT';
      _statusSubtitle = 'No immediate hazards found in scan.';
    }
    notifyListeners();
  }
}
