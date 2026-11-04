/// Task 1281: Heavy baseline and asymmetrical letterform compensator
class DyslexiaWeightAdapter {
  double getBaselineWeight(bool isDyslexicMode) => isDyslexicMode ? 1.35 : 1.0;
}
