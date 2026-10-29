enum HomeServicesDomain {
  locksmithEmergency,
  urgentRepairs,
}

extension HomeServicesDomainLabels on HomeServicesDomain {
  String get labelDe => switch (this) {
        HomeServicesDomain.locksmithEmergency =>
          'Schlüsseldienst & Schlüsselnotfall',
        HomeServicesDomain.urgentRepairs =>
          'Heizung & Sanitär-Notdienst',
      };

  String get labelAr => switch (this) {
        HomeServicesDomain.locksmithEmergency =>
          'خدمة الأقفال وطوارئ المفاتيح',
        HomeServicesDomain.urgentRepairs =>
          'طوارئ التدفئة والسباكة',
      };
}

final class HomeServicePhrase {
  const HomeServicePhrase({
    required this.id,
    required this.domain,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final HomeServicesDomain domain;
  final String german;
  final String arabic;
  final String contextDe;
  final String contextAr;
  final List<String> keywords;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    final haystack = <String>[
      german,
      arabic,
      contextDe,
      contextAr,
      ...keywords,
    ].join(' ').toLowerCase();

    return haystack.contains(needle);
  }
}

final class ConsumerProtectionWarning {
  const ConsumerProtectionWarning({
    required this.id,
    required this.german,
    required this.arabic,
  });

  final String id;
  final String german;
  final String arabic;
}
