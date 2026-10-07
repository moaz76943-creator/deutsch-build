import 'language_registry.dart';

class LanguageState {
  final String activeLanguageCode;
  final List<LanguageRecord> supportedLanguages;

  const LanguageState({
    this.activeLanguageCode = 'de',
    this.supportedLanguages = const [],
  });

  LanguageState copyWith({
    String? activeLanguageCode,
    List<LanguageRecord>? supportedLanguages,
  }) {
    return LanguageState(
      activeLanguageCode: activeLanguageCode ?? this.activeLanguageCode,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
    );
  }
}
