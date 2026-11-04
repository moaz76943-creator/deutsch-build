/// Task 1487: Workplace email scenario evaluator (salutation, request, close)
class WorkplaceEmailRubricEvaluator {
  bool hasFormalEnvelope(String email) => (email.contains('Sehr geehrte') || email.contains('Guten Tag')) && (email.contains('Mit freundlichen Grüßen') || email.contains('مع التحية'));
}
