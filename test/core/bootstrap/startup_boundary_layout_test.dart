import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/bootstrap/startup_boundary.dart';

class _CriticalStartup implements StartupOperations {
  @override
  Future<StartupOutcome> start() async =>
      const StartupOutcome(StartupState.CRITICAL_ERROR);

  @override
  Future<void> markStable() async {}

  @override
  Future<void> exitSafeMode() async {}

  @override
  Future<StartupOutcome> continueSafeOffline() async =>
      const StartupOutcome(StartupState.DEGRADED);
}


class _MissingPackStartup implements StartupOperations {
  @override
  Future<StartupOutcome> start() async =>
      const StartupOutcome(StartupState.DEGRADED);

  @override
  Future<void> markStable() async {}

  @override
  Future<void> exitSafeMode() async {}

  @override
  Future<StartupOutcome> continueSafeOffline() async =>
      const StartupOutcome(StartupState.DEGRADED);
}


class _SafeModeMissingPackStartup implements StartupOperations {
  @override
  Future<StartupOutcome> start() async =>
      const StartupOutcome(StartupState.SAFE_MODE);

  @override
  Future<void> markStable() async {}

  @override
  Future<void> exitSafeMode() async {}

  @override
  Future<StartupOutcome> continueSafeOffline() async =>
      const StartupOutcome(StartupState.DEGRADED);
}

void main() {
  testWidgets('critical recovery stays scrollable on compact RTL screens',
      (tester) async {
    tester.view.physicalSize = const Size(320, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(2.0),
        ),
        child: child!,
      ),
      home: StartupBoundary(
        operations: _CriticalStartup(),
        child: const SizedBox.shrink(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('تعذر بدء الخدمات الأساسية'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsWidgets);
    expect(tester.takeException(), isNull);
  });
  testWidgets('offline first run remains accessible when no pack is installed',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: StartupBoundary(
        operations: _MissingPackStartup(),
        child: const Scaffold(
          body: Center(child: Text('FIRST_RUN_ONBOARDING')),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('FIRST_RUN_ONBOARDING'), findsOneWidget);
    expect(find.textContaining('حزمة اللغة'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('safe mode never unlocks unverified local content',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: StartupBoundary(
        operations: _SafeModeMissingPackStartup(),
        child: const Scaffold(
          body: Text('UNVERIFIED_LEARNING_CONTENT'),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('الوضع الآمن'), findsOneWidget);
    await tester.tap(find.text('متابعة آمنة بالمحتوى المحلي'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('UNVERIFIED_LEARNING_CONTENT'), findsNothing);
    expect(find.text('لا تتوفر حزمة محلية موثوقة'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

}
