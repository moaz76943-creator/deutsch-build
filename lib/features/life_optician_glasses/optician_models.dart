enum OpticianCategory {
  visionExam,
  lensMeasurements,
  glassesOrder;

  String get german => switch (this) {
        OpticianCategory.visionExam => 'Sehtest',
        OpticianCategory.lensMeasurements => 'Glaswerte & Messung',
        OpticianCategory.glassesOrder => 'Brille bestellen',
      };

  String get arabic => switch (this) {
        OpticianCategory.visionExam => 'فحص النظر',
        OpticianCategory.lensMeasurements => 'قياسات العدسات',
        OpticianCategory.glassesOrder => 'تفصيل النظارة',
      };
}

final class OpticianPhrase {
  const OpticianPhrase({
    required this.id,
    required this.category,
    required this.german,
    required this.arabic,
    required this.tags,
  });

  final String id;
  final OpticianCategory category;
  final String german;
  final String arabic;
  final List<String> tags;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return german.toLowerCase().contains(needle) ||
        arabic.toLowerCase().contains(needle) ||
        tags.any((tag) => tag.toLowerCase().contains(needle));
  }
}
