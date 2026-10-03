import 'package:deutsch_bilarabi/features/lexicon_search/data/offline_lexicon_search_repository.dart';
import 'package:deutsch_bilarabi/features/lexicon_search/domain/lexicon_models.dart';
import 'package:deutsch_bilarabi/features/search/domain/search_models.dart' as legacy;
import 'package:deutsch_bilarabi/features/search/domain/search_repositories.dart' as legacy;
import 'package:flutter_test/flutter_test.dart';

final class _MemorySearchRepository implements legacy.SearchRepository {
  _MemorySearchRepository(this.items);

  final List<legacy.SearchResultItem> items;
  legacy.SearchQuery? lastQuery;

  @override
  Future<legacy.SearchResultItem?> byId(String id) async {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<List<legacy.SearchResultItem>> search(legacy.SearchQuery query) async {
    lastQuery = query;
    final text = query.text.trim().toLowerCase();
    return items
        .where((item) => text.isEmpty || item.term.toLowerCase().contains(text))
        .take(query.limit)
        .toList(growable: false);
  }
}

void main() {
  final items = <legacy.SearchResultItem>[
    const legacy.SearchResultItem(
      id: 'haus',
      term: 'Haus',
      translationArabic: 'منزل',
      type: legacy.SearchItemType.noun,
      article: legacy.GermanArticle.das,
    ),
    const legacy.SearchResultItem(
      id: 'hund',
      term: 'Hund',
      translationArabic: 'كلب',
      type: legacy.SearchItemType.noun,
      article: legacy.GermanArticle.der,
    ),
  ];

  test('maps canonical offline results and applies CEFR filter', () async {
    final delegate = _MemorySearchRepository(items);
    final repository = OfflineLexiconSearchRepository(
      searchRepository: delegate,
      cefrLevelResolver: (id) => id == 'haus' ? 'A1' : 'A2',
    );

    final result = await repository.search(
      const LexiconSearchQuery(
        filters: LexiconSearchFilters(cefrLevels: <String>{'A1'}),
      ),
    );

    expect(result, hasLength(1));
    expect(result.single.wordId, 'haus');
    expect(result.single.article, LexiconArticle.das);
    expect(result.single.cefrLevel, 'A1');
    expect(delegate.lastQuery?.limit, 200);
  });

  test('article filters are delegated to the canonical search engine', () async {
    final delegate = _MemorySearchRepository(items);
    final repository = OfflineLexiconSearchRepository(
      searchRepository: delegate,
    );

    await repository.search(
      const LexiconSearchQuery(
        filters: LexiconSearchFilters(
          articles: <LexiconArticle>{LexiconArticle.der},
        ),
      ),
    );

    expect(delegate.lastQuery?.filters, contains(legacy.SearchFilter.der));
  });

  test('large result projection stays bounded by canonical 200 candidate cap',
      () async {
    final large = List<legacy.SearchResultItem>.generate(
      5000,
      (index) => legacy.SearchResultItem(
        id: 'word_$index',
        term: 'wort$index',
        translationArabic: 'معنى $index',
        type: legacy.SearchItemType.other,
      ),
    );
    final delegate = _MemorySearchRepository(large);
    final repository = OfflineLexiconSearchRepository(
      searchRepository: delegate,
      cefrLevelResolver: (_) => 'A1',
    );
    final stopwatch = Stopwatch()..start();

    final result = await repository.search(
      const LexiconSearchQuery(
        filters: LexiconSearchFilters(cefrLevels: <String>{'A1'}),
        limit: 80,
      ),
    );
    stopwatch.stop();

    expect(delegate.lastQuery?.limit, 200);
    expect(result, hasLength(80));
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 1)));
  });
}
