import re

with open('lib/services/trie_search_engine.dart', 'r') as f:
    content = f.read()

# Replace tryInsert block to fix the logic error
new_tryinsert = """
  /// Returns false when the word cannot be indexed at all.
  /// A word that exceeds [maxNodes] is indexed only for the prefix that fits.
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

    var current = _root;
    var indexed = false;
    for (final unit in units) {
      final existing = current.children[unit];
      if (existing != null) {
        if (!existing.wordIds.contains(id)) {
          if (existing.wordIds.length >= maxResultsPerNode) return indexed;
        }
        current = existing;
      } else {
        if (_nodeCount >= maxNodes) break;
        final created = TrieNode();
        current.children[unit] = created;
        _nodeCount++;
        current = created;
      }
      if (!current.wordIds.contains(id)) {
        if (current.wordIds.length >= maxResultsPerNode) return indexed;
        current.wordIds.add(id);
      }
      indexed = true;
    }
    return indexed;
  }
"""

old_tryinsert = """
  /// Returns false when the word cannot be indexed at all.
  /// A word that exceeds [maxNodes] is indexed only for the prefix that fits.
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
    return indexed;
  }
"""

content = content.replace(old_tryinsert.strip(), new_tryinsert.strip())

with open('lib/services/trie_search_engine.dart', 'w') as f:
    f.write(content)
