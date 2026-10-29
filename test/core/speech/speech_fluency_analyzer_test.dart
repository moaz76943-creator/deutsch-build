import 'package:test/test.dart';
import 'package:deutsch_build/src/core/speech/speech_fluency_analyzer.dart';

void main() {
  group('SpeechFluencyAnalyzer Tests', () {
    const analyzer = SpeechFluencyAnalyzer();

    test('Scores high fluency on steady speech flow with minimal hesitations', () {
      final timeline = [
        const SpeechSegmentDuration(text: 'Ich', durationMs: 300),
        const SpeechSegmentDuration(text: 'pause', durationMs: 50, isSilenceOrPause: true),
        const SpeechSegmentDuration(text: 'gehe', durationMs: 400),
        const SpeechSegmentDuration(text: 'pause', durationMs: 50, isSilenceOrPause: true),
        const SpeechSegmentDuration(text: 'nach', durationMs: 300),
        const SpeechSegmentDuration(text: 'Hause', durationMs: 450),
      ];

      final report = analyzer.evaluateFluency(timeline: timeline, expectedWordsCount: 4);

      expect(report.hesitationPausesCount, equals(0));
      expect(report.phonationRatio, greaterThan(0.85));
      expect(report.fluencyScore, greaterThanOrEqualTo(75.0));
    });

    test('Detects hesitation pauses and reduces fluency score', () {
      final timeline = [
        const SpeechSegmentDuration(text: 'Ich', durationMs: 300),
        const SpeechSegmentDuration(text: 'pause', durationMs: 600, isSilenceOrPause: true), // Heavy hesitation
        const SpeechSegmentDuration(text: 'weiß', durationMs: 400),
        const SpeechSegmentDuration(text: 'pause', durationMs: 800, isSilenceOrPause: true), // Heavy hesitation
        const SpeechSegmentDuration(text: 'nicht', durationMs: 400),
      ];

      final report = analyzer.evaluateFluency(timeline: timeline, expectedWordsCount: 3);

      expect(report.hesitationPausesCount, equals(2));
      expect(report.fluencyScore, lessThan(70.0));
    });
  });
}
