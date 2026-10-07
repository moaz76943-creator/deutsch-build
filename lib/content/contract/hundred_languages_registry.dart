// 100-Language Registry - Post-V1 Expansion
// Manages language records and readiness states without forcing production visibility

enum LanguageReadinessState {
  registered,
  specified,
  implemented,
  tested,
  verified,
  productionReady,
}

class LanguageRecord {
  final String id;
  final String bcpCode;
  final String nativeName;
  final LanguageReadinessState readinessState;

  const LanguageRecord({
    required this.id,
    required this.bcpCode,
    required this.nativeName,
    this.readinessState = LanguageReadinessState.registered,
  });
}

class HundredLanguagesRegistry {
  static final List<LanguageRecord> supportedLanguages = [
    const LanguageRecord(id: 'de', bcpCode: 'de-DE', nativeName: 'Deutsch', readinessState: LanguageReadinessState.productionReady),
    const LanguageRecord(id: 'ar', bcpCode: 'ar-SA', nativeName: 'العربية', readinessState: LanguageReadinessState.productionReady),
    const LanguageRecord(id: 'en', bcpCode: 'en-US', nativeName: 'English', readinessState: LanguageReadinessState.registered),
  ];

  static LanguageRecord? getLanguage(String id) {
    try {
      return supportedLanguages.firstWhere((lang) => lang.id == id);
    } catch (_) {
      return null;
    }
  }
}
