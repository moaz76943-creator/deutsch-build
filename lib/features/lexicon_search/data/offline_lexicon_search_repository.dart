import '../../search/domain/search_models.dart' as legacy;
import '../../search/domain/search_repositories.dart' as legacy;
import '../domain/lexicon_models.dart';
import '../domain/lexicon_repositories.dart';

typedef CefrLevelResolver = String? Function(String wordId);

/// Lexicon-specific projection over the canonical offline search engine.
///
/// The canonical search index remains the single indexing implementation;
/// this adapter adds CEFR filtering and the richer lexicon result contract.
final class OfflineLexiconSearchRepository implements LexiconSearchRepository {
  OfflineLexiconSearchRepository({
    required legacy.SearchRepository searchRepository,
    CefrLevelResolver? cefrLevelResolver,
  })  : _searchRepository = searchRepository,
        _cefrLevelResolver = cefrLevelResolver ?? _unknownLevel;

  final legacy.SearchRepository _searchRepository;
  final CefrLevelResolver _cefrLevelResolver;

  static String _unknownLevel(String _) => '—';

  @override
  Future<SearchResultItem?> byId(String wordId) async {
    final item = await _searchRepository.byId(wordId.trim());
    return item == null ? null : _map(item);
  }

  @override
  Future<List<SearchResultItem>> search(LexiconSearchQuery query) async {
    final articleFilters = <legacy.SearchFilter>{};
    for (final article in query.filters.articles) {
      final mapped = switch (article) {
        LexiconArticle.der => legacy.SearchFilter.der,
        LexiconArticle.die => legacy.SearchFilter.die,
        LexiconArticle.das => legacy.SearchFilter.das,
        LexiconArticle.none => null,
      };
      if (mapped != null) articleFilters.add(mapped);
    }

    final needsPostFilter = query.filters.cefrLevels.isNotEmpty;
    final delegateLimit = needsPostFilter ? 200 : query.limit;
    final raw = await _searchRepository.search(
      legacy.SearchQuery(
        text: query.text,
        filters: articleFilters,
        limit: delegateLimit,
      ),
    );

    final mapped = raw.map(_map).where((item) {
      final levels = query.filters.cefrLevels;
      return levels.isEmpty || levels.contains(item.cefrLevel.toUpperCase());
    }).take(query.limit);

    return List<SearchResultItem>.unmodifiable(mapped);
  }

  SearchResultItem _map(legacy.SearchResultItem item) {
    return SearchResultItem(
      wordId: item.id,
      germanWord: item.term,
      article: switch (item.article) {
        legacy.GermanArticle.der => LexiconArticle.der,
        legacy.GermanArticle.die => LexiconArticle.die,
        legacy.GermanArticle.das => LexiconArticle.das,
        legacy.GermanArticle.none => LexiconArticle.none,
      },
      arabicMeaning: item.translationArabic,
      cefrLevel: (_cefrLevelResolver(item.id) ?? '—').trim().toUpperCase(),
    );
  }
}
