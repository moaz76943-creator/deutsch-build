import 'dart:async';

import 'package:deutsch_bilarabi/services/search_fusion_service.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> hit(String language, String word, {
  String? lemma,
  String? translation,
}) => <String, dynamic>{
  'language_code': language,
  'surface': word,
  'lemma': lemma ?? word,
  'translation_ar': translation ?? '',
};

void main() {
  test('returns a ranked first page before a blocked pack finishes', () async {
    final slow = Completer<List<Map<String, dynamic>>>();
    final fusion = SearchFusionService(search: (query, language, limit) {
      if (language == 'fr') return slow.future;
      return Future<List<Map<String, dynamic>>>.value(
        <Map<String, dynamic>>[hit('de', 'Haus')],
      );
    });
    final firstPage = Completer<SearchFusionPage>();
    final pages = <SearchFusionPage>[];
    final streamDone = Completer<void>();
    final subscription = fusion.search(
      query: 'Haus', activeLanguageCode: 'de-DE',
      mountedLanguages: <String>['fr', 'de'], pageSize: 20,
    ).listen((page) {
      pages.add(page);
      if (!firstPage.isCompleted) firstPage.complete(page);
    }, onDone: streamDone.complete);

    final initial = await firstPage.future;
    expect(initial.isComplete, isFalse);
    expect(initial.items.single.word['surface'], 'Haus');
    expect(initial.items.single.matchTier, 0);

    slow.complete(<Map<String, dynamic>>[hit('fr', 'maison', translation: 'Haus')]);
    await streamDone.future;
    await subscription.cancel();
    expect(pages.last.isComplete, isTrue);
    expect(pages.last.items.first.word['surface'], 'Haus');
  });

  test('deduplicates same-language lemma and fuses rank scores', () async {
    final fusion = SearchFusionService(search: (_, language, __) async {
      if (language == 'de') {
        return <Map<String, dynamic>>[
          hit('de', 'ging', lemma: 'gehen'),
          hit('de', 'gehen'),
        ];
      }
      return <Map<String, dynamic>>[hit('en', 'go')];
    });
    final pages = await fusion.search(
      query: 'gehen', activeLanguageCode: 'de',
      mountedLanguages: <String>['de', 'en'],
    ).toList();
    final last = pages.last;
    expect(last.isComplete, true);
    expect(last.totalHits, 2);
    expect(last.items.first.key, 'de|gehen');
    expect(last.items.first.matchTier, 0);
  });

  test('emits stable final paginated results and tolerates failed packs',
      () async {
    final fusion = SearchFusionService(search: (_, language, __) async {
      if (language == 'it') throw StateError('pack missing');
      return List<Map<String, dynamic>>.generate(
        45,
        (i) => hit('de', 'wort$i'),
      );
    });
    final pages = await fusion.search(
      query: 'test', activeLanguageCode: 'de',
      mountedLanguages: <String>['de', 'it'],
    ).toList();
    final finalPages = pages.where((p) => p.isComplete).toList();
    expect(finalPages.map((p) => p.items.length), <int>[20, 20, 5]);
    expect(finalPages.first.totalHits, 45);
  });

  test('rejects malformed pack locales and caps expensive inputs', () async {
    final fusion = SearchFusionService(search: (_, __, ___) async => []);
    expect(
      () => fusion.search(
        query: 'ok', activeLanguageCode: 'de',
        mountedLanguages: <String>['../bad'],
      ).toList(),
      throwsArgumentError,
    );
    final pages = await fusion.search(
      query: List<String>.filled(31, 'x').join(),
      activeLanguageCode: 'de',
      mountedLanguages: <String>['de'],
    ).toList();
    expect(pages.single.items, isEmpty);
  });
}
