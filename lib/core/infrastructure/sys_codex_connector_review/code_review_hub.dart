import 'architecture_validator.dart';
import 'performance_profiler.dart';

final class CodeReviewReport {
  const CodeReviewReport({
    required this.architecture,
    required this.performance,
  });

  final ArchitectureValidationResult architecture;
  final List<PerformanceProfile> performance;

  bool get isApproved =>
      architecture.isValid &&
      performance.every((profile) => !profile.budgetExceeded);
}

final class CodeReviewHub {
  const CodeReviewHub({
    this.architectureValidator = const ArchitectureValidator(),
    this.performanceProfiler = const PerformanceProfiler(),
  });

  final ArchitectureValidator architectureValidator;
  final PerformanceProfiler performanceProfiler;

  CodeReviewReport review({
    required List<ArchitectureModule> modules,
    required ArchitecturePolicy policy,
    required List<PerformanceSample> samples,
    Map<String, int> budgetsMicros = const <String, int>{},
  }) {
    return CodeReviewReport(
      architecture: architectureValidator.validate(modules, policy),
      performance: performanceProfiler.profile(
        samples,
        budgetsMicros: budgetsMicros,
      ),
    );
  }
}
