/// Task 1162: Multi-tiered scaffolding prompt ladder
class ScaffoldingPromptLadder {
  String getScaffoldHint(int tier, String targetWord) => tier == 1 ? 'Hint: starts with ${targetWord[0]}' : 'Cloze: ... $targetWord ...';
}
