
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/core/bootstrap/isolated_bootstrap_pipeline.dart';
import 'package:deutsch_bilarabi/core/bootstrap/startup_boundary.dart';
import 'package:deutsch_bilarabi/services/crash_loop_guard.dart';

class _MockCriticalStep extends BootstrapStep {
  @override
  String get name => 'mock_critical';

  @override
  bool get isCritical => true;

  @override
  Duration get timeout => const Duration(seconds: 1);

  final bool shouldSucceed;

  _MockCriticalStep({this.shouldSucceed = true});

  @override
  Future<BootstrapStepResult> execute() async {
    return BootstrapStepResult(
      stepName: name,
      status: shouldSucceed
          ? BootstrapStepStatus.success
          : BootstrapStepStatus.fatalFailure,
    );
  }
}

class _MockOptionalStep extends BootstrapStep {
  @override
  String get name => 'mock_optional';

  @override
  bool get isCritical => false;

  @override
  Duration get timeout => const Duration(milliseconds: 200);

  final bool shouldThrow;
  final bool shouldTimeout;
  final bool shouldFail;

  _MockOptionalStep({
    this.shouldThrow = false,
    this.shouldTimeout = false,
    this.shouldFail = false,
  });

  @override
  Future<BootstrapStepResult> execute() async {
    if (shouldThrow) {
      throw Exception('Optional step crashed');
    }
    if (shouldTimeout) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return const BootstrapStepResult(
        stepName: 'mock_optional',
        status: BootstrapStepStatus.success,
      );
    }
    return BootstrapStepResult(
      stepName: name,
      status: shouldFail
          ? BootstrapStepStatus.recoverableFailure
          : BootstrapStepStatus.success,
    );
  }
}

class _MockCrashLoopGuard extends CrashLoopGuard {
  bool forceSafeMode = false;

  _MockCrashLoopGuard() : super(store: _MockBootLedgerStore());

  @override
  Future<bool> beginBoot() async {
    return forceSafeMode;
  }
}

class _MockBootLedgerStore implements BootLedgerStore {
  @override
  Future<Map<String, dynamic>?> read() async => null;
  @override
  Future<void> write(Map<String, dynamic> state) async {}
}

void main() {
  group('IsolatedBootstrapPipeline', () {
    test('Executes steps and correctly classifies failures', () async {
      final pipeline = IsolatedBootstrapPipeline([
        _MockCriticalStep(shouldSucceed: true),
        _MockOptionalStep(shouldFail: true), // Should be recoverable
        _MockOptionalStep(shouldThrow: true), // Should be recoverable
        _MockOptionalStep(shouldTimeout: true), // Should be recoverable
      ]);

      final results = await pipeline.runPipeline();

      expect(results.length, 4);

      final criticalResult =
          results.firstWhere((r) => r.stepName == 'mock_critical');
      expect(criticalResult.status, BootstrapStepStatus.success);

      final failingResults =
          results.where((r) => r.stepName == 'mock_optional').toList();
      expect(failingResults.length, 3);
      for (final result in failingResults) {
        expect(result.status, BootstrapStepStatus.recoverableFailure);
      }
    });

    test('Critical failure is correctly classified', () async {
      final pipeline = IsolatedBootstrapPipeline([
        _MockCriticalStep(shouldSucceed: false),
      ]);

      final results = await pipeline.runPipeline();
      expect(results.single.status, BootstrapStepStatus.fatalFailure);
    });
  });

  group('DeviceStartupOperations', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
        'Handles missing extra steps gracefully (CRITICAL_ERROR from active_content)',
        () async {
      final mockGuard = _MockCrashLoopGuard();
      // Since it's a real DeviceStartupOperations, _ActiveContentStep will try to hit the real DB.
      // We expect it to throw or fail, resulting in CRITICAL_ERROR or DEGRADED based on pipeline behavior.
      final ops = DeviceStartupOperations(guard: mockGuard);
      final outcome = await ops.start();

      // Without DB initialized, it falls into a critical error for preferences or DB
      // We just ensure it doesn't infinite loop.
      expect(
          outcome.state == StartupState.fatal ||
              outcome.state == StartupState.degraded,
          isTrue);
    });

    test('Forces Safe Mode when guard says so', () async {
      final mockGuard = _MockCrashLoopGuard()..forceSafeMode = true;
      final ops = DeviceStartupOperations(guard: mockGuard);
      final outcome = await ops.start();

      expect(outcome.state, StartupState.safeMode);
    });
  });
}
