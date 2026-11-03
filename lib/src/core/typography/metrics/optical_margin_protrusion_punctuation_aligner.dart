/// Task 1272: Hangs punctuation outside paragraph text margins
class OpticalMarginAligner {
  double getHangingOffset(String char, double fontSize) => ['"', '«', '“', '-'].contains(char) ? fontSize * -0.3 : 0.0;
}
