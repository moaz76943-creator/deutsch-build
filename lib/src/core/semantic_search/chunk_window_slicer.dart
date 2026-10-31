/// A coherent semantic chunk with overlapping boundary preservation.
class SemanticChunk {
  final int index;
  final String text;
  final int tokenCount;
  final String cefrEstimate;
  final Map<String, dynamic> metadata;

  const SemanticChunk({
    required this.index,
    required this.text,
    required this.tokenCount,
    required this.cefrEstimate,
    this.metadata = const {},
  });
}

/// Slices dialogue transcripts and reading passages into coherent semantic chunks.
class SemanticChunkWindowSlicer {
  final int targetChunkWords;
  final int overlapWords;

  const SemanticChunkWindowSlicer({
    this.targetChunkWords = 35,
    this.overlapWords = 8,
  });

  /// Slices long text into sentence-aware overlapping windows.
  List<SemanticChunk> sliceText({
    required String fullText,
    String defaultCefr = 'A2',
    Map<String, dynamic> baseMetadata = const {},
  }) {
    if (fullText.trim().isEmpty) return [];

    // Split by sentence boundaries (. ! ?)
    final sentenceRegex = RegExp(r'(?<=[.!?])\s+');
    final sentences = fullText.split(sentenceRegex).where((s) => s.trim().isNotEmpty).toList();

    final chunks = <SemanticChunk>[];
    List<String> currentSentences = [];
    int currentWordCount = 0;
    int chunkIndex = 0;

    for (final sentence in sentences) {
      final wordsInSentence = sentence.split(RegExp(r'\s+')).length;
      currentSentences.add(sentence);
      currentWordCount += wordsInSentence;

      if (currentWordCount >= targetChunkWords) {
        final chunkText = currentSentences.join(' ');
        chunks.add(SemanticChunk(
          index: chunkIndex++,
          text: chunkText,
          tokenCount: currentWordCount,
          cefrEstimate: defaultCefr,
          metadata: Map.from(baseMetadata),
        ));

        // Preserve trailing sentences for overlap context
        if (currentSentences.length > 1) {
          currentSentences = [currentSentences.last];
          currentWordCount = currentSentences.last.split(RegExp(r'\s+')).length;
        } else {
          currentSentences = [];
          currentWordCount = 0;
        }
      }
    }

    if (currentSentences.isNotEmpty) {
      chunks.add(SemanticChunk(
        index: chunkIndex++,
        text: currentSentences.join(' '),
        tokenCount: currentWordCount,
        cefrEstimate: defaultCefr,
        metadata: Map.from(baseMetadata),
      ));
    }

    return chunks;
  }
}
