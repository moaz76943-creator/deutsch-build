import 'declarative_language_profile.dart';

/// Universal engine for parsing, caching, and serving declarative language specifications.
/// Scales linearly O(N) by reading lightweight language profiles dynamically.
class DeclarativeLanguageEngine {
  final Map<String, LanguageProfile> _registry = {};

  DeclarativeLanguageEngine();

  /// Curated default profiles for primary platform languages.
  static const List<LanguageProfile> defaultProfiles = [
    LanguageProfile(
      isoCode: 'de',
      autonym: 'Deutsch',
      englishName: 'German',
      scriptDirection: 'ltr',
      scriptFamily: 'Latin',
      typology: 'SVO', // Verb-second V2 / SOV in subordinate clauses
      morphologyType: 'Fusional',
      casesCount: 4,
      caseNames: ['Nominativ', 'Akkusativ', 'Dativ', 'Genitiv'],
      genders: ['m', 'f', 'n'],
      hasArticles: true,
      hasNounDeclension: true,
      hasVerbConjugation: true,
      hasDualNumber: false,
    ),
    LanguageProfile(
      isoCode: 'ar',
      autonym: 'العربية',
      englishName: 'Arabic',
      scriptDirection: 'rtl',
      scriptFamily: 'Arabic',
      typology: 'VSO',
      morphologyType: 'Fusional', // Root and pattern (Trilateral)
      casesCount: 3,
      caseNames: ['مرفوع', 'منصوب', 'مجرور'],
      genders: ['m', 'f'],
      hasArticles: true,
      hasNounDeclension: true,
      hasVerbConjugation: true,
      hasDualNumber: true,
    ),
    LanguageProfile(
      isoCode: 'en',
      autonym: 'English',
      englishName: 'English',
      scriptDirection: 'ltr',
      scriptFamily: 'Latin',
      typology: 'SVO',
      morphologyType: 'Fusional',
      casesCount: 0,
      caseNames: [],
      genders: ['none'],
      hasArticles: true,
      hasNounDeclension: false,
      hasVerbConjugation: true,
      hasDualNumber: false,
    ),
  ];

  /// Initializes engine with built-in or provided profiles.
  void initialize({List<LanguageProfile>? customProfiles}) {
    _registry.clear();
    final source = customProfiles ?? defaultProfiles;
    for (final p in source) {
      registerProfile(p);
    }
  }

  /// Registers or hot-swaps a declarative language profile.
  void registerProfile(LanguageProfile profile) {
    _registry[profile.isoCode.toLowerCase().trim()] = profile;
  }

  /// Retrieves language profile by ISO code.
  LanguageProfile? getProfile(String isoCode) {
    return _registry[isoCode.toLowerCase().trim()];
  }

  /// Total registered languages in this engine instance.
  int get registeredCount => _registry.length;

  /// Returns all registered ISO codes.
  List<String> get availableIsoCodes => _registry.keys.toList();
}
