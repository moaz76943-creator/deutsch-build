enum CarServiceMode {
  all,
  workshop,
  inspection;

  String get labelDe => switch (this) {
        CarServiceMode.all => 'Alle',
        CarServiceMode.workshop => 'Werkstatt',
        CarServiceMode.inspection => 'HU / TÜV',
      };

  String get labelAr => switch (this) {
        CarServiceMode.all => 'الكل',
        CarServiceMode.workshop => 'ورشة الصيانة',
        CarServiceMode.inspection => 'الفحص الدوري',
      };
}

enum CarServiceTopic {
  appointment,
  costEstimate,
  oilChange,
  brakePads,
  tires,
  huPreparation,
  inspectionReport,
  inspectionSticker;

  String get labelDe => switch (this) {
        CarServiceTopic.appointment => 'Werkstatttermin',
        CarServiceTopic.costEstimate => 'Kostenvoranschlag',
        CarServiceTopic.oilChange => 'Ölwechsel',
        CarServiceTopic.brakePads => 'Bremsbeläge',
        CarServiceTopic.tires => 'Reifen',
        CarServiceTopic.huPreparation => 'HU vorbereiten',
        CarServiceTopic.inspectionReport => 'Prüfbericht',
        CarServiceTopic.inspectionSticker => 'HU-Plakette',
      };

  String get labelAr => switch (this) {
        CarServiceTopic.appointment => 'موعد الورشة',
        CarServiceTopic.costEstimate => 'تقدير التكلفة',
        CarServiceTopic.oilChange => 'تغيير الزيت',
        CarServiceTopic.brakePads => 'بطانات الفرامل',
        CarServiceTopic.tires => 'الإطارات',
        CarServiceTopic.huPreparation => 'التحضير للفحص',
        CarServiceTopic.inspectionReport => 'تقرير الفحص',
        CarServiceTopic.inspectionSticker => 'ملصق الفحص',
      };
}

final class CarServicePhrase {
  const CarServicePhrase({
    required this.id,
    required this.mode,
    required this.topic,
    required this.titleDe,
    required this.titleAr,
    required this.german,
    required this.arabic,
    this.noteDe,
    this.noteAr,
    this.keywords = const <String>[],
  });

  final String id;
  final CarServiceMode mode;
  final CarServiceTopic topic;
  final String titleDe;
  final String titleAr;
  final String german;
  final String arabic;
  final String? noteDe;
  final String? noteAr;
  final List<String> keywords;

  String get searchableText => <String>[
        titleDe,
        titleAr,
        german,
        arabic,
        topic.labelDe,
        topic.labelAr,
        ...keywords,
      ].join(' ');
}
