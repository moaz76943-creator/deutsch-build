class LockFreeSpscQueue<T> {
  final List<T?> _buffer;
  int _head = 0;
  int _tail = 0;

  LockFreeSpscQueue(int capacity) : _buffer = List<T?>.filled(capacity + 1, null);

  bool enqueue(T item) {
    final nextTail = (_tail + 1) % _buffer.length;
    if (nextTail == _head) return false;
    _buffer[_tail] = item;
    _tail = nextTail;
    return true;
  }

  T? dequeue() {
    if (_head == _tail) return null;
    final item = _buffer[_head];
    _buffer[_head] = null;
    _head = (_head + 1) % _buffer.length;
    return item;
  }
}
