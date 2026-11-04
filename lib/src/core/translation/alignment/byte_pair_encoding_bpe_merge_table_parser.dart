/// Task 1701: BPE merge rule table parser and subword vocabulary tokenizer
class BpeMergeTableParser {
  final Map<String, int> _merges = {};
  void addMerge(String pair, int rank) => _merges[pair] = rank;
  List<String> tokenize(String word) => word.split('');
}
