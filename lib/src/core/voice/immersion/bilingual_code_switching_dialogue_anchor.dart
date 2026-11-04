/// Task 1193: Anchor preventing unintended linguistic drift
class CodeSwitchingAnchor {
  String targetLanguage = 'de';
  bool isDriftAllowed(String wordLang) => wordLang == targetLanguage || wordLang == 'ar';
}
