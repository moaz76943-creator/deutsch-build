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

/// One phase of startup. Critical phases abort the pipeline. Optional phases
/// degrade to [BootstrapStepStatus.recoverableFailure] and the next phase runs.
abstract class BootstrapStep {
  String get name;

  /// When true, a failure or timeout stops every later phase.
  bool get isCritical => true;

  /// Replaces [IsolatedBootstrapPipeline.defaultStepTimeout] for this phase.
  Duration? get timeout => null;

  Future<BootstrapStepResult> execute();
}

/// Runs startup phases with a hard time budget.
///
/// A hung optional service (TTS, audio, session metadata) cannot freeze the
/// splash, and thrown exception text is never copied into the result. Callers
/// render only the stable [BootstrapStepResult.message] they choose to show.
class IsolatedBootstrapPipeline {
  /// Budget used when a step does not override [BootstrapStep.timeout].
  /// Long enough for a local preferences read, short enough that a stuck
  /// phase cannot hold the splash open.
  static const Duration startupStepBudget = Duration(seconds: 8);

  final List<BootstrapStep> steps;
  final Duration defaultStepTimeout;

  IsolatedBootstrapPipeline(
    this.steps, {
    this.defaultStepTimeout = startupStepBudget,
  });

  Future<List<BootstrapStepResult>> runPipeline() async {
    final results = <BootstrapStepResult>[];

    for (final step in steps) {
      final result = await _runBounded(step);
      results.add(result);
      if (result.status == BootstrapStepStatus.fatalFailure) {
        break;
      }
    }
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
