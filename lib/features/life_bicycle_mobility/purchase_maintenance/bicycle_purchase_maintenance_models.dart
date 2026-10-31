enum BicycleShopTopic {
  all,
  purchaseAdvice,
  fitAndSize,
  repair,
  maintenance;

  String get labelDe => switch (this) {
        BicycleShopTopic.all => 'Alle Themen',
        BicycleShopTopic.purchaseAdvice => 'Kaufberatung',
        BicycleShopTopic.fitAndSize => 'Größe & Einstellung',
        BicycleShopTopic.repair => 'Reparatur',
        BicycleShopTopic.maintenance => 'Wartung',
      };

  String get labelAr => switch (this) {
        BicycleShopTopic.all => 'كل المواضيع',
        BicycleShopTopic.purchaseAdvice => 'نصيحة الشراء',
        BicycleShopTopic.fitAndSize => 'المقاس والضبط',
        BicycleShopTopic.repair => 'إصلاح الأعطال',
        BicycleShopTopic.maintenance => 'الصيانة',
      };
}

final class BicycleShopPhrase {
  const BicycleShopPhrase({
    required this.id,
    required this.topic,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final BicycleShopTopic topic;
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

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ß', 'ss')
        .replaceAll('ـ', '');
  }
}
