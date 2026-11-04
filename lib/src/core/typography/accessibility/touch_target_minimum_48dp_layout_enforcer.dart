/// Task 1288: Enforces 48x48dp minimum interactive touch target sizes
class TouchTargetEnforcer {
  static const double minTouchTargetDp = 48.0;
  double enforceSize(double original) => original < minTouchTargetDp ? minTouchTargetDp : original;
}
