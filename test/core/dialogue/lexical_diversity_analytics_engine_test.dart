import 'package:test/test.dart';
import 'package:deutsch_build/src/core/dialogue/lexical_diversity_analytics_engine.dart';

void main() {
  group('LexicalDiversityAnalyticsEngine Tests', () {
    const engine = LexicalDiversityAnalyticsEngine();

    test('Computes accurate TTR and Guiraud index for diverse dialogue turns', () {
      final turns = [
        'Guten Tag! Ich möchte bitte ein Zimmer reservieren.',
        'Außerdem hätte ich gerne ein Frühstück inklusive.',
        'Tatsächlich bleibe ich drei Tage in Berlin.',
      ];

      final report = engine.analyzeTranscript(turns);

      expect(report.totalTokens, greaterThan(15));
      expect(report.uniqueTypes, greaterThan(10));
      expect(report.rawTtr, greaterThan(0.7));
      expect(report.guiraudIndex, greaterThan(3.5));
      expect(report.advancedVocabRatio, greaterThan(0.05));
    });

    test('Identifies overused words in repetitive dialogue', () {
      final repetitiveTurns = [
        'Das ist sehr gut und sehr schön.',
        'Ich finde es sehr gut und sehr praktisch.',
        'Es ist wirklich sehr gut.',
      ];

      final report = engine.analyzeTranscript(repetitiveTurns);

      expect(report.overusedTokens, contains('sehr'));
      expect(report.rawTtr, lessThan(0.6));
    });

    test('Handles empty transcript safely without divide-by-zero', () {
      final report = engine.analyzeTranscript([]);

      expect(report.totalTokens, equals(0));
      expect(report.rawTtr, equals(0.0));
      expect(report.overusedTokens, isEmpty);
    });
  });
}
