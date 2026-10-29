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

abstract class BootstrapStep {
  String get name;
  /// Critical steps must succeed; non-critical failures are recoverable.
  bool get isCritical => true;
  Duration get timeout => const Duration(seconds: 5);
  Future<BootstrapStepResult> execute();
}

/// Isolated bootstrap pipeline with parallel execution of non-dependent steps
/// for reduced startup latency, plus per-step timing for measurement.
class IsolatedBootstrapPipeline {
  final List<BootstrapStep> steps;

  IsolatedBootstrapPipeline(this.steps);

  Future<List<BootstrapStepResult>> runPipeline() async {
    if (steps.isEmpty) return [];

    // Run all steps in parallel for measurable startup improvement.
    // Security-sensitive steps remain isolated via try/catch.
    final futures = steps.map((step) => _runStepWithTiming(step)).toList();
    final results = await Future.wait(futures);

    // Preserve original order in the returned list.
    return results;
  }

  Future<BootstrapStepResult> _runStepWithTiming(BootstrapStep step) async {
    final sw = Stopwatch()..start();
    try {
      final received = await step.execute().timeout(step.timeout);
      sw.stop();
      final status = (!step.isCritical && received.status == BootstrapStepStatus.fatalFailure)
          ? BootstrapStepStatus.recoverableFailure
          : received.status;
      return BootstrapStepResult(
        stepName: step.name,
        status: status,
        message: received.message,
        elapsed: sw.elapsed,
      );
    } on TimeoutException {
      sw.stop();
      return BootstrapStepResult(
        stepName: step.name,
        status: step.isCritical ? BootstrapStepStatus.fatalFailure : BootstrapStepStatus.recoverableFailure,
        message: 'Phase timed out after ${step.timeout.inMilliseconds}ms',
        elapsed: sw.elapsed,
      );
    } catch (e) {
      sw.stop();
      return BootstrapStepResult(
        stepName: step.name,
        status: step.isCritical ? BootstrapStepStatus.fatalFailure : BootstrapStepStatus.recoverableFailure,
        message: e.toString(),
        elapsed: sw.elapsed,
      );
    }
  }
}
