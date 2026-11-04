/// Task 1797: Local sovereign feedback accumulator for user post-edits
class LocalFeedbackAccumulator {
  final List<String> _feedback = [];
  void recordFeedback(String edit) => _feedback.add(edit);
}
