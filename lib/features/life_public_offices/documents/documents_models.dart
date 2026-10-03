enum DocumentsTopic {
  all,
  formFilling,
  identityProof,
  certification,
  powerOfAttorney,
  missingDocuments;

  String get labelDe => switch (this) {
        DocumentsTopic.all => 'Alle Themen',
        DocumentsTopic.formFilling => 'Antrag ausfüllen',
        DocumentsTopic.identityProof => 'Identitätsnachweis',
        DocumentsTopic.certification => 'Beglaubigung',
        DocumentsTopic.powerOfAttorney => 'Vollmacht',
        DocumentsTopic.missingDocuments => 'Nachreichen',
      };

  String get labelAr => switch (this) {
        DocumentsTopic.all => 'كل المواضيع',
        DocumentsTopic.formFilling => 'تعبئة الطلب',
        DocumentsTopic.identityProof => 'إثبات الهوية',
        DocumentsTopic.certification => 'تصديق الأوراق',
        DocumentsTopic.powerOfAttorney => 'الوكالة',
        DocumentsTopic.missingDocuments => 'استكمال المستندات',
      };
}

final class DocumentsPhrase {
  const DocumentsPhrase({
    required this.id,
    required this.topic,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final DocumentsTopic topic;
  final String german;
  final String arabic;
  final String contextDe;
  final String contextAr;
  final List<String> keywords;

  bool matches(String query) {
    final needle = _normalize(query);
    if (needle.isEmpty) return true;

    return _normalize(<String>[
      topic.labelDe,
      topic.labelAr,
      german,
      arabic,
      contextDe,
      contextAr,
      ...keywords,
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
