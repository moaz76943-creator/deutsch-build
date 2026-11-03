class CefrA2WritingPart2SemiFormalInquiryScorer {
  int evaluateEmail(String text) => text.trim().split(' ').length >= 40 ? 10 : 5;
}
