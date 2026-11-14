import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/multimodal_dialogue/formant_trajectory_visualizer.dart';

void main() {
  group('FormantTrajectoryVisualizer Unit Tests (N075)', () {
    final visualizer = FormantTrajectoryVisualizer();

    test('Validates accurate German ü (/yː/) articulation within tolerance zone', () {
      const sample = FormantCoordinate(f1Hz: 305, f2Hz: 1740, timestampSec: 1.2);
      final report = visualizer.evaluateVowelHit(targetPhoneme: 'yː', learnerSample: sample);

      expect(report['isHit'], isTrue);
      expect(report['feedback'], equals('Perfekt getroffen!'));
      expect(report['distanceHz'], lessThan(50.0));
    });

    test('Detects back-vowel confusion for front rounded vowel and advises tongue position', () {
      // Learner produced /uː/ back vowel (F2 = 900) instead of /yː/ (F2 = 1750)
      const badSample = FormantCoordinate(f1Hz: 310, f2Hz: 900, timestampSec: 1.2);
      final report = visualizer.evaluateVowelHit(targetPhoneme: 'yː', learnerSample: badSample);

      expect(report['isHit'], isFalse);
      expect(report['feedback'], contains('Zunge weiter nach vorne schieben'));
    });
  });
}
