import 'dart:convert';

import 'package:deutsch_bilarabi/core/services/pack_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

/// Synthetic fixtures verify behavior only. They are not distributable corpus.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(ffi.sqfliteFfiInit);

  late Database db;

  setUp(() async {
    db = await ffi.databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('''
      CREATE TABLE lexicon (
        id TEXT PRIMARY KEY,
        surface TEXT NOT NULL,
        sort_key TEXT NOT NULL,
        language_code TEXT NOT NULL,
        cefr_level TEXT,
        part_of_speech TEXT NOT NULL,
        fields_json TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE senses (
        sense_id TEXT PRIMARY KEY,
        concept_id TEXT NOT NULL,
        lexeme_id TEXT NOT NULL,
        payload_json TEXT NOT NULL
      )
    ''');
    const entries = <List<String>>[
      ['de', 'Haus'], ['ar', 'بيت'], ['en', 'house'],
      ['es', 'casa'], ['fr', 'maison'],
    ];
    for (final entry in entries) {
      final code = entry[0];
      final surface = entry[1];
      await db.insert('lexicon', <String, Object?>{
        'id': 'lex.$code.1',
        'surface': surface,
        'sort_key': surface.toLowerCase(),
        'language_code': code,
        'cefr_level': 'A1',
        'part_of_speech': 'noun',
        'fields_json': jsonEncode(<String, Object?>{
          'morphology': <String, Object?>{'gender': 'unknown'},
        }),
      });
      await db.insert('senses', <String, Object?>{
        'sense_id': 'sense.$code.1',
        'concept_id': 'concept.home',
        'lexeme_id': 'lex.$code.1',
        'payload_json': jsonEncode(<String, Object?>{
          'semantic_tags': <String>['HOME_KITCHEN'],
          'domains': <String>['domain.housing'],
        }),
      });
    }
  });

  tearDown(() async {
    await db.close();
  });

  test('five-language v2 fixture queries never mix languages', () async {
    const expected = <String, String>{
      'de': 'Haus', 'ar': 'بيت', 'en': 'house',
      'es': 'casa', 'fr': 'maison',
    };
    for (final entry in expected.entries) {
      final rows = await PackManager.queryConceptsBySectionFromDb(
        db,
        languageCode: entry.key,
        sectionId: 'HOME_KITCHEN',
        cefr: 'A1',
      );
      expect(rows, hasLength(1), reason: entry.key);
      expect(rows.single['word'], entry.value);
      expect(rows.single['language_code'], entry.key);
      expect(rows.single['lexeme_id'], 'lex.' + entry.key + '.1');
    }
  });

  test('unknown section or level gives empty, not German results', () async {
    final section = await PackManager.queryConceptsBySectionFromDb(
      db, languageCode: 'ar', sectionId: 'PHARMA', cefr: 'A1',
    );
    final cefr = await PackManager.queryConceptsBySectionFromDb(
      db, languageCode: 'fr', sectionId: 'HOME_KITCHEN', cefr: 'B2',
    );
    expect(section, isEmpty);
    expect(cefr, isEmpty);
  });

  test('a bounded query rejects excessive limits', () async {
    await expectLater(
      PackManager.queryConceptsBySectionFromDb(
        db, languageCode: 'fr', sectionId: 'HOME_KITCHEN',
        cefr: 'A1', limit: 51,
      ),
      throwsRangeError,
    );
  });

  test('missing optional exercises are not invented', () async {
    final exercises = await PackManager.queryExercisesFromDb(
      db, conceptId: 'concept.home', languageCode: 'de',
    );
    expect(exercises, isEmpty);
  });

  test('vetted exercise records are selected by language and stable order', () async {
    await db.execute('''
      CREATE TABLE exercises (
        exercise_id TEXT PRIMARY KEY,
        concept_id TEXT NOT NULL,
        language_code TEXT NOT NULL,
        prompt TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        distractors_json TEXT NOT NULL
      )
    ''');
    await db.insert('exercises', <String, Object?>{
      'exercise_id': 'quiz.fr.1',
      'concept_id': 'concept.home',
      'language_code': 'fr',
      'prompt': 'French article',
      'correct_answer': 'la',
      'distractors_json': '["le","les"]',
    });
    await db.insert('exercises', <String, Object?>{
      'exercise_id': 'quiz.de.1',
      'concept_id': 'concept.home',
      'language_code': 'de',
      'prompt': 'German article',
      'correct_answer': 'das',
      'distractors_json': '["der","die"]',
    });
    final de = await PackManager.queryExercisesFromDb(
      db, conceptId: 'concept.home', languageCode: 'de',
    );
    final ar = await PackManager.queryExercisesFromDb(
      db, conceptId: 'concept.home', languageCode: 'ar',
    );
    expect(de, hasLength(1));
    expect(de.single['correct_answer'], 'das');
    expect(ar, isEmpty);
  });

  test('incompatible exercise schema rejects rather than hiding errors', () async {
    await db.execute('CREATE TABLE exercises (concept_id TEXT)');
    await expectLater(
      PackManager.queryExercisesFromDb(
        db, conceptId: 'concept.home', languageCode: 'de',
      ),
      throwsStateError,
    );
  });

  test('a concept maps to a language-scoped lexeme for SRS', () async {
    expect(await PackManager.resolveLexemeIdForConcept(
      db, conceptId: 'concept.home', languageCode: 'de',
    ), 'lex.de.1');
    expect(await PackManager.resolveLexemeIdForConcept(
      db, conceptId: 'concept.home', languageCode: 'es',
    ), 'lex.es.1');
    expect(await PackManager.resolveLexemeIdForConcept(
      db, conceptId: 'lex.fr.1', languageCode: 'fr',
    ), 'lex.fr.1');
    expect(await PackManager.resolveLexemeIdForConcept(
      db, conceptId: 'lex.fr.1', languageCode: 'ar',
    ), isNull);
  });

  test('JSON export cannot return a fictitious file path', () async {
    await expectLater(
      PackManager.exportDatasetAsJson('de'),
      throwsUnsupportedError,
    );
  });

  test('shared concept cannot silently grade a different lexeme', () async {
    await db.insert('lexicon', <String, Object?>{
      'id': 'lex.de.synonym',
      'surface': 'Wohnhaus',
      'sort_key': 'wohnhaus',
      'language_code': 'de',
      'cefr_level': 'A1',
      'part_of_speech': 'noun',
      'fields_json': '{}',
    });
    await db.insert('senses', <String, Object?>{
      'sense_id': 'sense.de.synonym',
      'concept_id': 'concept.home',
      'lexeme_id': 'lex.de.synonym',
      'payload_json': '{}',
    });
    await expectLater(
      PackManager.resolveLexemeIdForConcept(
        db, conceptId: 'concept.home', languageCode: 'de',
      ),
      throwsStateError,
    );
    expect(
      await PackManager.resolveLexemeIdForConcept(
        db, conceptId: 'lex.de.1', languageCode: 'de',
      ),
      'lex.de.1',
    );
  });

  test('invalid language code fails before accessing content', () async {
    await expectLater(
      PackManager.queryConceptsBySectionFromDb(
        db, sectionId: 'HOME_KITCHEN', cefr: 'A1',
        languageCode: 'invalid/language',
      ),
      throwsArgumentError,
    );
  });
}
