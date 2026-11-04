/// Task 2032: OR-Set CRDT accumulator managing vocabulary deck mutations
class OrSetCrdtAccumulator {
  final Set<String> _elements = {};
  void add(String item) => _elements.add(item);
  void remove(String item) => _elements.remove(item);
}
