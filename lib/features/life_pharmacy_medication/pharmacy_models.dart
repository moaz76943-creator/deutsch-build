enum PrescriptionKind {
  ePrescription,
  privatePrescription,
  greenRecommendation,
}

extension PrescriptionKindLabels on PrescriptionKind {
  String get labelDe => switch (this) {
        PrescriptionKind.ePrescription => 'E-Rezept',
        PrescriptionKind.privatePrescription => 'Privatrezept',
        PrescriptionKind.greenRecommendation => 'Grünes Rezept',
      };

  String get labelAr => switch (this) {
        PrescriptionKind.ePrescription => 'الوصفة الإلكترونية',
        PrescriptionKind.privatePrescription => 'الوصفة الخاصة',
        PrescriptionKind.greenRecommendation => 'الوصفة الخضراء (توصية)',
      };
}

enum MedicationForm {
  tablet,
  capsule,
  drops,
  syrup,
  ointment,
  inhalation,
}

extension MedicationFormLabels on MedicationForm {
  String get labelDe => switch (this) {
        MedicationForm.tablet => 'Tablette',
        MedicationForm.capsule => 'Kapsel',
        MedicationForm.drops => 'Tropfen',
        MedicationForm.syrup => 'Saft',
        MedicationForm.ointment => 'Salbe',
        MedicationForm.inhalation => 'Inhalation',
      };

  String get labelAr => switch (this) {
        MedicationForm.tablet => 'قرص',
        MedicationForm.capsule => 'كبسولة',
        MedicationForm.drops => 'قطرات',
        MedicationForm.syrup => 'شراب',
        MedicationForm.ointment => 'مرهم',
        MedicationForm.inhalation => 'استنشاق',
      };
}

final class DoseInstruction {
  const DoseInstruction({
    required this.amountText,
    required this.frequencyText,
    required this.timingText,
  });

  final String amountText;
  final String frequencyText;
  final String timingText;

  String get summaryDe => '$amountText · $frequencyText · $timingText';
}

enum PharmacyHubSection {
  prescriptions,
  otcConsultation,
  dosageAndSafety,
}

extension PharmacyHubSectionLabels on PharmacyHubSection {
  String get labelDe => switch (this) {
        PharmacyHubSection.prescriptions => 'Rezepte & Abgabe',
        PharmacyHubSection.otcConsultation => 'Rezeptfrei & Beratung',
        PharmacyHubSection.dosageAndSafety => 'Dosierung & Sicherheit',
      };

  String get labelAr => switch (this) {
        PharmacyHubSection.prescriptions => 'الوصفات والصرف',
        PharmacyHubSection.otcConsultation => 'دون وصفة والاستشارة',
        PharmacyHubSection.dosageAndSafety => 'الجرعة والسلامة',
      };
}

final class PharmacyHubCard {
  const PharmacyHubCard({
    required this.id,
    required this.section,
    required this.titleDe,
    required this.titleAr,
    required this.bodyDe,
    required this.bodyAr,
    this.keywords = const <String>[],
  });

  final String id;
  final PharmacyHubSection section;
  final String titleDe;
  final String titleAr;
  final String bodyDe;
  final String bodyAr;
  final List<String> keywords;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    return <String>[
      id,
      titleDe,
      titleAr,
      bodyDe,
      bodyAr,
      section.labelDe,
      section.labelAr,
      ...keywords,
    ].join(' ').toLowerCase().contains(needle);
  }
}
