import 'dart:async';

import 'package:deutsch_bilarabi/core/bootstrap/isolated_bootstrap_pipeline.dart';
import 'package:flutter_test/flutter_test.dart';

class _Step extends BootstrapStep {
  _Step(this.name, this.action, {this.critical = true, this.stepTimeout});

  @override
  final String name;
  final Future<BootstrapStepResult> Function() action;
  final bool critical;
  final Duration? stepTimeout;

  @override
  bool get isCritical => critical;

  @override
  Duration? get timeout => stepTimeout;

  @override
  Future<BootstrapStepResult> execute() => action();
}

void main() {
  test('optional fatal result degrades and later phases still run', () async {
    var coreRuns = 0;
    final results = await IsolatedBootstrapPipeline([
      _Step(
        'session',
        () async => const BootstrapStepResult(
          stepName: 'session',
          status: BootstrapStepStatus.fatalFailure,
          message: 'session metadata unreadable',
        ),
        critical: false,
      ),
      _Step('core', () async {
        coreRuns++;
        return const BootstrapStepResult(
          stepName: 'core',
          status: BootstrapStepStatus.success,
        );
      }),
    ]).runPipeline();

    expect(coreRuns, 1);
    expect(results.map((result) => result.status), [
      BootstrapStepStatus.recoverableFailure,
      BootstrapStepStatus.success,
    ]);
    expect(results.first.message, 'session metadata unreadable');
  });

  test('thrown exception text is not copied into the startup result', () async {
    const secret = 'user-vault-path:/data/learner/srs.db';
    final results = await IsolatedBootstrapPipeline([
      _Step('storage', () async => throw StateError(secret), critical: false),
    ]).runPipeline();

    expect(results.single.status, BootstrapStepStatus.recoverableFailure);
    expect(results.single.message, 'Phase failed');
    expect(results.single.message, isNot(contains(secret)));
    expect(results.single.message, isNot(contains('StateError')));
  });

  test('a step timeout overrides a longer pipeline budget', () async {
    final hanging = Completer<BootstrapStepResult>();
    final results = await IsolatedBootstrapPipeline(
      [
        _Step(
          'tts',
          () => hanging.future,
          critical: false,
          stepTimeout: const Duration(milliseconds: 15),
        ),
        _Step(
          'core',
          () async => const BootstrapStepResult(
            stepName: 'core',
            status: BootstrapStepStatus.success,
          ),
        ),
      ],
      defaultStepTimeout: const Duration(seconds: 30),
    ).runPipeline();

    expect(results, hasLength(2));
    expect(results.first.status, BootstrapStepStatus.recoverableFailure);
    expect(results.first.message, 'Phase timed out');
    expect(results.last.status, BootstrapStepStatus.success);
  });

  test('caller-supplied budget bounds a hung critical phase', () async {
    final hanging = Completer<BootstrapStepResult>();
    final results = await IsolatedBootstrapPipeline([
      _Step('storage', () => hanging.future),
      _Step(
        'later',
        () async => const BootstrapStepResult(
          stepName: 'later',
          status: BootstrapStepStatus.success,
        ),
      ),
    ], defaultStepTimeout: const Duration(milliseconds: 20)).runPipeline();

    expect(results, hasLength(1));
    expect(results.single.status, BootstrapStepStatus.fatalFailure);
    expect(results.single.message, 'Phase timed out');
  });

  test('startup budget is finite so the splash cannot wait forever', () {
    expect(
      IsolatedBootstrapPipeline.startupStepBudget,
      lessThan(const Duration(seconds: 30)),
    );
    expect(
      IsolatedBootstrapPipeline.startupStepBudget,
      greaterThan(const Duration(seconds: 1)),
    );
  });
}
