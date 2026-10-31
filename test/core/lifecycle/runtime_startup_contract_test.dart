import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/bootstrap/startup_boundary.dart';
import 'package:deutsch_bilarabi/main.dart';

class _ControlledStartup implements StartupOperations {
  _ControlledStartup(this.startOperation);
  final Future<StartupOutcome> Function() startOperation;
  int starts = 0;

  @override
  Future<StartupOutcome> start() {
    starts++;
    return startOperation();
  }

  @override
  Future<void> markStable() async {}

  @override
  Future<void> exitSafeMode() async {}

  @override
  Future<StartupOutcome> continueSafeOffline() async =>
      const StartupOutcome(StartupState.DEGRADED);
}

void main() {
  testWidgets('canonical main preserves first-frame startup boundary',
      (tester) async {
    await tester.pumpWidget(const DeutschApp());
    expect(find.byType(StartupBoundary), findsOneWidget);
    expect(find.text('جاري تهيئة التطبيق دون اتصال...'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('stalled startup ends in visible recovery without splash hang',
      (tester) async {
    final stalled = Completer<StartupOutcome>();
    final operations = _ControlledStartup(() => stalled.future);
    await tester.pumpWidget(MaterialApp(
      home: StartupBoundary(
        operations: operations,
        startupTimeout: const Duration(milliseconds: 30),
        child: const Text('Learning'),
      ),
    ));
    expect(find.text('جاري تهيئة التطبيق دون اتصال...'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.text('تعذر بدء الخدمات الأساسية'), findsOneWidget);
    expect(operations.starts, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    stalled.complete(const StartupOutcome(StartupState.READY));
    await tester.pump();
    expect(find.text('Learning'), findsNothing);
  });

  testWidgets('critical retry occurs at most once', (tester) async {
    final operations = _ControlledStartup(
        () async => const StartupOutcome(StartupState.CRITICAL_ERROR));
    await tester.pumpWidget(MaterialApp(
      home: StartupBoundary(
        operations: operations,
        child: const Text('Learning'),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('تعذر بدء الخدمات الأساسية'), findsOneWidget);
    await tester.tap(find.text('إعادة المحاولة مرة واحدة'));
    await tester.pumpAndSettle();
    expect(operations.starts, 2);
    expect(find.text('لا توجد محاولات استعادة إضافية لهذه الجلسة.'),
        findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('safe mode retains offline continuation without deleting data',
      (tester) async {
    final operations = _ControlledStartup(
        () async => const StartupOutcome(StartupState.SAFE_MODE));
    await tester.pumpWidget(MaterialApp(
      home: StartupBoundary(
        operations: operations,
        child: const Text('Learning'),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('الوضع الآمن'), findsOneWidget);
    await tester.tap(find.text('متابعة آمنة بالمحتوى المحلي'));
    await tester.pumpAndSettle();
    expect(find.text('المحتوى غير متاح حاليًا'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
