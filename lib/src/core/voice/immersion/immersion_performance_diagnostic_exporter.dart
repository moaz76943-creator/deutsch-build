/// Task 1198: Compiles local offline scorecards
class ImmersionDiagnosticExporter {
  Map<String, dynamic> generateReport(int fluencySec, double accuracy) => {'fluency_seconds': fluencySec, 'accuracy': accuracy, 'passed': accuracy >= 80.0};
}
