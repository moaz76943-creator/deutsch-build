enum ServiceRepairTopic {
  all,
  faultReport,
  diagnosis,
  costEstimate,
  repairStatus;

  String get labelDe => switch (this) {
        ServiceRepairTopic.all => 'Alle Themen',
        ServiceRepairTopic.faultReport => 'Defekt melden',
        ServiceRepairTopic.diagnosis => 'Diagnose',
        ServiceRepairTopic.costEstimate => 'Kostenvoranschlag',
        ServiceRepairTopic.repairStatus => 'Reparaturstatus',
      };

  String get labelAr => switch (this) {
        ServiceRepairTopic.all => 'كل المواضيع',
        ServiceRepairTopic.faultReport => 'الإبلاغ عن العطل',
        ServiceRepairTopic.diagnosis => 'التشخيص',
        ServiceRepairTopic.costEstimate => 'تقدير التكلفة',
        ServiceRepairTopic.repairStatus => 'حالة الإصلاح',
      };
}

final class ServiceRepairPhrase {
  const ServiceRepairPhrase({
    required this.id,
    required this.topic,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final ServiceRepairTopic topic;
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
