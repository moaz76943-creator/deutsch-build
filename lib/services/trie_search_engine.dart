class TrieNode {
  final Map<String, TrieNode> children = {};
  final Set<String> wordIds = {};
}

class TrieSearchEngine {
  TrieNode _root = TrieNode();
  int _nodeCount = 0;
  final int maxNodes;
  final int maxResults;

  TrieSearchEngine({this.maxNodes = 100000, this.maxResults = 100});

  /// تطبيع نصي عالمي يدعم اللاتينية، السلافية، والتشكيل العربي
  static String normalizeUniversal(String text) {
    if (text.isEmpty) return text;
    String res = text.toLowerCase().trim();

    // إزالة التشكيل العربي والنيقود العبري
    res = res.replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0591-\u05C7]'), '');

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

  void clear() {
    _root = TrieNode();
    _nodeCount = 0;
  }

  void insert(String word, String id) {
    if (word.isEmpty) return;

    // Instead of iterating by byte/code unit, use runes to safely handle multi-byte characters
    final normalized = normalizeUniversal(word);
    if (normalized.isEmpty) return;

    TrieNode current = _root;
    final runes = normalized.runes.toList();

    for (int i = 0; i < runes.length; i++) {
      final char = String.fromCharCode(runes[i]);
      if (_nodeCount >= maxNodes) {
        if (!current.children.containsKey(char)) {
            break;
        }
        current = current.children[char]!;
      } else {
        current = current.children.putIfAbsent(char, () {
          _nodeCount++;
          return TrieNode();
        });
      }

      // Add id to intermediate nodes for fast prefix retrieval
      if (current.wordIds.length < maxResults) {
          current.wordIds.add(id);
      }
    }
  }

  List<String> searchPrefix(String prefix) {
    if (prefix.isEmpty) return [];

    final normalized = normalizeUniversal(prefix);
    if (normalized.isEmpty) return [];

    TrieNode current = _root;
    final runes = normalized.runes.toList();

    for (int i = 0; i < runes.length; i++) {
      final char = String.fromCharCode(runes[i]);
      if (!current.children.containsKey(char)) return [];
      current = current.children[char]!;
    }

    return current.wordIds.toList(); // Return bounded results directly, deduplicated via Set
  }
}
