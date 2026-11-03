/// Task 1077: Fixed-point integer DSP arithmetic fallback
class FixedPointDspArithmetic {
  static int multiplyFixed(int a, int b) => (a * b) >> 15;
  static int addFixed(int a, int b) => a + b;
}
