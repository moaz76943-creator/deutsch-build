import 'package:deutsch_bilarabi/bootstrap/production_bootstrap.dart';
import 'package:deutsch_bilarabi/bootstrap/production_runtime.dart';
import 'package:deutsch_bilarabi/core/bootstrap/startup_boundary.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ReadyStartup implements StartupOperations {
  @override
  Future<StartupOutcome> start() async {
    return const StartupOutcome(StartupState.READY, contentAvailable: true);
  }

  @override
  Future<void> markStable() async {}

  @override
  Future<void> exitSafeMode() async {}

  @override
  Future<StartupOutcome> continueSafeOffline() async {
    return const StartupOutcome(StartupState.DEGRADED, contentAvailable: true);
  }
}

void main() {
  test('pack security uses the keystore vault cipher', () {
    final coordinator = ProductionRuntimeCoordinator();
    expect(coordinator.progressCipher, isA<AndroidKeystoreVaultCipher>());
  });

  testWidgets('production shell shows the home after startup is ready',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: hostProductionShell(
          operations: _ReadyStartup(),
          stabilityWindow: Duration.zero,
          child: const Text('home-ready'),
        ),
      ),
    );
    expect(find.text('جاري تهيئة التطبيق دون اتصال...'), findsOneWidget);
    expect(find.text('home-ready'), findsNothing);

    await tester.pump();
    expect(find.text('home-ready'), findsOneWidget);
    await tester.pump();
  });
}
