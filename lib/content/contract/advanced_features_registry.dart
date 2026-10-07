// Advanced Features Registry - Post-V1 Expansion
// Manages conditional feature availability per language pack

class AdvancedFeaturesRegistry {
  static final Map<String, List<String>> _featureMap = {
    'de': ['srs', 'offline_tts', 'grammar_analysis'],
    'ar': ['srs', 'offline_tts', 'dialect_support'],
  };

  static bool isFeatureSupported(String languageCode, String featureName) {
    final features = _featureMap[languageCode];
    if (features == null) return false;
    return features.contains(featureName);
  }
}
