/// Task 1525: Vector Clock tracker determining causal precedence
class VectorClock {
  final Map<String, int> clock = {};
  void tick(String nodeId) => clock[nodeId] = (clock[nodeId] ?? 0) + 1;
  bool dominates(Map<String, int> other) => clock.entries.every((e) => e.value >= (other[e.key] ?? 0));
}
