import 'package:test/test.dart';
import '../../lib/src/core/semantic_search/semantic_density_governor.dart';

void main() {
  group('SemanticDensityGovernor Unit Tests (N056)', () {
    const governor = SemanticDensityGovernor(windowSize: 10, minAcceptableTtr: 0.50);

    test('Evaluates rich diverse text with high TTR and zero penalty', () {
      const richText =
          'Die Sonne scheint hell über den Bergen während der Wanderer den steinigen Pfad erklimmt.';
      final metrics = governor.evaluateDiversity(richText);

      expect(metrics.typeTokenRatio, greaterThan(0.85));
      expect(metrics.movingAverageTtr, greaterThan(0.80));
      expect(metrics.hasRepetitiveLooping, isFalse);
      expect(metrics.repetitionPenalty, equals(0.0));
    });

    test('Detects severe robotic looping and applies heavy repetition penalty', () {
      const repetitiveText = 'sehr gut sehr gut sehr gut sehr gut sehr gut sehr gut sehr gut';
      final metrics = governor.evaluateDiversity(repetitiveText);

      expect(metrics.hasRepetitiveLooping, isTrue);
      expect(metrics.movingAverageTtr, lessThan(0.50));
      expect(metrics.repetitionPenalty, greaterThan(0.5));
    });

    test('Empty text handles gracefully', () {
      final metrics = governor.evaluateDiversity('');
      expect(metrics.hasRepetitiveLooping, isFalse);
      expect(metrics.repetitionPenalty, equals(0.0));
    });
  });
}
