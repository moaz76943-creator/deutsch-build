enum CyclingCategory { trafficSafety, workshopRepair }

enum CyclingTopic {
  equipment,
  radweg,
  oneWayStreet,
  handSignal,
  tyre,
  innerTube,
  chain,
  workshop,
}

extension CyclingCategoryLabels on CyclingCategory {
  String get labelDe => switch (this) {
        CyclingCategory.trafficSafety => 'Verkehr & Sicherheit',
        CyclingCategory.workshopRepair => 'Werkstatt & Reparatur',
      };

  String get labelAr => switch (this) {
        CyclingCategory.trafficSafety => 'المرور والسلامة',
        CyclingCategory.workshopRepair => 'الورشة والإصلاح',
      };
}

extension CyclingTopicLabels on CyclingTopic {
  String get labelDe => switch (this) {
        CyclingTopic.equipment => 'Verkehrssicheres Fahrrad',
        CyclingTopic.radweg => 'Radwegbenutzungspflicht',
        CyclingTopic.oneWayStreet => 'Einbahnstraße',
        CyclingTopic.handSignal => 'Handzeichen',
        CyclingTopic.tyre => 'Reifen flicken',
        CyclingTopic.innerTube => 'Schlauch wechseln',
        CyclingTopic.chain => 'Kette spannen',
        CyclingTopic.workshop => 'Fahrradwerkstatt',
      };

  String get labelAr => switch (this) {
        CyclingTopic.equipment => 'تجهيزات الدراجة الآمنة',
        CyclingTopic.radweg => 'إلزام استخدام مسار الدراجات',
        CyclingTopic.oneWayStreet => 'شارع باتجاه واحد',
        CyclingTopic.handSignal => 'إشارة اليد',
        CyclingTopic.tyre => 'ترقيع الإطار',
        CyclingTopic.innerTube => 'تغيير الأنبوب الداخلي',
        CyclingTopic.chain => 'شد السلسلة',
        CyclingTopic.workshop => 'ورشة الدراجات',
      };
}

final class CyclingPhrase {
  const CyclingPhrase({
    required this.id,
    required this.category,
    required this.topic,
    required this.titleDe,
    required this.german,
    required this.arabic,
    this.keywords = const <String>[],
  });

  final String id;
  final CyclingCategory category;
  final CyclingTopic topic;
  final String titleDe;
  final String german;
  final String arabic;
  final List<String> keywords;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    return <String>[
      titleDe,
      german,
      arabic,
      topic.labelDe,
      topic.labelAr,
      ...keywords,
    ].join(' ').toLowerCase().contains(needle);
  }
}

final class BikeSafetyCheckItem {
  const BikeSafetyCheckItem({
    required this.id,
    required this.labelDe,
    required this.labelAr,
    required this.legalBasis,
  });

  final String id;
  final String labelDe;
  final String labelAr;
  final String legalBasis;
}
