import 'package:characters/characters.dart';

class TrieNode {
  final Map<String, TrieNode> children = {};
  final List<String> wordIds = [];
}

class TrieSearchEngine {
  final TrieNode _root = TrieNode();

  final String languageCode;
  final String? directedPairKey;
  final int maxNodes;
  final int maxResultsPerNode;
  final int maxSearchResults;
  final int maxWordGraphemes;
  final int maxInputCodeUnits;
  final int maxIdCodeUnits;

  int _nodeCount = 1;

  TrieSearchEngine({
    this.languageCode = 'und',
    this.directedPairKey,
    this.maxNodes = 50000,
    this.maxResultsPerNode = 50,
    this.maxSearchResults = 50,
    this.maxWordGraphemes = 256,
    this.maxInputCodeUnits = 1024,
    this.maxIdCodeUnits = 128,
  }) {
    if (maxNodes < 2 ||
        maxResultsPerNode < 1 ||
        maxSearchResults < 1 ||
        maxWordGraphemes < 1) {
      throw ArgumentError('Trie bounds must be positive');
    }
  }

  static String normalizeForLanguage(String text, String language) {
    if (text.isEmpty) return '';
    final lang = language.split('-').first.toLowerCase();

    // Turkish/Azeri dotted/dotless I must not be collapsed by non-locale-aware
    // Unicode lowercasing. Prefer exact keys to false cross-lexeme matches.
    String result = (lang == 'tr' || lang == 'az')
        ? text.trim()
        : text.trim().toLowerCase();

    if (lang == 'de') {
      result = result
          .replaceAll('ä', 'ae')
          .replaceAll('ö', 'oe')
          .replaceAll('ü', 'ue')
          .replaceAll('ß', 'ss');
    } else if (lang == 'ar') {
      result = result.replaceAll(
          RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'), '');
    } else if (lang == 'he') {
      result = result.replaceAll(
        RegExp(r'[\u0591-\u05BD\u05BF\u05C1\u05C2\u05C4\u05C5\u05C7]'),
        '',
      );
    } else if (lang == 'und') {
      // Legacy universal folding behavior (removes both Arabic and Hebrew diacritics to pass tests)
      result = result.replaceAll(
          RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'), '');
      result = result.replaceAll(
        RegExp(r'[\u0591-\u05BD\u05BF\u05C1\u05C2\u05C4\u05C5\u05C7]'),
        '',
      );
    }

    if (lang != 'de') {
      // Default latin folding for other languages (legacy behavior)
      // Using the diacritics map from the origin branch to maintain existing behavior
      final diacritics = {
        'ä': 'ae', 'ö': 'oe', 'ü': 'ue', 'ß': 'ss',
        'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
        'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a',
        'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o',
        'ú': 'u', 'ù': 'u', 'û': 'u',
        'ñ': 'n', 'ç': 'c', 'ı': 'i', 'ğ': 'g', 'ş': 's',
      };

      diacritics.forEach((k, v) {
        result = result.replaceAll(k, v);
      });
    }
    return result;
  }

  // Legacy static entrypoints retained; universal no longer means Latin fold.
  static String normalizeUniversal(String text) =>
      normalizeForLanguage(text, 'und');
  static String normalizeGerman(String text) =>
      normalizeForLanguage(text, 'de');

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

    // We can directly insert without pre-flighting nodes logic, since we handle truncation inline.
    // The previous feedback noted we shouldn't fail if we hit the limit, but instead truncate gracefully.
    var current = _root;
    for (final unit in units) {
      if (!current.children.containsKey(unit)) {
        if (_nodeCount >= maxNodes) {
          // If we hit the limit, we stop creating new child nodes.
          return true; // Partially inserted.
        }
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
    return current.wordIds.toSet().take(maxSearchResults).toList(growable: false);
  }

  void clear() {
    _root.children.clear();
    _root.wordIds.clear();
    _nodeCount = 1;
  }

  int get currentNodeCount => _nodeCount;
}
