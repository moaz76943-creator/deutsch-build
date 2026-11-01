import 'dart:math' as math;

class CachedSemanticItem {
  final String key;
  final String prompt;
  final List<double> vector;
  final dynamic response;
  CachedSemanticItem({required this.key, required this.prompt, required this.vector, required this.response});
}

class CrossLingualSemanticCache {
  final double similarityThreshold;
  final Map<String, CachedSemanticItem> _cache = {};
  CrossLingualSemanticCache({this.similarityThreshold = 0.90});

  int get size => _cache.length;

  static double _cosine(List<double> a, List<double> b) {
    double dot = 0.0, na = 0.0, nb = 0.0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i]; na += a[i] * a[i]; nb += b[i] * b[i];
    }
    if (na == 0.0 || nb == 0.0) return 0.0;
    return dot / (math.sqrt(na) * math.sqrt(nb));
  }

  dynamic lookup(List<double> queryVector) {
    for (final item in _cache.values) {
      if (_cosine(queryVector, item.vector) >= similarityThreshold) {
        return item.response;
      }
    }
    return null;
  }

  void put(String key, String prompt, List<double> vector, dynamic response) {
    _cache[key] = CachedSemanticItem(key: key, prompt: prompt, vector: List.from(vector), response: response);
  }
}
