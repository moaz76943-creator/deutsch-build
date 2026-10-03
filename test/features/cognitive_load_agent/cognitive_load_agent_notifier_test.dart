import 'package:deutsch_bilarabi/features/cognitive_load_agent/application/cognitive_load_agent_notifier.dart';
import 'package:deutsch_bilarabi/features/cognitive_load_agent/data/local_pacing_repository.dart';
import 'package:deutsch_bilarabi/features/cognitive_load_agent/domain/cognitive_load_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('live telemetry immediately updates pacing state', () async {
    final notifier = CognitiveLoadAgentNotifier(
      repository: LocalPacingRepository(capacity: 16),
    );

    await notifier.recordInteraction(
      SessionTelemetry(
        eventId: 'slow-1',
        occurredAtUtc: DateTime.utc(2026, 10, 3, 18),
        responseTimeMs: 9000,
        hesitationCount: 3,
        consecutiveErrors: 2,
      ),
    );

    expect(notifier.state.samples, 1);
    expect(
      notifier.state.cognitiveState,
      isNot(CognitiveState.optimal),
    );
    expect(notifier.state.recommendation.showSupportHint, isTrue);
  });

  test('rolling window prevents old session data from dominating', () async {
    final repository = LocalPacingRepository(capacity: 32);
    final notifier = CognitiveLoadAgentNotifier(
      repository: repository,
      analysisWindow: 4,
    );

    for (var i = 0; i < 4; i++) {
      await notifier.recordInteraction(
        SessionTelemetry(
          eventId: 'slow-$i',
          occurredAtUtc: DateTime.utc(2026, 10, 3, 18, i),
          responseTimeMs: 12000,
          hesitationCount: 4,
          consecutiveErrors: 4,
        ),
      );
    }
    for (var i = 0; i < 4; i++) {
      await notifier.recordInteraction(
        SessionTelemetry(
          eventId: 'recovered-$i',
          occurredAtUtc: DateTime.utc(2026, 10, 3, 19, i),
          responseTimeMs: 1800,
          hesitationCount: 0,
          consecutiveErrors: 0,
        ),
      );
    }

    expect(notifier.state.samples, 4);
    expect(notifier.state.cognitiveState, CognitiveState.optimal);
    expect(notifier.state.recommendation.action, PacingAction.keepPace);
  });

  test('reset clears session telemetry and returns to neutral state', () async {
    final repository = LocalPacingRepository(capacity: 16);
    final notifier = CognitiveLoadAgentNotifier(repository: repository);

    await notifier.recordInteraction(
      SessionTelemetry(
        eventId: 'e1',
        occurredAtUtc: DateTime.utc(2026, 10, 3, 18),
        responseTimeMs: 10000,
        hesitationCount: 4,
        consecutiveErrors: 3,
      ),
    );
    await notifier.resetSession();

    expect(notifier.state.samples, 0);
    expect(notifier.state.cognitiveState, CognitiveState.optimal);
    expect(await repository.recent(limit: 10), isEmpty);
  });
}
