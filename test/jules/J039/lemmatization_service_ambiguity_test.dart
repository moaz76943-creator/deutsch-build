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

  group('LemmatizationService Ambiguity Tests', () {
    late LemmatizationService service;

    setUp(() async {
      final db = await openLexemeFixtureDb();
      addTearDown(db.close);
      service = LemmatizationService(openContentDb: (_) async => db);

      // Insert ambiguous candidates
      final batch = db.batch();

      // Two senses for "Bank"
      batch.insert('concepts', {'concept_id': 'daily.bank.institution', 'category': 'daily', 'cefr_level': 'A1'}, conflictAlgorithm: ConflictAlgorithm.ignore);
      batch.insert('lexemes', {'lexeme_id': 'lex.de.bank.institution', 'concept_id': 'daily.bank.institution', 'language_code': 'de', 'lemma': 'Bank', 'display_text': 'die Bank', 'plural': 'Banken'}, conflictAlgorithm: ConflictAlgorithm.ignore);

      batch.insert('concepts', {'concept_id': 'daily.bank.seat', 'category': 'daily', 'cefr_level': 'A1'}, conflictAlgorithm: ConflictAlgorithm.ignore);
      batch.insert('lexemes', {'lexeme_id': 'lex.de.bank.seat', 'concept_id': 'daily.bank.seat', 'language_code': 'de', 'lemma': 'Bank', 'display_text': 'die Bank', 'plural': 'Bänke'}, conflictAlgorithm: ConflictAlgorithm.ignore);

      await batch.commit(noResult: true);
    });

    test('Ambiguous candidates remain distinguishable', () async {
      final results = await service.resolveLemma('Bank', 'de');
      expect(results.length, 2);
      expect(results.every((r) => r.lemma == 'Bank'), true);
      // We can distinguish them using senseId
      expect(results.any((r) => r.senseId == 'daily.bank.institution'), true);
      expect(results.any((r) => r.senseId == 'daily.bank.seat'), true);
    });

    test('Plural resolves to specific sense', () async {
      final results1 = await service.resolveLemma('Banken', 'de');
      expect(results1.length, 1);
      expect(results1.first.lemma, 'Bank');
      expect(results1.first.senseId, 'daily.bank.institution');

      final results2 = await service.resolveLemma('Bänke', 'de');
      expect(results2.length, 1);
      expect(results2.first.lemma, 'Bank');
      expect(results2.first.senseId, 'daily.bank.seat');
    });
  });
}
