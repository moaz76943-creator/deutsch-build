/// Task 1483: Evaluates pragmatic indirect speech acts (polite requests)
class SpeechActPragmaticEvaluator {
  bool isPoliteRequest(String utterance) => utterance.contains('könnten Sie') || utterance.contains('würden Sie') || utterance.contains('من فضلك');
}
