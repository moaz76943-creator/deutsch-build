import 'package:deutsch_bilarabi/features/error_pattern_agent/domain/error_pattern_analyzer.dart';
import 'package:deutsch_bilarabi/features/error_pattern_agent/domain/error_pattern_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const analyzer = ErrorPatternAnalyzer();
  final at = DateTime.utc(2026, 10, 3, 12);

  test('classifies article gender confusion without personality inference', () {
    final type = analyzer.classify(
      LearningFailureSignal(
        source: ErrorEventSource.flashcard,
        skillTag: 'article_gender',
        expected: 'der',
        actual: 'die',
        focus: 'Tisch',
        occurredAt: at,
      ),
    );
    expect(type, ErrorPatternType.genderConfusion);
  });

  test('classifies case mismatch from explicit grammar case tag', () {
    final type = analyzer.classify(
      LearningFailureSignal(
        source: ErrorEventSource.grammar,
        skillTag: 'case_akkusativ',
        expected: 'den',
        actual: 'der',
        focus: 'Mann',
        occurredAt: at,
      ),
    );
    expect(type, ErrorPatternType.caseMismatch);
  });

  test('classifies reordered same-word grammar answer as word order drift', () {
    final type = analyzer.classify(
      LearningFailureSignal(
        source: ErrorEventSource.grammar,
        skillTag: 'sentence_reorder',
        expected: 'Heute gehe ich nach Hause',
        actual: 'Heute ich gehe nach Hause',
        focus: 'V2',
        occurredAt: at,
      ),
    );
    expect(type, ErrorPatternType.wordOrderDrift);
  });

  test('does not force unrelated vocabulary errors into a blind spot class', () {
    final type = analyzer.classify(
      LearningFailureSignal(
        source: ErrorEventSource.flashcard,
        skillTag: 'meaning_recall',
        expected: 'شجرة',
        actual: 'زهرة',
        focus: 'Baum',
        occurredAt: at,
      ),
    );
    expect(type, isNull);
  });

  test('report ranks top three by count and computes cumulative frequency', () {
    ErrorLogEntry entry(
      String id,
      ErrorPatternType type,
      int minute,
    ) =>
        ErrorLogEntry(
          id: id,
          type: type,
          focus: type.name,
          expected: 'expected',
          actual: 'actual',
          source: ErrorEventSource.grammar,
          timestamp: at.add(Duration(minutes: minute)),
        );

    final entries = <ErrorLogEntry>[
      for (var i = 0; i < 5; i++)
        entry('g$i', ErrorPatternType.genderConfusion, i),
      for (var i = 0; i < 3; i++)
        entry('c$i', ErrorPatternType.caseMismatch, i + 10),
      entry('w0', ErrorPatternType.wordOrderDrift, 20),
    ];
    final report = analyzer.buildReport(entries, now: at);

    expect(report.totalErrors, 9);
    expect(report.topBlindSpots, hasLength(3));
    expect(
      report.topBlindSpots.first.type,
      ErrorPatternType.genderConfusion,
    );
    expect(report.topBlindSpots.first.count, 5);
    expect(report.topBlindSpots.first.frequency, closeTo(5 / 9, .0001));
    expect(
      report.topBlindSpots.first.severity,
      DiagnosticSeverity.high,
    );
    expect(
      report.topBlindSpots[1].type,
      ErrorPatternType.caseMismatch,
    );
  });
}
