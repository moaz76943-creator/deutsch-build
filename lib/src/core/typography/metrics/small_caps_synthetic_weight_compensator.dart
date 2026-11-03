/// Task 1273: Synthetic small-caps weight compensator
class SmallCapsWeightCompensator {
  double getStrokeWeightMultiplier(bool isSynthetic) => isSynthetic ? 1.12 : 1.0;
}
