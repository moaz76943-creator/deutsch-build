/// Task 1603: Sensory mnemonics salience calculator (scale, color, motion)
class SensorySalienceCalculator {
  double computeSalience(double bizarreScale, bool hasVibrantColor) => bizarreScale * (hasVibrantColor ? 1.5 : 1.0);
}
