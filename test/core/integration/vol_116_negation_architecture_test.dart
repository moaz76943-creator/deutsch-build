import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_negation_architecture_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave17_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4917 Negation Architecture Engine Tests', () {
    test('LING-040: kein- inflects correctly for masculine accusative noun', () {
      final res = GermanNegationArchitectureEngine.negateNoun(
        subject: 'Ich',
        verb: 'habe',
        nounStem: 'Hunger',
        gender: 'maskulin',
        gramCase: 'akkusativ',
      );

      expect(res.wordType, equals(NegationWordType.indefiniteNounKein));
      expect(res.generatedSentence, equals('Ich habe keinen Hunger.'));
    });

    test('LING-040: Satznegation places nicht before separable verb prefix', () {
      final res = GermanNegationArchitectureEngine.negateWithNicht(
        subject: 'Ich',
        verb: 'rufe',
        scope: NegationScope.sentenceNegation,
        directObjectOrElement: 'dich',
        separablePrefixOrParticiple: 'an',
      );

      expect(res.generatedSentence, equals('Ich rufe dich nicht an.'));
      expect(res.placementRuleExplanation, contains('سابقة الفعل المنفصل'));
    });

    test('LING-040: Satznegation places nicht before prepositional phrase', () {
      final res = GermanNegationArchitectureEngine.negateWithNicht(
        subject: 'Er',
        verb: 'fährt',
        scope: NegationScope.sentenceNegation,
        prepositionalPhrase: 'nach Berlin',
      );

      expect(res.generatedSentence, equals('Er fährt nicht nach Berlin.'));
    });

    test('UI Bridge generates accurate Task 4917 diagnostics report', () {
      final bridge = Vol116Wave17UIBridge();
      final report = bridge.getTask4917Diagnostics();

      expect(report['task_id'], equals(4917));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(83));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
