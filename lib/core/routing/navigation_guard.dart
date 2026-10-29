import 'dart:async';

/// NavigationGuard - Master Constitution Section 10 & #486 Compliant.
/// Prevents duplicate route pushes on rapid multi-taps, guards against
/// black screen pops on root routes, and ensures action buttons never deadlock.
class DebouncedNavigationGuard {
  final Duration debounceCooldown;
  int _lastNavigationTime = 0;
  bool _isNavigating = false;

  DebouncedNavigationGuard({
    this.debounceCooldown = const Duration(milliseconds: 400),
  });

  bool get isLocked => _isNavigating;

  /// Executes navigation callback if cooldown window has elapsed
  Future<bool> safeNavigate(Future<void> Function() navigateAction) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_isNavigating || (now - _lastNavigationTime) < debounceCooldown.inMilliseconds) {
      // Drop duplicate tap in same tick or cooldown window
      return false;
    }

    _isNavigating = true;
    _lastNavigationTime = now;

    try {
      await navigateAction();
      return true;
    } finally {
      // Allow subsequent navigation after small microtask buffer
      await Future.delayed(const Duration(milliseconds: 50));
      _isNavigating = false;
    }
  }

  /// Safe pop guard preventing crashes when popping root navigator
  bool safePop({required bool canPop, required void Function() popAction}) {
    if (!canPop) {
      return false;
    }
    popAction();
    return true;
  }
}
