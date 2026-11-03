/// Task 1206: East Asian line breaking rules preventing bad punctuation wraps
class CjkLineBreaker {
  bool canBreakBefore(int codePoint) => codePoint != 0x3002 && codePoint != 0xFF0C;
}
