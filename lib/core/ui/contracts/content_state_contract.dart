enum ContentState { loading, ready, empty, degraded, corrupted, failed }

abstract class OptionalContentContract {
  String get semanticLabel;
  String? get bcp47LanguageCode;
  String get fallbackText;
}
