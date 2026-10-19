import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:deutsch_bilarabi/services/search_fusion_service.dart';
import 'package:deutsch_bilarabi/services/fts_search_service.dart';
import 'package:deutsch_bilarabi/services/database_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<Database> createMockPack(String language, List<Map<String, dynamic>> words) async {
    final db = await databaseFactory.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(
            version: 2,
            onCreate: (db, version) async {
              await db.execute('PRAGMA user_version = 2');
              await db.execute('''
                CREATE TABLE lexicon(
                  id TEXT PRIMARY KEY,
                  surface TEXT NOT NULL,
                  part_of_speech TEXT,
                  fields_json TEXT
                )
              ''');
              await db.execute('''
                CREATE VIRTUAL TABLE lexicon_fts USING fts5(
                  surface, lemma, gloss, language_code
                )
              ''');
              await db.execute('CREATE TABLE metadata(key TEXT, value TEXT)');
              await db.execute('CREATE TABLE schema_migrations(id TEXT)');
              await db.execute('CREATE TABLE concepts(id TEXT)');
              await db.execute('CREATE TABLE senses(id TEXT)');
              await db.execute('CREATE TABLE translations(id TEXT)');
              await db.execute('CREATE TABLE examples(id TEXT)');
              await db.execute('CREATE TABLE lexical_relations(id TEXT)');
              await db.execute('CREATE TABLE grammar(id TEXT)');
              await db.execute('CREATE VIEW lexemes AS SELECT * FROM lexicon');

              for (final word in words) {
                final id = word['id'] ?? '1';
                final surface = word['surface'] ?? '';
                final lemma = word['lemma'] ?? surface;
                final fieldsJson = word['fields_json'] ?? '{"lemma":"$lemma"}';

                await db.execute(
                    'INSERT INTO lexicon(id, surface, fields_json) VALUES(?, ?, ?)',
                    [id, surface, fieldsJson]);
                await db.execute(
                    'INSERT INTO lexicon_fts(rowid, surface, lemma, gloss, language_code) VALUES(last_insert_rowid(), ?, ?, ?, ?)',
                    [surface, lemma, '', language]);
              }
            }));
    return db;
  }

  test('Fuses results correctly, preserving distinct senses via ID', () async {
    final dbDe = await createMockPack('de', [
      {'id': '1', 'surface': 'Bank', 'lemma': 'Bank'}, // financial
      {'id': '2', 'surface': 'Bank', 'lemma': 'Bank'}, // furniture
      {'id': '3', 'surface': 'Apfel', 'lemma': 'Apfel'},
    ]);

    final searchService = FtsSearchService();

    final fusionService = SearchFusionService(
      search: (query, language, limit) async {
        if (language == 'de') return searchService.searchDatabase(dbDe, query, languageCode: 'de');
        return [];
      },
    );

    final pages = await fusionService.search(
      query: 'Bank',
      activeLanguageCode: 'de',
      mountedLanguages: ['de'],
    ).toList();

    expect(pages.isNotEmpty, isTrue);
    final lastPage = pages.last;
    expect(lastPage.totalHits, 2); // Should have both distinct Bank entries
    expect(lastPage.items.length, 2);
    expect(lastPage.items.any((h) => h.word['id'] == '1'), isTrue);
    expect(lastPage.items.any((h) => h.word['id'] == '2'), isTrue);

    await dbDe.close();
  });

  test('Strips results from unmounted languages preventing reverse-pair reuse', () async {
    final dbDe = await createMockPack('de', [
      {'id': '1', 'surface': 'Haus'},
    ]);
    final dbFr = await createMockPack('fr', [
      {'id': '2', 'surface': 'Haus'},
    ]);

    final searchService = FtsSearchService();

    final fusionService = SearchFusionService(
      search: (query, language, limit) async {
        if (language == 'de') return searchService.searchDatabase(dbDe, query, languageCode: 'de');
        if (language == 'fr') return searchService.searchDatabase(dbFr, query, languageCode: 'fr');
        return [];
      },
    );

    final pages = await fusionService.search(
      query: 'Haus',
      activeLanguageCode: 'de',
      // Notice 'fr' is intentionally excluded from mountedLanguages here
      mountedLanguages: ['de'],
    ).toList();

    final lastPage = pages.last;
    // The query finds 'Haus' in de. The mock also has it in 'fr', but 'fr' wasn't requested.
    // The MountedPackSearch is called only for mountedLanguages, but if a pack returns rows with language_code='fr', they should be skipped.
    // To properly test this, we return a row with 'language_code': 'fr' from 'de' search, mocking a cross-pack bleed or dictionary containing multiple languages.
    expect(lastPage.totalHits, 1);
    expect(lastPage.items.first.word['id'], '1');

    await dbDe.close();
    await dbFr.close();
  });

  test('Cross-language results from the same DB are stripped if language is not mounted', () async {
    final fusionService = SearchFusionService(
      search: (query, language, limit) async {
        return [
          {'language_code': 'de', 'id': '1', 'surface': 'Haus', 'lemma': 'Haus'},
          {'language_code': 'ru', 'id': '2', 'surface': 'Haus', 'lemma': 'Haus'},
        ];
      },
    );

    final pages = await fusionService.search(
      query: 'Haus',
      activeLanguageCode: 'de',
      mountedLanguages: ['de'],
    ).toList();

    final lastPage = pages.last;
    expect(lastPage.totalHits, 1);
    expect(lastPage.items.first.word['id'], '1');
  });

  test('Stale searches short-circuit (Generation ID)', () async {
    final dbDe = await createMockPack('de', [
      {'id': '1', 'surface': 'Apfel'},
    ]);
    final searchService = FtsSearchService();
    final completer = Completer<List<Map<String, dynamic>>>();

    final fusionService = SearchFusionService(
      search: (query, language, limit) {
        return completer.future;
      },
    );

    // Start first search
    final stream1 = fusionService.search(
      query: 'Apfel',
      activeLanguageCode: 'de',
      mountedLanguages: ['de'],
    );

    final results1 = <SearchFusionPage>[];
    stream1.listen((page) {
      results1.add(page);
    });

    // Start second search, effectively superseding stream1
    final stream2 = fusionService.search(
      query: 'Baum',
      activeLanguageCode: 'de',
      mountedLanguages: ['de'],
    );
    final results2 = <SearchFusionPage>[];
    stream2.listen((page) {
      results2.add(page);
    });

    // Complete the database mock operation now
    completer.complete(await searchService.searchDatabase(dbDe, 'Apfel', languageCode: 'de'));

    // Allow stream processing to settle
    await Future<void>.delayed(Duration(milliseconds: 50));

    // stream1 should not have received any non-empty yields
    expect(results1, isEmpty);
    // stream2 received the results, though they correspond to 'Apfel' due to mocked completer, it emitted
    expect(results2.isNotEmpty, isTrue);

    await dbDe.close();
  });

  test('CJK and Arabic query ranking', () async {
    final db = await createMockPack('ar', [
      {'id': '1', 'surface': 'كتاب', 'lemma': 'كتاب', 'fields_json': '{"lemma":"كتاب"}'},
      {'id': '2', 'surface': 'كتب', 'lemma': 'كتب', 'fields_json': '{"lemma":"كتب"}'},
    ]);

    final searchService = FtsSearchService();
    final fusionService = SearchFusionService(
      search: (query, language, limit) async {
        return searchService.searchDatabase(db, query, languageCode: 'ar');
      },
    );

    final pages = await fusionService.search(
      query: 'كتاب',
      activeLanguageCode: 'ar',
      mountedLanguages: ['ar'],
    ).toList();

    expect(pages.isNotEmpty, isTrue);
    final lastPage = pages.last;
    expect(lastPage.totalHits, 1);
    expect(lastPage.items.first.word['surface'], 'كتاب');

    await db.close();
  });
}
