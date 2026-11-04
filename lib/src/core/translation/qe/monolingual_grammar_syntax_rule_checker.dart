/// Task 1795: Monolingual target syntax and grammar rule validator
class TargetSyntaxRuleChecker {
  bool validateSyntax(String sentence) => sentence.isNotEmpty && !sentence.contains('  ');
}
