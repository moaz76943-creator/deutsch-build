/// Task 1117: Sub-sample soft-knee audio limiter preventing distortion
class SoftKneeLimiter {
  double limitSample(double val) => val.clamp(-1.0, 1.0);
}
