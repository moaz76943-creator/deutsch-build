import 'dart:async';
import 'dart:isolate';

import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';
import 'package:deutsch_bilarabi/core/srs_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fresh isolates with a rolled-back clock cannot reuse review IDs',
      () async {
    // Each isolate starts with fresh static state, like a process restart.
    // A clock-derived counter alone repeats the same durable event ID.
    Future<String> freshIsolateEventId() => Isolate.run(() async {
          final captured = <String>[];
          final bridge = SrsCompatBridge(
            clock: () => DateTime.utc(2026, 10, 25, 1),
            durableWriter: (event) async {
              captured.add(event.reviewEventId);
            },
          );
          await bridge.recordReviewCompat(
            contentKey: 'restart-same-clock-card',
            rating: 3,
            sourceIso: 'de',
            targetIso: 'ar',
          );
          return captured.single;
        });

    final first = await freshIsolateEventId();
    final afterRestart = await freshIsolateEventId();
    expect(afterRestart, isNot(first),
        reason: 'A reused durable review ID silently loses a new review');
  });

  test('same-clock reviews of one card retain every distinct review', () async {
    final fixed = DateTime.utc(2026, 10, 25, 1, 0);
    final bridge = SrsCompatBridge(clock: () => fixed, durableWriter: (_) async {});
    const key = 'core-event-id-same-clock-20261025';

    await Future.wait(List<Future<void>>.generate(
      32,
      (_) => bridge.recordReviewCompat(
        contentKey: key,
        rating: 3,
        sourceIso: 'de',
        targetIso: 'ar',
      ),
    ));

    final recorded = UnifiedSrsScheduler.instance.history
        .where((entry) => entry.learnerContentKey == key)
        .toList();
    expect(recorded, hasLength(32));
    expect(recorded.map((entry) => entry.reviewEventId).toSet(),
        hasLength(32));
    // The event timestamp, not only its ID, must remain ordered when the
    // device clock stalls; otherwise a durable stale-review guard drops work.
    expect(
      recorded.map((entry) => entry.timestamp.microsecondsSinceEpoch),
      orderedEquals(List<int>.generate(
        32, (index) => fixed.microsecondsSinceEpoch + index,
      )),
    );
    expect(
      recorded.every((entry) => entry.languagePairKey == 'de_ar'),
      isTrue,
    );
  });

  test('clock rollback cannot silently discard a later review', () async {
    final baseline = DateTime.utc(2026, 10, 25, 12);
    final ticks = <DateTime>[
      baseline,
      baseline.subtract(const Duration(minutes: 2)),
      baseline.add(const Duration(microseconds: 5)),
    ];
    var tick = 0;
    final persisted = <DateTime>[];
    final bridge = SrsCompatBridge(
      clock: () => ticks[tick++],
      durableWriter: (event) async {
        // Mirrors the existing canonical stale-timestamp guard.
        if (persisted.isNotEmpty &&
            !event.timestamp.isAfter(persisted.last)) {
          throw StateError('Stale review command');
        }
        persisted.add(event.timestamp);
      },
    );

    for (var index = 0; index < ticks.length; index++) {
      await bridge.recordReviewCompat(
        contentKey: 'clock-rollback-card',
        rating: 3,
        sourceIso: 'de',
        targetIso: 'ar',
      );
    }
    expect(persisted, hasLength(3));
    expect(persisted.first, baseline);
    expect(persisted[1].microsecondsSinceEpoch,
        baseline.microsecondsSinceEpoch + 1);
    expect(persisted.last, baseline.add(const Duration(microseconds: 5)));
  });

  test('opposite directed pairs never suppress each other at one instant',
      () async {
    final fixed = DateTime.utc(2026, 10, 25, 1, 0);
    final bridge = SrsCompatBridge(clock: () => fixed, durableWriter: (_) async {});
    const key = 'core-event-id-directed-pair-20261025';

    await bridge.recordReviewCompat(
      contentKey: key,
      rating: 3,
      sourceIso: 'de',
      targetIso: 'ar',
    );
    await bridge.recordReviewCompat(
      contentKey: key,
      rating: 1,
      sourceIso: 'ar',
      targetIso: 'de',
    );

    final recorded = UnifiedSrsScheduler.instance.history
        .where((entry) => entry.learnerContentKey == key)
        .toList();
    expect(recorded, hasLength(2));
    expect(recorded.map((entry) => entry.reviewEventId).toSet(),
        hasLength(2));
    expect(recorded.map((entry) => entry.languagePairKey).toList(),
        <String>['de_ar', 'ar_de']);
    expect(recorded.map((entry) => entry.rating).toList(), <int>[3, 1]);
  });

  test('legacy correct grade 4 is normalized to canonical easy 3', () async {
    final bridge = SrsCompatBridge(clock: () => DateTime.utc(2026, 10, 25), durableWriter: (_) async {});
    const key = 'core-legacy-grade-four-20261025';

    await bridge.recordReviewCompat(
      contentKey: key,
      rating: 4,
      sourceIso: 'de',
      targetIso: 'ar',
    );

    final recorded = UnifiedSrsScheduler.instance.history
        .where((event) => event.learnerContentKey == key)
        .single;
    expect(recorded.rating, 3);
    expect(recorded.languagePairKey, 'de_ar');
  });

  test('ambiguous directed pair keys are rejected before durable writes',
      () async {
    var writes = 0;
    final bridge = SrsCompatBridge(
      clock: () => DateTime.utc(2026, 10, 25),
      durableWriter: (_) async { writes++; },
    );

    // Both pairs would otherwise serialize to the same "de_ar_fr" key.
    await expectLater(
      bridge.recordReviewCompat(
        contentKey: 'collision-card', rating: 3,
        sourceIso: 'de_ar', targetIso: 'fr',
      ),
      throwsArgumentError,
    );
    await expectLater(
      bridge.recordReviewCompat(
        contentKey: 'collision-card', rating: 3,
        sourceIso: 'de', targetIso: 'ar_fr',
      ),
      throwsArgumentError,
    );
    // Case-only variants are the same language, not opposite directions.
    await expectLater(
      bridge.recordReviewCompat(
        contentKey: 'collision-card', rating: 3,
        sourceIso: 'de', targetIso: 'DE',
      ),
      throwsArgumentError,
    );
    await expectLater(
      bridge.recordReviewCompat(
        contentKey: 'collision-card', rating: 3,
        sourceIso: 'de\\n', targetIso: 'ar',
      ),
      throwsArgumentError,
    );
    expect(writes, 0,
        reason: 'Malformed pairs must never reach canonical persistence');
  });

  test('hyphenated language tags remain distinct in both directions',
      () async {
    final committedPairs = <String>[];
    final bridge = SrsCompatBridge(
      clock: () => DateTime.utc(2026, 10, 25),
      durableWriter: (event) async {
        committedPairs.add(event.languagePairKey);
      },
    );
    const key = 'core-bcp47-directed-pair-20261025';

    await bridge.recordReviewCompat(
      contentKey: key, rating: 3,
      sourceIso: 'zh-Hant', targetIso: 'en-US',
    );
    await bridge.recordReviewCompat(
      contentKey: key, rating: 1,
      sourceIso: 'en-US', targetIso: 'zh-Hant',
    );

    expect(committedPairs, <String>['zh-Hant_en-US', 'en-US_zh-Hant']);
    expect(
      UnifiedSrsScheduler.instance.history
          .where((event) => event.learnerContentKey == key)
          .map((event) => event.languagePairKey),
      <String>['zh-Hant_en-US', 'en-US_zh-Hant'],
    );
  });

  test('invalid grade, content and directed pair never enter SRS journal',
      () async {
    final bridge = SrsCompatBridge(clock: () => DateTime.utc(2026, 10, 25));
    const key = 'core-rejected-invalid-review-20261025';
    final initialCount = UnifiedSrsScheduler.instance.history
        .where((event) => event.learnerContentKey == key)
        .length;

    await expectLater(
      bridge.recordReviewCompat(
        contentKey: key,
        rating: 5,
        sourceIso: 'de',
        targetIso: 'ar',
      ),
      throwsArgumentError,
    );
    await expectLater(
      bridge.recordReviewCompat(
        contentKey: key,
        rating: 3,
        sourceIso: 'de',
        targetIso: 'de',
      ),
      throwsArgumentError,
    );
    await expectLater(
      bridge.recordReviewCompat(
        contentKey: ' ',
        rating: 3,
        sourceIso: 'de',
        targetIso: 'ar',
      ),
      throwsArgumentError,
    );

    expect(
      UnifiedSrsScheduler.instance.history
          .where((event) => event.learnerContentKey == key)
          .length,
      initialCount,
    );
  });


  test('legacy review fails closed without a bound canonical writer', () async {
    final bridge = SrsCompatBridge(clock: () => DateTime.utc(2026, 10, 25));
    const key = 'core-no-durable-writer-20261025';
    await expectLater(
      bridge.recordReviewCompat(
        contentKey: key, rating: 3, sourceIso: 'de', targetIso: 'ar',
      ),
      throwsStateError,
    );
    expect(
      UnifiedSrsScheduler.instance.history
          .where((event) => event.learnerContentKey == key),
      isEmpty,
      reason: 'An in-memory journal is not proof of persisted progress',
    );
  });

  test('failed canonical write cannot acknowledge a review', () async {
    var attempts = 0;
    final bridge = SrsCompatBridge(
      clock: () => DateTime.utc(2026, 10, 25),
      durableWriter: (_) async {
        attempts++;
        if (attempts == 1) throw StateError('storage unavailable');
      },
    );
    const key = 'core-durable-writer-failure-20261025';
    Future<void> submit() => bridge.recordReviewCompat(
      contentKey: key, rating: 3, sourceIso: 'de', targetIso: 'ar',
    );
    await expectLater(submit(), throwsStateError);
    expect(
      UnifiedSrsScheduler.instance.history
          .where((event) => event.learnerContentKey == key),
      isEmpty,
    );
    await submit();
    expect(attempts, 2);
    expect(
      UnifiedSrsScheduler.instance.history
          .where((event) => event.learnerContentKey == key),
      hasLength(1),
    );
  });

  test('compat journal projects only after canonical write finishes', () async {
    final release = Completer<void>();
    var writes = 0;
    final bridge = SrsCompatBridge(
      clock: () => DateTime.utc(2026, 10, 25),
      durableWriter: (_) async {
        writes++;
        await release.future;
      },
    );
    const key = 'core-durable-writer-ordering-20261025';
    final pending = bridge.recordReviewCompat(
      contentKey: key, rating: 3, sourceIso: 'de', targetIso: 'ar',
    );
    await Future<void>.delayed(Duration.zero);
    expect(writes, 1);
    expect(
      UnifiedSrsScheduler.instance.history
          .where((event) => event.learnerContentKey == key),
      isEmpty,
    );
    release.complete();
    await pending;
    expect(
      UnifiedSrsScheduler.instance.history
          .where((event) => event.learnerContentKey == key),
      hasLength(1),
    );
  });

  test('canonical writer cannot be replaced without a new bridge', () {
    final bridge = SrsCompatBridge(clock: () => DateTime.utc(2026, 10, 25));
    bridge.bindCanonicalWriter((_) async {});
    expect(() => bridge.bindCanonicalWriter((_) async {}), throwsStateError);
  });

  test('serializes same-card compatibility writes until durable completion',
      () async {
    final releaseFirst = Completer<void>();
    final entered = <String>[];
    final bridge = SrsCompatBridge(
      clock: () => DateTime.utc(2026, 10, 25, 1),
      durableWriter: (event) async {
        entered.add(event.reviewEventId);
        if (entered.length == 1) await releaseFirst.future;
      },
    );
    const key = 'core-same-card-durable-order-20261025';

    final first = bridge.recordReviewCompat(
      contentKey: key, rating: 3, sourceIso: 'de', targetIso: 'ar',
    );
    await Future<void>.delayed(Duration.zero);
    final second = bridge.recordReviewCompat(
      contentKey: key, rating: 1, sourceIso: 'de', targetIso: 'ar',
    );
    await Future<void>.delayed(Duration.zero);
    expect(entered, hasLength(1),
        reason: 'A later review must not overtake an unfinished write');
    releaseFirst.complete();
    await Future.wait(<Future<void>>[first, second]);
    expect(entered, hasLength(2));
    expect(entered[0], isNot(entered[1]));
  });

  test('opposite directed pairs remain independent while one write waits',
      () async {
    final releaseForward = Completer<void>();
    final enteredPairs = <String>[];
    final bridge = SrsCompatBridge(
      clock: () => DateTime.utc(2026, 10, 25, 1),
      durableWriter: (event) async {
        enteredPairs.add(event.languagePairKey);
        if (event.languagePairKey == 'de_ar') {
          await releaseForward.future;
        }
      },
    );
    const key = 'core-opposite-pair-durable-order-20261025';

    final forward = bridge.recordReviewCompat(
      contentKey: key, rating: 3, sourceIso: 'de', targetIso: 'ar',
    );
    final reverse = bridge.recordReviewCompat(
      contentKey: key, rating: 1, sourceIso: 'ar', targetIso: 'de',
    );
    await reverse.timeout(const Duration(seconds: 2));
    expect(enteredPairs, <String>['de_ar', 'ar_de']);
    releaseForward.complete();
    await forward;
  });

  test('failed write releases queued same-card review without false success',
      () async {
    final releaseFailure = Completer<void>();
    var attempts = 0;
    final bridge = SrsCompatBridge(
      clock: () => DateTime.utc(2026, 10, 25, 1),
      durableWriter: (_) async {
        attempts++;
        if (attempts == 1) {
          await releaseFailure.future;
          throw StateError('injected durable write failure');
        }
      },
    );
    const key = 'core-queued-after-durable-failure-20261025';

    final first = expectLater(
      bridge.recordReviewCompat(
        contentKey: key, rating: 3, sourceIso: 'de', targetIso: 'ar',
      ),
      throwsStateError,
    );
    final second = bridge.recordReviewCompat(
      contentKey: key, rating: 1, sourceIso: 'de', targetIso: 'ar',
    );
    await Future<void>.delayed(Duration.zero);
    expect(attempts, 1);
    releaseFailure.complete();
    await first;
    await second;
    expect(attempts, 2);
    expect(
      UnifiedSrsScheduler.instance.history
          .where((event) => event.learnerContentKey == key),
      hasLength(1),
      reason: 'Only the successfully committed review is projected',
    );
  });

}
