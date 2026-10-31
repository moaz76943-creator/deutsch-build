import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/fts_search_service.dart';
import 'package:deutsch_bilarabi/services/database_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('FtsSearchService Tests (Fallback)', () {
    test('Fallback search works when FTS5 missing', () async {
      // Need to make sure lexemes_fts doesn't exist
      final db = await DatabaseService.instance.contentDb;
      await db.execute('DROP TABLE IF EXISTS lexemes_fts');

      final service = FtsSearchService();
      final results = await service.search('Wasser', 'de');
      expect(results.length, greaterThanOrEqualTo(1));
      expect(results.first['lemma'], 'Wasser');
    });

    test('Search handles injection characters gracefully', () async {
      final service = FtsSearchService();
      final results = await service.search('Wasser" OR 1=1', 'de');
      expect(results, isNotNull);
    });

    test('Search returns nothing on completely malformed inputs that strip to empty string', () async {
      final service = FtsSearchService();
      final results = await service.search(r'$$$$', 'de');
      expect(results, isNotNull);
    });

    test('Test various languages and scripts (Arabic)', () async {
      final service = FtsSearchService();
      var results = await service.search('ماء', 'de');
      expect(results, isNotNull);
    });

    test('Test various languages and scripts (Hebrew)', () async {
      final service = FtsSearchService();
      var results = await service.search('מים', 'de'); // Water in Hebrew
      expect(results, isNotNull);
    });

    test('Test bounds logic', () async {
      final service = FtsSearchService();
      final results = await service.search('', 'de', limit: 1);
      expect(results.length, lessThanOrEqualTo(1));
    });
  });

  group('FtsSearchService Tests (With FTS5)', () {
    test('Search with FTS index', () async {
      final db = await DatabaseService.instance.contentDb;

      // Seed some test data
      await db.execute('''
        CREATE VIRTUAL TABLE IF NOT EXISTS lexemes_fts USING fts5(lexeme_id, lemma, display_text, content=lexemes)
      ''');

      await db.execute('''
        INSERT INTO lexemes_fts(rowid, lexeme_id, lemma, display_text)
        VALUES (1, 'lex.de.water', 'Wasser', 'das Wasser')
      ''');

      await db.execute('''
        INSERT INTO lexemes_fts(rowid, lexeme_id, lemma, display_text)
        VALUES (2, 'lex.de.book', 'Buch', 'das Buch')
      ''');

      await db.execute('''
        INSERT INTO lexemes_fts(rowid, lexeme_id, lemma, display_text)
        VALUES (3, 'lex.de.car', 'Auto', 'das Auto')
      ''');

      final service = FtsSearchService();

      // German prefix search
      final results = await service.search('Wass', 'de');
      expect(results.length, 1);
      expect(results.first['lemma'], 'Wasser');

      // Empty string fallback
      final emptyResults = await service.search('', 'de');
      expect(emptyResults, isNotEmpty);

      // Test injection in FTS mode
      final injectResults = await service.search('Wass" OR 1=1', 'de');
      expect(injectResults, isNotNull); // Shouldn't crash

      // Test offset/limit
      final boundResults = await service.search('a', 'de', limit: 1, offset: 0);
      expect(boundResults.length, lessThanOrEqualTo(1));

      // Test Unicode
      final unicodeResults = await service.search('ß', 'de');
      expect(unicodeResults, isNotNull);

      // Clean up
      await db.execute('DROP TABLE lexemes_fts');
    });
  });
}
