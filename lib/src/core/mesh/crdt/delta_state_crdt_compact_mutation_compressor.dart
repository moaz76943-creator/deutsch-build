/// Task 1526: Delta-state CRDT mutation compressor
class DeltaCrdtCompressor {
  final List<String> _pendingDeltas = [];
  void recordDelta(String delta) => _pendingDeltas.add(delta);
  List<String> flushDeltas() {
    var out = List<String>.from(_pendingDeltas);
    _pendingDeltas.clear();
    return out;
  }
}
