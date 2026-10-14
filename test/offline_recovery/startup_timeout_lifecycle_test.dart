import 'dart:async';

import 'package:deutsch_bilarabi/core/bootstrap/startup_boundary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStartup implements StartupOperations {
  _FakeStartup(this.onStart, {this.onContinue});

  final Future<StartupOutcome> Function() onStart;
  final Future<StartupOutcome> Function()? onContinue;
  int stableMarks = 0;

  @override
  Future<StartupOutcome> start() => onStart();

  @override
  Future<StartupOutcome> continueSafeOffline() {
    return onContinue?.call() ??
        Future<StartupOutcome>.value(
          const StartupOutcome(StartupState.DEGRADED),
        );
  }

  @override
  Future<void> markStable() async {
    stableMarks++;
  }

  @override
  Future<void> exitSafeMode() async {}
}

Widget _app(
  StartupOperations operations, {
  Duration timeout = const Duration(milliseconds: 100),
}) {
  return MaterialApp(
    home: StartupBoundary(
      operations: operations,
      startupTimeout: timeout,
      stabilityWindow: const Duration(minutes: 1),
      child: const Scaffold(body: Center(child: Text('LESSON_READY'))),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('zero installed packs shows recovery rather than endless splash',
      (tester) async {
    final startup = _FakeStartup(
      () async => const StartupOutcome(StartupState.DEGRADED),
    );
    await tester.pumpWidget(_app(startup));
    await tester.pump();

    expect(find.text('المحتوى غير متاح حاليًا'), findsOneWidget);
    expect(find.text('LESSON_READY'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    // Disposing cancels the long stability timer before test tearDown.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('stalled boot reaches visible error within configured deadline',
      (tester) async {
    final neverFinishes = Completer<StartupOutcome>();
    final startup = _FakeStartup(() => neverFinishes.future);
    await tester.pumpWidget(
      _app(startup, timeout: const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 51));
    await tester.pump();

    expect(find.text('تعذر بدء الخدمات الأساسية'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('LESSON_READY'), findsNothing);
  });

  testWidgets('late boot completion after dispose cannot revive the UI',
      (tester) async {
    final delayed = Completer<StartupOutcome>();
    final startup = _FakeStartup(() => delayed.future);
    await tester.pumpWidget(_app(startup));
    await tester.pumpWidget(const SizedBox.shrink());

    delayed.complete(
      const StartupOutcome(StartupState.READY, contentAvailable: true),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(startup.stableMarks, 0);
    expect(find.text('LESSON_READY'), findsNothing);
  });

  testWidgets('safe-mode offline continuation does not fabricate pack success',
      (tester) async {
    final startup = _FakeStartup(
      () async => const StartupOutcome(StartupState.SAFE_MODE),
      onContinue: () async => const StartupOutcome(StartupState.DEGRADED),
    );
    await tester.pumpWidget(_app(startup));
    await tester.pump();
    expect(find.text('الوضع الآمن'), findsOneWidget);

    await tester.tap(find.text('متابعة آمنة بالمحتوى المحلي'));
    await tester.pump();
    expect(find.text('المحتوى غير متاح حاليًا'), findsOneWidget);
    expect(find.text('LESSON_READY'), findsNothing);
  });
}
