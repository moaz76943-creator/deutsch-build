import 'unit_test_automation.dart';
import 'workflow_build_fixer.dart';

final class CiCdWorkflowReport {
  const CiCdWorkflowReport({
    required this.workflow,
    required this.tests,
  });

  final WorkflowRepairResult workflow;
  final UnitTestPlan tests;

  bool get isReady => workflow.issuesAfter.isEmpty && !tests.isEmpty;
}

final class CiCdWorkflowHub {
  const CiCdWorkflowHub({
    this.workflowFixer = const WorkflowBuildFixer(),
    this.testAutomation = const UnitTestAutomation(),
  });

  final WorkflowBuildFixer workflowFixer;
  final UnitTestAutomation testAutomation;

  CiCdWorkflowReport prepare({
    required String workflowYaml,
    required List<UnitTestModule> modules,
  }) {
    return CiCdWorkflowReport(
      workflow: workflowFixer.repair(workflowYaml),
      tests: testAutomation.plan(modules),
    );
  }
}
