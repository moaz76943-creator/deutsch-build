import 'package:deutsch_bilarabi/features/search/application/search_controller.dart';
import 'package:deutsch_bilarabi/features/search/domain/search_models.dart';
import 'package:deutsch_bilarabi/features/search/domain/search_repositories.dart';
import 'package:flutter_test/flutter_test.dart';

final class _CountingSearchRepository implements SearchRepository {
  final List<String> queries = <String>[];

  @override
  Future<SearchResultItem?> byId(String id) async => null;

  @override
  Future<List<SearchResultItem>> search(SearchQuery query) async {
    queries.add(query.text);
    return <SearchResultItem>[
      SearchResultItem(
        id: query.text,
        term: query.text,
        translationArabic: 'نتيجة',
        type: SearchItemType.other,
      ),
    ];
  }
}

void main() {
  test('debouncing executes only the latest rapidly typed query', () async {
    final repository = _CountingSearchRepository();
    final controller = SearchController(
      repository: repository,
      debounceDuration: const Duration(milliseconds: 20),
    );

    controller.updateText('b');
    controller.updateText('bu');
    controller.updateText('bucher');
    await Future<void>.delayed(const Duration(milliseconds: 45));

    expect(repository.queries, <String>['bucher']);
    expect(controller.state.results.single.term, 'bucher');
    controller.dispose();
  });

  test('filter changes execute without waiting for typing debounce', () async {
    final repository = _CountingSearchRepository();
    final controller = SearchController(
      repository: repository,
      debounceDuration: const Duration(seconds: 1),
    );

    controller.toggleFilter(SearchFilter.die);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.query.filters, contains(SearchFilter.die));
    expect(repository.queries, hasLength(1));
    controller.dispose();
  });
}
