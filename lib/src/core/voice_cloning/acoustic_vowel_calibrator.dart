class AcousticVowelCalibrator {
  bool isInQuadrilateral({required double f1, required double f2}) {
    return f1 >= 200 && f1 <= 900 && f2 >= 600 && f2 <= 2600;
  }
}
