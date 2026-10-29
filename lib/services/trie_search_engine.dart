import 'package:characters/characters.dart';

class TrieNode {
  final Map<String, TrieNode> children = {};
  final Set<String> wordIds = {};
}

class TrieSearchEngine {
  TrieNode _root = TrieNode();
  int _nodeCount = 1;

  final int maxNodes;
  final int maxResultsPerNode;
  final int maxSearchResults;

  TrieSearchEngine({
    this.maxNodes = 50000,
    this.maxResultsPerNode = 50,
    this.maxSearchResults = 50,
  });

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
    _nodeCount = 1;
  }

  void insert(String word, String id) {
    if (_nodeCount >= maxNodes) return;

    final normalized = normalizeUniversal(word);
    if (normalized.isEmpty) return;

    TrieNode current = _root;
    for (final char in normalized.characters) {
      if (!current.children.containsKey(char)) {
        if (_nodeCount >= maxNodes) break;
        current.children[char] = TrieNode();
        _nodeCount++;
      }
      current = current.children[char]!;

      if (current.wordIds.length < maxResultsPerNode) {
        current.wordIds.add(id);
      }
    }
  }

  List<String> searchPrefix(String prefix) {
    final normalized = normalizeUniversal(prefix);
    if (normalized.isEmpty) return [];

    TrieNode current = _root;
    for (final char in normalized.characters) {
      if (!current.children.containsKey(char)) return [];
      current = current.children[char]!;
    }

    return current.wordIds.take(maxSearchResults).toList();
  }
}
