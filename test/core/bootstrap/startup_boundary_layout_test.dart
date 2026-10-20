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
}
