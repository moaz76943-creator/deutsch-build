import 'dart:convert';

import 'package:deutsch_bilarabi/services/fts_search_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

// Synthetic, in-memory fixtures only. No pack publication or learner DB access.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(ffi.sqfliteFfiInit);
  late Database db;
  late FtsSearchService service;

  setUp(() async {
    service = FtsSearchService();
    db = await ffi.databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('''
      CREATE TABLE lexicon (
        id TEXT PRIMARY KEY, surface TEXT NOT NULL,
        part_of_speech TEXT NOT NULL, fields_json TEXT NOT NULL,
        language_code TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_lexicon_surface '
        'ON lexicon(language_code, surface)');
    await db.execute("CREATE VIRTUAL TABLE lexicon_fts USING "
        "fts5(surface, tokenize='unicode61 remove_diacritics 0')");
    const tokens = <String, String>{
      'de': 'shared', 'ar': 'shared', 'fr': 'shared',
      'de.umlaut': 'Äpfel', 'de.sharp': 'Straße',
      'ar.diacritic': 'مِثَال', 'tr': 'İzmir', 'tr.dotless': 'ırmak',
      'ja': '日本語検索', 'zh': '中文搜索', 'ko': '한국어',
      'hi': 'नमस्ते', 'he': 'שלום', 'en.literal': '100%_literal',
    };
    for (final entry in tokens.entries) {
      final rowid = await db.insert('lexicon', <String, Object?>{
        'id': entry.key, 'surface': entry.value,
        'part_of_speech': 'fixture',
        'fields_json': jsonEncode(<String, String>{'lemma': entry.value}),
        'language_code': entry.key.split('.').first,
      });
      await db.rawInsert('INSERT INTO lexicon_fts(rowid, surface) VALUES (?, ?)',
          <Object?>[rowid, entry.value]);
    }
  });

  tearDown(() async => db.close());

  Future<List<Map<String, dynamic>>> search(String term, String code,
      {int limit = 50}) => service.searchDatabase(
        db, term, languageCode: code, limit: limit,
      );

  test('empty query lists only the selected language', () async {
    final rows = await search('', 'ar');
    expect(rows.map((r) => r['id']).toSet(), <String>{'ar', 'ar.diacritic'});
    expect(rows.every((r) => r['language_code'] == 'ar'), isTrue);
  });

  test('FTS shared spelling cannot leak or relabel another language', () async {
    for (final code in <String>['de', 'ar', 'fr']) {
      final rows = await search('shared', code);
      expect(rows.map((r) => r['id']), <String>[code]);
    }
  });

  test('short prefix remains language-scoped', () async {
    expect((await search('sh', 'fr')).map((r) => r['id']), <String>['fr']);
  });

  test('empty unicode61 MATCH uses prefix then substring fallback', () async {
    expect((await search('Äpf', 'de')).single['surface'], 'Äpfel');
    expect((await search('har', 'ar')).map((r) => r['id']), <String>['ar']);
    expect((await search('日本語', 'ja')).single['surface'], '日本語検索');
  });

  test('prefix and substring pages exclude duplicates and foreign rows', () async {
    await db.insert('lexicon', <String, Object?>{
      'id': 'ar.extra', 'surface': 'xshared', 'part_of_speech': 'fixture',
      'fields_json': '{}', 'language_code': 'ar',
    });
    final rows = await search('sh', 'ar', limit: 2);
    expect(rows.map((r) => r['id']), <String>['ar', 'ar.extra']);
    expect(rows.map((r) => r['id']).toSet(), hasLength(2));
  });

  test('missing FTS uses scoped fallback without changing content', () async {
    await db.execute('DROP TABLE lexicon_fts');
    expect((await search('shared', 'ar')).map((r) => r['id']), <String>['ar']);
    expect(await db.rawQuery('SELECT COUNT(*) AS n FROM lexicon'),
        <Map<String, Object?>>[<String, Object?>{'n': 14}]);
  });

  test('suggestions only use requested-language candidates', () async {
    final feedback = await service.searchDatabaseWithFeedback(
      db, 'shard', languageCode: 'ar',
    );
    expect(feedback.results, isEmpty);
    expect(feedback.suggestions, <String>['shared']);
    final unavailable = await service.searchDatabaseWithFeedback(
      db, 'shard', languageCode: 'xx',
    );
    expect(unavailable.results, isEmpty);
    expect(unavailable.suggestions, isEmpty);
  });

  test('Unicode, combining marks and scripts remain original', () async {
    const examples = <String, String>{
      'de': 'Äpfel', 'ar': 'مِثَال', 'tr': 'İzmir', 'ja': '日本語検索',
      'zh': '中文搜索', 'ko': '한국어', 'hi': 'नमस्ते', 'he': 'שלום',
    };
    for (final entry in examples.entries) {
      expect((await search(entry.value, entry.key)).single['surface'], entry.value);
    }
  });

  test('German umlauts and sharp s are not rewritten', () async {
    expect((await search('Straße', 'de')).single['surface'], 'Straße');
    expect(await search('Strasse', 'de'), isEmpty);
    expect(await search('Apfel', 'de'), isEmpty);
  });

  test('Turkish original dotted and dotless I exact forms remain searchable', () async {
    expect((await search('İzmir', 'tr')).single['surface'], 'İzmir');
    expect((await search('ırmak', 'tr')).single['surface'], 'ırmak');
    // Locale-specific case folding is not claimed by these exact-form tests.
  });

  test('unknown language produces no German fallback', () async {
    expect(await search('', 'xx'), isEmpty);
    expect(await search('shared', 'xx'), isEmpty);
  });

  test('parameters escape SQL and LIKE metacharacters', () async {
    expect(await search("' OR 1=1 --", 'ar'), isEmpty);
    // Force fallback to exercise literal wildcard escaping.
    await db.execute('DROP TABLE lexicon_fts');
    expect((await search('100%_', 'en')).single['surface'], '100%_literal');
    expect(await search('%', 'ar'), isEmpty);
  });

  test('page limits stay bounded and invalid limits fail', () async {
    expect(await search('', 'de', limit: 1), hasLength(1));
    await expectLater(search('', 'de', limit: 0), throwsRangeError);
    await expectLater(search('', 'de', limit: 51), throwsRangeError);
  });

  test('language normalization agrees with existing DatabaseService', () async {
    expect((await search('shared', ' DE_de ')).single['language_code'], 'de');
    expect((await search('shared', ' AR ')).single['language_code'], 'ar');
    await expectLater(search('', "ar' OR 1=1"), throwsArgumentError);
  });
}
