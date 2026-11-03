/// Task 1108: Chunked PCM audio stream generator achieving zero-lag
class StreamingPcmPipe {
  final List<List<int>> _chunks = [];
  void pushChunk(List<int> chunk) => _chunks.add(chunk);
  int get queuedChunks => _chunks.length;
}
