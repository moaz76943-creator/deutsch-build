/// Task 1097: Enforcing idempotent state transitions
class LifecycleStateSanitizer {
  String currentState = 'RESUMED';
  void transitionTo(String next) => currentState = next;
  bool get isForeground => currentState == 'RESUMED';
}
