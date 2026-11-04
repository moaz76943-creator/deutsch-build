/// Task 1771: High-speed Trie matcher for OCR recognized character sequences
class OcrCharacterTrieMatcher {
  final Map<String, dynamic> _root = {};
  void insert(String word) {
    var cur = _root;
    for (var r in word.runes) {
      final s = String.fromCharCode(r);
      cur = cur.putIfAbsent(s, () => <String, dynamic>{});
    }
    cur['\$'] = true;
  }
}
