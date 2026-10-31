import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Small writable lexeme database for tests.
///
/// This is not a production content pack and is never written to
/// `assets/content/packs/de/sqlite/de-1.0.0.sqlite`. Rows are the same
/// attested seed the app would insert into an empty content schema:
/// Wasser, Buch/Bücher, and Auto.
Future<Database> openLexemeFixtureDb() async {
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(singleInstance: false),
  );
  await db.execute('''
    CREATE TABLE language_profiles (
      language_code TEXT PRIMARY KEY,
      name_native TEXT NOT NULL,
      name_ar TEXT NOT NULL,
      direction TEXT NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE concepts (
      concept_id TEXT PRIMARY KEY,
      category TEXT NOT NULL,
      cefr_level TEXT NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE lexemes (
      lexeme_id TEXT PRIMARY KEY,
      concept_id TEXT NOT NULL,
      language_code TEXT NOT NULL,
      lemma TEXT NOT NULL,
      display_text TEXT NOT NULL,
      article TEXT,
      plural TEXT,
      gender TEXT,
      grammar_json TEXT DEFAULT '{}'
    )
  ''');
  final batch = db.batch();
  batch.insert('language_profiles', {
    'language_code': 'de',
    'name_native': 'Deutsch',
    'name_ar': 'الألمانية',
    'direction': 'ltr',
  });
  batch.insert('language_profiles', {
    'language_code': 'ar',
    'name_native': 'العربية',
    'name_ar': 'العربية',
    'direction': 'rtl',
  });
  batch.insert('concepts', {
    'concept_id': 'daily.water',
    'category': 'daily',
    'cefr_level': 'A1',
  });
  batch.insert('concepts', {
    'concept_id': 'daily.book',
    'category': 'daily',
    'cefr_level': 'A1',
  });
  batch.insert('concepts', {
    'concept_id': 'daily.car',
    'category': 'daily',
    'cefr_level': 'A1',
  });
  batch.insert('lexemes', {
    'lexeme_id': 'lex.de.water',
    'concept_id': 'daily.water',
    'language_code': 'de',
    'lemma': 'Wasser',
    'display_text': 'das Wasser',
    'article': 'das',
    'gender': 'n',
  });
  batch.insert('lexemes', {
    'lexeme_id': 'lex.de.book',
    'concept_id': 'daily.book',
    'language_code': 'de',
    'lemma': 'Buch',
    'display_text': 'das Buch',
    'article': 'das',
    'plural': 'Bücher',
    'gender': 'n',
  });
  batch.insert('lexemes', {
    'lexeme_id': 'lex.de.car',
    'concept_id': 'daily.car',
    'language_code': 'de',
    'lemma': 'Auto',
    'display_text': 'das Auto',
    'article': 'das',
    'plural': 'Autos',
    'gender': 'n',
  });
  await batch.commit(noResult: true);
  return db;
}
