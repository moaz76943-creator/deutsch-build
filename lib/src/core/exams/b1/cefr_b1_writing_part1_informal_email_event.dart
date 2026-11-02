class CefrB1WritingPart1InformalEmailEvent {
  int evaluateEmail(String text) {
    final words = text.trim().split(RegExp(r'\s+')).length;
    return words >= 80 ? 20 : (words >= 60 ? 15 : 10);
  }
}
