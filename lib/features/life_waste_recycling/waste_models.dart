enum WasteCategory { householdSortingPfand, bulkyWasteDepot }

extension WasteCategoryLabels on WasteCategory {
  String get labelDe => switch (this) {
        WasteCategory.householdSortingPfand => 'Mülltrennung & Pfand',
        WasteCategory.bulkyWasteDepot => 'Sperrmüll & Wertstoffhof',
      };

  String get labelAr => switch (this) {
        WasteCategory.householdSortingPfand => 'فرز النفايات والعبوات المرتجعة',
        WasteCategory.bulkyWasteDepot => 'النفايات كبيرة الحجم ومركز التدوير',
      };
}

final class WastePhrase {
  const WastePhrase({
    required this.id,
    required this.category,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final WasteCategory category;
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

final class WasteLookupResult {
  const WasteLookupResult({
    required this.routeDe,
    required this.routeAr,
    required this.noteDe,
    required this.noteAr,
    required this.isKnown,
  });

  final String routeDe;
  final String routeAr;
  final String noteDe;
  final String noteAr;
  final bool isKnown;
}
