import '../../srs/corpus_sqlite_repository.dart';
import '../domain/german_search_normalizer.dart';
import '../domain/lexicon_models.dart';
import '../domain/lexicon_repositories.dart';

/// Lexicon projection over the admitted indexed SQLite corpus.
///
/// CEFR, article, German text and Arabic meaning all come from the same
/// [IndexedSrsCorpusRepository]. No secondary CEFR resolver or legacy
/// in-memory search graph participates in this runtime path.
final class OfflineLexiconSearchRepository implements LexiconSearchRepository {
  const OfflineLexiconSearchRepository({
    required IndexedSrsCorpusRepository corpusRepository,
  }) : _corpusRepository = corpusRepository;

  final IndexedSrsCorpusRepository _corpusRepository;

  @override
  Future<SearchResultItem?> byId(String wordId) async {
    final id = wordId.trim();
    if (id.isEmpty) return null;
    final rows = await _corpusRepository.fetchByIds(<String>[id]);
    return rows.isEmpty ? null : _map(rows.single);
  }

  @override
  Future<List<SearchResultItem>> search(LexiconSearchQuery query) async {
    final requestedLevels = query.filters.cefrLevels
        .map((value) => value.trim().toUpperCase())
        .where((value) => value.isNotEmpty)
        .toSet();
    if (requestedLevels.any(
      (value) => !LexiconSearchFilters.supportedCefrLevels.contains(value),
    )) {
      return const <SearchResultItem>[];
    }

    final articleFilters = <String>{
      for (final article in query.filters.articles)
        if (article != LexiconArticle.none) article.name,
    };
    final rows = await _corpusRepository.searchContent(
      terms: GermanSearchNormalizer.variants(query.text),
      cefrLevels: requestedLevels,
      articles: articleFilters,
      limit: query.limit,
    );
    return List<SearchResultItem>.unmodifiable(rows.map(_map));
  }

  SearchResultItem _map(SrsCorpusItem item) {
    return SearchResultItem(
      wordId: item.id,
      germanWord: item.german,
      article: switch (item.article.trim().toLowerCase()) {
        'der' => LexiconArticle.der,
        'die' => LexiconArticle.die,
        'das' => LexiconArticle.das,
        _ => LexiconArticle.none,
      },
      arabicMeaning: item.arabic,
      cefrLevel: item.cefr.trim(),
    );
  }
}
