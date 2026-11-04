/// Task 1573: Modified Merkle Patricia Trie (MPT) for lesson state lookup
class MerklePatriciaTrie {
  final Map<String, String> _trie = {};
  void insert(String key, String value) => _trie[key] = value;
  String? get(String key) => _trie[key];
}
