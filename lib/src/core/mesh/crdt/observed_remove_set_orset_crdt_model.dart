/// Task 1522: Observed-Remove Set (OR-Set) CRDT for vocabulary items
class OrSetCrdt<T> {
  final Map<T, Set<String>> _addTags = {};
  final Map<T, Set<String>> _removeTags = {};
  void add(T element, String tag) => _addTags.putIfAbsent(element, () => {}).add(tag);
  void remove(T element, String tag) => _removeTags.putIfAbsent(element, () => {}).add(tag);
  bool contains(T element) => (_addTags[element] ?? {}).difference(_removeTags[element] ?? {}).isNotEmpty;
}
