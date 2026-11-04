import 'package:deutsch_bilarabi/services/lemmatization_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/database_service.dart';

import '../../support/lexeme_fixture_db.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final db = await DatabaseService.instance.contentDb;

    // Test with actual morphological_forms table structure also if available
    try {
      await db.execute('ALTER TABLE lexemes ADD COLUMN sense_id TEXT;');
    } catch (_) {}
    try {
      await db.execute('ALTER TABLE lexemes ADD COLUMN part_of_speech TEXT;');
    } catch (_) {}

    await db.execute('DELETE FROM lexemes');
    await db.execute('DROP TABLE IF EXISTS morphology_forms');
    await db.execute('CREATE TABLE morphology_forms (form TEXT, lemma TEXT, lang TEXT, sense_id TEXT, part_of_speech TEXT)');

    // Insert into morphology_forms
    await db.insert('morphology_forms', {
        'form': 'ging', 'lemma': 'gehen', 'lang': 'de', 'sense_id': 's1', 'part_of_speech': 'verb'
    });
    // Tr fallback
    await db.insert('lexemes', {
        'lexeme_id': 'geliyorum', 'concept_id': 'mock', 'language_code': 'tr', 'lemma': 'gelmek', 'display_text': 'geliyorum', 'part_of_speech': 'verb', 'sense_id': 's2'
    });
    // Hebrew ambiguity
    await db.insert('morphology_forms', {
        'form': 'ספר', 'lemma': 'סֵפֶר', 'lang': 'he', 'sense_id': 's3', 'part_of_speech': 'noun'
    });
    await db.insert('morphology_forms', {
        'form': 'ספר', 'lemma': 'סַפָּר', 'lang': 'he', 'sense_id': 's4', 'part_of_speech': 'noun'
    });
    // Fallback dictionary
    await db.insert('lexemes', {
        'lexeme_id': 'water', 'concept_id': 'mock', 'language_code': 'de', 'lemma': 'Wasser', 'display_text': 'das Wasser', 'part_of_speech': 'noun', 'sense_id': 's5'
    });
  });

  test('resolveLemmas resolves attested German form from morphology', () async {
    final service = LemmatizationService();
    final results = await service.resolveLemmas(form: 'ging', languageCode: 'de', packIdentity: 'mock-pack');
    expect(results.length, 1);
    expect(results.first.lemma, 'gehen');
    expect(results.first.senseId, 's1');
  });

    setUp(() async {
      final db = await openLexemeFixtureDb();
      addTearDown(db.close);
      service = LemmatizationService(openContentDb: (_) async => db);
    });

  test('resolveLemmas resolves ambiguous Hebrew candidates from morphology', () async {
    final service = LemmatizationService();
    final results = await service.resolveLemmas(form: 'ספר', languageCode: 'he', packIdentity: 'mock-pack');
    expect(results.length, 2);
    final lemmas = results.map((e) => e.lemma).toList();
    expect(lemmas, contains('סֵפֶר'));
    expect(lemmas, contains('סַפָּר'));
    final senses = results.map((e) => e.senseId).toList();
    expect(senses, contains('s3'));
    expect(senses, contains('s4'));
  });

  test('resolveLemmas handles unsupported CJK forms by returning empty', () async {
    final service = LemmatizationService();
    final results = await service.resolveLemmas(form: '你好', languageCode: 'zh', packIdentity: 'mock-pack');
    expect(results, isEmpty);
  });

  test('resolveLemmas resolves attested form fallback from lexemes', () async {
    final service = LemmatizationService();
    final results = await service.resolveLemmas(form: 'Wasser', languageCode: 'de', packIdentity: 'mock-pack');
    expect(results.length, 1);
    expect(results.first.lemma, 'Wasser');
  });

  test('resolveLemmas returns empty list for unattested forms', () async {
    final service = LemmatizationService();
    final results = await service.resolveLemmas(form: 'unattested_xyz', languageCode: 'de', packIdentity: 'mock-pack');
    expect(results, isEmpty);
  });
}
