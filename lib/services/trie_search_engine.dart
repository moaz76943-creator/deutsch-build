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
  String? _languagePair;

  TrieSearchEngine({
    this.maxNodes = 100000,
    this.maxResults = 100,
  });

  void clear({String? contentVersion, String? languagePair}) {
    _root = TrieNode();
    _nodeCount = 1;
    _contentVersion = contentVersion;
    _languagePair = languagePair;
  }

  bool isStale(String contentVersion, String languagePair) {
    if (_contentVersion == null || _languagePair == null) return true;
    return _contentVersion != contentVersion || _languagePair != languagePair;
  }

  /// تطبيع نصي عالمي يدعم اللاتينية، السلافية، والتشكيل العربي
  static String normalizeUniversal(String text) {
    if (text.isEmpty) return text;
    String res = text.toLowerCase().trim();

    // إزالة التشكيل العربي
    res = res.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');

    // Arabic specific normalizations
    // Remove Tatweel
    res = res.replaceAll('\u0640', '');
    // Normalize Alefs (أ إ آ -> ا)
    res = res.replaceAll(RegExp(r'[\u0622\u0623\u0625]'), '\u0627');
    // Normalize Teh Marbuta to Heh (ة -> ه)
    res = res.replaceAll('\u0629', '\u0647');
    // Normalize Alef Maksura to Yeh (ى -> ي)
    res = res.replaceAll('\u0649', '\u064A');

    // Remove Hebrew Niqqud
    res = res.replaceAll(RegExp(r'[\u0591-\u05C7]'), '');

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
    if (normalized.isEmpty) return;

    TrieNode current = _root;
    for (final rune in normalized.runes) {
      final char = String.fromCharCode(rune);
      if (!current.children.containsKey(char)) {
        if (_nodeCount >= maxNodes) {
          // Stop adding new nodes if memory bound is reached
          break;
        }
        current.children[char] = TrieNode();
        _nodeCount++;
      }
      current = current.children[char]!;
      if (current.wordIds.length < maxResults) {
        current.wordIds.add(id);
      }
    }
  }

  List<String> searchPrefix(String prefix) {
    final normalized = normalizeUniversal(prefix);
    if (normalized.isEmpty) return [];

    TrieNode current = _root;
    for (final rune in normalized.runes) {
      final char = String.fromCharCode(rune);
      if (!current.children.containsKey(char)) return [];
      current = current.children[char]!;
    }
    return current.wordIds.toList();
  }
}
