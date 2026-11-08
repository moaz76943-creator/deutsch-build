/// Mathematical Vector Clock with True Partial-Order Dominance (ARCH-003 Root Fix)
class VectorClock {
  final Map<String, int> clock = {};

  VectorClock([Map<String, int>? initial]) {
    if (initial != null) clock.addAll(initial);
  }

  void tick(String nodeId) => clock[nodeId] = (clock[nodeId] ?? 0) + 1;

  /// Returns true only if local clock component-wise dominates remote clock
  /// Checks all entries in both clocks so missing remote entries are treated as zero.
  bool dominates(Map<String, int> other) {
    for (final entry in other.entries) {
      if ((clock[entry.key] ?? 0) < entry.value) {
        return false;
      }
    }
    return true;
  }

  void merge(VectorClock remote) {
    remote.clock.forEach((node, time) {
      clock[node] = (clock[node] ?? 0) > time ? (clock[node] ?? 0) : time;
    });
  }

  Map<String, int> snapshot() => Map<String, int>.unmodifiable(clock);
}
