import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/fts_search_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<Database> createTestDb({bool includeFts = true}) async {
    var db = await databaseFactory.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(version: 1));
    await db.execute('''
      CREATE TABLE lexicon (
        id TEXT PRIMARY KEY,
        surface TEXT,
        part_of_speech TEXT,
        fields_json TEXT
      )
    ''');

    if (includeFts) {
      await db.execute('''
        CREATE VIRTUAL TABLE lexicon_fts USING fts5(surface, fields_json);
      ''');
    }
    return db;
  }

  Future<void> insertLexicon(Database db, int rowid, String id, String surface, {bool includeFts = true}) async {
    await db.execute(
        "INSERT INTO lexicon (rowid, id, surface, part_of_speech, fields_json) VALUES (?, ?, ?, 'Noun', '{}')",
        [rowid, id, surface]);
    if (includeFts) {
      await db.execute(
          "INSERT INTO lexicon_fts (rowid, surface, fields_json) VALUES (?, ?, '{}')",
          [rowid, surface]);
    }
  }

  group('FtsSearchService Tests', () {
    late FtsSearchService service;

    setUp(() {
      service = FtsSearchService();
    });

    test('German prefix search with ranking', () async {
      final db = await createTestDb();
      await insertLexicon(db, 1, '1', 'Apfel');
      await insertLexicon(db, 2, '2', 'Äpfel');
      await insertLexicon(db, 3, '3', 'Apfelbaum');
      await insertLexicon(db, 4, '4', 'Der Apfel');

      // The prefix search should match "Apfel" and "Apfelbaum" and "Äpfel"
      // depending on how FTS5 tokenizes it, but FTS5 default tokenizer usually
      // separates based on ASCII. Wait, "Der Apfel" will match if we search "Apfel".
      // But FtsSearchService checks `term.runes.length >= 3`
      final results = await service.searchDatabase(db, 'Apfe', languageCode: 'de');

      // Expected to match Apfel, Apfelbaum because FTS5 prefix matching matches tokens starting with 'Apfe'
      expect(results.length, greaterThanOrEqualTo(1));

      // Ranking test: exact prefix or exact match should come first.
      // Actually FTS5 BM25 handles ranking, but searchDatabase has an ORDER BY CASE
      // to put exact matches first, then LIKE matches, etc.
      final apfelResult = await service.searchDatabase(db, 'Apfel', languageCode: 'de');
      expect(apfelResult.first['surface'], 'Apfel');

      await db.close();
    });

    test('Arabic search', () async {
      final db = await createTestDb();
      await insertLexicon(db, 1, '1', 'تفاحة');
      await insertLexicon(db, 2, '2', 'تفاح');

      final results = await service.searchDatabase(db, 'تفا', languageCode: 'ar');
      expect(results.length, 2);

      await db.close();
    });

    test('Hebrew search', () async {
      final db = await createTestDb();
      await insertLexicon(db, 1, '1', 'תפוח');
      await insertLexicon(db, 2, '2', 'תפוחים');

      final results = await service.searchDatabase(db, 'תפו', languageCode: 'he');
      expect(results.length, 2);

      await db.close();
    });

    test('Unicode input (Emojis)', () async {
      final db = await createTestDb();
      await insertLexicon(db, 1, '1', '🍎');
      await insertLexicon(db, 2, '2', '🍏');

      // Emoji search is 1 rune, so it hits the < 3 fallback
      final results = await service.searchDatabase(db, '🍎', languageCode: 'de');
      expect(results.length, 1);
      expect(results.first['surface'], '🍎');

      await db.close();
    });

    test('Malformed MATCH syntax injection safely handled', () async {
      final db = await createTestDb();
      await insertLexicon(db, 1, '1', 'Test');
      await insertLexicon(db, 2, '2', 'Testing');

      // This should not crash, it should return gracefully
      // even if FTS throws, the catch block calls _fallback
      final results = await service.searchDatabase(db, '" OR 1=1 --', languageCode: 'en');
      expect(results.length, 0);

      // Quotes only should not crash
      final resultsQuotes = await service.searchDatabase(db, '"""', languageCode: 'en');
      expect(resultsQuotes.length, 0);

      await db.close();
    });

    test('Missing FTS tables handled gracefully (fallback)', () async {
      final db = await createTestDb(includeFts: false);
      await insertLexicon(db, 1, '1', 'Fallback', includeFts: false);
      await insertLexicon(db, 2, '2', 'Falling', includeFts: false);

      final results = await service.searchDatabase(db, 'Fall', languageCode: 'en');
      expect(results.length, 2);

      await db.close();
    });

    test('Sorting is correct', () async {
      final db = await createTestDb();
      await insertLexicon(db, 1, '1', 'Apple Tree');
      await insertLexicon(db, 2, '2', 'Apple');
      await insertLexicon(db, 3, '3', 'Apples');

      final results = await service.searchDatabase(db, 'Apple', languageCode: 'en');
      // "Apple" is exact match, should be first
      expect(results.first['surface'], 'Apple');

      await db.close();
    });
  });
}
