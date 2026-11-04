/// Task 2035: Vector clock causality tracker ordering distributed study milestones
class VectorClockCausalityTracker {
  final Map<String, int> _clock = {};
  void tick(String nodeId) => _clock[nodeId] = (_clock[nodeId] ?? 0) + 1;
}
