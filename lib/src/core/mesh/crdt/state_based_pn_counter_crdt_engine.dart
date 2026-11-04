/// Task 1521: Positive-Negative Counter (PN-Counter) CRDT
class PnCounterCrdt {
  final Map<String, int> _p = {};
  final Map<String, int> _n = {};
  void increment(String nodeId) => _p[nodeId] = (_p[nodeId] ?? 0) + 1;
  void decrement(String nodeId) => _n[nodeId] = (_n[nodeId] ?? 0) + 1;
  int get value => _p.values.fold(0, (a, b) => a + b) - _n.values.fold(0, (a, b) => a + b);
}
