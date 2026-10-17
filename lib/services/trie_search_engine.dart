class TrieNode {
  final Map<String, TrieNode> children = {};
  final Set<String> wordIds = {};
}

class TrieSearchEngine {
  TrieNode _root = TrieNode();

  final int maxNodes;
  final int maxResults;
  int _nodeCount = 1;
  String? _contentVersion;

  TrieSearchEngine({this.maxNodes = 100000, this.maxResults = 50});

  String? get contentVersion => _contentVersion;

  void reset({String? contentVersion}) {
    _root = TrieNode();
    _nodeCount = 1;
    _contentVersion = contentVersion;
  }

  /// تطبيع نصي عالمي يدعم اللاتينية، السلافية، والتشكيل العربي
  static String normalizeUniversal(String text) {
    if (text.isEmpty) return text;
    String res = text.toLowerCase().trim();

    // إزالة التشكيل العربي، التطويل، والنيقود العبري
    res = res.replaceAll(RegExp(r'[\u0640\u064B-\u065F\u0670\u0591-\u05C7]'), '');

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
    for (final rune in normalized.runes) {
      final char = String.fromCharCode(rune);
      if (!current.children.containsKey(char)) {
        if (_nodeCount >= maxNodes) break;
        current.children[char] = TrieNode();
        _nodeCount++;
      }
      current = current.children[char]!;
      current.wordIds.add(id);
    }
  }

  List<String> searchPrefix(String prefix) {
    final normalized = normalizeUniversal(prefix);
    TrieNode current = _root;
    for (final rune in normalized.runes) {
      final char = String.fromCharCode(rune);
      if (!current.children.containsKey(char)) return [];
      current = current.children[char]!;
    }

    final results = current.wordIds.toList();
    if (results.length > maxResults) {
      return results.sublist(0, maxResults);
    }
    return results;
  }
}
