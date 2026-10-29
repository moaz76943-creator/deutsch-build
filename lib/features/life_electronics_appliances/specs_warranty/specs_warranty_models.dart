enum SpecsWarrantyTopic {
  all,
  specifications,
  comparison,
  warranty,
  returnExchange;

  String get labelDe => switch (this) {
        SpecsWarrantyTopic.all => 'Alle Themen',
        SpecsWarrantyTopic.specifications => 'Technische Daten',
        SpecsWarrantyTopic.comparison => 'Vergleichen',
        SpecsWarrantyTopic.warranty => 'Garantie & Gewährleistung',
        SpecsWarrantyTopic.returnExchange => 'Rückgabe & Umtausch',
      };

  String get labelAr => switch (this) {
        SpecsWarrantyTopic.all => 'كل المواضيع',
        SpecsWarrantyTopic.specifications => 'المواصفات التقنية',
        SpecsWarrantyTopic.comparison => 'المقارنة',
        SpecsWarrantyTopic.warranty => 'الكفالة وحقوق العيوب',
        SpecsWarrantyTopic.returnExchange => 'الإرجاع والاستبدال',
      };
}

final class SpecsWarrantyPhrase {
  const SpecsWarrantyPhrase({
    required this.id,
    required this.topic,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final SpecsWarrantyTopic topic;
  final String german;
  final String arabic;
  final String contextDe;
  final String contextAr;
  final List<String> keywords;

  bool matches(String query) {
    final needle = _normalize(query);
    if (needle.isEmpty) return true;
    return _normalize(<String>[
      topic.labelDe,
      topic.labelAr,
      german,
      arabic,
      contextDe,
      contextAr,
      ...keywords,
    ].join(' ')).contains(needle);
  }

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll('ä', 'a')
      .replaceAll('ö', 'o')
      .replaceAll('ü', 'u')
      .replaceAll('ß', 'ss')
      .replaceAll('ـ', '');
}
