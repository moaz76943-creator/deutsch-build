import 'dart:typed_data';

/// Hardened Bounded Context LRU (MEM-001 Root Fix)
/// Strictly enforces slot bounds (1 <= slots <= maxSlots) and memory budgets.
class BoundedContextLRU {
  static const int maxSlots = 128;
  static const int blockBytes = 262144; // 256 KB per slot
  
  final int allocatedSlots;
  late final Uint8List _storage;
  final Map<String, int> _slotIndex = {};
  final List<String> _lruOrder = [];

  BoundedContextLRU(this.allocatedSlots) {
    if (allocatedSlots < 1 || allocatedSlots > maxSlots) {
      throw RangeError.range(allocatedSlots, 1, maxSlots, 'allocatedSlots',
          'Slots must be strictly between 1 and $maxSlots to avoid memory exhaustion');
    }
    _storage = Uint8List(allocatedSlots * blockBytes);
  }

  int get capacityBytes => allocatedSlots * blockBytes;
  int get activeSlots => _lruOrder.length;

  bool contains(String key) => _slotIndex.containsKey(key);

  void touch(String key) {
    if (_lruOrder.remove(key)) {
      _lruOrder.add(key);
    }
  }

  void put(String key, Uint8List data) {
    if (data.length > blockBytes) {
      throw ArgumentError.value(data.length, 'data.length', 'Data exceeds maximum block size ($blockBytes bytes)');
    }
    if (_lruOrder.length >= allocatedSlots && !_slotIndex.containsKey(key)) {
      final evictKey = _lruOrder.removeAt(0);
      _slotIndex.remove(evictKey);
    }
    _lruOrder.remove(key);
    _lruOrder.add(key);
    _slotIndex[key] = _lruOrder.length - 1;
  }
}
