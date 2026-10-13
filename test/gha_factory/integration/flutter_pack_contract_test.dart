// Independent, non-production Flutter/SQLite contract coverage.
// Route 14 installer end-to-end tests remain gated on PR #55 and GHA-06.
// This test intentionally never downloads or mutates a real learner vault.
import 'dart:convert';
import 'dart:io';

import 'package:deutsch_bilarabi/services/database_service.dart';
import 'package:deutsch_bilarabi/services/language_pack_manager.dart';
import 'package:deutsch_bilarabi/services/pack_downloader_service.dart';
import 'package:flutter/widgets.dart' show TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart' show Database, OpenDatabaseOptions;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> openSyntheticV2Fixture(
  Directory directory,
  String language,
  String token,
) async {
  final db = await databaseFactoryFfi.openDatabase(
    '${directory.path}/fixture-$language.sqlite',
    options: OpenDatabaseOptions(singleInstance: false),
  );
  await db.execute('PRAGMA user_version = 2');
  await db.execute('CREATE TABLE metadata (key TEXT PRIMARY KEY, value TEXT)');
  await db.execute('CREATE TABLE schema_migrations (version TEXT)');
  await db.execute('CREATE TABLE concepts (id TEXT)');
  await db.execute('''
    CREATE TABLE lexicon (
      id TEXT PRIMARY KEY, surface TEXT, sort_key TEXT,
      language_code TEXT, cefr_level TEXT,
      part_of_speech TEXT, fields_json TEXT
    )
  ''');
  await db.execute('''
    CREATE TABLE senses (
      sense_id TEXT, lexeme_id TEXT, concept_id TEXT, payload_json TEXT
    )
  ''');
  await db.execute('CREATE TABLE translations (id TEXT)');
  await db.execute('''
    CREATE TABLE examples (
      example_id TEXT, lexeme_id TEXT, language_code TEXT, text TEXT
    )
  ''');
  await db.execute('CREATE TABLE lexical_relations (id TEXT)');
  await db.execute('CREATE TABLE grammar (id TEXT)');
  await db.execute('CREATE VIEW lexemes AS SELECT * FROM lexicon');
  await db.execute('CREATE VIRTUAL TABLE lexicon_fts USING fts5(surface)');
  for (final item in <String, String>{
    'mapping_version': '2.0.0',
    'contract_version': '1.0.0',
    'language_code': language,
  }.entries) {
    await db.insert('metadata', <String, Object?>{
      'key': item.key,
      'value': item.value,
    });
  }
  await db.insert('lexicon', <String, Object?>{
    'id': 'fixture-$language',
    'surface': token,
    'sort_key': token,
    'language_code': language,
    'cefr_level': 'A1',
    'part_of_speech': 'fixture',
    'fields_json': jsonEncode(<String, Object>{'lemma': token}),
  });
  return db;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('pack-integration-contract-');
  });
  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  const tokens = <String, String>{
    'de': 'Äpfel',
    'ar': 'مِثَال',
    'en': 'sample',
    'es': 'niño',
    'fr': 'élève',
  };

  for (final entry in tokens.entries) {
    test('Route 15 accepts isolated synthetic SQLite v2 ${entry.key}', () async {
      final db = await openSyntheticV2Fixture(temp, entry.key, entry.value);
      try {
        await expectLater(
          DatabaseService.instance.verifyUniversalSchema(db, entry.key),
          completes,
        );
        final rows = await db.rawQuery(
          'SELECT surface FROM lexicon WHERE language_code = ? LIMIT ?',
          <Object?>[entry.key, 20],
        );
        expect(rows.single['surface'], entry.value);
      } finally {
        await db.close();
      }
    });

    test('Route 15 rejects ${entry.key} fixture as a different language', () async {
      final db = await openSyntheticV2Fixture(temp, entry.key, entry.value);
      try {
        final wrong = entry.key == 'de' ? 'fr' : 'de';
        await expectLater(
          DatabaseService.instance.verifyUniversalSchema(db, wrong),
          throwsA(isA<StateError>()),
        );
      } finally {
        await db.close();
      }
    });
  }

  test('Route 15 rejects incompatible SQLite user_version', () async {
    final db = await openSyntheticV2Fixture(temp, 'ar', 'مِثَال');
    try {
      await db.execute('PRAGMA user_version = 1');
      await expectLater(
        DatabaseService.instance.verifyUniversalSchema(db, 'ar'),
        throwsA(isA<StateError>()),
      );
    } finally {
      await db.close();
    }
  });

  test('Route 15 rejects missing FTS5 virtual table', () async {
    final db = await openSyntheticV2Fixture(temp, 'fr', 'élève');
    try {
      await db.execute('DROP TABLE lexicon_fts');
      await expectLater(
        DatabaseService.instance.verifyUniversalSchema(db, 'fr'),
        throwsA(isA<StateError>()),
      );
    } finally {
      await db.close();
    }
  });

  test('Route 15 rejects empty foreign-language lexicon', () async {
    final db = await openSyntheticV2Fixture(temp, 'es', 'niño');
    try {
      await db.delete('lexicon');
      await expectLater(
        DatabaseService.instance.verifyUniversalSchema(db, 'es'),
        throwsA(isA<StateError>()),
      );
    } finally {
      await db.close();
    }
  });

  test('Route 15 rejects incompatible mapping version', () async {
    final db = await openSyntheticV2Fixture(temp, 'de', 'Äpfel');
    try {
      await db.update(
        'metadata', <String, Object?>{'value': '1.0.0'},
        where: 'key = ?', whereArgs: <Object?>['mapping_version'],
      );
      await expectLater(
        DatabaseService.instance.verifyUniversalSchema(db, 'de'),
        throwsA(isA<StateError>()),
      );
    } finally {
      await db.close();
    }
  });

  test('CJK Unicode remains unchanged in isolated SQLite fixture', () async {
    final db = await openSyntheticV2Fixture(temp, 'zh', '中文検索');
    try {
      await DatabaseService.instance.verifyUniversalSchema(db, 'zh');
      final rows = await db.rawQuery(
        'SELECT surface FROM lexicon WHERE language_code = ? LIMIT ?',
        <Object?>['zh', 1],
      );
      expect(rows.single['surface'], '中文検索');
    } finally {
      await db.close();
    }
  });

  test('SQL language filter never silently substitutes German', () async {
    final db = await openSyntheticV2Fixture(temp, 'es', 'niño');
    try {
      final german = await db.rawQuery(
        'SELECT surface FROM lexicon WHERE language_code = ? LIMIT ?',
        <Object?>['de', 20],
      );
      expect(german, isEmpty);
    } finally {
      await db.close();
    }
  });

  test('language direction respects Arabic and Latin-script sources', () {
    final packs = LanguagePackManager();
    expect(packs.textDirectionFor('ar'), TextDirection.rtl);
    expect(packs.textDirectionFor('ar-Latn'), TextDirection.ltr);
    expect(packs.textDirectionFor('en'), TextDirection.ltr);
    expect(packs.textDirectionFor('de'), TextDirection.ltr);
  });

  test('translation language tag remains independent of source and UI', () {
    final englishDefinition = DatabaseService.resolveLexiconTranslation(
      <String, dynamic>{
        'translations': <Map<String, String>>[
          <String, String>{'text': 'probe', 'languageCode': 'en'},
        ],
      },
    );
    expect(englishDefinition?.text, 'probe');
    expect(englishDefinition?.languageCode, 'en');
    final arabicDefinition = DatabaseService.resolveLexiconTranslation(
      <String, dynamic>{'translation_ar': 'تجربة'},
    );
    expect(arabicDefinition?.languageCode, 'ar');
  });

  test('downloader rejects HTTP manifest before network access', () async {
    expect(
      await PackDownloaderService.downloadPack(
        'fr',
        manifestUrl: 'http://127.0.0.1:1/manifest.json',
      ),
      isFalse,
    );
  });

  test('gzip expansion cap rejects oversized synthetic envelope', () async {
    final original = utf8.encode(List<String>.filled(256, 'probe').join());
    final compressed = gzip.encode(original);
    await expectLater(
      PackDownloaderService.decodeGzipEnvelope(
        Stream<List<int>>.value(compressed),
        maxExpandedBytes: 128,
      ),
      throwsA(isA<StateError>()),
    );
  });
}
