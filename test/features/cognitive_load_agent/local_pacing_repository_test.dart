import 'package:deutsch_bilarabi/features/cognitive_load_agent/data/local_pacing_repository.dart';
import 'package:deutsch_bilarabi/features/cognitive_load_agent/domain/cognitive_load_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SessionTelemetry event(String id, int seconds) => SessionTelemetry(
        eventId: id,
        occurredAtUtc: DateTime.utc(2026, 10, 3, 18, 0, seconds),
        responseTimeMs: 2500,
        hesitationCount: 0,
        consecutiveErrors: 0,
      );

  test('local repository deduplicates events by event id', () async {
    final repository = LocalPacingRepository(capacity: 8);

    await repository.record(event('same', 1));
    await repository.record(event('same', 2));

    final items = await repository.recent(limit: 8);
    expect(items, hasLength(1));
    expect(items.single.occurredAtUtc.second, 2);
  });

  test('local repository keeps only bounded newest telemetry', () async {
    final repository = LocalPacingRepository(capacity: 3);

    await repository.record(event('a', 1));
    await repository.record(event('b', 2));
    await repository.record(event('c', 3));
    await repository.record(event('d', 4));

    final items = await repository.recent(limit: 10);
    expect(items.map((item) => item.eventId), <String>['b', 'c', 'd']);
  });

  test('recent returns requested newest window in chronological order', () async {
    final repository = LocalPacingRepository(capacity: 8);
    for (var i = 1; i <= 5; i++) {
      await repository.record(event('e$i', i));
    }

    final items = await repository.recent(limit: 2);
    expect(items.map((item) => item.eventId), <String>['e4', 'e5']);
  });
}
