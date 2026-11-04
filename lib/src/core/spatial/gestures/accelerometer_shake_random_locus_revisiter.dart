/// Task 1648: Shake-to-revisit gesture jumping to random due locus
class ShakeLocusRevisiter {
  bool isShakeDetected(double ax, double ay, double az) => (ax * ax + ay * ay + az * az) > 250.0;
}
