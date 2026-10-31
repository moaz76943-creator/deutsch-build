enum DoctorClinicType {
  hausarzt,
  facharzt;

  String get german => switch (this) {
        DoctorClinicType.hausarzt => 'Hausarzt',
        DoctorClinicType.facharzt => 'Facharzt',
      };

  String get arabic => switch (this) {
        DoctorClinicType.hausarzt => 'طبيب الأسرة',
        DoctorClinicType.facharzt => 'الطبيب المختص',
      };
}

enum DoctorDocumentKind {
  gesundheitskarte,
  ueberweisung,
}

final class DoctorDocumentCard {
  const DoctorDocumentCard({
    required this.id,
    required this.kind,
    required this.titleDe,
    required this.titleAr,
    required this.promptDe,
    required this.explanationAr,
    this.clinicType,
  });

  final String id;
  final DoctorDocumentKind kind;
  final String titleDe;
  final String titleAr;
  final String promptDe;
  final String explanationAr;
  final DoctorClinicType? clinicType;
}

final class DoctorAppointmentChecklistItem {
  const DoctorAppointmentChecklistItem({
    required this.id,
    required this.titleDe,
    required this.titleAr,
    required this.detailDe,
    required this.detailAr,
  });

  final String id;
  final String titleDe;
  final String titleAr;
  final String detailDe;
  final String detailAr;
}

final class DoctorHubPhrase {
  const DoctorHubPhrase({
    required this.id,
    required this.german,
    required this.arabic,
    required this.tags,
    this.clinicType,
  });

  final String id;
  final String german;
  final String arabic;
  final List<String> tags;
  final DoctorClinicType? clinicType;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return german.toLowerCase().contains(needle) ||
        arabic.toLowerCase().contains(needle) ||
        tags.any((tag) => tag.toLowerCase().contains(needle));
  }
}
