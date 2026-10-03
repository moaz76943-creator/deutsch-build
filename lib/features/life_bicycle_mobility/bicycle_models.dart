enum BicycleDomain {
  all,
  purchaseMaintenance,
  trafficRules;

  String get labelDe => switch (this) {
        BicycleDomain.all => 'Alle Bereiche',
        BicycleDomain.purchaseMaintenance => 'Kauf & Werkstatt',
        BicycleDomain.trafficRules => 'Verkehr & Sicherheit',
      };

  String get labelAr => switch (this) {
        BicycleDomain.all => 'كل الأقسام',
        BicycleDomain.purchaseMaintenance => 'الشراء والصيانة',
        BicycleDomain.trafficRules => 'المرور والسلامة',
      };
}

enum BicycleRouteId {
  purchaseMaintenance,
  trafficRules,
}

final class BicycleRouteDescriptor {
  const BicycleRouteDescriptor({
    required this.id,
    required this.domain,
    required this.routeName,
    required this.titleDe,
    required this.titleAr,
    required this.descriptionDe,
    required this.descriptionAr,
    this.searchTerms = const <String>[],
  });

  final BicycleRouteId id;
  final BicycleDomain domain;
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
