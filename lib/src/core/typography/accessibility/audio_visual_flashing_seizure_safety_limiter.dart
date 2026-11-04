/// Task 1291: WCAG 2.3.1 seizure safety 3-flashes-per-second limiter
class SeizureSafetyLimiter {
  bool isStrobeSafe(int flashCount, int windowMs) => (flashCount / (windowMs / 1000.0)) <= 3.0;
}
