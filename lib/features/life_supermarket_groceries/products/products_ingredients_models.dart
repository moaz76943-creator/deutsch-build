enum ProductInquiryKind {
  location,
  dietaryIngredients,
  freshCounter,
}

final class ProductInquiryPhrase {
  const ProductInquiryPhrase({
    required this.id,
    required this.kind,
    required this.topicDe,
    required this.topicAr,
    required this.german,
    required this.arabic,
    this.keywords = const <String>[],
  });

  final String id;
  final ProductInquiryKind kind;
  final String topicDe;
  final String topicAr;
  final String german;
  final String arabic;
  final List<String> keywords;

  bool matches(String query) {
    final needle = _normalize(query);
    if (needle.isEmpty) return true;

    final haystack = _normalize(
      <String>[
        topicDe,
        topicAr,
        german,
        arabic,
        ...keywords,
      ].join(' '),
    );
    return haystack.contains(needle);
  }

  static String _normalize(String value) {
    var normalized = value.toLowerCase();
    normalized = normalized
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ß', 'ss');
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9ء-ي ]'), ' ');
    return normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
