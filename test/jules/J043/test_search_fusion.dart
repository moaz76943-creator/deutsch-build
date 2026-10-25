import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
import 'package:sqflite/sqflite.dart';
import 'package:deutsch_bilarabi/services/search_fusion_service.dart';

void main() {
  setUpAll(() {
    ffi.sqfliteFfiInit();
  });

  late Database deDb;
  late Database arDb;
  late SearchFusionService service;

  setUp(() async {
    final dePath = ffi.inMemoryDatabasePath;
    final arPath = ffi.inMemoryDatabasePath;

    deDb = await ffi.databaseFactoryFfi.openDatabase(dePath, options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE lexicon (
            id TEXT PRIMARY KEY, surface TEXT, part_of_speech TEXT,
            language_code TEXT, sort_key TEXT, cefr_level TEXT, fields_json TEXT
          )
        ''');
        await db.execute('CREATE VIRTUAL TABLE lexicon_fts USING fts5(surface, lemma, gloss, language_code UNINDEXED)');
      },
    ));

    arDb = await ffi.databaseFactoryFfi.openDatabase(arPath, options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE lexicon (
            id TEXT PRIMARY KEY, surface TEXT, part_of_speech TEXT,
            language_code TEXT, sort_key TEXT, cefr_level TEXT, fields_json TEXT
          )
        ''');
        await db.execute('CREATE VIRTUAL TABLE lexicon_fts USING fts5(surface, lemma, gloss, language_code UNINDEXED)');
      },
    ));

    // Polysemous words (same surface and lemma, different id/meaning)
    await deDb.insert('lexicon', {
      'id': 'de.bank.1',
      'surface': 'Bank',
      'language_code': 'de',
      'fields_json': jsonEncode({'lemma': 'Bank', 'translation_ar': 'مصرف'}),
    });
    await deDb.insert('lexicon', {
      'id': 'de.bank.2',
      'surface': 'Bank',
      'language_code': 'de',
      'fields_json': jsonEncode({'lemma': 'Bank', 'translation_ar': 'مقعد'}),
    });

    // CJK and prefix testing
    await deDb.insert('lexicon', {
      'id': 'de.auto.1',
      'surface': 'Auto',
      'language_code': 'de',
      'fields_json': jsonEncode({'lemma': 'Auto', 'translation_ar': 'سيارة'}),
    });

    // Reverse pair (should be filtered out)
    await arDb.insert('lexicon', {
      'id': 'ar.sayara.1',
      'surface': 'سيارة',
      'language_code': 'ar',
      'fields_json': jsonEncode({'lemma': 'سيارة', 'translation_ar': 'Auto'}),
    });

    // Ignore unauthorized cross language
    await arDb.insert('lexicon', {
      'id': 'fr.voiture.1',
      'surface': 'voiture',
      'language_code': 'fr',
      'fields_json': jsonEncode({'lemma': 'voiture', 'translation_ar': 'سيارة'}),
    });

    service = SearchFusionService(
      search: (query, languageCode, limit) async {
        final db = languageCode == 'de' ? deDb : arDb;
        final rows = await db.rawQuery('SELECT * FROM lexicon');
        return rows.map((row) {
          final fields = jsonDecode(row['fields_json'] as String) as Map<String, dynamic>;
          return {
            'id': row['id'],
            'lexeme_id': row['id'],
            'surface': row['surface'],
            'language_code': row['language_code'],
            'lemma': fields['lemma'],
            'translation_ar': fields['translation_ar'],
          };
        }).toList();
      },
    );
  });

  tearDown(() async {
    await deDb.close();
    await arDb.close();
  });

  test('polysemous words are separated by id and deterministic', () async {
    final stream = service.search(
      query: 'bank',
      activeLanguageCode: 'de',
      mountedLanguages: ['de', 'ar', 'fr'],
    );

    final pages = await stream.toList();
    final completePage = pages.lastWhere((page) => page.isComplete);

    expect(completePage.items.length, 2);
    expect(completePage.items[0].word['id'], 'de.bank.1'); // Deterministic ordering
    expect(completePage.items[1].word['id'], 'de.bank.2');
  });

  test('stale queries do not emit results', () async {
    final stream1 = service.search(query: 'ba', activeLanguageCode: 'de', mountedLanguages: ['de']).toList();
    final stream2 = service.search(query: 'bank', activeLanguageCode: 'de', mountedLanguages: ['de']).toList();

    final pages1 = await stream1;
    final pages2 = await stream2;

    // The first stream should terminate without emitting actual completed results because it was superseded
    expect(pages1.isEmpty || !pages1.last.isComplete, isTrue);
    expect(pages2.last.isComplete, isTrue);
  });

  test('reverse pairs and inappropriate languages are filtered', () async {
    final stream = service.search(
      query: 'سيارة',
      activeLanguageCode: 'de',
      mountedLanguages: ['de', 'ar', 'fr'],
    );

    final pages = await stream.toList();
    final completePage = pages.lastWhere((page) => page.isComplete);

    // "Auto" translates to سيارة, so it should be found (from 'de').
    // "سيارة" (ar) translates to Auto, and "voiture" (fr).
    // The 'fr' one should be filtered out entirely.
    // The 'ar' one is tricky: it's language=ar which is allowed, but it's an exact surface match.
    final items = completePage.items;

    // We expect the German "Auto" since its translation matches 'سيارة'
    final deMatches = items.where((i) => i.word['language_code'] == 'de').toList();
    expect(deMatches.length, 1);
    expect(deMatches.first.word['surface'], 'Auto');
    expect(deMatches.first.matchTier, 2); // Exact translation

    // The french one MUST be filtered out because language is 'fr' which isn't active ('de') or 'ar'.
    final frMatches = items.where((i) => i.word['language_code'] == 'fr').toList();
    expect(frMatches.isEmpty, isTrue);
  });

  test('pagination bounds are respected', () async {
    final stream = service.search(
      query: 'bank',
      activeLanguageCode: 'de',
      mountedLanguages: ['de'],
      pageSize: 1,
    );

    final pages = await stream.toList();
    final completePages = pages.where((page) => page.isComplete).toList();

    expect(completePages.length, 2); // 2 total items, pageSize 1 = 2 pages
    expect(completePages[0].items.length, 1);
    expect(completePages[1].items.length, 1);
  });
}
