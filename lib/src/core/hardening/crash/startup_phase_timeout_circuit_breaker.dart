/// Task 1087: Per-step startup timeout circuit breaker preventing hangs
class StartupCircuitBreaker {
  int timeoutLimitMs = 3000;
  bool isPhaseTimedOut(int durationMs) => durationMs > timeoutLimitMs;
}
