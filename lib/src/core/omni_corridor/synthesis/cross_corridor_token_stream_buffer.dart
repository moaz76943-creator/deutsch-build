/// Task 1981: Zero-alloc token streaming buffer for real-time corridor synthesis
class CrossCorridorTokenStreamBuffer {
  final List<String> _stream = [];
  void pushToken(String t) => _stream.add(t);
  String flush() { final out = _stream.join(' '); _stream.clear(); return out; }
}
