import 'package:deutsch_bilarabi/services/fts_search_service.dart';
import 'package:deutsch_bilarabi/services/vocabulary_filter_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute(
      'CREATE TABLE lexicon ('
      'id TEXT PRIMARY KEY, surface TEXT, part_of_speech TEXT, '
      'fields_json TEXT, cefr_level TEXT, frequency_rank INTEGER)',
    );
    await db.execute(
      'CREATE TABLE inflections_lookup ('
      'inflected_form TEXT, language_code TEXT, '
      'lemma TEXT, lexicon_id TEXT)',
    );
    for (final entry in <List<String>>[
      <String>['1', 'go', 'A1'],
      <String>['2', 'word', 'A1'],
      <String>['3', 'gehen', 'A2'],
      <String>['4', 'parler', 'B1'],
    ]) {
      await db.insert('lexicon', <String, Object?>{
        'id': entry[0],
        'surface': entry[1],
        'part_of_speech': 'verb',
        'fields_json': '{}',
        'cefr_level': entry[2],
        'frequency_rank': 10,
      });
    }
    for (final entry in <List<String>>[
      <String>['went', 'en', 'go'],
      <String>['ging', 'de', 'gehen'],
      <String>['parlé', 'fr', 'parler'],
    ]) {
      await db.insert('inflections_lookup', <String, Object?>{
        'inflected_form': entry[0],
        'language_code': entry[1],
        'lemma': entry[2],
      });
    }
  });

  tearDown(() async {
    await db.close();
  });

  test('FTS resolves attested lemmas even without an FTS table', () async {
    final service = FtsSearchService();
    for (final example in <List<String>>[
      <String>['went', 'en', 'go'],
      <String>['ging', 'de', 'gehen'],
      <String>['parlé', 'fr', 'parler'],
    ]) {
      final result = await service.searchDatabaseWithFeedback(
        db, example[0], languageCode: example[1],
      );
      expect(result.resolvedLemma, example[2]);
      expect(result.results.first['surface'], example[2]);
      expect(result.suggestions, isEmpty);
    }
  });

  test('no FTS results yields at most three typo suggestions', () async {
    final result = await FtsSearchService().searchDatabaseWithFeedback(
      db, 'wrod', languageCode: 'en',
    );
    expect(result.results, isEmpty);
    expect(result.suggestions, contains('word'));
    expect(result.suggestions.length, lessThanOrEqualTo(3));
  });

  test('CEFR filters remain applied to lemma and fuzzy searches', () async {
    final filtered = VocabularyFilterService(
      openContentDb: (_) async => db,
    );
    final german = await filtered.searchWithFeedback(
      languageCode: 'de',
      level: VocabularyCefrFilter.a2,
      searchText: 'ging',
    );
    expect(german.resolvedLemma, 'gehen');
    expect(german.results.single['surface'], 'gehen');
    final typo = await filtered.searchWithFeedback(
      languageCode: 'en',
      level: VocabularyCefrFilter.a1,
      searchText: 'wrod',
    );
    expect(typo.results, isEmpty);
    expect(typo.suggestions, contains('word'));
  });

  test('direct hits suppress suggestions and lemma indicators', () async {
    final result = await FtsSearchService().searchDatabaseWithFeedback(
      db, 'word', languageCode: 'en',
    );
    expect(result.resolvedLemma, isNull);
    expect(result.suggestions, isEmpty);
    expect(result.results.single['surface'], 'word');
  });
}
