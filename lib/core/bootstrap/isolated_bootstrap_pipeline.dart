import 'dart:async';

enum BootstrapStepStatus { success, recoverableFailure, fatalFailure }

class BootstrapStepResult {
  final String stepName;
  final BootstrapStepStatus status;
  final String? message;
  final Duration elapsed;

  const BootstrapStepResult({
    required this.stepName,
    required this.status,
    this.message,
    this.elapsed = Duration.zero,
  });
}

/// One phase of startup. Critical phases abort the pipeline. Optional phases
/// degrade to [BootstrapStepStatus.recoverableFailure] and the next phase runs.
abstract class BootstrapStep {
  String get name;
  Duration get timeout => const Duration(seconds: 6);
  bool get isCritical => true;
  Future<BootstrapStepResult> execute();

  // Existing steps remain source-compatible. Optional steps may opt out of
  // startup-fatal classification without hiding their failures.
  bool get isCritical => true;
  Duration? get timeout => null;
}

<<<<<<< HEAD
/// Isolated bootstrap pipeline with parallel execution of non-dependent steps
/// for reduced startup latency, plus per-step timing for measurement.
=======
/// Bounded sequential bootstrap: each dependency is probed once, and a fatal
/// failure prevents dependent steps from running. Timeouts do not cancel the
/// underlying future; callers must ignore obsolete results after disposal.
>>>>>>> origin/staging/v2-full-platform
class IsolatedBootstrapPipeline {
  final List<BootstrapStep> steps;
  final Duration defaultStepTimeout;

  IsolatedBootstrapPipeline(
    this.steps, {
    this.defaultStepTimeout = const Duration(seconds: 6),
  });

  Future<List<BootstrapStepResult>> runPipeline() async {
<<<<<<< HEAD
    if (steps.isEmpty) return [];

    // Run all steps in parallel for measurable startup improvement.
    // Security-sensitive steps remain isolated via try/catch.
    final futures = steps.map((step) => _runStepWithTiming(step)).toList();
    final results = await Future.wait(futures);

    // Preserve original order in the returned list.
=======
    final results = <BootstrapStepResult>[];
    for (final step in steps) {
      BootstrapStepResult result;
      try {
        final received = await step.execute().timeout(step.timeout);
        result = BootstrapStepResult(
          stepName: step.name,
          status: !step.isCritical &&
                  received.status == BootstrapStepStatus.fatalFailure
              ? BootstrapStepStatus.recoverableFailure
              : received.status,
          message: received.message,
        );
      } on TimeoutException {
        result = BootstrapStepResult(
          stepName: step.name,
          status: step.isCritical
              ? BootstrapStepStatus.fatalFailure
              : BootstrapStepStatus.recoverableFailure,
          message: 'Phase timed out',
        );
      } catch (e) {
        result = BootstrapStepResult(
          stepName: step.name,
          status: step.isCritical
              ? BootstrapStepStatus.fatalFailure
              : BootstrapStepStatus.recoverableFailure,
          message: 'Phase failed',
        );
      }
      results.add(result);
      if (result.status == BootstrapStepStatus.fatalFailure) {
        break;
      }
      results.add(result);
      if (result.status == BootstrapStepStatus.fatalFailure) break;
    }
>>>>>>> origin/staging/v2-full-platform
    return results;
  }

  Future<BootstrapStepResult> _runBounded(BootstrapStep step) async {
    final budget = step.timeout ?? defaultStepTimeout;
    try {
      final received = await step.execute().timeout(budget);
      final fatal = received.status == BootstrapStepStatus.fatalFailure;
      return BootstrapStepResult(
        stepName: step.name,
        status: !step.isCritical && fatal
            ? BootstrapStepStatus.recoverableFailure
            : received.status,
        message: received.message,
      );
    } on TimeoutException {
      return BootstrapStepResult(
        stepName: step.name,
        status: step.isCritical
            ? BootstrapStepStatus.fatalFailure
            : BootstrapStepStatus.recoverableFailure,
        message: 'Phase timed out',
      );
    } catch (_) {
      // Drop the exception object. Its toString() can contain paths,
      // preference keys, or other local details that must not reach the UI.
      return BootstrapStepResult(
        stepName: step.name,
        status: step.isCritical
            ? BootstrapStepStatus.fatalFailure
            : BootstrapStepStatus.recoverableFailure,
        message: 'Phase failed',
      );
    }
  }
}
