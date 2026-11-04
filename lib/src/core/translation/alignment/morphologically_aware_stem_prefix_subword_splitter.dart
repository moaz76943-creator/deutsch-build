/// Task 1708: Morphological boundary-respecting subword segmenter
class MorphologicalSubwordSplitter {
  List<String> splitWithMorphology(String word) => word.startsWith('un') ? ['un', word.substring(2)] : [word];
}
