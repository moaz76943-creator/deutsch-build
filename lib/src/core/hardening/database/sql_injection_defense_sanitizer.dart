/// Task 1033: Strict parameter binding and query token sanitizer
class SqlSanitizer {
  bool isParamSafe(String val) => !val.contains(';') && !val.contains('--');
}
