import 'package:test/test.dart';
import 'package:deutsch_build/src/core/voice_cloning/choral_shadowing_synchronizer.dart';

void main() {
  group('ChoralShadowingSynchronizer Tests', () {
    const synchronizer = ChoralShadowingSynchronizer();

    test('Validates near-zero lag (80ms) as perfect choral synchronization', () {
      final report = synchronizer.evaluateShadowingSynchrony(
        nativeGuideOnsetMs: 1000,
        learnerSpeechOnsetMs: 1080,
      );

      expect(report.lagLatencyMs, equals(80));
      expect(report.isPacingAcceptable, isTrue);
      expect(report.synchronyScorePercent, greaterThan(80.0));
      expect(report.rhythmGuidance, contains('Perfektes Choral-Timing'));
    });

    test('Flags lagging delay over 350ms with constructive pacing advice', () {
      final report = synchronizer.evaluateShadowingSynchrony(
        nativeGuideOnsetMs: 1000,
        learnerSpeechOnsetMs: 1420, // 420ms lag
      );

      expect(report.lagLatencyMs, equals(420));
      expect(report.isPacingAcceptable, isFalse);
      expect(report.rhythmGuidance, contains('zu spät'));
    });
  });
}
