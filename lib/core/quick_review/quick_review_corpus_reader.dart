import '../../features/srs/corpus_sqlite_repository.dart';
import 'quick_review_models.dart';

abstract interface class QuickReviewCorpusReader {
  Future<List<QuickReviewCorpusItem>> fetchByIds(
    Iterable<String> contentIds,
  );
}

/// Lazy adapter over the admitted indexed SQLite corpus.
///
/// No query runs during construction. Each call is bounded to at most
/// [maxIdsPerQuery] content identifiers.
final class IndexedSrsQuickReviewCorpusReader
    implements QuickReviewCorpusReader {
  const IndexedSrsQuickReviewCorpusReader(this.repository);

  static const int maxIdsPerQuery = 20;
  static const int maxContentIdLength = 160;

  final IndexedSrsCorpusRepository repository;

  @override
  Future<List<QuickReviewCorpusItem>> fetchByIds(
    Iterable<String> contentIds,
  ) async {
    final normalized = <String>[];
    final seen = <String>{};

    for (final rawId in contentIds) {
      if (normalized.length >= maxIdsPerQuery) break;
      final id = rawId.trim();
      if (id.isEmpty ||
          id.length > maxContentIdLength ||
          !seen.add(id)) {
        continue;
      }
      normalized.add(id);
    }

    if (normalized.isEmpty) {
      return const <QuickReviewCorpusItem>[];
    }

    final rows = await repository.fetchByIds(normalized);
    return rows
        .map(
          (item) => QuickReviewCorpusItem(
            id: item.id,
            sourceText: item.german,
            translationText: item.arabic,
            exampleText: item.sentence,
            exampleTranslationText: item.sentenceAr,
            grammaticalMarker: item.article,
            pluralForm: item.plural,
            topic: item.topic,
            skill: item.skill,
            acceptedForms: item.accepted,
          ),
        )
        .toList(growable: false);
  }
}
