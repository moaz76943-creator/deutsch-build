/// Task 1188: Zero-latency snapshot of situational simulation state
class ImmersionSessionSnapshot {
  final Map<String, dynamic> state = {};
  void saveCheckpoint(String key, dynamic val) => state[key] = val;
  dynamic restoreCheckpoint(String key) => state[key];
}
