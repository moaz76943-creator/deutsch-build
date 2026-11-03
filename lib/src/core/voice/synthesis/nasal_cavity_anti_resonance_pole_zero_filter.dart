/// Task 1114: Pole-zero digital filter simulating nasal cavity anti-resonances
class NasalCavityFilter {
  bool isNasalActive = true;
  double applyNasalZero(double x, double xPrev) => x - 0.85 * xPrev;
}
