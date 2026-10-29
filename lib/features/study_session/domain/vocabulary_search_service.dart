import 'models.dart';

class VocabularySearchService {
  const VocabularySearchService();

  String _normalizeText(String value) {
    return value
        .toLowerCase()
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ß', 'ss')
        .replaceAll(RegExp(r'[.!?,;:،؛؟]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<Flashcard> search(List<Flashcard> items, String query) {
    if (query.trim().isEmpty) {
      return items;
    }

    final normalizedQuery = _normalizeText(query);

    return items.where((card) {
      final normalizedConceptId = _normalizeText(card.conceptId);
      final normalizedGerman = _normalizeText(card.german);
      final normalizedArabic = _normalizeText(card.arabic);

      return normalizedConceptId.contains(normalizedQuery) ||
          normalizedGerman.contains(normalizedQuery) ||
          normalizedArabic.contains(normalizedQuery);
    }).toList();
  }
}
