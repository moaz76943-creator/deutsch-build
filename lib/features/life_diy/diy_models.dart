enum DiyDomain { materialsHardware, servicesRental }

enum DiyLengthUnit { millimeter, centimeter, meter }

extension DiyDomainLabels on DiyDomain {
  String get labelDe => switch (this) {
        DiyDomain.materialsHardware => 'Material & Beschläge',
        DiyDomain.servicesRental => 'Service & Geräteverleih',
      };

  String get labelAr => switch (this) {
        DiyDomain.materialsHardware => 'مواد وأدوات تثبيت',
        DiyDomain.servicesRental => 'خدمات وتأجير معدات',
      };
}

extension DiyLengthUnitLabels on DiyLengthUnit {
  String get symbol => switch (this) {
        DiyLengthUnit.millimeter => 'mm',
        DiyLengthUnit.centimeter => 'cm',
        DiyLengthUnit.meter => 'm',
      };

  double get metersPerUnit => switch (this) {
        DiyLengthUnit.millimeter => 0.001,
        DiyLengthUnit.centimeter => 0.01,
        DiyLengthUnit.meter => 1,
      };
}

final class DiyPhrase {
  const DiyPhrase({
    required this.id,
    required this.domain,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final DiyDomain domain;
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

final class DiySizingPrompt {
  const DiySizingPrompt({
    required this.german,
    required this.arabic,
  });

  final String german;
  final String arabic;
}
