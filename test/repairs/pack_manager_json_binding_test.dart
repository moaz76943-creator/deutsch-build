import 'dart:convert';

import 'package:deutsch_bilarabi/core/services/pack_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

/// These records are synthetic SQLite regression fixtures, not public content.
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

    Future<void> add(String id, String language, String word,
        Map<String, Object?> evidence) async {
      await db.insert('lexicon', <String, Object?>{
        'id': id,
        'surface': word,
        'sort_key': word,
        'language_code': language,
        'cefr_level': 'A1',
        'part_of_speech': 'noun',
        'fields_json': '{}',
      });
      await db.insert('senses', <String, Object?>{
        'sense_id': 'sense.$id',
        'concept_id': 'concept.$id',
        'lexeme_id': id,
        'payload_json': jsonEncode(evidence),
      });
    }

    await add('lex.de.tag', 'de', 'Haus',
        <String, Object?>{'semantic_tags': <String>['HOME_KITCHEN']});
    await add('lex.de.domain', 'de', 'Wohnung',
        <String, Object?>{'domains': <String>['domain.housing']});
    await add('lex.ar.tag', 'ar', 'بيت',
        <String, Object?>{'semantic_tags': <String>['HOME_KITCHEN']});
  });

  tearDown(() async => db.close());

  test('semantic_tags JSON path matches its own German row', () async {
    final rows = await PackManager.queryConceptsBySectionFromDb(
      db, sectionId: 'HOME_KITCHEN', cefr: 'A1', languageCode: 'de',
    );
    expect(rows, hasLength(1));
    expect(rows.single['word'], 'Haus');
    expect(rows.single['language_code'], 'de');
  });

  test('domains JSON path matches when semantic_tags is absent', () async {
    final rows = await PackManager.queryConceptsBySectionFromDb(
      db, sectionId: 'domain.housing', cefr: 'A1', languageCode: 'de',
    );
    expect(rows, hasLength(1));
    expect(rows.single['word'], 'Wohnung');
  });

  test('the same evidence never leaks a different language', () async {
    final rows = await PackManager.queryConceptsBySectionFromDb(
      db, sectionId: 'HOME_KITCHEN', cefr: 'A1', languageCode: 'ar',
    );
    expect(rows, hasLength(1));
    expect(rows.single['word'], 'بيت');
    expect(rows.single['language_code'], 'ar');
  });

  test('untrusted apostrophes and SQL syntax are values, not SQL', () async {
    final rows = await PackManager.queryConceptsBySectionFromDb(
      db,
      sectionId: "HOME_KITCHEN' OR 1=1 --",
      cefr: 'A1',
      languageCode: 'de',
    );
    expect(rows, isEmpty);
  });
}
