/// Task 1438: Synthesizes composite CEFR spoken fluency score
class CefrSpokenFluencySynthesizer {
  double calculateComposite(double gop, double ptf, double pvi) => (gop * 0.4 + ptf * 30.0 + pvi * 0.3).clamp(0.0, 100.0);
}
