enum SportsFacilityType {
  all,
  gym,
  communityClub;

  String get labelDe => switch (this) {
        SportsFacilityType.all => 'Alle',
        SportsFacilityType.gym => 'Fitnessstudio',
        SportsFacilityType.communityClub => 'Sportverein',
      };

  String get labelAr => switch (this) {
        SportsFacilityType.all => 'الكل',
        SportsFacilityType.gym => 'النادي الرياضي',
        SportsFacilityType.communityClub => 'النادي المجتمعي',
      };
}

enum SportsLevel {
  a2,
  b1,
  b2;

  String get label => name.toUpperCase();
}

enum SportsTopic {
  trialTraining,
  equipment,
  hygiene,
  coaching,
  contract,
  registration,
  membershipFees,
  schedule;

  String get labelDe => switch (this) {
        SportsTopic.trialTraining => 'Probetraining',
        SportsTopic.equipment => 'Geräte',
        SportsTopic.hygiene => 'Hygiene',
        SportsTopic.coaching => 'Training',
        SportsTopic.contract => 'Vertrag',
        SportsTopic.registration => 'Anmeldung',
        SportsTopic.membershipFees => 'Mitgliedsbeitrag',
        SportsTopic.schedule => 'Trainingsplan',
      };

  String get labelAr => switch (this) {
        SportsTopic.trialTraining => 'تجربة تدريب',
        SportsTopic.equipment => 'الأجهزة',
        SportsTopic.hygiene => 'النظافة',
        SportsTopic.coaching => 'التدريب',
        SportsTopic.contract => 'العقد',
        SportsTopic.registration => 'التسجيل',
        SportsTopic.membershipFees => 'رسوم العضوية',
        SportsTopic.schedule => 'المواعيد',
      };
}

final class SportsPhrase {
  const SportsPhrase({
    required this.id,
    required this.facility,
    required this.level,
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
  final SportsFacilityType facility;
  final SportsLevel level;
  final SportsTopic topic;
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
