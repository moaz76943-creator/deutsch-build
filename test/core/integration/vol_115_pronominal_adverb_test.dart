import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_pronominal_adverb_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_115_capstone_ui_bridge.dart';

void main() {
  group('Volume 115 Task 4900 Pronominal Adverb Engine Tests', () {
    test('LING-023: Vowel-initial prepositions insert epenthetic -r- for inanimate things', () {
      final resAn = GermanPronominalAdverbEngine.buildForms(
        preposition: 'an',
        referenceType: EntityReferenceType.conceptInanimate,
        governingVerb: 'denkst',
      );

      expect(resAn.hasEpentheticR, isTrue);
      expect(resAn.demonstrativeForm, equals('daran'));
      expect(resAn.interrogativeForm, equals('woran'));
      expect(resAn.sampleQuestion, equals('Woran denkst du?'));
      expect(resAn.sampleAnswer, equals('Ich denkst daran.'));

      final resAuf = GermanPronominalAdverbEngine.buildForms(
        preposition: 'auf',
        referenceType: EntityReferenceType.conceptInanimate,
        governingVerb: 'wartest',
      );
      expect(resAuf.demonstrativeForm, equals('darauf'));
      expect(resAuf.interrogativeForm, equals('worauf'));
    });

    test('LING-023: Consonant-initial prepositions do not insert -r-', () {
      final resMit = GermanPronominalAdverbEngine.buildForms(
        preposition: 'mit',
        referenceType: EntityReferenceType.conceptInanimate,
        governingVerb: 'schreibst',
      );

      expect(resMit.hasEpentheticR, isFalse);
      expect(resMit.demonstrativeForm, equals('damit'));
      expect(resMit.interrogativeForm, equals('womit'));
    });

    test('LING-023: Animate persons use preposition + case pronoun instead of da/wo compounds', () {
      final resPerson = GermanPronominalAdverbEngine.buildForms(
        preposition: 'an',
        referenceType: EntityReferenceType.personAnimate,
        governingVerb: 'denkst',
      );

      expect(resPerson.demonstrativeForm, equals('an ihn'));
      expect(resPerson.interrogativeForm, equals('an wen'));
      expect(resPerson.sampleQuestion, equals('An wen denkst du?'));
    });

    test('UI Bridge generates accurate Milestone 4900 diagnostics report', () {
      final bridge = Vol115CapstoneUIBridge();
      final report = bridge.getTask4900Diagnostics();

      expect(report['task_id'], equals(4900));
      expect(report['milestone'], equals('MILESTONE_4900_REACHED'));
      expect(report['tasks_remaining_to_5000'], equals(100));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
