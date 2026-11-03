/// Task 1231: Accumulator for fractional horizontal kerning deltas
class FractionalKerningAccumulator {
  double currentAdvance = 0.0;
  void addKerning(double kerningDelta) => currentAdvance += kerningDelta;
  double get totalAdvance => currentAdvance;
}
