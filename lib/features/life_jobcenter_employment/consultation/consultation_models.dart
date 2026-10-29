enum ConsultationTopic {
  adviserMeeting,
  skillsProfile,
  courseFunding,
  applications,
  travelCosts,
}

extension ConsultationTopicLabels on ConsultationTopic {
  String get labelDe => switch (this) {
        ConsultationTopic.adviserMeeting => 'Beratung',
        ConsultationTopic.skillsProfile => 'Fähigkeiten',
        ConsultationTopic.courseFunding => 'Kursförderung',
        ConsultationTopic.applications => 'Bewerbungen',
        ConsultationTopic.travelCosts => 'Fahrtkosten',
      };

  String get labelAr => switch (this) {
        ConsultationTopic.adviserMeeting => 'الاستشارة',
        ConsultationTopic.skillsProfile => 'المهارات',
        ConsultationTopic.courseFunding => 'تمويل الدورات',
        ConsultationTopic.applications => 'طلبات التوظيف',
        ConsultationTopic.travelCosts => 'تكاليف السفر',
      };
}

final class ConsultationPhrase {
  const ConsultationPhrase({
    required this.id,
    required this.topic,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final ConsultationTopic topic;
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
