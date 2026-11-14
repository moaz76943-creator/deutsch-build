import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/curriculum/case_agreement_conformance_guard.dart';

void main() {
  group('CaseAgreementConformanceGuard Unit Tests (N038)', () {
    final guard = CaseAgreementConformanceGuard();

    test('Validates masculine accusative article and adjective inflection (den großen Hund)', () {
      final report = guard.validateDefiniteNounPhrase(
        article: 'den',
        adjective: 'großen',
        noun: 'Hund',
        expectedCase: GrammaticalCase.accusative,
        expectedGender: GrammaticalGender.masculine,
      );

      expect(report.isValid, isTrue);
      expect(report.correctedPhrase, equals('den großen Hund'));
    });

    test('Corrects common masculine accusative error (der große Hund in direct object slot)', () {
      final report = guard.validateDefiniteNounPhrase(
        article: 'der',
        adjective: 'große',
        noun: 'Hund',
        expectedCase: GrammaticalCase.accusative,
        expectedGender: GrammaticalGender.masculine,
      );

      expect(report.isValid, isFalse);
      expect(report.correctedPhrase, equals('den großen Hund'));
      expect(report.errorExplanation, contains('Morphosyntactic Agreement Mismatch'));
    });

    test('Validates dative feminine case inflection (der kleinen Katze)', () {
      final report = guard.validateDefiniteNounPhrase(
        article: 'der',
        adjective: 'kleinen',
        noun: 'Katze',
        expectedCase: GrammaticalCase.dative,
        expectedGender: GrammaticalGender.feminine,
      );

      expect(report.isValid, isTrue);
      expect(report.correctedPhrase, equals('der kleinen Katze'));
    });
  });
}
