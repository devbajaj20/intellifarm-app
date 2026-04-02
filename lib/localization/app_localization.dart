import 'package:shared_preferences/shared_preferences.dart';

class AppStrings {
  static String _lang = 'en-IN';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString('app_language') ?? 'en-IN';
  }

  static String text(String key) {
    return _localizedValues[_lang]?[key]
        ?? _localizedValues['en-IN']![key]!;
  }
}

/// 🌍 ALL TRANSLATIONS HERE
final Map<String, Map<String, String>> _localizedValues = {
  'en-IN': {
    'welcome': 'Welcome to IntelliFarm',
    'crop_recommendation': 'Crop Recommendation',
    'disease_detection': 'Disease Detection',
    'yield_prediction': 'Yield Prediction',
    'fertilizer': 'Fertilizer Suggestion',
    'marketplace': 'Marketplace',
    'weather': 'Weather Advisory',
    'loans': 'Loans & Schemes',
    'ai_chatbot': 'AI Chatbot',
    'search_hint': 'Search features (Crop, Disease, Weather)',
  },

  'hi-IN': {
    'welcome': 'इंटेलीफार्म में आपका स्वागत है',
    'crop_recommendation': 'फसल सिफारिश',
    'disease_detection': 'रोग पहचान',
    'yield_prediction': 'उपज पूर्वानुमान',
    'fertilizer': 'उर्वरक सुझाव',
    'marketplace': 'बाज़ार',
    'weather': 'मौसम सलाह',
    'loans': 'ऋण और योजनाएँ',
    'ai_chatbot': 'एआई चैटबॉट',
    'search_hint': 'फसल, रोग, मौसम खोजें',
  },
};
