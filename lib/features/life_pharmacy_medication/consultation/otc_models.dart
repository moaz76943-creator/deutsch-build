enum OtcTopic {
  mildPain,
  coldSymptoms,
  dosage,
  mealTiming,
  leaflet,
  sideEffects,
  expiryAndStorage,
}

extension OtcTopicLabels on OtcTopic {
  String get labelDe => switch (this) {
        OtcTopic.mildPain => 'Leichte Schmerzen',
        OtcTopic.coldSymptoms => 'Erkältung',
        OtcTopic.dosage => 'Dosierung',
        OtcTopic.mealTiming => 'Einnahme & Essen',
        OtcTopic.leaflet => 'Packungsbeilage',
        OtcTopic.sideEffects => 'Nebenwirkungen',
        OtcTopic.expiryAndStorage => 'Verfallsdatum & Lagerung',
      };

  String get labelAr => switch (this) {
        OtcTopic.mildPain => 'ألم خفيف',
        OtcTopic.coldSymptoms => 'نزلة برد',
        OtcTopic.dosage => 'الجرعة',
        OtcTopic.mealTiming => 'التناول والطعام',
        OtcTopic.leaflet => 'النشرة الداخلية',
        OtcTopic.sideEffects => 'الآثار الجانبية',
        OtcTopic.expiryAndStorage => 'الصلاحية والحفظ',
      };
}

final class OtcPhrase {
  const OtcPhrase({
    required this.id,
    required this.topic,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final OtcTopic topic;
  final String german;
  final String arabic;
  final String contextDe;
  final String contextAr;
  final List<String> keywords;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    return <String>[
      id,
      topic.labelDe,
      topic.labelAr,
      german,
      arabic,
      contextDe,
      contextAr,
      ...keywords,
    ].join(' ').toLowerCase().contains(needle);
  }
}
