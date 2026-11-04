/// Task 1241: Franklin M. Liang's TeX hyphenation pattern trie matcher
class LiangHyphenationMatcher {
  final Map<String, int> _trie = {};
  void insertPattern(String pattern, int val) => _trie[pattern] = val;
  bool hasHyphenPoint(String sub) => _trie.containsKey(sub);
}
