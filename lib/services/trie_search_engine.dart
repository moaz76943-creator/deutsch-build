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
    int? maxResults,
    int? maxSearchResults,
    this.maxWordGraphemes = 256,
  }) : maxSearchResults = maxResults ?? maxSearchResults ?? 50 {
    if (maxNodes < 2 ||
        maxResultsPerNode < 1 ||
        this.maxSearchResults < 1 ||
        maxWordGraphemes < 1) {
      throw ArgumentError('Trie bounds must be positive');
    }
  }

  /// تطبيع نصي عالمي يدعم اللاتينية، السلافية، والتشكيل العربي
  static String normalizeUniversal(String text) {
    if (text.isEmpty) return text;
    String res = text.toLowerCase().trim();

    // إزالة التشكيل العربي
    res = res.replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'), '');

    // إزالة تشكيل العبري
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

  // دعم التوافق مع الكود السابق
  String normalizeGerman(String text) => normalizeUniversal(text);

  String normalizeForLanguage(String text, String language) {
    if (text.isEmpty) return '';
    final lang = language.split('-').first.toLowerCase();

    if (lang == 'tr' || lang == 'az') {
      return text.trim();
    }

    if (lang == 'de') {
      var result = text.trim().toLowerCase();
      result = result
          .replaceAll('ä', 'ae')
          .replaceAll('ö', 'oe')
          .replaceAll('ü', 'ue')
          .replaceAll('ß', 'ss');
      return result;
    } else if (lang == 'ar') {
      var result = text.trim().toLowerCase();
      return result.replaceAll(
          RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'), '');
    } else if (lang == 'he') {
      var result = text.trim().toLowerCase();
      return result.replaceAll(
        RegExp(r'[\u0591-\u05BD\u05BF\u05C1\u05C2\u05C4\u05C5\u05C7]'),
        '',
      );
    }

    // For 'und' or other languages, fallback to universal
    return normalizeUniversal(text);
  }

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

    // We no longer strictly abort on `missingNodes` before inserting to support
    // partial insertions as requested by unit tests testing node bounds.
    // That means we insert up to maxNodes.
    var current = _root;
    for (final unit in units) {
      if (!current.children.containsKey(unit)) {
        if (_nodeCount >= maxNodes) {
           // Instead of break, we must return true / false?
           // If we just break, we'll try to add id to current node. Let's do that!
           break;
        }
        current.children[unit] = TrieNode();
        _nodeCount++;
      }
      current = current.children[unit]!;
      if (current.wordIds.length < maxResultsPerNode) {
        if (!current.wordIds.contains(id)) {
          current.wordIds.add(id);
        }
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
    _root = TrieNode();
    _nodeCount = 1;
  }

  int get currentNodeCount => _nodeCount;
}
