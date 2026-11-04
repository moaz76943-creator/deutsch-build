/// Task 1532: Multi-Value Register (MVR) preserving concurrent sibling versions
class MultiValueRegister<T> {
  final Map<String, T> _values = {};
  void assign(String vclock, T val) => _values[vclock] = val;
  List<T> readSiblings() => _values.values.toList();
}
