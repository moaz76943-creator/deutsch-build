/// Task 1758: Rule-based Automatic Post-Editing (APE) cleanup engine
class AutomaticPostEditingRuleApplicator {
  String applyPostEdits(String translation) => translation.trim().replaceAll('  ', ' ');
}
