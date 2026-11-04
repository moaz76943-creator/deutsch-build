/// Task 1091: In-memory rolling ring buffer of last 50 diagnostic events
class EmergencyLogRingBuffer {
  final List<String> _buffer = [];
  void log(String entry) {
    if (_buffer.length >= 50) _buffer.removeAt(0);
    _buffer.add(entry);
  }
  List<String> get snapshot => List.unmodifiable(_buffer);
}
