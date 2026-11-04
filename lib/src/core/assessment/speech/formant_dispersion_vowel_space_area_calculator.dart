/// Task 1434: Calculates Vowel Space Area (VSA) measuring articulatory clarity
class VowelSpaceAreaCalculator {
  double calculateVsa(double f1i, double f2i, double f1a, double f2a, double f1u, double f2u) => ((f1i * (f2a - f2u) + f1a * (f2u - f2i) + f1u * (f2i - f2a)) / 2.0).abs();
}
