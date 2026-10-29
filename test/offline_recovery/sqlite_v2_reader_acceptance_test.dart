import 'package:deutsch_bilarabi/services/database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Synthetic SQLite v2 contract fixture. This deliberately uses a real SQLite
/// handle but never mounts, modifies, or repairs any installed learner pack.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);

  Future<Database> fixture({
    required bool virtualFts,
    required bool orphanedExample,
  }) async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    await db.execute('PRAGMA foreign_keys = OFF');
    await db.execute('PRAGMA user_version = 2');
    await db.execute('CREATE TABLE metadata (key TEXT PRIMARY KEY, value TEXT)');
    await db.execute('CREATE TABLE schema_migrations (version INTEGER)');
    await db.execute('CREATE TABLE concepts (concept_id TEXT PRIMARY KEY)');
    await db.execute('''
      CREATE TABLE lexicon (
        id TEXT PRIMARY KEY, surface TEXT, sort_key TEXT,
        language_code TEXT, cefr_level TEXT, part_of_speech TEXT,
        fields_json TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE senses (
        sense_id TEXT PRIMARY KEY, lexeme_id TEXT, concept_id TEXT,
        payload_json TEXT
      )
    ''');
    await db.execute('CREATE TABLE translations (translation_id TEXT)');
    await db.execute('''
      CREATE TABLE examples (
        example_id TEXT, lexeme_id TEXT REFERENCES lexicon(id),
        language_code TEXT, text TEXT
      )
    ''');
    await db.execute('CREATE TABLE lexical_relations (relation_id TEXT)');
    await db.execute('CREATE TABLE grammar (grammar_id TEXT)');
    await db.execute('''
      CREATE VIEW lexemes AS SELECT id, surface, part_of_speech, fields_json
      FROM lexicon
    ''');
    if (virtualFts) {
      await db.execute('''
        CREATE VIRTUAL TABLE lexicon_fts
        USING fts5(surface, lemma, gloss, language_code UNINDEXED)
      ''');
    } else {
      // Name and sqlite_master.type='table' look right; MATCH will fail.
      await db.execute('''
        CREATE TABLE lexicon_fts (
          surface TEXT, lemma TEXT, gloss TEXT, language_code TEXT
        )
      ''');
    }
    for (final entry in <String, String>{
      'mapping_version': '2.0.0',
      'contract_version': '1.0.0',
      'language_code': 'fr',
    }.entries) {
      await db.insert('metadata', <String, Object?>{
        'key': entry.key,
        'value': entry.value,
      });
    }
    await db.insert('lexicon', <String, Object?>{
      'id': 'lex-good-1',
      'surface': 'bonjour',
      'sort_key': 'bonjour',
      'language_code': 'fr',
      'cefr_level': 'A1',
      'part_of_speech': 'interjection',
      'fields_json': '{}',
    });
    if (orphanedExample) {
      await db.insert('examples', <String, Object?>{
        'example_id': 'example-orphan',
        'lexeme_id': 'lex-MISSING',
        'language_code': 'fr',
        'text': 'synthetic fixture only',
      });
    }
    return db;
  }

  test('v2 reader rejects ordinary table impersonating FTS5 virtual table',
      () async {
    final db = await fixture(virtualFts: false, orphanedExample: false);
    addTearDown(db.close);
    expect(
      (await db.rawQuery('PRAGMA integrity_check')).single.values.single,
      'ok',
    );
    final master = await db.rawQuery(
      "SELECT type FROM sqlite_master WHERE name = 'lexicon_fts'",
    );
    expect(master.single['type'], 'table');

    // Expected RED on staging: verifyUniversalSchema currently checks only
    // sqlite_master.type == 'table', not actual FTS5 MATCH capability.
    await expectLater(
      DatabaseService.instance.verifyUniversalSchema(db, 'fr'),
      throwsStateError,
    );
  });

  test('v2 reader rejects orphaned examples despite passing integrity_check',
      () async {
    final db = await fixture(virtualFts: true, orphanedExample: true);
    addTearDown(db.close);
    expect(
      (await db.rawQuery('PRAGMA integrity_check')).single.values.single,
      'ok',
    );
    expect(await db.rawQuery('PRAGMA foreign_key_check'), isNotEmpty);

    // Expected RED on staging: the reader checks integrity through quick_check
    // but verifyUniversalSchema does not reject dangling FK relationships.
    await expectLater(
      DatabaseService.instance.verifyUniversalSchema(db, 'fr'),
      throwsStateError,
    );
  });

  test('v2 reader accepts a correctly shaped, FK-intact FTS5 fixture',
      () async {
    final db = await fixture(virtualFts: true, orphanedExample: false);
    addTearDown(db.close);
    expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    await DatabaseService.instance.verifyUniversalSchema(db, 'fr');
  });
}
