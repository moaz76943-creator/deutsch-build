import 'dart:typed_data';

final class BoundedContextLru {
  static const int keyCount = 5000;
  static const int blockBytes = 262144; // 256 KiB
  static const int maxSlots = 128;      // 32 MiB سقف آمن ومثالي للهواتف المحمولة

  final int slots;
  final Uint8List _arena;
  final Int32List _slotByKey;
  final Int32List _key;
  final Int32List _length;
  final Int32List _prev;
  final Int32List _next;

  int _allocated = 0;
  int _head = -1;
  int _tail = -1;

  BoundedContextLru({this.slots = 64})
      : _arena = Uint8List(slots * blockBytes),
        _slotByKey = Int32List(keyCount),
        _key = Int32List(slots),
        _length = Int32List(slots),
        _prev = Int32List(slots),
        _next = Int32List(slots) {
    _slotByKey.fillRange(0, keyCount, -1);
    _key.fillRange(0, slots, -1);
    _prev.fillRange(0, slots, -1);
    _next.fillRange(0, slots, -1);
  }

  bool put(int key, Uint8List source) {
    if (key < 0 || key >= keyCount || source.length > blockBytes) return false;
    int slot = _slotByKey[key];
    if (slot == -1) {
      if (_allocated < slots) {
        slot = _allocated++;
      } else {
        slot = _tail;
        _slotByKey[_key[slot]] = -1;
        _unlink(slot);
      }
      _key[slot] = key;
      _slotByKey[key] = slot;
      _linkHead(slot);
    } else {
      _touch(slot);
    }
    final int start = slot * blockBytes;
    _arena.setRange(start, start + source.length, source);
    _length[slot] = source.length;
    return true;
  }

  int copyInto(int key, Uint8List destination) {
    if (key < 0 || key >= keyCount) return -1;
    final int slot = _slotByKey[key];
    if (slot == -1) return -1;
    final int count = _length[slot];
    if (destination.length < count) return -2;
    destination.setRange(0, count, _arena, slot * blockBytes);
    _touch(slot);
    return count;
  }

  void _touch(int slot) {
    if (_head == slot) return;
    _unlink(slot);
    _linkHead(slot);
  }

  void _unlink(int slot) {
    final int before = _prev[slot];
    final int after = _next[slot];
    if (before == -1) { _head = after; } else { _next[before] = after; }
    if (after == -1) { _tail = before; } else { _prev[after] = before; }
    _prev[slot] = -1;
    _next[slot] = -1;
  }

  void _linkHead(int slot) {
    _prev[slot] = -1;
    _next[slot] = _head;
    if (_head == -1) { _tail = slot; } else { _prev[_head] = slot; }
    _head = slot;
  }
}
