enum SafetyCategory { roadsideAssistance, officialReporting }

enum SafetyTopic {
  breakdown,
  flatTire,
  towing,
  highwayLocation,
  lostItem,
  bikeTheft,
  insuranceClaim,
}

extension SafetyCategoryLabels on SafetyCategory {
  String get german => switch (this) {
        SafetyCategory.roadsideAssistance => 'Pannenhilfe',
        SafetyCategory.officialReporting => 'Offizielle Meldungen',
      };

  String get arabic => switch (this) {
        SafetyCategory.roadsideAssistance => 'المساعدة على الطريق',
        SafetyCategory.officialReporting => 'البلاغات الرسمية',
      };
}

extension SafetyTopicLabels on SafetyTopic {
  String get german => switch (this) {
        SafetyTopic.breakdown => 'Panne',
        SafetyTopic.flatTire => 'Reifenpanne',
        SafetyTopic.towing => 'Abschleppen',
        SafetyTopic.highwayLocation => 'Standort auf der Autobahn',
        SafetyTopic.lostItem => 'Fundsache',
        SafetyTopic.bikeTheft => 'Fahrraddiebstahl',
        SafetyTopic.insuranceClaim => 'Versicherungsschaden',
      };
}

final class SafetyLearningItem {
  const SafetyLearningItem({
    required this.id,
    required this.category,
    required this.topic,
    required this.german,
    required this.arabic,
    required this.tags,
  });

  final String id;
  final SafetyCategory category;
  final SafetyTopic topic;
  final String german;
  final String arabic;
  final List<String> tags;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    return german.toLowerCase().contains(needle) ||
        arabic.toLowerCase().contains(needle) ||
        topic.german.toLowerCase().contains(needle) ||
        tags.any((tag) => tag.toLowerCase().contains(needle));
  }
}

final class SafetyPanicAction {
  const SafetyPanicAction({
    required this.id,
    required this.phoneNumber,
    required this.authorityGerman,
    required this.authorityArabic,
    required this.germanScript,
    required this.arabicGuide,
  });

  final String id;
  final String phoneNumber;
  final String authorityGerman;
  final String authorityArabic;
  final String germanScript;
  final String arabicGuide;
}
