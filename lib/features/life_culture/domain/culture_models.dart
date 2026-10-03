enum CultureDomain {
  publicLibrary,
  adultEducation,
}

enum CultureIntent {
  libraryCardIssuance,
  libraryCardRenewal,
  loanExtension,
  digitalMediaOnleihe,
  studyRoomEtiquette,
  vhsCourseRegistration,
  scheduleInquiry,
  materialsInquiry,
  attendanceCertificate,
}

extension CultureDomainLabels on CultureDomain {
  String get germanLabel => switch (this) {
        CultureDomain.publicLibrary => 'Stadtbibliothek',
        CultureDomain.adultEducation => 'Volkshochschule (VHS)',
      };

  String get arabicLabel => switch (this) {
        CultureDomain.publicLibrary => 'المكتبة العامة',
        CultureDomain.adultEducation => 'تعليم الكبار (VHS)',
      };
}

final class CultureGuide {
  const CultureGuide({
    required this.id,
    required this.domain,
    required this.intent,
    required this.titleDe,
    required this.titleAr,
    required this.phraseDe,
    required this.phraseAr,
    required this.noteAr,
    this.searchTerms = const <String>[],
  });

  final String id;
  final CultureDomain domain;
  final CultureIntent intent;
  final String titleDe;
  final String titleAr;
  final String phraseDe;
  final String phraseAr;
  final String noteAr;
  final List<String> searchTerms;

  bool matches(String normalizedQuery) {
    if (normalizedQuery.isEmpty) return true;

    final haystack = <String>[
      id,
      titleDe,
      titleAr,
      phraseDe,
      phraseAr,
      noteAr,
      domain.germanLabel,
      domain.arabicLabel,
      ...searchTerms,
    ].join(' ').toLowerCase();

    return haystack.contains(normalizedQuery);
  }
}
