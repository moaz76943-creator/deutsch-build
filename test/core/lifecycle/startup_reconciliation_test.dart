import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/bootstrap/startup_boundary.dart';
import 'package:deutsch_bilarabi/core/resilience/feature_boundary.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';

class _FakeStartup implements StartupOperations {
  _FakeStartup(this.future);
  final Future<StartupOutcome> future;
  var stableCalls = 0;
  @override
  Future<StartupOutcome> start() => future;
  @override
  Future<void> markStable() async { stableCalls++; }
  @override
  Future<void> exitSafeMode() async {}
  @override
  Future<StartupOutcome> continueSafeOffline() async =>
      const StartupOutcome(StartupState.DEGRADED);
}

void main() {
  testWidgets('first frame remains visible while startup is outstanding',
      (tester) async {
    final started = Completer<StartupOutcome>();
    final ops = _FakeStartup(started.future);
    await tester.pumpWidget(MaterialApp(
      home: StartupBoundary(
        operations: ops,
        child: const Text('content ready'),
      ),
    ));
    expect(find.text('جاري تهيئة التطبيق دون اتصال...'), findsOneWidget);
    started.complete(const StartupOutcome(
      StartupState.READY, contentAvailable: true,
    ));
    await tester.pump();
    await tester.pump();
    expect(find.text('content ready'), findsOneWidget);
  });

  testWidgets('failed bootstrap exposes recovery instead of infinite splash',
      (tester) async {
    final failed = Completer<StartupOutcome>();
    final ops = _FakeStartup(failed.future);
    await tester.pumpWidget(MaterialApp(
      home: StartupBoundary(
        operations: ops,
        child: const Text('content ready'),
      ),
    ));
    failed.completeError(StateError('simulated local init failure'));
    await tester.pump();
    await tester.pump();
    expect(find.text('تعذر بدء الخدمات الأساسية'), findsOneWidget);
    expect(find.text('content ready'), findsNothing);
  });

  testWidgets('disposed startup ignores late successful result',
      (tester) async {
    final started = Completer<StartupOutcome>();
    await tester.pumpWidget(MaterialApp(
      home: StartupBoundary(
        operations: _FakeStartup(started.future),
        child: const Text('old startup'),
      ),
    ));
    await tester.pumpWidget(const MaterialApp(home: Text('new session')));
    started.complete(const StartupOutcome(
      StartupState.READY, contentAvailable: true,
    ));
    await tester.pump();
    expect(find.text('old startup'), findsNothing);
    expect(find.text('new session'), findsOneWidget);
  });

  testWidgets('optional feature init failure shows fallback', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: FeatureBoundary(
        featureName: 'optional',
        onInitialize: () async { throw StateError('offline option failed'); },
        child: const Text('optional content'),
      ),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('تعذر تشغيل optional'), findsOneWidget);
    expect(find.text('optional content'), findsNothing);
  });

  testWidgets('critical storage report cannot be silently swallowed',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: FeatureBoundary(
        featureName: 'feature',
        child: Text('child'),
      ),
    ));
    expect(
      () => FeatureBoundary.report(
        tester.element(find.text('child')),
        const StorageFailure('store', 'corrupt'),
      ),
      throwsA(isA<StorageFailure>()),
    );
  });
}
