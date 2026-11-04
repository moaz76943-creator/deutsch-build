/// Task 1286: Enforces prefers-reduced-motion to eliminate sickness triggers
class ReducedMotionGate {
  bool shouldAnimate(bool prefersReducedMotion) => !prefersReducedMotion;
}
