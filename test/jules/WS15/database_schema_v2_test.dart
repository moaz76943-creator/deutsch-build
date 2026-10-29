import 'package:deutsch_bilarabi/services/database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

/// Synthetic database records only. Never a production pack or learner vault.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(ffi.sqfliteFfiInit);

  late Database db;

  setUp(() async {
    db = await ffi.databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> createCanonicalFixture(String language) async {
    await db.execute('PRAGMA user_version = 2');
    await db.execute('CREATE TABLE metadata (key TEXT PRIMARY KEY, value TEXT)');
    await db.execute('CREATE TABLE schema_migrations (version TEXT)');
    await db.execute('CREATE TABLE concepts (concept_id TEXT PRIMARY KEY)');
    await db.execute('''
      CREATE TABLE lexicon (
        id TEXT PRIMARY KEY, surface TEXT, part_of_speech TEXT,
        language_code TEXT, sort_key TEXT, cefr_level TEXT, fields_json TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE senses (
        sense_id TEXT, lexeme_id TEXT, concept_id TEXT, payload_json TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE examples (
        example_id TEXT, lexeme_id TEXT, language_code TEXT, text TEXT
      )
    ''');
    await db.execute('CREATE TABLE translations (translation_id TEXT)');
    await db.execute('CREATE TABLE lexical_relations (relation_id TEXT)');
    await db.execute('CREATE TABLE grammar (grammar_id TEXT)');
    await db.execute('''
      CREATE VIEW lexemes AS
      SELECT id, surface, part_of_speech, fields_json FROM lexicon
    ''');
    await db.execute('''
      CREATE VIRTUAL TABLE lexicon_fts
      USING fts5(surface, lemma, gloss, language_code UNINDEXED)
    ''');
    for (final entry in <String, String>{
      'mapping_version': '2.0.0',
      'contract_version': '1.0.0',
      'language_code': language,
    }.entries) {
      await db.insert('metadata', <String, Object>{
        'key': entry.key, 'value': entry.value,
      });
    }
    await db.insert('lexicon', <String, Object>{
      'id': 'lex.$language.1',
      'surface': 'test',
      'part_of_speech': 'noun',
      'language_code': language,
      'sort_key': 'test',
      'cefr_level': 'A1',
      'fields_json': '{}',
    });
  }

  test('valid immutable content schema is admitted for requested language', () async {
    await createCanonicalFixture('fr');
    await DatabaseService.instance.verifyUniversalSchema(db, 'fr');
  });

  test('German metadata never passes for selected Arabic pack', () async {
    await createCanonicalFixture('de');
    await expectLater(
      DatabaseService.instance.verifyUniversalSchema(db, 'ar'),
      throwsStateError,
    );
  });

  test('SQLite user version 1 is explicitly rejected', () async {
    await createCanonicalFixture('en');
    await db.execute('PRAGMA user_version = 1');
    await expectLater(
      DatabaseService.instance.verifyUniversalSchema(db, 'en'),
      throwsStateError,
    );
  });

  test('missing required lexicon sort key rejects legacy schema', () async {
    await createCanonicalFixture('es');
    await db.execute('ALTER TABLE lexicon DROP COLUMN sort_key');
    await expectLater(
      DatabaseService.instance.verifyUniversalSchema(db, 'es'),
      throwsStateError,
    );
  });

  test('metadata alone never counts as a real Arabic content pack', () async {
    await createCanonicalFixture('ar');
    await db.delete('lexicon');
    await expectLater(
      DatabaseService.instance.verifyUniversalSchema(db, 'ar'),
      throwsStateError,
    );
  });
}
