class ZeroAllocStringTokenizer {
  static int countTokens(String text) {
    int count = 0, inWord = 0;
    for (int i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) <= 32) { inWord = 0; }
      else if (inWord == 0) { inWord = 1; count++; }
    }
    return count;
  }
}
