import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';
import 'package:deutsch_bilarabi/core/concurrency/cancellation_token.dart';
import 'package:deutsch_bilarabi/core/resilience/resilient_feature_executor.dart';

void main() {
  test('transient errors use bounded retry and succeed', () async {
    final executor = ResilientFeatureExecutor();
    var attempts = 0;
    final outcome = await executor.execute(
      task: () async {
        attempts++;
        if (attempts < 3) throw StateError('transient');
        return 'ready';
      },
      backoff: const Duration(milliseconds: 1),
    );
    expect(attempts, 3);
    expect(outcome.data, 'ready');
  });

  test('a hung optional feature returns an outcome after deadline', () async {
    final executor = ResilientFeatureExecutor();
    final result = await executor.execute<void>(
      task: () => Completer<void>().future,
      maxAttempts: 1,
      taskTimeout: const Duration(milliseconds: 5),
    );
    expect(result.isFailed, isTrue);
    expect(result.error, isA<TimeoutException>());
  });

  test('previous sessions never publish late completion', () async {
    final executor = ResilientFeatureExecutor();
    final pending = Completer<String>();
    final old = executor.execute(task: () => pending.future);
    executor.resetSession();
    pending.complete('old');
    expect((await old).isStale, isTrue);
  });

  test('session cancellation wins over successful task completion', () async {
    final executor = ResilientFeatureExecutor();
    final token = CancellationToken();
    final pending = Completer<void>();
    final future = executor.execute<void>(
      task: () => pending.future, cancellationToken: token,
    );
    token.cancel();
    pending.complete();
    expect((await future).isCancelled, isTrue);
  });

  test('critical storage failures do not retry', () async {
    final executor = ResilientFeatureExecutor();
    var attempts = 0;
    await expectLater(executor.execute<void>(
      task: () async {
        attempts++;
        throw const StorageFailure('critical', 'store inaccessible');
      },
      backoff: Duration.zero,
    ), throwsA(isA<StorageFailure>()));
    expect(attempts, 1);
  });
  test('timed out tasks never run again while prior work may be alive', () async {
    final executor = ResilientFeatureExecutor();
    var invoked = 0;
    final result = await executor.execute<void>(
      task: () {
        invoked++;
        return Completer<void>().future;
      },
      maxAttempts: 3,
      backoff: const Duration(milliseconds: 1),
      taskTimeout: const Duration(milliseconds: 5),
    );
    expect(result.isFailed, isTrue);
    expect(result.error, isA<TimeoutException>());
    expect(invoked, 1, reason: 'No duplicate un-cancellable side effects');
  });

}
