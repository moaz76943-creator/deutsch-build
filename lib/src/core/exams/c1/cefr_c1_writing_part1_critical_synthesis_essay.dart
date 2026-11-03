class CefrC1WritingPart1CriticalSynthesisEssay {
  int evaluateEssay(String text) {
    final words = text.trim().split(RegExp(r'\s+')).length;
    return words >= 220 ? 25 : (words >= 180 ? 18 : 10);
  }
}
