/// Task 1014: High-frequency lexical token interning & deduplication pool
class StringInterningPool {
  static final StringInterningPool instance = StringInterningPool._();
  StringInterningPool._();
  final Map<String, String> _pool = {};
  String intern(String val) => _pool.putIfAbsent(val, () => val);
  int get poolSize => _pool.length;
  void clear() => _pool.clear();
}
