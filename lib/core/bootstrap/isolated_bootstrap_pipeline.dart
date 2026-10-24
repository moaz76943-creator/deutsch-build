import 'dart:async';

enum BootstrapStepStatus { success, recoverableFailure, fatalFailure }

class BootstrapStepResult {
  final String stepName;
  final BootstrapStepStatus status;
  final String? message;

  const BootstrapStepResult({
    required this.stepName,
    required this.status,
    this.message,
  });
}

abstract class BootstrapStep {
  String get name;
  Duration get timeout => const Duration(seconds: 6);
  bool get isCritical => true;
  Future<BootstrapStepResult> execute();
}

/// Isolated bootstrap pipeline that prevents error swallowing and documents each startup phase status.
/// Timeouts protect against hangs; critical steps fail the pipeline, optional ones continue.
class IsolatedBootstrapPipeline {
  final List<BootstrapStep> steps;

  IsolatedBootstrapPipeline(this.steps);

  Future<List<BootstrapStepResult>> runPipeline() async {
    final List<BootstrapStepResult> results = [];

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
    }
    return results;
  }
}
