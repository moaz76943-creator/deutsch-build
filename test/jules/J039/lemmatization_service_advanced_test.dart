import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/lemmatization_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/lexeme_fixture_db.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('LemmatizationService Advanced Tests', () {
    late LemmatizationService service;

    setUp(() async {
      final db = await openLexemeFixtureDb();
      addTearDown(db.close);
      service = LemmatizationService(openContentDb: (_) async => db);

      // Insert Hebrew/Arabic ambiguity and unsupported CJK forms
      final batch = db.batch();

      // Turkish suffix forms
      batch.insert('language_profiles', {'language_code': 'tr', 'name_native': 'Türkçe', 'name_ar': 'التركية', 'direction': 'ltr'}, conflictAlgorithm: ConflictAlgorithm.ignore);
      batch.insert('concepts', {'concept_id': 'daily.ev', 'category': 'daily', 'cefr_level': 'A1'}, conflictAlgorithm: ConflictAlgorithm.ignore);
      batch.insert('lexemes', {'lexeme_id': 'lex.tr.ev', 'concept_id': 'daily.ev', 'language_code': 'tr', 'lemma': 'ev', 'display_text': 'ev', 'plural': 'evler'}, conflictAlgorithm: ConflictAlgorithm.ignore);

      // Hebrew/Arabic ambiguity
      batch.insert('language_profiles', {'language_code': 'he', 'name_native': 'עברית', 'name_ar': 'العبرية', 'direction': 'rtl'}, conflictAlgorithm: ConflictAlgorithm.ignore);
      batch.insert('concepts', {'concept_id': 'daily.sefer', 'category': 'daily', 'cefr_level': 'A1'}, conflictAlgorithm: ConflictAlgorithm.ignore);
      batch.insert('lexemes', {'lexeme_id': 'lex.he.sefer', 'concept_id': 'daily.sefer', 'language_code': 'he', 'lemma': 'ספר', 'display_text': 'סֵפֶר', 'plural': 'ספרים'}, conflictAlgorithm: ConflictAlgorithm.ignore);

      batch.insert('concepts', {'concept_id': 'daily.kitab', 'category': 'daily', 'cefr_level': 'A1'}, conflictAlgorithm: ConflictAlgorithm.ignore);
      batch.insert('lexemes', {'lexeme_id': 'lex.ar.kitab', 'concept_id': 'daily.kitab', 'language_code': 'ar', 'lemma': 'كتاب', 'display_text': 'كِتَاب', 'plural': 'كتب'}, conflictAlgorithm: ConflictAlgorithm.ignore);

      // Unsupported CJK forms
      batch.insert('language_profiles', {'language_code': 'ja', 'name_native': '日本語', 'name_ar': 'اليابانية', 'direction': 'ltr'}, conflictAlgorithm: ConflictAlgorithm.ignore);
      batch.insert('concepts', {'concept_id': 'daily.hon', 'category': 'daily', 'cefr_level': 'A1'}, conflictAlgorithm: ConflictAlgorithm.ignore);
      batch.insert('lexemes', {'lexeme_id': 'lex.ja.hon', 'concept_id': 'daily.hon', 'language_code': 'ja', 'lemma': '本', 'display_text': '本'}, conflictAlgorithm: ConflictAlgorithm.ignore);

      await batch.commit(noResult: true);
    });

    test('Turkish suffix forms', () async {
      final results = await service.resolveLemma('evler', 'tr');
      expect(results.length, 1);
      expect(results.first.lemma, 'ev');
    });

    test('Hebrew ambiguity with display text', () async {
      final results = await service.resolveLemma('ספר', 'he');
      expect(results.length, 1);
      expect(results.first.lemma, 'ספר');

      final resultsWithNiqqud = await service.resolveLemma('סֵפֶר', 'he');
      expect(resultsWithNiqqud.length, 1);
      expect(resultsWithNiqqud.first.lemma, 'ספר');
    });

    test('Arabic ambiguity with diacritics', () async {
      final results = await service.resolveLemma('كتاب', 'ar');
      expect(results.length, 1);
      expect(results.first.lemma, 'كتاب');

      final resultsWithTashkeel = await service.resolveLemma('كِتَاب', 'ar');
      expect(resultsWithTashkeel.length, 1);
      expect(resultsWithTashkeel.first.lemma, 'كتاب');
    });

    test('Unsupported CJK forms', () async {
      final results = await service.resolveLemma('本', 'ja');
      expect(results.length, 1);
      expect(results.first.lemma, '本');
    });
  });
}
