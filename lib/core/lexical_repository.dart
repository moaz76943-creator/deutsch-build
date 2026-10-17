// ignore_for_file: unused_import
import 'language_bidi_helper.dart';

/// نموذج المفردة اللغوية الكاملة
class LexicalEntry {
  final String id;
  final String domainId;
  final String sourceLocale;
  final String targetLocale;
  final String targetTerm;
  final String sourceMeaning;
  final String targetExample;
  final String sourceExampleTranslation;
  final String partOfSpeech;

  const LexicalEntry({
    required this.id,
    required this.domainId,
    required this.sourceLocale,
    required this.targetLocale,
    required this.targetTerm,
    required this.sourceMeaning,
    required this.targetExample,
    required this.sourceExampleTranslation,
    required this.partOfSpeech,
  });
}

/// مستودع إدارة واسترجاع المفردات محلياً بدون إنترنت
class LexicalRepository {
  static final List<LexicalEntry> _inMemoryStore = [];

  static void initializeStore(List<LexicalEntry> initialEntries) {
    _inMemoryStore.clear();
    for (final entry in initialEntries) {
      if (LanguageBiDiHelper.isLanguageAllowed(entry.targetLocale) &&
          LanguageBiDiHelper.isLanguageAllowed(entry.sourceLocale)) {
        _inMemoryStore.add(entry);
      }
    }
  }

  static List<LexicalEntry> getEntriesByDomain(String domainId) {
    return _inMemoryStore.where((e) => e.domainId == domainId).toList();
  }

  static List<LexicalEntry> getEntriesForPair({
    required String sourceLocale,
    required String targetLocale,
  }) {
    return _inMemoryStore
        .where((e) =>
            e.sourceLocale == sourceLocale && e.targetLocale == targetLocale)
        .toList();
  }
}
