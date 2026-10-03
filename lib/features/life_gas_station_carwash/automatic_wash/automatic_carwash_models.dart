enum CarwashTopic {
  all,
  program,
  preparation,
  conveyor,
  aftercare;

  String get labelDe => switch (this) {
        CarwashTopic.all => 'Alle Themen',
        CarwashTopic.program => 'Waschprogramm',
        CarwashTopic.preparation => 'Vorbereitung',
        CarwashTopic.conveyor => 'Einfahrt & Förderband',
        CarwashTopic.aftercare => 'Ausfahrt & Nachpflege',
      };

  String get labelAr => switch (this) {
        CarwashTopic.all => 'كل المواضيع',
        CarwashTopic.program => 'برنامج الغسيل',
        CarwashTopic.preparation => 'تجهيز السيارة',
        CarwashTopic.conveyor => 'الدخول والناقل',
        CarwashTopic.aftercare => 'الخروج والعناية',
      };
}

final class CarwashPhrase {
  const CarwashPhrase({
    required this.id,
    required this.topic,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final CarwashTopic topic;
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
