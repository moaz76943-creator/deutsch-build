enum EducationLevel {
  a1a2('A1/A2'),
  b1('B1'),
  b2('B2');

  const EducationLevel(this.label);

  final String label;
}

enum EducationArea {
  daycare,
  school,
}

enum EducationTopic {
  dropOffPickup,
  allergy,
  dailyRoutine,
  careTimes,
  sickLeave,
  parentTeacherConference,
  homework,
}

final class EducationEntry {
  const EducationEntry({
    required this.id,
    required this.area,
    required this.level,
    required this.topic,
    required this.titleDe,
    required this.titleAr,
    required this.germanText,
    required this.arabicText,
    this.noteAr = '',
    this.keywords = const <String>[],
    this.formalRegister = false,
  });

  final String id;
  final EducationArea area;
  final EducationLevel level;
  final EducationTopic topic;
  final String titleDe;
  final String titleAr;
  final String germanText;
  final String arabicText;
  final String noteAr;
  final List<String> keywords;
  final bool formalRegister;

  String get searchableText => <String>[
        id,
        titleDe,
        titleAr,
        germanText,
        arabicText,
        noteAr,
        ...keywords,
      ].join(' ');
}

final class EmergencyAbsenceMessage {
  const EmergencyAbsenceMessage({
    required this.area,
    required this.level,
    required this.titleDe,
    required this.titleAr,
    required this.germanText,
    required this.arabicGuidance,
    required this.isFormal,
  });

  final EducationArea area;
  final EducationLevel level;
  final String titleDe;
  final String titleAr;
  final String germanText;
  final String arabicGuidance;
  final bool isFormal;
}
