/// Task 1328: Derivational morphology analyzer (-chen, -lein, تصغير)
class DiminutiveAnalyzer {
  bool isDiminutive(String word) => word.endsWith('chen') || word.endsWith('lein');
}
