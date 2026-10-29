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
  bool get isCritical => true;
  Duration? get timeout => null;
  Future<BootstrapStepResult> execute();
}

/// خط إقلاع معزول يمنع ابتلاع الأخطاء ويوثق حالة كل مرحلة في بدء التشغيل
class IsolatedBootstrapPipeline {
  final List<BootstrapStep> steps;
  final Duration defaultStepTimeout;

  IsolatedBootstrapPipeline(
    this.steps, {
    this.defaultStepTimeout = const Duration(seconds: 5),
  });

  Future<List<BootstrapStepResult>> runPipeline() async {
    final List<BootstrapStepResult> results = [];

    for (final step in steps) {
      BootstrapStepResult result;
      try {
        final received = await step.execute().timeout(
              step.timeout ?? defaultStepTimeout,
            );
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
          message: e.toString(),
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
