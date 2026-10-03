import 'package:deutsch_bilarabi/features/cognitive_load_agent/domain/cognitive_load_engine.dart';
import 'package:deutsch_bilarabi/features/cognitive_load_agent/domain/cognitive_load_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = CognitiveLoadEngine();

  SessionTelemetry telemetry({
    required int responseMs,
    required int hesitations,
    required int errors,
  }) {
    return SessionTelemetry(
      eventId: 'e-$responseMs-$hesitations-$errors',
      occurredAtUtc: DateTime.utc(2026, 10, 3, 18),
      responseTimeMs: responseMs,
      hesitationCount: hesitations,
      consecutiveErrors: errors,
    );
  }

  test('fast confident response stays in optimal range', () {
    final analysis = engine.analyze(<SessionTelemetry>[
      telemetry(responseMs: 1800, hesitations: 0, errors: 0),
      telemetry(responseMs: 2200, hesitations: 1, errors: 0),
    ]);

    expect(analysis.state, CognitiveState.optimal);
    expect(analysis.loadScore, lessThan(.40));
    expect(
      analysis.recommendation.action,
      PacingAction.keepPace,
    );
  });

  test('slow responses and hesitation produce fatigue support', () {
    final analysis = engine.analyze(<SessionTelemetry>[
      telemetry(responseMs: 7200, hesitations: 2, errors: 1),
      telemetry(responseMs: 7800, hesitations: 3, errors: 1),
    ]);

    expect(analysis.state, CognitiveState.fatigue);
    expect(analysis.loadScore, inInclusiveRange(.40, .699999));
    expect(analysis.recommendation.reducePace, isTrue);
    expect(analysis.recommendation.showSupportHint, isTrue);
    expect(analysis.recommendation.suggestShortBreak, isFalse);
  });

  test('sustained very slow responses and errors become overwhelmed', () {
    final analysis = engine.analyze(<SessionTelemetry>[
      telemetry(responseMs: 10500, hesitations: 4, errors: 3),
      telemetry(responseMs: 12000, hesitations: 4, errors: 4),
      telemetry(responseMs: 11000, hesitations: 5, errors: 4),
    ]);

    expect(analysis.state, CognitiveState.overwhelmed);
    expect(analysis.loadScore, greaterThanOrEqualTo(.70));
    expect(analysis.recommendation.suggestShortBreak, isTrue);
    expect(analysis.recommendation.showSupportHint, isTrue);
  });

  test('response score is bounded for extreme telemetry', () {
    final analysis = engine.analyze(<SessionTelemetry>[
      telemetry(responseMs: 120000, hesitations: 99, errors: 99),
    ]);

    expect(analysis.loadScore, inInclusiveRange(0, 1));
    expect(analysis.focusIndex, inInclusiveRange(0, 1));
    expect(analysis.comprehensionPace, inInclusiveRange(0, 1));
  });
}
