/// Task 1142: Formant F1 vs F2 vowel space quadrilateral accuracy grader
class FormantVowelAnalyzer {
  double gradeVowelFormants(double f1, double f2, double targetF1, double targetF2) {
    double dist = ((f1 - targetF1).abs() + (f2 - targetF2).abs()) / 2.0;
    return (100.0 - dist * 0.1).clamp(0.0, 100.0);
  }
}
