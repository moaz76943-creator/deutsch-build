/// Task 1248: Guards against illegal word-breaking in Arabic scripts
class ArabicWordBreakSentinel {
  bool isHyphenationAllowed(String script) => script != 'Arabic';
}
