/// Small, dependency-free guards for runtime data and async boundaries.
T? safeFirst<T>(List<T>? values) {
  try {
    if (values == null || values.isEmpty) return null;
    return values.first;
  } catch (_) {
    return null;
  }
}

int safeIndex(int index, int length) {
  try {
    if (length <= 0 || index < 0 || index >= length) return -1;
    return index;
  } catch (_) {
    return -1;
  }
}

Future<T?> safeAsync<T>(Future<T> Function() action, {T? fallback}) async {
  try {
    return await action();
  } catch (_) {
    return fallback;
  }
}
