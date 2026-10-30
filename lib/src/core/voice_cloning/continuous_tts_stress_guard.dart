import 'dart:collection';

/// Memory and buffer lifecycle manager for continuous TTS shadowing sessions.
class ContinuousTtsStressGuard {
  final int maxPooledBuffers;
  final int maxBufferSizeBytes;
  final Queue<List<int>> _bufferPool = Queue<List<int>>();
  int _allocatedBytes = 0;
  int _recycledCount = 0;

  ContinuousTtsStressGuard({
    this.maxPooledBuffers = 32,
    this.maxBufferSizeBytes = 65536,
  });

  int get activePoolSize => _bufferPool.length;
  int get allocatedBytes => _allocatedBytes;
  int get recycledCount => _recycledCount;

  /// Acquires a clean buffer from the pool or allocates an isolated block.
  List<int> acquireBuffer(int size) {
    if (size > maxBufferSizeBytes) {
      throw ArgumentError('Requested buffer exceeds maximum threshold of $maxBufferSizeBytes bytes');
    }
    if (_bufferPool.isNotEmpty) {
      final buffer = _bufferPool.removeFirst();
      if (buffer.length >= size) {
        _recycledCount++;
        return buffer;
      }
    }
    _allocatedBytes += size;
    return List<int>.filled(size, 0);
  }

  /// Recycles a spent audio buffer back into the reuse pool to prevent GC pauses.
  void releaseBuffer(List<int> buffer) {
    if (_bufferPool.length < maxPooledBuffers && buffer.length <= maxBufferSizeBytes) {
      _bufferPool.add(buffer);
    } else {
      _allocatedBytes -= buffer.length;
      if (_allocatedBytes < 0) _allocatedBytes = 0;
    }
  }

  /// Simulates continuous speech stress and returns memory stability metrics.
  Map<String, dynamic> runStressCycle({required int iterations, required int bufferSize}) {
    final startAllocated = _allocatedBytes;
    for (int i = 0; i < iterations; i++) {
      final buf = acquireBuffer(bufferSize);
      buf[0] = i % 256;
      releaseBuffer(buf);
    }

    return {
      'iterations': iterations,
      'netLeakBytes': (_allocatedBytes - startAllocated).clamp(0, 999999),
      'poolUtilization': _bufferPool.length / maxPooledBuffers,
      'isLeakFree': _allocatedBytes <= (maxPooledBuffers * bufferSize),
      'totalRecycled': _recycledCount,
    };
  }

  /// Clears all retained buffers.
  void purge() {
    _bufferPool.clear();
    _allocatedBytes = 0;
    _recycledCount = 0;
  }
}
