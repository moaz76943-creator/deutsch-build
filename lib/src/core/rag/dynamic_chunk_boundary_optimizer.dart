import 'dart:math' as math;

class DynamicChunkBoundaryOptimizer {
  final int targetChunkLength;
  const DynamicChunkBoundaryOptimizer({this.targetChunkLength = 250});

  List<String> optimizeChunks(String text) {
    if (text.length <= targetChunkLength) return text.trim().isEmpty ? [] : [text.trim()];
    final chunks = <String>[];
    int start = 0;
    while (start < text.length) {
      int end = math.min(start + targetChunkLength, text.length);
      if (end < text.length) {
        int punct = text.lastIndexOf(RegExp(r'[.؟!\n]'), end);
        if (punct > start + (targetChunkLength ~/ 2)) end = punct + 1;
      }
      final chunk = text.substring(start, end).trim();
      if (chunk.isNotEmpty) chunks.add(chunk);
      start = end;
    }
    return chunks;
  }
}
