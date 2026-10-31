import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../lib/services/fts_search_service.dart';

void main() {
  late Database database;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    database = await databaseFactory.openDatabase(inMemoryDatabasePath);
    await database.execute('''
      CREATE TABLE lexicon (
        id TEXT PRIMARY KEY,
        surface TEXT,
        part_of_speech TEXT,
        fields_json TEXT
      )
    ''');
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> _createFtsTable() async {
    await database.execute('''
      CREATE VIRTUAL TABLE lexicon_fts USING fts5(
        surface,
        content='lexicon',
        content_rowid='rowid'
      )
    ''');
    await database.execute('''
      INSERT INTO lexicon_fts(lexicon_fts, rowid, surface)
      SELECT 'rebuild', rowid, surface FROM lexicon
    ''');
  }

  Future<void> _insert(String id, String surface, {String? pos, Map<String, dynamic>? fields}) async {
    await database.insert('lexicon', {
      'id': id,
      'surface': surface,
      'part_of_speech': pos,
      'fields_json': fields != null ? jsonEncode(fields) : null,
    });
  }

  test('safely handles malformed MATCH syntax', () async {
    await _insert('1', 'dog');
    await _createFtsTable();

    final service = FtsSearchService();
    // Inputs that would normally throw if not sanitized
    final inputs = ['dog *', '^*', 'dog"', "dog'"];

    for (final input in inputs) {
      final results = await service.searchDatabase(database, input, languageCode: 'en');
      // Should not throw DatabaseException
      expect(results, isNotNull);
    }
  });

  test('searches missing indexes gracefully', () async {
    await _insert('1', 'cat');
    // FTS table is NOT created here

    final service = FtsSearchService();
    final results = await service.searchDatabase(database, 'cat', languageCode: 'en');

    expect(results.length, 1);
    expect(results.first['surface'], 'cat');
  });

  test('Arabic input', () async {
    await _insert('1', 'كلب', fields: {'translation_ar': 'كلب'});
    await _createFtsTable();

    final service = FtsSearchService();
    final results = await service.searchDatabase(database, 'كلب', languageCode: 'ar');

    expect(results.length, 1);
    expect(results.first['surface'], 'كلب');
  });

  test('Hebrew input', () async {
    await _insert('1', 'כלב', fields: {'translation': 'dog', 'translationLanguageCode': 'en'});
    await _createFtsTable();

    final service = FtsSearchService();
    final results = await service.searchDatabase(database, 'כלב', languageCode: 'he');

    expect(results.length, 1);
    expect(results.first['surface'], 'כלב');
  });

  test('German input', () async {
    await _insert('1', 'hund', fields: {'translation': 'dog', 'translationLanguageCode': 'en'});
    await _createFtsTable();

    final service = FtsSearchService();
    final results = await service.searchDatabase(database, 'hund', languageCode: 'de');

    expect(results.length, 1);
    expect(results.first['surface'], 'hund');
  });

  test('sorts by BM25 and surface matching', () async {
    await _insert('1', 'cat house');
    await _insert('2', 'cat');
    await _insert('3', 'tomcat');
    await _createFtsTable();

    final service = FtsSearchService();
    final results = await service.searchDatabase(database, 'cat', languageCode: 'en');

    // Note: FTS match "cat*" only matches prefix words.
    // 'tomcat' doesn't match 'cat*' unless we do '*cat*'.
    // FTS prefix matches words that start with "cat".
    // So 'cat' and 'cat house' will match. 'tomcat' will not.
    expect(results.length, 2);
    // Exact match 'cat' should be first
    expect(results.first['surface'], 'cat');
  });
}
