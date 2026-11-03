class CefrB2WritingPart2FormalWorkplaceReport {
  int evaluateReport(String text) {
    final words = text.trim().split(RegExp(r'\s+')).length;
    return words >= 100 ? 15 : (words >= 70 ? 10 : 5);
  }
}
