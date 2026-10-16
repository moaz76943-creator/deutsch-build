import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/bootstrap/isolated_bootstrap_pipeline.dart';

class FakeBootstrapStep extends BootstrapStep {
  FakeBootstrapStep(this.name, this.action, {this.critical = true});

  @override
  final String name;
  final Future<BootstrapStepResult> Function() action;
  final bool critical;

  @override
  bool get isCritical => critical;

  @override
  Future<BootstrapStepResult> execute() => action();
}

void main() {
  test('critical failure stops dependent startup phases', () async {
    var dependentRuns = 0;
    final results = await IsolatedBootstrapPipeline([
      FakeBootstrapStep('critical', () async => const BootstrapStepResult(
        stepName: 'critical', status: BootstrapStepStatus.fatalFailure,
      )),
      FakeBootstrapStep('dependent', () async {
        dependentRuns++;
        return const BootstrapStepResult(
          stepName: 'dependent', status: BootstrapStepStatus.success,
        );
      }),
    ]).runPipeline();
    expect(results, hasLength(1));
    expect(results.single.status, BootstrapStepStatus.fatalFailure);
    expect(dependentRuns, 0);
  });

  test('optional exception degrades and does not prevent next phase', () async {
    final results = await IsolatedBootstrapPipeline([
      FakeBootstrapStep('audio', () async => throw StateError('private diagnostic'),
          critical: false),
      FakeBootstrapStep('core', () async => const BootstrapStepResult(
        stepName: 'core', status: BootstrapStepStatus.success,
      )),
    ]).runPipeline();
    expect(results.map((e) => e.status), [
      BootstrapStepStatus.recoverableFailure, BootstrapStepStatus.success,
    ]);
    expect(results.first.message, isNot(contains('private diagnostic')));
  });

  test('optional timeout is bounded and next step can run', () async {
    final hanging = Completer<BootstrapStepResult>();
    final results = await IsolatedBootstrapPipeline([
      FakeBootstrapStep('tts', () => hanging.future, critical: false),
      FakeBootstrapStep('core', () async => const BootstrapStepResult(
        stepName: 'core', status: BootstrapStepStatus.success,
      )),
    ], defaultStepTimeout: const Duration(milliseconds: 1)).runPipeline();
    expect(results, hasLength(2));
    expect(results.first.status, BootstrapStepStatus.recoverableFailure);
    expect(results.last.status, BootstrapStepStatus.success);
  });

  test('critical timeout stops pipeline with fatal outcome', () async {
    final hanging = Completer<BootstrapStepResult>();
    final results = await IsolatedBootstrapPipeline([
      FakeBootstrapStep('storage', () => hanging.future),
      FakeBootstrapStep('unused', () async => const BootstrapStepResult(
        stepName: 'unused', status: BootstrapStepStatus.success,
      )),
    ], defaultStepTimeout: const Duration(milliseconds: 1)).runPipeline();
    expect(results, hasLength(1));
    expect(results.single.status, BootstrapStepStatus.fatalFailure);
  });
}
