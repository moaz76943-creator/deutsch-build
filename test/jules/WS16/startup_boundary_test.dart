import 'dart:async';

import 'package:deutsch_bilarabi/core/bootstrap/startup_boundary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeStartupOperations implements StartupOperations {
  FakeStartupOperations(this.outcomes);

  final List<Future<StartupOutcome>> outcomes;
  int starts = 0;
  int stableMarks = 0;
  int safeModeExits = 0;
  int safeModeContinues = 0;

  @override
  Future<StartupOutcome> start() => outcomes[starts++];

  @override
  Future<void> markStable() async {
    stableMarks++;
  }

  @override
  Future<void> exitSafeMode() async {
    safeModeExits++;
  }

  @override
  Future<StartupOutcome> continueSafeOffline() async {
    safeModeContinues++;
    return const StartupOutcome(
      StartupState.DEGRADED, contentAvailable: true,
    );
  }
}

Future<void> mountBoundary(
  WidgetTester tester,
  FakeStartupOperations operations, {
  Duration startupTimeout = const Duration(seconds: 5),
}) async {
  await tester.pumpWidget(MaterialApp(
    home: StartupBoundary(
      operations: operations,
      startupTimeout: startupTimeout,
      child: const Scaffold(body: Center(child: Text('Offline Explorer'))),
    ),
  ));
}

void main() {
  testWidgets('first frame renders without waiting for initialization', (tester) async {
    final waiting = Completer<StartupOutcome>();
    final ops = FakeStartupOperations([waiting.future]);
    await mountBoundary(tester, ops);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Offline Explorer'), findsNothing);
    waiting.complete(const StartupOutcome(
      StartupState.READY, contentAvailable: true,
    ));
    await tester.pumpAndSettle();
    expect(find.text('Offline Explorer'), findsOneWidget);
  });

  testWidgets('missing SQLite pack presents bounded offline recovery', (tester) async {
    final ops = FakeStartupOperations([
      Future.value(const StartupOutcome(StartupState.DEGRADED)),
    ]);
    await mountBoundary(tester, ops);
    await tester.pumpAndSettle();
    expect(find.text('المحتوى غير متاح حاليًا'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Offline Explorer'), findsNothing);
  });

  testWidgets('optional audio failure permits local content', (tester) async {
    final ops = FakeStartupOperations([
      Future.value(const StartupOutcome(
        StartupState.DEGRADED, contentAvailable: true,
      )),
    ]);
    await mountBoundary(tester, ops);
    await tester.pumpAndSettle();
    expect(find.text('Offline Explorer'), findsOneWidget);
    expect(find.textContaining('الميزات الاختيارية'), findsOneWidget);
  });

  testWidgets('crash-loop safe mode never silently clears learner data', (tester) async {
    final ops = FakeStartupOperations([
      Future.value(const StartupOutcome(StartupState.SAFE_MODE)),
      Future.value(const StartupOutcome(
        StartupState.READY, contentAvailable: true,
      )),
    ]);
    await mountBoundary(tester, ops);
    await tester.pumpAndSettle();
    expect(find.text('الوضع الآمن'), findsOneWidget);
    expect(ops.safeModeExits, 0);
    await tester.tap(find.text('إعادة المحاولة مرة واحدة'));
    await tester.pumpAndSettle();
    expect(ops.safeModeExits, 1);
    expect(find.text('Offline Explorer'), findsOneWidget);
  });

  testWidgets('safe offline continuation leaves crash ledger intact', (tester) async {
    final ops = FakeStartupOperations([
      Future.value(const StartupOutcome(StartupState.SAFE_MODE)),
    ]);
    await mountBoundary(tester, ops);
    await tester.pumpAndSettle();
    await tester.tap(find.text('متابعة آمنة بالمحتوى المحلي'));
    await tester.pumpAndSettle();
    expect(ops.safeModeExits, 0);
    expect(ops.safeModeContinues, 1);
    expect(find.text('Offline Explorer'), findsOneWidget);
  });

  testWidgets('fatal storage issue is explicit; retry is limited', (tester) async {
    final failed = Future.value(
      const StartupOutcome(StartupState.CRITICAL_ERROR),
    );
    final ops = FakeStartupOperations([failed, failed]);
    await mountBoundary(tester, ops);
    await tester.pumpAndSettle();
    expect(find.text('تعذر بدء الخدمات الأساسية'), findsOneWidget);
    await tester.tap(find.text('إعادة المحاولة مرة واحدة'));
    await tester.pumpAndSettle();
    expect(ops.starts, 2);
    expect(find.text('لا توجد محاولات استعادة إضافية لهذه الجلسة.'), findsOneWidget);
  });

  testWidgets('hung startup future ends in critical recovery instead of spinner', (tester) async {
    final waiting = Completer<StartupOutcome>();
    final ops = FakeStartupOperations([waiting.future]);
    await mountBoundary(tester, ops,
        startupTimeout: const Duration(milliseconds: 5));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    expect(find.text('تعذر بدء الخدمات الأساسية'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('repeated startup recovers after prior optional failure', (tester) async {
    final ops = FakeStartupOperations([
      Future.value(const StartupOutcome(
        StartupState.DEGRADED, contentAvailable: true,
      )),
      Future.value(const StartupOutcome(
        StartupState.READY, contentAvailable: true,
      )),
    ]);
    await mountBoundary(tester, ops);
    await tester.pumpAndSettle();
    expect(find.textContaining('الميزات الاختيارية'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await mountBoundary(tester, ops);
    await tester.pumpAndSettle();
    expect(ops.starts, 2);
    expect(find.text('Offline Explorer'), findsOneWidget);
    expect(find.textContaining('الميزات الاختيارية'), findsNothing);
  });

  testWidgets('late completion after disposal does not call setState', (tester) async {
    final waiting = Completer<StartupOutcome>();
    final ops = FakeStartupOperations([waiting.future]);
    await mountBoundary(tester, ops);
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    waiting.complete(const StartupOutcome(
      StartupState.READY, contentAvailable: true,
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
