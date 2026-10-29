import '../../../core/content_contract.dart';
import '../../../services/search_index.dart';
import '../domain/search_models.dart';
import '../domain/search_repositories.dart';
import 'search_text_normalizer.dart';

typedef SearchItemTypeResolver<T extends LearningContent> = SearchItemType Function(T item);

final class LexiconSearchRepository<T extends LearningContent>
    implements SearchRepository {
  LexiconSearchRepository({
    required SearchIndex<T> index,
    required Iterable<T> corpus,
    SearchItemTypeResolver<T>? typeResolver,
  })  : _index = index,
        _itemsById = <String, T>{for (final item in corpus) item.id: item},
        _typeResolver = typeResolver;

  final SearchIndex<T> _index;
  final Map<String, T> _itemsById;
  final SearchItemTypeResolver<T>? _typeResolver;

  @override
  Future<SearchResultItem?> byId(String id) async {
    final item = _itemsById[id.trim()];
    return item == null ? null : _toDomain(item);
  }

  @override
  Future<List<SearchResultItem>> search(SearchQuery query) async {
    final variants = SearchTextNormalizer.variants(query.text);
    final scored = <String, ({T item, int score})>{};
    final searchTerms = variants.isEmpty ? const <String>{''} : variants;
    final candidateLimit = (query.limit * 4).clamp(1, 200).toInt();

    for (final term in searchTerms) {
      for (final result in _index.searchDetailed(term, limit: candidateLimit)) {
        final existing = scored[result.item.id];
        if (existing == null || result.score > existing.score) {
          scored[result.item.id] = (item: result.item, score: result.score);
        }
      }
    }

    final ranked = scored.values.toList(growable: false)
      ..sort((left, right) {
        final byScore = right.score.compareTo(left.score);
        if (byScore != 0) return byScore;
        return left.item.sourceText.toLowerCase().compareTo(
              right.item.sourceText.toLowerCase(),
            );
      });

    return List<SearchResultItem>.unmodifiable(
      ranked
          .map((entry) => _toDomain(entry.item))
          .where((item) => _matchesFilters(item, query.filters))
          .take(query.limit),
    );
  }

  SearchResultItem _toDomain(T item) {
    final article = _article(item.grammaticalMarker);
    return SearchResultItem(
      id: item.id,
      term: item.sourceText,
      translationArabic: item.translationText,
      type: _typeResolver?.call(item) ?? _inferType(item, article),
      article: article,
      aliases: List<String>.unmodifiable(
        <String>[
          if (item.pluralForm.trim().isNotEmpty) item.pluralForm,
          ...item.acceptedForms.where((value) => value.trim().isNotEmpty),
        ],
      ),
    );
  }

  SearchItemType _inferType(T item, GermanArticle article) {
    if (article != GermanArticle.none) return SearchItemType.noun;
    final skill = item.skill.trim().toLowerCase();
    if (skill == 'verb' ||
        skill == 'verbs' ||
        skill.contains('conjug') ||
        skill.contains('verb')) {
      return SearchItemType.verb;
    }
    return SearchItemType.other;
  }

  GermanArticle _article(String value) => switch (value.trim().toLowerCase()) {
        'der' => GermanArticle.der,
        'die' => GermanArticle.die,
        'das' => GermanArticle.das,
        _ => GermanArticle.none,
      };

  bool _matchesFilters(SearchResultItem item, Set<SearchFilter> filters) {
    if (filters.isEmpty) return true;
    final hasTypeFilter = filters.contains(SearchFilter.verbs) ||
        filters.contains(SearchFilter.nouns);
    final typeMatches = !hasTypeFilter ||
        (filters.contains(SearchFilter.verbs) &&
            item.type == SearchItemType.verb) ||
        (filters.contains(SearchFilter.nouns) &&
            item.type == SearchItemType.noun);
    if (!typeMatches) return false;

    final hasArticleFilter = filters.contains(SearchFilter.der) ||
        filters.contains(SearchFilter.die) ||
        filters.contains(SearchFilter.das);
    if (!hasArticleFilter) return true;
    return switch (item.article) {
      GermanArticle.der => filters.contains(SearchFilter.der),
      GermanArticle.die => filters.contains(SearchFilter.die),
      GermanArticle.das => filters.contains(SearchFilter.das),
      GermanArticle.none => false,
    };
  }
}
