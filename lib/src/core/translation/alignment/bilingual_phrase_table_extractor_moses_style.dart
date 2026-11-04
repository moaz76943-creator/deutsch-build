/// Task 1706: Symmetric phrase extraction from bi-directional word alignments
class PhraseTableExtractor {
  List> extractPhrases(List<String> src, List<String> tgt) => [{'source': src.join(' '), 'target': tgt.join(' ')}];
}
