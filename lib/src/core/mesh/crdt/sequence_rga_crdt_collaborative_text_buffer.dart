/// Task 1528: Replicated Growable Array (RGA) CRDT for collaborative text
class RgaTextBuffer {
  final List<String> _buffer = [];
  void insertAt(int idx, String char) => _buffer.insert(idx.clamp(0, _buffer.length), char);
  String get text => _buffer.join('');
}
