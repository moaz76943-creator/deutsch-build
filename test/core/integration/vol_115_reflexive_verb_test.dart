import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_reflexive_verb_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_115_wave10_ui_bridge.dart';

void main() {
  group('Volume 115 Task 4896 Reflexive Verb Engine Tests', () {
    test('LING-019: Akkusativ reflexive pronoun used without direct object', () {
      final res = GermanReflexiveVerbEngine.buildReflexivePhrase(
        verbInfinitive: 'waschen',
        subject: SubjectPronoun.ich,
        conjugatedVerbStem: 'wasche',
      );

      expect(res.pronounCase, equals(ReflexiveCase.akkusativ));
      expect(res.reflexivePronoun, equals('mich'));
      expect(res.generatedSentence, equals('Ich wasche mich.'));
    });

    test('LING-019: Dativ reflexive pronoun used when direct object is present', () {
      final res = GermanReflexiveVerbEngine.buildReflexivePhrase(
        verbInfinitive: 'waschen',
        subject: SubjectPronoun.ich,
        directAccusativeObject: 'die Hände',
        conjugatedVerbStem: 'wasche',
      );

      expect(res.pronounCase, equals(ReflexiveCase.dativ));
      expect(res.reflexivePronoun, equals('mir'));
      expect(res.generatedSentence, equals('Ich wasche mir die Hände.'));
    });

    test('LING-019: 2nd person singular switches correctly between dich and dir', () {
      // Dich: Du ziehst dich an.
      final resDich = GermanReflexiveVerbEngine.buildReflexivePhrase(
        verbInfinitive: 'anziehen',
        subject: SubjectPronoun.du,
        conjugatedVerbStem: 'ziehst',
      );
      expect(resDich.reflexivePronoun, equals('dich'));

      // Dir: Du ziehst dir die Jacke an.
      final resDir = GermanReflexiveVerbEngine.buildReflexivePhrase(
        verbInfinitive: 'anziehen',
        subject: SubjectPronoun.du,
        directAccusativeObject: 'die Jacke',
        conjugatedVerbStem: 'ziehst',
      );
      expect(resDir.reflexivePronoun, equals('dir'));
    });

    test('UI Bridge generates accurate Task 4896 diagnostics report', () {
      final bridge = Vol115Wave10UIBridge();
      final report = bridge.getTask4896Diagnostics();

      expect(report['task_id'], equals(4896));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
