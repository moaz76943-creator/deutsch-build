/// Task 1478: Pacing assistant encouraging rapid silent reading
class SilentReadingPacer {
  int getChunkPacingMs(int wordsInChunk, double targetWpm) => targetWpm > 0 ? ((wordsInChunk / targetWpm) * 60000).round() : 1000;
}
