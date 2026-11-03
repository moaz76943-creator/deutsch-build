class CefrB2WritingPart1ArgumentativeEssayScorer {
  int evaluateEssay(String text) {
    final words = text.trim().split(RegExp(r'\s+')).length;
    return words >= 150 ? 20 : (words >= 100 ? 15 : 10);
  }
}
