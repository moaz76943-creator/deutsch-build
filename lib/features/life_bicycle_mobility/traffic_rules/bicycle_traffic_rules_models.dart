enum BicycleRuleTopic {
  all,
  cycleLane,
  trafficSignals,
  lighting,
  safeRiding;

  String get labelDe => switch (this) {
        BicycleRuleTopic.all => 'Alle Regeln',
        BicycleRuleTopic.cycleLane => 'Radweg',
        BicycleRuleTopic.trafficSignals => 'Ampeln & Vorfahrt',
        BicycleRuleTopic.lighting => 'Beleuchtung',
        BicycleRuleTopic.safeRiding => 'Sicher fahren',
      };

  String get labelAr => switch (this) {
        BicycleRuleTopic.all => 'كل القواعد',
        BicycleRuleTopic.cycleLane => 'مسار الدراجات',
        BicycleRuleTopic.trafficSignals => 'الإشارات والأولوية',
        BicycleRuleTopic.lighting => 'الإضاءة',
        BicycleRuleTopic.safeRiding => 'القيادة الآمنة',
      };
}

final class BicycleRulePhrase {
  const BicycleRulePhrase({
    required this.id,
    required this.topic,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final BicycleRuleTopic topic;
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
