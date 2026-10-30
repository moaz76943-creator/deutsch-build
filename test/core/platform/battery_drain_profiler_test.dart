import 'package:test/test.dart';
import 'package:deutsch_build/src/core/platform/battery_drain_profiler.dart';

void main() {
  group('BatteryDrainProfiler Tests', () {
    const profiler = BatteryDrainProfiler();

    test('15-minute intensive roleplay session with OLED dark mode strictly stays under 18 mAh', () {
      const metrics = StudySessionPowerMetrics(
        activeStudyMinutes: 15,
        ttsAudioSynthesisSeconds: 60, // 1 min of speech
        asrSpeechRecognitionSeconds: 45,
        llmGenerationTurns: 10,
        isOledPureBlackTheme: true,
      );

      final report = profiler.profileSession(metrics);

      expect(report.totalEstimatedMahDrain, lessThan(18.0));
      expect(report.isWithinEcoBudget, isTrue);
      expect(report.efficiencyVerdict, equals('ECO_EFFICIENCY_CERTIFIED'));
      expect(report.estimatedBatteryPercentPerHour, lessThan(3.0)); // Less than 3% battery per hour
    });

    test('OLED pure black theme demonstrates verified display power savings over standard theme', () {
      const oledMetrics = StudySessionPowerMetrics(
        activeStudyMinutes: 30,
        ttsAudioSynthesisSeconds: 0,
        asrSpeechRecognitionSeconds: 0,
        llmGenerationTurns: 0,
        isOledPureBlackTheme: true,
      );

      const standardMetrics = StudySessionPowerMetrics(
        activeStudyMinutes: 30,
        ttsAudioSynthesisSeconds: 0,
        asrSpeechRecognitionSeconds: 0,
        llmGenerationTurns: 0,
        isOledPureBlackTheme: false,
      );

      final oledReport = profiler.profileSession(oledMetrics);
      final standardReport = profiler.profileSession(standardMetrics);

      expect(oledReport.totalEstimatedMahDrain, lessThan(standardReport.totalEstimatedMahDrain));
      expect(oledReport.componentBreakdownMah['display']!, lessThan(standardReport.componentBreakdownMah['display']!));
    });
  });
}
