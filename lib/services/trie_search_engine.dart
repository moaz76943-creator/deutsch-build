import 'package:characters/characters.dart';

class TrieNode {
  final Map<String, TrieNode> children = {};
  final Set<String> wordIds = {};
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
  final int maxInputCodeUnits = 1000;
  final int maxIdCodeUnits = 100;

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

  static String normalizeUniversal(String text) {
    if (text.isEmpty) return text;
    String res = text.toLowerCase().trim();
    res = res.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');

    final diacritics = {
      'ä': 'ae',
      'ö': 'oe',
      'ü': 'ue',
      'ß': 'ss',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ñ': 'n',
      'ç': 'c',
      'ı': 'i',
      'ğ': 'g',
      'ş': 's',
    };

    diacritics.forEach((k, v) {
      res = res.replaceAll(k, v);
    });

    return res;
  }

  String normalizeForLanguage(String text, String language) {
    if (text.isEmpty) return '';
    final lang = language.split('-').first.toLowerCase();
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
      final diacritics = {
        'ä': 'ae',
        'ö': 'oe',
        'ü': 'ue',
        'ß': 'ss',
        'é': 'e',
        'è': 'e',
        'ê': 'e',
        'ë': 'e',
        'á': 'a',
        'à': 'a',
        'â': 'a',
        'ã': 'a',
        'ó': 'o',
        'ò': 'o',
        'ô': 'o',
        'õ': 'o',
        'ú': 'u',
        'ù': 'u',
        'û': 'u',
        'ñ': 'n',
        'ç': 'c',
        'ı': 'i',
        'ğ': 'g',
        'ş': 's',
      };

      diacritics.forEach((k, v) {
        result = result.replaceAll(k, v);
      });

      result = result.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
      result = result.replaceAll(
        RegExp(r'[\u0591-\u05BD\u05BF\u05C1\u05C2\u05C4\u05C5\u05C7]'),
        '',
      );
    }
    return result;
  }

  String normalizeGerman(String text) => normalizeForLanguage(text, 'de');

  bool matchesScope(String? pairKey) =>
      directedPairKey == null || directedPairKey == pairKey;

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

    // Preflight atomic check to make sure we don't exceed maxNodes.
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
      if (current.wordIds.length < maxResultsPerNode) {
        current.wordIds.add(id);
      }
    }
    return true;
  }

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
