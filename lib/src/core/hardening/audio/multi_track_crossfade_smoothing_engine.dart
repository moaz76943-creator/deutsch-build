/// Task 1055: Zero-click crossfading between phoneme snippets
class CrossfadeSmoothingEngine {
  int crossfadeDurationMs = 15;
  double calculateAlpha(int elapsedMs) => (elapsedMs / crossfadeDurationMs).clamp(0.0, 1.0);
}
