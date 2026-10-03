enum EmergencyHealthDomain { ambulance112, medicalOnCall }

enum EmergencyUrgency { lifeThreatening, urgentNonLifeThreatening }

extension EmergencyHealthDomainLabels on EmergencyHealthDomain {
  String get labelDe => switch (this) {
        EmergencyHealthDomain.ambulance112 => 'Notruf 112',
        EmergencyHealthDomain.medicalOnCall => 'Notdienst & 116 117',
      };

  String get labelAr => switch (this) {
        EmergencyHealthDomain.ambulance112 => 'طوارئ الإسعاف 112',
        EmergencyHealthDomain.medicalOnCall => 'الطبيب المناوب والصيدلية',
      };
}

final class EmergencyPhrase {
  const EmergencyPhrase({
    required this.id,
    required this.domain,
    required this.urgency,
    required this.titleDe,
    required this.titleAr,
    required this.german,
    required this.arabic,
    required this.explanationAr,
    this.tags = const <String>[],
  });

  final String id;
  final EmergencyHealthDomain domain;
  final EmergencyUrgency urgency;
  final String titleDe;
  final String titleAr;
  final String german;
  final String arabic;
  final String explanationAr;
  final List<String> tags;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    final haystack = <String>[
      titleDe,
      titleAr,
      german,
      arabic,
      explanationAr,
      ...tags,
    ].join(' ').toLowerCase();

    return haystack.contains(needle);
  }
}

abstract interface class EmergencyHealthContentSource {
  EmergencyHealthDomain get domain;
  List<EmergencyPhrase> get items;
}

final class EmergencyChecklistAction {
  const EmergencyChecklistAction({
    required this.id,
    required this.titleDe,
    required this.titleAr,
    required this.detailAr,
  });

  final String id;
  final String titleDe;
  final String titleAr;
  final String detailAr;
}

final class EmergencyMedicalTerm {
  const EmergencyMedicalTerm({
    required this.german,
    required this.arabic,
    required this.explanationAr,
  });

  final String german;
  final String arabic;
  final String explanationAr;
}
