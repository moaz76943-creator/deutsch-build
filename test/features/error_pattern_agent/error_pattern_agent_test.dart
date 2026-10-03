import 'package:deutsch_bilarabi/features/error_pattern_agent/domain/error_pattern_analyzer.dart';
import 'package:deutsch_bilarabi/features/error_pattern_agent/domain/error_pattern_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const analyzer = ErrorPatternAnalyzer();

  test('compatibility test validates the canonical diagnostic engine', () {
    final now = DateTime.utc(2026, 10, 3, 18);
    final report = analyzer.buildReport(
      <ErrorLogEntry>[
        ErrorLogEntry(
          id: 'e1',
          type: ErrorPatternType.caseMismatch,
          focus: 'Mann',
          expected: 'den',
          actual: 'der',
          source: ErrorEventSource.grammar,
          timestamp: now,
        ),
        ErrorLogEntry(
          id: 'e2',
          type: ErrorPatternType.caseMismatch,
          focus: 'Mann',
          expected: 'dem',
          actual: 'den',
          source: ErrorEventSource.grammar,
          timestamp: now.add(const Duration(minutes: 1)),
        ),
        ErrorLogEntry(
          id: 'e3',
          type: ErrorPatternType.genderConfusion,
          focus: 'Lampe',
          expected: 'die',
          actual: 'der',
          source: ErrorEventSource.flashcard,
          timestamp: now.add(const Duration(minutes: 2)),
        ),
      ],
      now: now,
    );

    expect(report.totalErrors, 3);
    expect(report.topBlindSpots.first.type, ErrorPatternType.caseMismatch);
    expect(report.topBlindSpots.first.count, 2);
    expect(report.topBlindSpots.first.frequency, closeTo(2 / 3, .0001));
  });
}
