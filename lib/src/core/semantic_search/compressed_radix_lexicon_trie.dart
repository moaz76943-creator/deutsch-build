/// Node representing a compressed edge in a Radix Trie.
class RadixTrieNode {
  String edgeLabel;
  bool isTerminal;
  final Map<String, RadixTrieNode> children = <String, RadixTrieNode>{};

  RadixTrieNode({required this.edgeLabel, this.isTerminal = false});
}

/// Space-efficient Radix / Patricia Trie for instant offline prefix matching.
/// Eliminates single-character node chains and ensures sub-millisecond autocomplete on mobile.
class CompressedRadixLexiconTrie {
  final RadixTrieNode _root = RadixTrieNode(edgeLabel: '');
  int _wordCount = 0;

  int get totalWords => _wordCount;

  /// Insert a word into the Radix Trie.
  void insert(String word) {
    if (word.isEmpty) return;
    final clean = word.trim().toLowerCase();
    _insertAt(_root, clean);
  }

  void _insertAt(RadixTrieNode current, String remaining) {
    for (final child in current.children.values) {
      final edge = child.edgeLabel;
      final commonPrefixLength = _getCommonPrefixLength(edge, remaining);

      if (commonPrefixLength > 0) {
        if (commonPrefixLength == edge.length) {
          // Exact match on edge: continue deeper
          final nextRemaining = remaining.substring(commonPrefixLength);
          if (nextRemaining.isEmpty) {
            if (!child.isTerminal) {
              child.isTerminal = true;
              _wordCount++;
            }
          } else {
            _insertAt(child, nextRemaining);
          }
          return;
        } else {
          // Partial match on edge: split the edge
          final splitChild = RadixTrieNode(
            edgeLabel: edge.substring(commonPrefixLength),
            isTerminal: child.isTerminal,
          );
          splitChild.children.addAll(child.children);

          child.edgeLabel = edge.substring(0, commonPrefixLength);
          child.children.clear();
          child.children[splitChild.edgeLabel[0]] = splitChild;

          final nextRemaining = remaining.substring(commonPrefixLength);
          if (nextRemaining.isEmpty) {
            child.isTerminal = true;
          } else {
            child.isTerminal = false;
            final newLeaf = RadixTrieNode(
              edgeLabel: nextRemaining,
              isTerminal: true,
            );
            child.children[nextRemaining[0]] = newLeaf;
          }
          _wordCount++;
          return;
        }
      }
    }

    // No common prefix found with existing children: add new branch
    final newLeaf = RadixTrieNode(edgeLabel: remaining, isTerminal: true);
    current.children[remaining[0]] = newLeaf;
    _wordCount++;
  }

  int _getCommonPrefixLength(String a, String b) {
    int i = 0;
    while (i < a.length && i < b.length && a[i] == b[i]) {
      i++;
    }
    return i;
  }

  /// Search for all words matching the specified prefix.
  List<String> findWordsWithPrefix(String prefix, {int limit = 10}) {
    if (prefix.isEmpty) return const [];
    final clean = prefix.trim().toLowerCase();
    final results = <String>[];

    RadixTrieNode current = _root;
    String matchedSoFar = '';
    String remaining = clean;

    while (remaining.isNotEmpty) {
      RadixTrieNode? matchingChild;
      for (final child in current.children.values) {
        if (remaining.startsWith(child.edgeLabel) || child.edgeLabel.startsWith(remaining)) {
          matchingChild = child;
          break;
        }
      }

      if (matchingChild == null) return results;

      if (matchingChild.edgeLabel.length >= remaining.length) {
        matchedSoFar += matchingChild.edgeLabel;
        _collectAll(matchingChild, matchedSoFar, results, limit);
        return results;
      } else {
        matchedSoFar += matchingChild.edgeLabel;
        remaining = remaining.substring(matchingChild.edgeLabel.length);
        current = matchingChild;
      }
    }

    return results;
  }

  void _collectAll(RadixTrieNode node, String prefix, List<String> results, int limit) {
    if (results.length >= limit) return;
    if (node.isTerminal) {
      results.add(prefix);
    }
    for (final child in node.children.values) {
      _collectAll(child, prefix + child.edgeLabel, results, limit);
      if (results.length >= limit) return;
    }
  }
}
