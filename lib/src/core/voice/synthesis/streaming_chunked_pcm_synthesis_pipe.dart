import 'dart:typed_data';

/// Hardened Streaming Chunked PCM Pipe (P1-08 Root Fix)
/// Strictly enforces a maximum byte budget, bounded backpressure, and FIFO dequeue.
class StreamingChunkedPCMSynthesisPipe {
  static const int defaultMaxQueuedBytes = 1048576; // 1 MB hard buffer ceiling
  
  final int maxQueuedBytes;
  final List<Uint8List> _chunks = [];
  int _currentQueuedBytes = 0;
  bool _isDisposed = false;

  StreamingChunkedPCMSynthesisPipe({this.maxQueuedBytes = defaultMaxQueuedBytes}) {
    if (maxQueuedBytes <= 0) {
      throw ArgumentError.value(maxQueuedBytes, 'maxQueuedBytes', 'Buffer capacity must be strictly positive');
    }
  }

  int get queuedChunks => _chunks.length;
  int get queuedBytes => _currentQueuedBytes;
  bool get isDisposed => _isDisposed;
  bool get isEmpty => _chunks.isEmpty;

  /// Pushes a PCM audio chunk. Fails closed with backpressure error if budget exceeded.
  void pushChunk(Uint8List chunk) {
    if (_isDisposed) throw StateError('Cannot push chunks to a disposed PCM pipe');
    if (chunk.isEmpty) return;

    if (_currentQueuedBytes + chunk.length > maxQueuedBytes) {
      throw StateError(
        'PCM Buffer Overflow: current $_currentQueuedBytes bytes + incoming ${chunk.length} bytes '
        'exceeds maximum allocation budget of $maxQueuedBytes bytes.',
      );
    }

    _chunks.add(Uint8List.fromList(chunk)); // Safe immutable copy
    _currentQueuedBytes += chunk.length;
  }

  /// Dequeues the oldest PCM chunk in FIFO order
  Uint8List? dequeueChunk() {
    if (_isDisposed || _chunks.isEmpty) return null;
    final chunk = _chunks.removeAt(0);
    _currentQueuedBytes -= chunk.length;
    return chunk;
  }

  /// Clears queued audio buffers
  void clear() {
    _chunks.clear();
    _currentQueuedBytes = 0;
  }

  /// Disposes audio pipeline resources
  void dispose() {
    clear();
    _isDisposed = true;
  }
}
