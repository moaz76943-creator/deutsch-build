/// Task 1257: Custom exception dictionary overrider for proper names
class HyphenationExceptionOverrider {
  final Map<String, String> _overrides = {};
  void addOverride(String word, String hyphenated) => _overrides[word.toLowerCase()] = hyphenated;
  String? getHyphenation(String word) => _overrides[word.toLowerCase()];
}
