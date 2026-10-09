class TrieNode {
  final Map<String, TrieNode> children = {};
  final List<String> wordIds = [];
}

class TrieSearchEngine {
  final TrieNode _root = TrieNode();

  static String normalizeGerman(String text) {
    return text
        .toLowerCase()
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('ß', 'ss')
        .trim();
  }

  void insert(String word, String id) {
    final normalized = normalizeGerman(word);
    TrieNode current = _root;
    for (int i = 0; i < normalized.length; i++) {
      final char = normalized[i];
      current = current.children.putIfAbsent(char, () => TrieNode());
      current.wordIds.add(id);
    }
  }

  List<String> searchPrefix(String prefix) {
    final normalized = normalizeGerman(prefix);
    TrieNode current = _root;
    for (int i = 0; i < normalized.length; i++) {
      final char = normalized[i];
      if (!current.children.containsKey(char)) return [];
      current = current.children[char]!;
    }
    return current.wordIds.toSet().toList();
  }
}
