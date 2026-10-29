import 'package:characters/characters.dart';

class TrieNode {
  final Map<String, TrieNode> children = {};
  final List<String> wordIds = [];
}

class TrieSearchEngine {
  TrieNode _root = TrieNode();
  int _nodeCount = 1;

  final String languageCode;
  final String? directedPairKey;
  final int maxNodes;
  final int maxResultsPerNode;
  final int maxSearchResults;
  final int maxWordGraphemes;

  static const int maxInputCodeUnits = 1024;
  static const int maxIdCodeUnits = 256;

  TrieSearchEngine({
    this.languageCode = 'und',
    this.directedPairKey,
    this.maxNodes = 50000,
    this.maxResultsPerNode = 50,
    this.maxSearchResults = 50,
    this.maxWordGraphemes = 256,
  }) {
    if (maxNodes < 2 ||
        maxResultsPerNode < 1 ||
        maxSearchResults < 1 ||
        maxWordGraphemes < 1) {
      throw ArgumentError('Trie bounds must be positive');
    }
  }

  static String _normalize(String text) {
    if (text.isEmpty) return text;
    String res = text.trim().toLowerCase();

    // إزالة التشكيل العربي
    res = res.replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'), '');

    // إزالة التشكيل العبري
    res = res.replaceAll(RegExp(r'[\u0591-\u05BD\u05BF\u05C1\u05C2\u05C4\u05C5\u05C7]'), '');

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

  String normalizeForLanguage(String text, String language) {
    if (text.isEmpty) return '';
    final lang = language.split('-').first.toLowerCase();

    // Turkish/Azeri dotted/dotless I must not be collapsed by non-locale-aware
    // Unicode lowercasing. Prefer exact keys to false cross-lexeme matches.
    if (lang == 'tr' || lang == 'az') {
       return text.trim();
    }

    if (lang == 'de') {
      final expanded = text.trim().toLowerCase()
          .replaceAll('ä', 'ae')
          .replaceAll('ö', 'oe')
          .replaceAll('ü', 'ue')
          .replaceAll('ß', 'ss');
      return _normalize(expanded);
    }

    return _normalize(text);
  }

  // Legacy static entrypoints retained; universal no longer means Latin fold.
  static String normalizeUniversal(String text) {
      return _normalize(text);
  }

  String normalizeGerman(String text) => normalizeForLanguage(text, 'de');

  bool matchesScope(String? pairKey) =>
      directedPairKey == null || directedPairKey == pairKey;

  /// Returns false on capacity limits. A failed insert makes NO partial path.
  bool tryInsert(String word, String id, {String? pairKey}) {
    if (!matchesScope(pairKey) ||
        id.isEmpty ||
        word.length > maxInputCodeUnits ||
        id.length > maxIdCodeUnits) {
      return false;
    }
    final normalized = normalizeForLanguage(word, languageCode);
    if (normalized.isEmpty) return false;
    final units = normalized.characters.toList(growable: false);
    if (units.length > maxWordGraphemes) return false;

    // Preflight both capacity dimensions before touching the index.
    TrieNode? cursor = _root;
    var missingNodes = 0;
    for (final unit in units) {
      if (cursor == null) {
        missingNodes++;
      } else {
        final child = cursor.children[unit];
        if (child == null) {
          missingNodes++;
          cursor = null;
        } else {
          cursor = child;
          if (!cursor.wordIds.contains(id) &&
              cursor.wordIds.length >= maxResultsPerNode) {
            return false;
          }
        }
      }
    }
    if (_nodeCount + missingNodes > maxNodes) return false;

    var current = _root;
    for (final unit in units) {
      if (!current.children.containsKey(unit)) {
        current.children[unit] = TrieNode();
        _nodeCount++;
      }
      current = current.children[unit]!;
      if (!current.wordIds.contains(id) && current.wordIds.length < maxResultsPerNode) {
        current.wordIds.add(id);
      }
    }
    return true;
  }

  // Retains original void API for current callers.
  void insert(String word, String id, {String? pairKey}) {
    tryInsert(word, id, pairKey: pairKey);
  }

  List<String> searchPrefix(String prefix, {String? pairKey}) {
    if (!matchesScope(pairKey) || prefix.length > maxInputCodeUnits) {
      return <String>[];
    }
    final normalized = normalizeForLanguage(prefix, languageCode);
    if (normalized.isEmpty) return <String>[];
    final units = normalized.characters.toList(growable: false);
    if (units.length > maxWordGraphemes) return <String>[];

    var current = _root;
    for (final unit in units) {
      final next = current.children[unit];
      if (next == null) return <String>[];
      current = next;
    }
    return current.wordIds.take(maxSearchResults).toList(growable: false);
  }

  void clear() {
    _root = TrieNode();
    _nodeCount = 1;
  }

  int get currentNodeCount => _nodeCount;
}
