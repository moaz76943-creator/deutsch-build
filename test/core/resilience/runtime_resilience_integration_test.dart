import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';
import 'package:deutsch_bilarabi/core/concurrency/cancellation_token.dart';
import 'package:deutsch_bilarabi/core/resilience/feature_boundary.dart';
import 'package:deutsch_bilarabi/core/resilience/recovery_outcome.dart';
import 'package:deutsch_bilarabi/core/resilience/resilient_feature_executor.dart';

void main() {
  test('temporary failures retry bounded times', () async {
    final executor = ResilientFeatureExecutor();
    var attempts = 0;
    final result = await executor.execute<String>(
      task: () async {
        attempts++;
        if (attempts < 3) throw StateError('temporary');
        return 'done';
      },
      backoff: Duration.zero,
    );
    expect(result.isSuccess, isTrue);
    expect(result.data, 'done');
    expect(attempts, 3);
  });

  test('timeout never starts overlapping initialization', () async {
    final executor = ResilientFeatureExecutor();
    final blocked = Completer<String>();
    var attempts = 0;
    final outcome = await executor.execute<String>(
      task: () {
        attempts++;
        return blocked.future;
      },
      attemptTimeout: const Duration(milliseconds: 1),
      backoff: Duration.zero,
    );
    expect(outcome.isFailed, isTrue);
    expect(attempts, 1);
    blocked.complete('late');
  });

  test('cancel and session switch reject stale completions', () async {
    final executor = ResilientFeatureExecutor();
    final token = CancellationToken();
    final pending = Completer<String>();
    final first = executor.execute<String>(
      task: () => pending.future,
      cancellationToken: token,
    );
    token.cancel();
    pending.complete('old');
    expect((await first).isCancelled, isTrue);

    final another = Completer<String>();
    final previous = executor.execute<String>(task: () => another.future);
    executor.resetSession();
    another.complete('wrong-pair');
    expect((await previous).isStale, isTrue);
  });

  test('typed storage integrity failure is not swallowed or retried',
      () async {
    final executor = ResilientFeatureExecutor();
    var attempts = 0;
    final result = await executor.execute<void>(
      task: () async {
        attempts++;
        throw const StorageFailure('corrupt', 'ledger unavailable');
      },
      backoff: Duration.zero,
    );
    expect(result.isFailed, isTrue);
    expect(FailureCategorization.isCritical(result.error!), isTrue);
    expect(attempts, 1);
  });

  testWidgets('reinitialization ignores prior completion on pair change',
      (tester) async {
    final old = Completer<void>();
    final current = Completer<void>();
    var pair = 'de-ar';
    Future<void> init() => pair == 'de-ar' ? old.future : current.future;
    Widget build() => MaterialApp(
          home: Scaffold(
            body: FeatureBoundary(
              featureName: 'lexicon',
              initializationDependency: pair,
              onInitialize: init,
              child: const Text('Ready'),
            ),
          ),
        );
    await tester.pumpWidget(build());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pair = 'de-fr';
    await tester.pumpWidget(build());
    old.complete();
    await tester.pump();
    expect(find.text('Ready'), findsNothing);
    current.complete();
    await tester.pump();
    expect(find.text('Ready'), findsOneWidget);
  });

  testWidgets('failed optional init shows fallback rather than endless spinner',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FeatureBoundary(
          featureName: 'audio',
          onInitialize: () async => throw StateError('missing audio'),
          maxInitializationAttempts: 1,
          child: const Text('Ready'),
        ),
      ),
    ));
    await tester.pump();
    expect(find.text('تعذر تشغيل audio'), findsOneWidget);
  });
}
