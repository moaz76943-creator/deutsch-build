import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/curriculum/cefr_milestone_evaluator.dart';

void main() {
  group('CefrMilestoneEvaluator Unit Tests (N034)', () {
    final evaluator = CefrMilestoneEvaluator();

    test('Certifies A1 interaction milestone when vocabulary and accuracy thresholds are met', () {
      final report = evaluator.evaluateReadiness(
        milestoneCode: 'A1_INT_01',
        activeVocabularySize: 420,
        communicativeAccuracy: 0.82,
      );

      expect(report['isCertified'], isTrue);
      expect(report['cefrLevel'], equals('A1'));
      expect(report['vocabularyFulfillment'], equals(100.0));
    });

    test('Rejects B2 interaction when lexical threshold is deficient', () {
      final report = evaluator.evaluateReadiness(
        milestoneCode: 'B2_INT_01',
        activeVocabularySize: 1800,
        communicativeAccuracy: 0.90,
      );

      expect(report['isCertified'], isFalse);
      expect(report['cefrLevel'], equals('B2'));
      expect(report['vocabularyFulfillment'], lessThan(50.0));
    });

    test('Throws on unrecognized milestone code', () {
      expect(
        () => evaluator.evaluateReadiness(milestoneCode: 'UNKNOWN', activeVocabularySize: 500, communicativeAccuracy: 0.8),
        throwsArgumentError,
      );
    });
  });
}
