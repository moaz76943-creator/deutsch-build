/// Task 1133: Early conversational intent predictor (Question/Affirmation/Hesitation)
enum DialogueAct { question, affirmation, hesitation, completion }
class DialogueActClassifier {
  DialogueAct classifyEnding(String text) => text.endsWith('?') ? DialogueAct.question : DialogueAct.completion;
}
