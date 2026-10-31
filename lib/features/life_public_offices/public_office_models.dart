enum PublicOfficeType {
  all,
  buergeramt,
  auslaenderbehoerde,
  finanzamt;

  String get labelDe => switch (this) {
        PublicOfficeType.all => 'Alle Behörden',
        PublicOfficeType.buergeramt => 'Bürgeramt',
        PublicOfficeType.auslaenderbehoerde => 'Ausländerbehörde',
        PublicOfficeType.finanzamt => 'Finanzamt',
      };

  String get labelAr => switch (this) {
        PublicOfficeType.all => 'كل الدوائر',
        PublicOfficeType.buergeramt => 'مكتب شؤون المواطنين',
        PublicOfficeType.auslaenderbehoerde => 'دائرة شؤون الأجانب',
        PublicOfficeType.finanzamt => 'دائرة الضرائب',
      };
}

enum OfficialDocumentKind {
  identity,
  registrationCertificate,
  applicationForm,
  certifiedCopy,
  powerOfAttorney,
  taxDocument;

  String get labelDe => switch (this) {
        OfficialDocumentKind.identity => 'Identitätsnachweis',
        OfficialDocumentKind.registrationCertificate => 'Meldeunterlage',
        OfficialDocumentKind.applicationForm => 'Antragsformular',
        OfficialDocumentKind.certifiedCopy => 'Beglaubigte Kopie',
        OfficialDocumentKind.powerOfAttorney => 'Vollmacht',
        OfficialDocumentKind.taxDocument => 'Steuerunterlage',
      };

  String get labelAr => switch (this) {
        OfficialDocumentKind.identity => 'إثبات الهوية',
        OfficialDocumentKind.registrationCertificate => 'وثيقة تسجيل السكن',
        OfficialDocumentKind.applicationForm => 'استمارة طلب',
        OfficialDocumentKind.certifiedCopy => 'نسخة مصدقة',
        OfficialDocumentKind.powerOfAttorney => 'وكالة رسمية',
        OfficialDocumentKind.taxDocument => 'وثيقة ضريبية',
      };
}

final class OfficialDocument {
  const OfficialDocument({
    required this.id,
    required this.titleDe,
    required this.titleAr,
    required this.kind,
    required this.applicableOffices,
    this.required = true,
    this.noteDe,
    this.noteAr,
  });

  final String id;
  final String titleDe;
  final String titleAr;
  final OfficialDocumentKind kind;
  final List<PublicOfficeType> applicableOffices;
  final bool required;
  final String? noteDe;
  final String? noteAr;

  bool matchesOffice(PublicOfficeType office) {
    return office == PublicOfficeType.all || applicableOffices.contains(office);
  }
}

final class OfficialAppointment {
  const OfficialAppointment({
    required this.id,
    required this.office,
    required this.purposeDe,
    required this.purposeAr,
    this.reference,
    this.dateLabel,
    this.statusDe,
    this.statusAr,
  });

  final String id;
  final PublicOfficeType office;
  final String purposeDe;
  final String purposeAr;
  final String? reference;
  final String? dateLabel;
  final String? statusDe;
  final String? statusAr;
}

enum PublicOfficeRouteId {
  anmeldungAppointments,
  formsDocuments,
}

final class PublicOfficeRouteDescriptor {
  const PublicOfficeRouteDescriptor({
    required this.id,
    required this.routeName,
    required this.titleDe,
    required this.titleAr,
    required this.descriptionDe,
    required this.descriptionAr,
    required this.supportedOffices,
    this.searchTerms = const <String>[],
  });

  final PublicOfficeRouteId id;
  final String routeName;
  final String titleDe;
  final String titleAr;
  final String descriptionDe;
  final String descriptionAr;
  final List<PublicOfficeType> supportedOffices;
  final List<String> searchTerms;

  bool supportsOffice(PublicOfficeType office) {
    return office == PublicOfficeType.all || supportedOffices.contains(office);
  }

  bool matches(String query) {
    final needle = _normalize(query);
    if (needle.isEmpty) return true;
    return _normalize(<String>[
      titleDe,
      titleAr,
      descriptionDe,
      descriptionAr,
      ...searchTerms,
    ].join(' ')).contains(needle);
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ß', 'ss')
        .replaceAll('ـ', '');
  }
}

abstract interface class PublicOfficeModuleDependency {
  PublicOfficeRouteDescriptor get route;

  Iterable<OfficialDocument> get documents;
}
