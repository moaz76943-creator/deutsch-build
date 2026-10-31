enum LaundryDomain {
  selfServiceLaundromat,
  professionalCleaning,
}

extension LaundryDomainLabels on LaundryDomain {
  String get labelDe => switch (this) {
        LaundryDomain.selfServiceLaundromat => 'Waschsalon · Selbstbedienung',
        LaundryDomain.professionalCleaning => 'Reinigung · Bügelservice',
      };

  String get labelAr => switch (this) {
        LaundryDomain.selfServiceLaundromat => 'مغسلة ذاتية الخدمة',
        LaundryDomain.professionalCleaning => 'تنظيف احترافي وكيّ',
      };
}

final class LaundryPhrase {
  const LaundryPhrase({
    required this.id,
    required this.domain,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final LaundryDomain domain;
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

final class FabricCareSymbol {
  const FabricCareSymbol({
    required this.id,
    required this.symbol,
    required this.german,
    required this.arabic,
  });

  final String id;
  final String symbol;
  final String german;
  final String arabic;
}
