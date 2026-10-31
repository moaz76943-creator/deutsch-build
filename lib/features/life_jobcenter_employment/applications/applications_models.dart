enum ApplicationsTopic {
  hauptantrag,
  housingCosts,
  approvalNotice,
  objection,
  delayedPayment,
}

extension ApplicationsTopicLabels on ApplicationsTopic {
  String get labelDe => switch (this) {
        ApplicationsTopic.hauptantrag => 'Hauptantrag',
        ApplicationsTopic.housingCosts => 'Unterkunft',
        ApplicationsTopic.approvalNotice => 'Bescheid',
        ApplicationsTopic.objection => 'Widerspruch',
        ApplicationsTopic.delayedPayment => 'Zahlung',
      };

  String get labelAr => switch (this) {
        ApplicationsTopic.hauptantrag => 'الطلب الرئيسي',
        ApplicationsTopic.housingCosts => 'تكاليف السكن',
        ApplicationsTopic.approvalNotice => 'إشعار الموافقة',
        ApplicationsTopic.objection => 'الاعتراض',
        ApplicationsTopic.delayedPayment => 'الدفعة',
      };
}

final class ApplicationsPhrase {
  const ApplicationsPhrase({
    required this.id,
    required this.topic,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final ApplicationsTopic topic;
  final String german;
  final String arabic;
  final String contextDe;
  final String contextAr;
  final List<String> keywords;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    final haystack = <String>[
      id,
      german,
      arabic,
      contextDe,
      contextAr,
      topic.labelDe,
      topic.labelAr,
      ...keywords,
    ].join(' ').toLowerCase();

    return haystack.contains(needle);
  }
}
