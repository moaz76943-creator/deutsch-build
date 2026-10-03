enum ElectronicsDomain {
  all,
  specificationsWarranty,
  serviceRepair;

  String get labelDe => switch (this) {
        ElectronicsDomain.all => 'Alle Bereiche',
        ElectronicsDomain.specificationsWarranty => 'Beratung & Garantie',
        ElectronicsDomain.serviceRepair => 'Service & Reparatur',
      };

  String get labelAr => switch (this) {
        ElectronicsDomain.all => 'كل الأقسام',
        ElectronicsDomain.specificationsWarranty => 'المواصفات والكفالة',
        ElectronicsDomain.serviceRepair => 'الصيانة والإصلاح',
      };
}

enum ElectronicsRouteId {
  specificationsWarranty,
  serviceRepair,
}

final class ElectronicsRouteDescriptor {
  const ElectronicsRouteDescriptor({
    required this.id,
    required this.domain,
    required this.routeName,
    required this.titleDe,
    required this.titleAr,
    required this.descriptionDe,
    required this.descriptionAr,
    this.searchTerms = const <String>[],
  });

  final ElectronicsRouteId id;
  final ElectronicsDomain domain;
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
