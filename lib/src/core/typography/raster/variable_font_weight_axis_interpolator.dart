/// Task 1228: OpenType variable font design space multi-axis interpolator
class VariableFontAxisInterpolator {
  double interpolateWeight(double minWeight, double maxWeight, double normalized) => minWeight + (maxWeight - minWeight) * normalized;
}
