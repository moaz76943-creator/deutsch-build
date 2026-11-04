/// Task 1322: Arabic trilateral root extraction and pattern (Wazn) segmenter
class ArabicRootExtractor {
  String extractRoot(String word) => word.length >= 3 ? word.substring(0, 3) : word;
}
