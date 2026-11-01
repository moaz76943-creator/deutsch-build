class SemanticChunk {
  final String id;
  final String text;
  final String languageCode;
  final int tokenCount;
  const SemanticChunk({required this.id, required this.text, required this.languageCode, required this.tokenCount});
}

class SemanticWindowSlicerV2 {
  const SemanticWindowSlicerV2();
  static final RegExp _delim = RegExp(r'([.?!؟!\n]+)');

  List<String> extractSentences(String text) {
    return text.split(_delim).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  List<SemanticChunk> sliceText({required String docId, required String text, required String lang}) {
    final sents = extractSentences(text);
    return List.generate(sents.length, (i) => SemanticChunk(id: '${docId}_$i', text: sents[i], languageCode: lang, tokenCount: sents[i].split(' ').length));
  }
}
