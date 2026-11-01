class ComprehensibleInputVerifier {
  const ComprehensibleInputVerifier();

  bool isComprehensible(String text, Set<String> knownWords, {double threshold = 95.0}) {
    final words = text.toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return true;
    final knownCount = words.where((w) => knownWords.contains(w)).length;
    return ((knownCount / words.length) * 100.0) >= threshold;
  }
}
