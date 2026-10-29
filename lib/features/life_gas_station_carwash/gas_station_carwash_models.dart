enum GasStationDomain {
  all,
  fuelPayment,
  automaticWash;

  String get labelDe => switch (this) {
        GasStationDomain.all => 'Alle Bereiche',
        GasStationDomain.fuelPayment => 'Tanken & Bezahlen',
        GasStationDomain.automaticWash => 'Autowäsche',
      };

  String get labelAr => switch (this) {
        GasStationDomain.all => 'كل الأقسام',
        GasStationDomain.fuelPayment => 'الوقود والدفع',
        GasStationDomain.automaticWash => 'غسيل السيارة',
      };
}

enum GasStationRouteId {
  fuelPayment,
  automaticWash,
}

final class GasStationRouteDescriptor {
  const GasStationRouteDescriptor({
    required this.id,
    required this.domain,
    required this.routeName,
    required this.titleDe,
    required this.titleAr,
    required this.descriptionDe,
    required this.descriptionAr,
    this.searchTerms = const <String>[],
  });

  final GasStationRouteId id;
  final GasStationDomain domain;
  final String routeName;
  final String titleDe;
  final String titleAr;
  final String descriptionDe;
  final String descriptionAr;
  final List<String> searchTerms;

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
