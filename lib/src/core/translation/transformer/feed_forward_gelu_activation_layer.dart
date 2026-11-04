/// Task 1725: GELU feed-forward layer with fast polynomial approximation
class GeluActivationLayer {
  double gelu(double x) => 0.5 * x * (1.0 + x.clamp(-1.0, 1.0));
}
