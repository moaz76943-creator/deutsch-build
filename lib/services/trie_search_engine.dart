class TrieNode {
  final Map<String, TrieNode> children = {};
  final List<String> wordIds = [];
}

class TrieSearchEngine {
  final TrieNode _root = TrieNode();

  /// تطبيع نصي عالمي يدعم اللاتينية، السلافية، والتشكيل العربي
  static String normalizeUniversal(String text) {
    if (text.isEmpty) return text;
    String res = text.toLowerCase().trim();

    // إزالة التشكيل العربي
    res = res.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');

    // تطبيع الحروف ذات النبرات والـ Umlauts عبر اللغات اللاتينية
    final diacritics = {
      'ä': 'ae', 'ö': 'oe', 'ü': 'ue', 'ß': 'ss',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a',
      'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o',
      'ú': 'u', 'ù': 'u', 'û': 'u',
      'ñ': 'n', 'ç': 'c', 'ı': 'i', 'ğ': 'g', 'ş': 's',
    };

    diacritics.forEach((k, v) {
      res = res.replaceAll(k, v);
    });

    return res;
  }

  // دعم التوافق مع الكود السابق
  static String normalizeGerman(String text) => normalizeUniversal(text);

  void insert(String word, String id) {
    final normalized = normalizeUniversal(word);
    TrieNode current = _root;
    for (int i = 0; i < normalized.length; i++) {
      final char = normalized[i];
      current = current.children.putIfAbsent(char, () => TrieNode());
      current.wordIds.add(id);
    }
  }

  List<String> searchPrefix(String prefix) {
    final normalized = normalizeUniversal(prefix);
    TrieNode current = _root;
    for (int i = 0; i < normalized.length; i++) {
      final char = normalized[i];
      if (!current.children.containsKey(char)) return [];
      current = current.children[char]!;
    }
    return current.wordIds.toSet().toList();
  }
}
