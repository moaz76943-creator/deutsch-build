import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/search_fusion_service.dart';
import 'package:deutsch_bilarabi/services/fts_search_service.dart';

void main() {
  late Database db;
  late FtsSearchService fts;

  setUpAll(() async {
    sqfliteFfiInit();
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('''
      CREATE TABLE lexicon(
        id TEXT PRIMARY KEY, surface TEXT, sort_key TEXT,
        language_code TEXT, cefr_level TEXT, part_of_speech TEXT,
        fields_json TEXT
      );
    ''');
    await db.execute('''
      CREATE VIRTUAL TABLE lexicon_fts USING fts5(surface, lemma, gloss, language_code);
    ''');
    fts = FtsSearchService();
  });

  tearDownAll(() async {
    await db.close();
  });

  test('Polysemy: preserves identical surface forms with different ids', () async {
    await db.insert('lexicon', {'id': '1', 'surface': 'Bank', 'fields_json': '{"lemma": "Bank"}'});
    await db.insert('lexicon', {'id': '2', 'surface': 'Bank', 'fields_json': '{"lemma": "Bank"}'});
    await db.insert('lexicon_fts', {'rowid': 1, 'surface': 'Bank', 'lemma': 'Bank'});
    await db.insert('lexicon_fts', {'rowid': 2, 'surface': 'Bank', 'lemma': 'Bank'});

    final service = SearchFusionService(
      search: (q, lang, limit) => fts.searchDatabase(db, q, languageCode: lang, limit: limit)
    );

    final pages = await service.search(
      query: 'Bank',
      activeLanguageCode: 'de',
      mountedLanguages: ['de']
    ).toList();

    final items = pages.last.items;
    expect(items.length, 2);
    expect(items[0].key, 'de|bank|1');
    expect(items[1].key, 'de|bank|2');
  });

  test('CJK/Arabic/German script support', () async {
    await db.insert('lexicon', {'id': '3', 'surface': 'مرحبا', 'fields_json': '{}'});
    await db.insert('lexicon', {'id': '4', 'surface': 'Haus', 'fields_json': '{}'});
    await db.insert('lexicon', {'id': '5', 'surface': '你好', 'fields_json': '{}'});
    await db.insert('lexicon_fts', {'rowid': 3, 'surface': 'مرحبا', 'lemma': 'مرحبا'});
    await db.insert('lexicon_fts', {'rowid': 4, 'surface': 'Haus', 'lemma': 'Haus'});
    await db.insert('lexicon_fts', {'rowid': 5, 'surface': '你好', 'lemma': '你好'});

    final service = SearchFusionService(
      search: (q, lang, limit) => fts.searchDatabase(db, q, languageCode: lang, limit: limit)
    );

    for (final q in ['مرحبا', 'Haus', '你好']) {
      final pages = await service.search(
        query: q,
        activeLanguageCode: 'de',
        mountedLanguages: ['de']
      ).toList();
      expect(pages.last.items.length, 1);
    }
  });

  test('Ranking and pagination logic handles correctly', () async {
    for (int i = 0; i < 30; i++) {
      await db.insert('lexicon', {'id': 'p$i', 'surface': 'Page', 'fields_json': '{}'});
      await db.insert('lexicon_fts', {'rowid': 100 + i, 'surface': 'Page', 'lemma': 'Page'});
    }

    final service = SearchFusionService(
      search: (q, lang, limit) => fts.searchDatabase(db, q, languageCode: lang, limit: limit)
    );

    final pages = await service.search(
      query: 'Page',
      activeLanguageCode: 'de',
      mountedLanguages: ['de'],
      pageSize: 20
    ).toList();

    final completePages = pages.where((p) => p.isComplete).toList();
    expect(completePages.length, 2);
    expect(completePages[0].items.length, 20);
    expect(completePages[1].items.length, 10);
  });
}
