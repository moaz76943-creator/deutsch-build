import 'dart:collection';
import 'package:characters/characters.dart';

class TrieNode {
  final Map<String, TrieNode> children = <String, TrieNode>{};
  final Set<String> wordIds = LinkedHashSet<String>();
}

/// A bounded, language-specific *search-key* index. It does not mutate or
/// replace original surface spellings, and it does not infer segmentation.
class TrieSearchEngine {
  static const int maxInputCodeUnits = 2048;
  static const int maxIdCodeUnits = 128;
  TrieNode _root = TrieNode();
  int _nodeCount = 1;

  final String languageCode;
  final String? directedPairKey;
  final int maxNodes;
  final int maxResultsPerNode;
  final int maxSearchResults;
  final int maxWordGraphemes;

  TrieSearchEngine({
    this.languageCode = 'und',
    this.directedPairKey,
    this.maxNodes = 50000,
    this.maxResultsPerNode = 50,
    this.maxSearchResults = 50,
    this.maxWordGraphemes = 256,
  }) {
    if (maxNodes < 2 || maxResultsPerNode < 1 ||
        maxSearchResults < 1 || maxWordGraphemes < 1) {
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
      result = result.replaceAll('ä', 'ae')
          .replaceAll('ö', 'oe')
          .replaceAll('ü', 'ue')
          .replaceAll('ß', 'ss');
    } else if (lang == 'ar') {
      result = result.replaceAll(RegExp(
        r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'
      ), '');
    } else if (lang == 'he') {
      result = result.replaceAll(
        RegExp(r'[\u0591-\u05BD\u05BF\u05C1\u05C2\u05C4\u05C5\u05C7]'), '',
      );
    }
    return result;
  }

  // Legacy static entrypoints retained; universal no longer means Latin fold.
  static String normalizeUniversal(String text) =>
      normalizeForLanguage(text, 'und');
  static String normalizeGerman(String text) =>
      normalizeForLanguage(text, 'de');

  bool _matchesScope(String? pairKey) =>
      directedPairKey == null || directedPairKey == pairKey;

  /// Returns false on capacity limits. A failed insert makes NO partial path.
  bool tryInsert(String word, String id, {String? pairKey}) {
    if (!_matchesScope(pairKey) || id.isEmpty ||
        word.length > maxInputCodeUnits || id.length > maxIdCodeUnits) {
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
      if (current.wordIds.length < maxResultsPerNode) {
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
    if (!_matchesScope(pairKey) || prefix.length > maxInputCodeUnits) {
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
