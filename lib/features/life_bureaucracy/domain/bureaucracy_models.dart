enum BureaucracyCategory {
  cityRegistration,
  immigrationOffice,
}

enum BureaucracyIntent {
  registrationAppointment,
  housingConfirmation,
  certificateRequest,
  residencePermitExtension,
  biometricPhoto,
  statusInquiry,
}

enum BureaucracyRegister {
  formalSie,
}

extension BureaucracyCategoryLabels on BureaucracyCategory {
  String get germanLabel => switch (this) {
        BureaucracyCategory.cityRegistration => 'Bürgeramt & Anmeldung',
        BureaucracyCategory.immigrationOffice => 'Ausländerbehörde',
      };

  String get arabicLabel => switch (this) {
        BureaucracyCategory.cityRegistration => 'مكتب المواطنين وتسجيل السكن',
        BureaucracyCategory.immigrationOffice => 'دائرة شؤون الأجانب',
      };
}

extension BureaucracyRegisterLabels on BureaucracyRegister {
  String get germanLabel => switch (this) {
        BureaucracyRegister.formalSie => 'Sie-Form',
      };

  String get arabicLabel => switch (this) {
        BureaucracyRegister.formalSie => 'صيغة رسمية مهذبة',
      };
}

final class OfficialDocument {
  const OfficialDocument({
    required this.id,
    required this.nameDe,
    required this.nameAr,
    required this.noteAr,
  });

  final String id;
  final String nameDe;
  final String nameAr;
  final String noteAr;
}

final class BureaucracyGuide {
  const BureaucracyGuide({
    required this.id,
    required this.category,
    required this.intent,
    required this.register,
    required this.titleDe,
    required this.titleAr,
    required this.phraseDe,
    required this.phraseAr,
    required this.explanationAr,
    required this.documents,
  });

  final String id;
  final BureaucracyCategory category;
  final BureaucracyIntent intent;
  final BureaucracyRegister register;
  final String titleDe;
  final String titleAr;
  final String phraseDe;
  final String phraseAr;
  final String explanationAr;
  final List<OfficialDocument> documents;

  bool matches(String normalizedQuery) {
    if (normalizedQuery.isEmpty) return true;

    final haystack = <String>[
      id,
      titleDe,
      titleAr,
      phraseDe,
      phraseAr,
      explanationAr,
      category.germanLabel,
      category.arabicLabel,
      register.germanLabel,
      register.arabicLabel,
      for (final document in documents) ...<String>[
        document.nameDe,
        document.nameAr,
        document.noteAr,
      ],
    ].join(' ').toLowerCase();

    return haystack.contains(normalizedQuery);
  }
}

final class ChecklistSnapshot {
  ChecklistSnapshot({
    required List<OfficialDocument> documents,
    required Set<String> readyDocumentIds,
  })  : documents = List<OfficialDocument>.unmodifiable(documents),
        readyDocumentIds = Set<String>.unmodifiable(readyDocumentIds);

  final List<OfficialDocument> documents;
  final Set<String> readyDocumentIds;

  List<OfficialDocument> get missingDocuments => List<OfficialDocument>.unmodifiable(
        documents.where(
          (document) => !readyDocumentIds.contains(document.id),
        ),
      );

  int get readyCount =>
      documents.where((document) => readyDocumentIds.contains(document.id)).length;

  bool get isReady => documents.isNotEmpty && readyCount == documents.length;
}
