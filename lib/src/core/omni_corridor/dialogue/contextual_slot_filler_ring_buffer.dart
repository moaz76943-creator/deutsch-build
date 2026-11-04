/// Task 1924: Ring-buffer slot filler for rapid, zero-alloc turn-taking in live dialogues
class ContextualSlotFillerBuffer {
  final List<String> _slots = List.filled(32, '');
  int _idx = 0;
  void pushSlot(String val) { _slots[_idx % 32] = val; _idx++; }
}
