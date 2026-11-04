/// Task 2063: Modal verbs objective vs epistemic meaning evaluator (können, müssen, dürfen)
class ModalVerbMeaningEvaluator {
  bool isEpistemic(String modal, String context) => context.contains('sicher') || context.contains('wahrscheinlich');
}
