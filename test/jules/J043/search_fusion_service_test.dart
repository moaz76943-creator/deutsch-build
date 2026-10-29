import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/fts_search_service.dart';
import 'package:deutsch_bilarabi/services/search_fusion_service.dart';

void main() {
  late Database db;
  late Directory tempDir;
  late SearchFusionService fusionService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('j043_test_');
    final dbPath = '${tempDir.path}/test.db';
    db = await databaseFactory.openDatabase(dbPath, options: OpenDatabaseOptions(version: 1));
    await db.execute('PRAGMA user_version = 0');
    await db.execute('''
      CREATE TABLE lexicon (
        id TEXT PRIMARY KEY,
        surface TEXT,
        part_of_speech TEXT,
        fields_json TEXT
      )
    ''');
    await db.execute('''
      CREATE VIRTUAL TABLE lexicon_fts USING fts5(
        surface,
        content='lexicon',
        content_rowid='rowid'
      )
    ''');

    await db.execute("INSERT INTO lexicon (id, surface, part_of_speech, fields_json) VALUES ('id1', 'testword', 'noun', '{\"translation_ar\":\"arabic1\"}')");
    await db.execute("INSERT INTO lexicon (id, surface, part_of_speech, fields_json) VALUES ('id2', 'testword', 'verb', '{\"translation_ar\":\"arabic2\"}')");
    await db.execute("INSERT INTO lexicon_fts (rowid, surface) VALUES (1, 'testword')");
    await db.execute("INSERT INTO lexicon_fts (rowid, surface) VALUES (2, 'testword')");

    final ftsService = FtsSearchService();

    Future<List<Map<String, dynamic>>> searchMock(String query, String languageCode, int limit) async {
       if (languageCode == 'de') {
          return ftsService.searchDatabase(db, query, languageCode: 'de', limit: limit);
       }
       return [];
    }

    fusionService = SearchFusionService(search: searchMock);
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('Search fusion deduplicates by stable lexical ID, separating distinct meanings', () async {
    final stream = fusionService.search(
      query: 'testword',
      activeLanguageCode: 'de',
      mountedLanguages: ['de', 'ar', 'en'],
    );
    final pages = await stream.toList();
    expect(pages.isNotEmpty, isTrue);
    final lastPage = pages.last;
    expect(lastPage.isComplete, isTrue);
    expect(lastPage.totalHits, 2);
    expect(lastPage.items.length, 2);
    expect(lastPage.items[0].word['id'], 'id1');
    expect(lastPage.items[1].word['id'], 'id2');
  });

  test('Drops stale async results across generations', () async {
    final stream1 = fusionService.search(
      query: 'test',
      activeLanguageCode: 'de',
      mountedLanguages: ['de'],
    );
    final stream2 = fusionService.search(
      query: 'testword',
      activeLanguageCode: 'de',
      mountedLanguages: ['de'],
    );

    final results1 = await stream1.toList();
    final results2 = await stream2.toList();
    expect(results2.last.totalHits, 2);
  });
}
