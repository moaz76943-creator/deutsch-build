import 'dart:math';

/// Distributed Token Bucket Rate Limiter for offline peer synchronization.
/// Prevents local socket congestion, battery throttling, and packet drops on Android/Termux.
class TokenBucketRateLimiter {
  final int capacityTokens;
  final double refillRatePerSecond;
  double _availableTokens;
  DateTime _lastRefillUtc;

  TokenBucketRateLimiter({
    this.capacityTokens = 64,
    this.refillRatePerSecond = 16.0,
  })  : _availableTokens = capacityTokens.toDouble(),
        _lastRefillUtc = DateTime.now().toUtc();

  double get availableTokens => _availableTokens;
  int get capacity => capacityTokens;

  /// Refill tokens based on elapsed wall time.
  void _refill() {
    final now = DateTime.now().toUtc();
    final elapsedMs = now.difference(_lastRefillUtc).inMilliseconds;
    if (elapsedMs <= 0) return;

    final tokensToAdd = (elapsedMs / 1000.0) * refillRatePerSecond;
    _availableTokens = min(capacityTokens.toDouble(), _availableTokens + tokensToAdd);
    _lastRefillUtc = now;
  }

  /// Attempt to consume requested tokens. Returns true if permitted.
  bool tryAcquire({int tokens = 1}) {
    _refill();
    if (_availableTokens >= tokens) {
      _availableTokens -= tokens;
      return true;
    }
    return false;
  }

  /// Reset the bucket to full capacity.
  void reset() {
    _availableTokens = capacityTokens.toDouble();
    _lastRefillUtc = DateTime.now().toUtc();
  }
}
