import 'package:characters/characters.dart';

class TrieNode {
  final Map<String, TrieNode> children = <String, TrieNode>{};
  final Set<String> wordIds = <String>{};
}

/// A bounded, language-specific *search-key* index. It does not mutate or
/// replace original surface spellings, and it does not infer segmentation.
class TrieSearchEngine {
  final int maxInputCodeUnits;
  final int maxIdCodeUnits;
  TrieNode _root = TrieNode();
  int _nodeCount = 1;
  int _contentVersion = 0;

  final String languageCode;
  final String? directedPairKey;
  final int maxNodes;
  final int maxResultsPerNode;
  final int maxSearchResults;
  final int maxWordGraphemes;
  final int maxInputCodeUnits;
  final int maxIdCodeUnits;

  TrieSearchEngine({
    this.languageCode = 'und',
    this.directedPairKey,
    this.maxNodes = 50000,
    this.maxResultsPerNode = 50,
    this.maxSearchResults = 50,
    this.maxWordGraphemes = 256,
    this.maxInputCodeUnits = 1024,
    this.maxIdCodeUnits = 256,
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
    // 'und' is the default multilingual index used by prefix search. Apply
    // each script fold there; a specific language keeps only its own fold.
    final foldGerman = lang == 'de' || lang == 'und';
    final foldArabic = lang == 'ar' || lang == 'und';
    final foldHebrew = lang == 'he' || lang == 'und';
    if (foldGerman) {
      result = result
          .replaceAll('ä', 'ae')
          .replaceAll('ö', 'oe')
          .replaceAll('ü', 'ue')
          .replaceAll('ß', 'ss');
    }
    if (foldArabic) {
      result = result.replaceAll(
          RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'), '');
    }
    if (foldHebrew) {
      result = result.replaceAll(
        RegExp(r'[\u0591-\u05BD\u05BF\u05C1\u05C2\u05C4\u05C5\u05C7]'),
        '',
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

  /// Returns false when the word cannot be indexed at all.
  /// A word that exceeds [maxNodes] is indexed only for the prefix that fits.
  bool tryInsert(String word, String id, {String? pairKey}) {
    if (!_matchesScope(pairKey) ||
        id.isEmpty ||
        word.length > maxInputCodeUnits ||
        id.length > maxIdCodeUnits) {
      return false;
    }
    final normalized = normalizeForLanguage(word, languageCode);
    if (normalized.isEmpty) return false;
    final units = normalized.characters.toList(growable: false);
    if (units.length > maxWordGraphemes) return false;

    var current = _root;
    var indexed = false;
    for (final unit in units) {
      final existing = current.children[unit];
      if (existing != null) {
        if (!existing.wordIds.contains(id) &&
            existing.wordIds.length >= maxResultsPerNode) {
          return indexed;
        }
        current = existing;
      } else {
        if (_nodeCount >= maxNodes) break;
        final created = TrieNode();
        current.children[unit] = created;
        _nodeCount++;
        current = created;
      }
      if (!current.wordIds.contains(id) &&
          current.wordIds.length >= maxResultsPerNode) {
        return indexed;
      }
      current.wordIds.add(id);
      indexed = true;
    }

    // If the word was inserted, we should consider it indexed successfully
    // Even if it hit maxNodes bounds during insert, the prefix was inserted
    return indexed;
  }

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
    // Convert to Set first to guarantee deduplication if somehow duplicates exist
    return current.wordIds.toSet().take(maxSearchResults).toList(growable: false);
  }

  void clear() {
    _root = TrieNode();
    _nodeCount = 1;
  }

  void reset(int version) {
    clear();
    _contentVersion = version;
  }

  int get currentNodeCount => _nodeCount;

  int get contentVersion => _contentVersion;
}
