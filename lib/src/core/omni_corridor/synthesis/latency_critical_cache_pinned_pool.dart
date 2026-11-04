/// Task 1986: Cache-pinned memory pool keeping top 1,000 frequent terms resident in RAM
class CachePinnedMemoryPool {
  final Map<String, dynamic> _pinned = {};
  void pin(String k, dynamic v) => _pinned[k] = v;
  dynamic get(String k) => _pinned[k];
}
