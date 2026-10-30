import 'package:test/test.dart';
import 'package:deutsch_build/src/core/voice_cloning/intonation_expressiveness_meter.dart';

void main() {
  group('IntonationExpressivenessMeter Tests', () {
    const meter = IntonationExpressivenessMeter();

    test('Validates falling intonation on German declarative sentence', () {
      final trajectory = [180.0, 195.0, 170.0, 140.0, 125.0]; // Falling cadence
      final report = meter.evaluateIntonation(
        f0TrajectoryHz: trajectory,
        sentenceType: GermanSentenceType.declarativeStatement,
      );

      expect(report.detectedDirection, equals(PitchDirection.fallingCadence));
      expect(report.isIntonationCorrect, isTrue);
      expect(report.expressivenessScore, greaterThan(75.0));
    });

    test('Identifies rising intonation on German Yes/No question', () {
      final trajectory = [140.0, 150.0, 165.0, 195.0, 210.0]; // Rising terminal
      final report = meter.evaluateIntonation(
        f0TrajectoryHz: trajectory,
        sentenceType: GermanSentenceType.yesNoQuestion,
      );

      expect(report.detectedDirection, equals(PitchDirection.risingTerminal));
      expect(report.isIntonationCorrect, isTrue);
      expect(report.prosodicAdvice, contains('Die Stimme steigt am Satzende klar an'));
    });
  });
}
