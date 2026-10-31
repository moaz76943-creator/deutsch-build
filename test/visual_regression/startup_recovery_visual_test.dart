import 'dart:async';

import 'package:deutsch_bilarabi/core/bootstrap/startup_boundary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deterministic boot tests: no disk, network, user database or pack writes.
class _FakeStartup implements StartupOperations {
  _FakeStartup(this.outcomes, {this.offlineOutcome});

  final List<Future<StartupOutcome>> outcomes;
  final StartupOutcome? offlineOutcome;
  int startCalls = 0;
  int continueCalls = 0;
  int stableCalls = 0;

  @override
  Future<StartupOutcome> start() {
    final index = startCalls < outcomes.length
        ? startCalls
        : outcomes.length - 1;
    startCalls++;
    return outcomes[index];
  }

  @override
  Future<StartupOutcome> continueSafeOffline() async {
    continueCalls++;
    return offlineOutcome ??
        const StartupOutcome(StartupState.DEGRADED);
  }

  @override
  Future<void> exitSafeMode() async {}

  @override
  Future<void> markStable() async {
    stableCalls++;
  }
}

Future<void> _showStartup(
  WidgetTester tester,
  _FakeStartup operations, {
  Duration timeout = const Duration(milliseconds: 100),
}) async {
  await tester.pumpWidget(MaterialApp(
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: StartupBoundary(
        operations: operations,
        startupTimeout: timeout,
        stabilityWindow: const Duration(milliseconds: 1),
        child: const Scaffold(body: Center(child: Text('CONTENT_READY'))),
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  testWidgets('splash yields a visible error on a bounded boot timeout',
      (tester) async {
    final never = Completer<StartupOutcome>();
    final operations = _FakeStartup([never.future]);
    await _showStartup(tester, operations);
    expect(find.text('جاري تهيئة التطبيق دون اتصال...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('تعذر بدء الخدمات الأساسية'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('zero installed packs shows recovery, not an empty spinner',
      (tester) async {
    final unavailable = Future<StartupOutcome>.value(
      const StartupOutcome(StartupState.DEGRADED),
    );
    final operations = _FakeStartup([unavailable, unavailable]);
    await _showStartup(tester, operations);
    await tester.pump();

    expect(find.text('المحتوى غير متاح حاليًا'), findsOneWidget);
    expect(find.text('CONTENT_READY'), findsNothing);
    expect(find.text('إعادة المحاولة مرة واحدة'), findsOneWidget);

    await tester.tap(find.text('إعادة المحاولة مرة واحدة'));
    await tester.pump();
    await tester.pump();

    expect(operations.startCalls, 2);
    expect(find.text('إعادة المحاولة مرة واحدة'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('degraded but verified content remains usable offline',
      (tester) async {
    final operations = _FakeStartup([
      Future<StartupOutcome>.value(
        const StartupOutcome(StartupState.DEGRADED, contentAvailable: true),
      ),
    ]);
    await _showStartup(tester, operations);
    await tester.pump();

    expect(find.text('CONTENT_READY'), findsOneWidget);
    expect(find.textContaining('يمكنك المتابعة دون اتصال'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('safe mode offline fallback never claims a missing pack',
      (tester) async {
    final operations = _FakeStartup([
      Future<StartupOutcome>.value(
        const StartupOutcome(StartupState.SAFE_MODE),
      ),
    ], offlineOutcome: const StartupOutcome(StartupState.DEGRADED));
    await _showStartup(tester, operations);
    await tester.pump();

    expect(find.text('الوضع الآمن'), findsOneWidget);
    await tester.tap(find.text('متابعة آمنة بالمحتوى المحلي'));
    await tester.pump();
    await tester.pump();

    expect(operations.continueCalls, 1);
    expect(find.text('المحتوى غير متاح حاليًا'), findsOneWidget);
    expect(find.text('CONTENT_READY'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('late boot completion after dispose cannot recreate UI',
      (tester) async {
    final delayed = Completer<StartupOutcome>();
    final operations = _FakeStartup([delayed.future]);
    await _showStartup(tester, operations);

    await tester.pumpWidget(const MaterialApp(home: Text('CLOSED')));
    delayed.complete(
      const StartupOutcome(StartupState.READY, contentAvailable: true),
    );
    await tester.pump();

    expect(find.text('CLOSED'), findsOneWidget);
    expect(find.text('CONTENT_READY'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recovery remains bounded in a narrow Arabic viewport',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final operations = _FakeStartup([
      Future<StartupOutcome>.value(
        const StartupOutcome(StartupState.CRITICAL_ERROR),
      ),
    ]);
    await _showStartup(tester, operations);
    await tester.pump();
    expect(find.text('تعذر بدء الخدمات الأساسية'), findsOneWidget);
    expect(tester.takeException(), isNull,
        reason: 'A narrow device must not show a RenderFlex overflow.');
  });
}
