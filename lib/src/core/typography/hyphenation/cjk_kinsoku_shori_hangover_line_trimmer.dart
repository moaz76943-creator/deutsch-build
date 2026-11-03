/// Task 1258: Kinsoku Shori overflow trimmer for hanging punctuation
class CjkHangingPunctuationTrimmer {
  bool isHangingPunctuation(int code) => code == 0x3001 || code == 0x3002;
}
