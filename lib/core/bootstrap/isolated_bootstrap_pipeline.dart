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
  Future<BootstrapStepResult> execute();
}

/// خط إقلاع معزول يمنع ابتلاع الأخطاء ويوثق حالة كل مرحلة في بدء التشغيل
class IsolatedBootstrapPipeline {
  final List<BootstrapStep> steps;

  IsolatedBootstrapPipeline(this.steps);

  Future<List<BootstrapStepResult>> runPipeline() async {
    final List<BootstrapStepResult> results = [];

    for (final step in steps) {
      try {
<<<<<<< HEAD
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
      } catch (_) {
        result = BootstrapStepResult(
          stepName: step.name,
          status: step.isCritical
              ? BootstrapStepStatus.fatalFailure
              : BootstrapStepStatus.recoverableFailure,
          message: 'Phase failed',
=======
        final res = await step.execute();
        results.add(res);
        if (res.status == BootstrapStepStatus.fatalFailure) {
          break;
        }
      } catch (e) {
        results.add(
          BootstrapStepResult(
            stepName: step.name,
            status: BootstrapStepStatus.fatalFailure,
            message: e.toString(),
          ),
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
        );
        break;
      }
    }
    return results;
  }
}
