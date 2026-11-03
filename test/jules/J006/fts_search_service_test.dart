import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../lib/services/fts_search_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<Database> _createDbWithFts() async {
    return await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE lexicon (
              id TEXT,
              surface TEXT,
              part_of_speech TEXT,
              fields_json TEXT
            )
          ''');
          await db.execute('''
            CREATE VIRTUAL TABLE lexicon_fts USING fts5(surface, content=lexicon);
          ''');

          Future<void> insertLexicon(int id, String surface) async {
            await db.execute(
              'INSERT INTO lexicon (rowid, id, surface, fields_json) VALUES (?, ?, ?, ?)',
              [id, id.toString(), surface, '{}'],
            );
            await db.execute(
              'INSERT INTO lexicon_fts (rowid, surface) VALUES (?, ?)',
              [id, surface],
            );
          }

          // English
          await insertLexicon(1, 'hello world');
          await insertLexicon(2, 'hello');
          await insertLexicon(3, 'hell');
          await insertLexicon(4, 'apple');

          // Arabic
          await insertLexicon(5, 'مرحبا'); // marhaba
          await insertLexicon(6, 'مرح'); // marah

          // Hebrew
          await insertLexicon(7, 'שלום'); // shalom
          await insertLexicon(8, 'שלו');

          // German
          await insertLexicon(9, 'Mädchen');
          await insertLexicon(10, 'Mädel');

          // Unicode and special
          await insertLexicon(11, 'über');
          await insertLexicon(12, 'groß');
        },
      ),
    );
  }

  Future<Database> _createDbWithoutFts() async {
    return await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE lexicon (
              id TEXT,
              surface TEXT,
              part_of_speech TEXT,
              fields_json TEXT
            )
          ''');

          await db.execute(
            'INSERT INTO lexicon (rowid, id, surface, fields_json) VALUES (1, "1", "hello", "{}")',
          );
        },
      ),
    );
  }

  test('FTS prefix match for English words', () async {
    final db = await _createDbWithFts();
    final service = FtsSearchService();

    final results = await service.searchDatabase(db, 'hel', languageCode: 'en');
    expect(results.length, 3); // 'hello', 'hello world', 'hell'

    // Sort order: exact match first, prefix next, then BM25
    final surfaces = results.map((r) => r['surface'] as String).toList();
    expect(surfaces, containsAll(['hell', 'hello', 'hello world']));

    await db.close();
  });

  test('FTS prefix match for Arabic words', () async {
    final db = await _createDbWithFts();
    final service = FtsSearchService();

    final results = await service.searchDatabase(db, 'مرح', languageCode: 'ar');
    expect(results.length, 2);
    final surfaces = results.map((r) => r['surface'] as String).toList();
    expect(surfaces.first, 'مرح'); // Exact match comes first
    expect(surfaces[1], 'مرحبا');

    await db.close();
  });

  test('FTS prefix match for Hebrew words', () async {
    final db = await _createDbWithFts();
    final service = FtsSearchService();

    final results = await service.searchDatabase(db, 'שלו', languageCode: 'he');
    expect(results.length, 2);
    final surfaces = results.map((r) => r['surface'] as String).toList();
    expect(surfaces, containsAll(['שלו', 'שלום']));

    await db.close();
  });

  test('FTS prefix match for German words and Unicode', () async {
    final db = await _createDbWithFts();
    final service = FtsSearchService();

    final results = await service.searchDatabase(db, 'Mäd', languageCode: 'de');
    expect(results.length, 2);
    final surfaces = results.map((r) => r['surface'] as String).toList();
    expect(surfaces, containsAll(['Mädchen', 'Mädel']));

    final results2 = await service.searchDatabase(db, 'gro', languageCode: 'de');
    expect(results2.length, 1);
    expect(results2.first['surface'], 'groß');

    await db.close();
  });

  test('Fallback behavior when lexicon_fts table is missing', () async {
    final db = await _createDbWithoutFts();
    final service = FtsSearchService();

    final results = await service.searchDatabase(db, 'hel', languageCode: 'en');
    expect(results.length, 1);
    expect(results.first['surface'], 'hello');

    await db.close();
  });

  test('SQL injection and malformed MATCH syntax is handled gracefully', () async {
    final db = await _createDbWithFts();
    final service = FtsSearchService();

    // Trying to break out of quotes
    final results = await service.searchDatabase(db, 'he"llo', languageCode: 'en');
    // Escaped correctly to "he""llo"*, should find nothing or gracefully handle it
    expect(results.length, 0);

    // SQLi attempt
    final results2 = await service.searchDatabase(db, 'hel" OR 1=1 --', languageCode: 'en');
    expect(results2.length, 0);

    await db.close();
  });
}
