enum FurnitureService { store, curbside, apartment, transporter }

final class FurnitureShoppingScenario {
  const FurnitureShoppingScenario({
    required this.id,
    required this.service,
    required this.titleDe,
    required this.titleAr,
    required this.german,
    required this.arabic,
    this.keywords = const <String>[],
  });

  final String id;
  final FurnitureService service;
  final String titleDe;
  final String titleAr;
  final String german;
  final String arabic;
  final List<String> keywords;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    final haystack = <String>[
      titleDe,
      titleAr,
      german,
      arabic,
      ...keywords,
    ].join(' ').toLowerCase();
    return haystack.contains(needle);
  }
}

final class FurnitureDimensions {
  const FurnitureDimensions({
    required this.heightCm,
    required this.widthCm,
    required this.depthCm,
  });

  final double heightCm;
  final double widthCm;
  final double depthCm;

  String get labelDe =>
      'Höhe ${_fmt(heightCm)} cm · Breite ${_fmt(widthCm)} cm · Tiefe ${_fmt(depthCm)} cm';

  static String _fmt(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}
