import 'package:test/test.dart';
import 'package:deutsch_build/src/core/analytics/reading_speed_benchmark.dart';

void main() {
  group('ReadingSpeedBenchmark Tests', () {
    const benchmark = ReadingSpeedBenchmark();

    test('Classifies fluent reading speed for space-delimited text', () {
      const text = 'Das ist ein wichtiges Buch für alle Studenten die Deutsch lernen';
      final result = benchmark.evaluate(
        text: text,
        timeSpent: const Duration(seconds: 5), // 11 words in 5 sec = ~132 WPM
      );

      expect(result.wordsPerMinute, greaterThanOrEqualTo(120.0));
      expect(result.tier, equals(ReadingFluencyTier.fluent));
    });

    test('Evaluates CJK text in characters per minute', () {
      const text = '这是一个测试句子用于阅读速度基准测试';
      final result = benchmark.evaluate(
        text: text,
        timeSpent: const Duration(seconds: 4),
        isCjk: true,
      );

      expect(result.charactersPerMinute, greaterThan(200.0));
      expect(result.tier, equals(ReadingFluencyTier.fluent));
    });
  });
}
