import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/bootstrap/startup_boundary.dart';
import 'package:deutsch_bilarabi/core/bootstrap/isolated_bootstrap_pipeline.dart';

class MockStartupOperations implements StartupOperations {
  StartupOutcome _outcome;
  bool isStableMarked = false;
  bool isSafeModeExited = false;
  bool isSafeOfflineContinued = false;
  Completer<StartupOutcome>? _startCompleter;

  MockStartupOperations(this._outcome);

  void setNextOutcome(StartupOutcome outcome) {
    _outcome = outcome;
  }

  void blockStart() {
    _startCompleter = Completer<StartupOutcome>();
  }

  void unblockStart() {
    if (_startCompleter != null && !_startCompleter!.isCompleted) {
      _startCompleter!.complete(_outcome);
    }
  }

  @override
  Future<StartupOutcome> start() async {
    if (_startCompleter != null) {
      return _startCompleter!.future;
    }
    return _outcome;
  }

  @override
  Future<void> markStable() async {
    isStableMarked = true;
  }

  @override
  Future<void> exitSafeMode() async {
    isSafeModeExited = true;
  }

  @override
  Future<StartupOutcome> continueSafeOffline() async {
    isSafeOfflineContinued = true;
    return const StartupOutcome(StartupState.degraded, contentAvailable: true);
  }
}

void main() {
  group('StartupBoundary Tests', () {
    testWidgets('shows child when ready', (WidgetTester tester) async {
      final ops = MockStartupOperations(const StartupOutcome(StartupState.ready, contentAvailable: true));
      await tester.pumpWidget(MaterialApp(
        home: StartupBoundary(
          operations: ops,
          stabilityWindow: const Duration(seconds: 1),
          child: const Text('App Ready'),
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.text('App Ready'), findsOneWidget);
    });

    testWidgets('shows recovery when degraded and no content', (WidgetTester tester) async {
      final ops = MockStartupOperations(const StartupOutcome(StartupState.degraded, contentAvailable: false));
      await tester.pumpWidget(MaterialApp(
        home: StartupBoundary(
          operations: ops,
          stabilityWindow: const Duration(seconds: 1),
          child: const Text('App Ready'),
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.text('المحتوى غير متاح حاليًا'), findsOneWidget);
    });

    testWidgets('shows recovery when safe mode', (WidgetTester tester) async {
      final ops = MockStartupOperations(const StartupOutcome(StartupState.safeMode, contentAvailable: false));
      await tester.pumpWidget(MaterialApp(
        home: StartupBoundary(
          operations: ops,
          stabilityWindow: const Duration(seconds: 1),
          child: const Text('App Ready'),
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.text('الوضع الآمن'), findsOneWidget);
    });

    testWidgets('shows recovery when critical error', (WidgetTester tester) async {
      final ops = MockStartupOperations(const StartupOutcome(StartupState.criticalError, contentAvailable: false));
      await tester.pumpWidget(MaterialApp(
        home: StartupBoundary(
          operations: ops,
          stabilityWindow: const Duration(seconds: 1),
          child: const Text('App Ready'),
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.text('تعذر بدء الخدمات الأساسية'), findsOneWidget);
    });
  });

  group('IsolatedBootstrapPipeline Tests', () {
    test('success case', () async {
      final pipeline = IsolatedBootstrapPipeline([
        _MockStep('step1', false, null, BootstrapStepStatus.success),
      ]);
      final results = await pipeline.runPipeline();
      expect(results.length, 1);
      expect(results[0].status, BootstrapStepStatus.success);
    });

    test('timeout case', () async {
      final pipeline = IsolatedBootstrapPipeline([
        _MockStep('slow_worker', false, const Duration(milliseconds: 50), BootstrapStepStatus.success, delay: const Duration(milliseconds: 100)),
      ]);
      final results = await pipeline.runPipeline();
      expect(results.length, 1);
      expect(results[0].status, BootstrapStepStatus.recoverableFailure);
    });

    test('critical failure case', () async {
      final pipeline = IsolatedBootstrapPipeline([
        _MockStep('critical_step', true, null, BootstrapStepStatus.fatalFailure),
        _MockStep('step2', false, null, BootstrapStepStatus.success),
      ]);
      final results = await pipeline.runPipeline();
      expect(results.length, 1);
      expect(results[0].status, BootstrapStepStatus.fatalFailure);
    });

    test('optional failure case', () async {
      final pipeline = IsolatedBootstrapPipeline([
        _MockStep('optional_step', false, null, BootstrapStepStatus.fatalFailure),
        _MockStep('step2', false, null, BootstrapStepStatus.success),
      ]);
      final results = await pipeline.runPipeline();
      expect(results.length, 2);
      expect(results[0].status, BootstrapStepStatus.recoverableFailure);
      expect(results[1].status, BootstrapStepStatus.success);
    });

    test('missing audio', () async {
      final pipeline = IsolatedBootstrapPipeline([
        _MockStep('audio_step', false, null, BootstrapStepStatus.recoverableFailure),
      ]);
      final results = await pipeline.runPipeline();
      expect(results.length, 1);
      expect(results[0].status, BootstrapStepStatus.recoverableFailure);
    });
  });
}

class _MockStep extends BootstrapStep {
  @override
  final String name;
  @override
  final bool isCritical;
  @override
  final Duration? timeout;
  final BootstrapStepStatus statusToReturn;
  final Duration delay;

  _MockStep(this.name, this.isCritical, this.timeout, this.statusToReturn, {this.delay = Duration.zero});

  @override
  Future<BootstrapStepResult> execute() async {
    await Future.delayed(delay);
    if (delay > (timeout ?? const Duration(days: 99))) {
        throw TimeoutException('timed out');
    }
    return BootstrapStepResult(stepName: name, status: statusToReturn);
  }
}
