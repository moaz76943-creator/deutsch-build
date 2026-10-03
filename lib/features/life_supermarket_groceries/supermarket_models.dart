enum GroceryDietFlag {
  vegan,
  glutenFree,
  halalCertified,
  containsPork,
}

extension GroceryDietFlagLabels on GroceryDietFlag {
  String get labelDe => switch (this) {
        GroceryDietFlag.vegan => 'Vegan',
        GroceryDietFlag.glutenFree => 'Glutenfrei',
        GroceryDietFlag.halalCertified => 'Halal-zertifiziert',
        GroceryDietFlag.containsPork => 'Enthält Schweinefleisch',
      };

  String get labelAr => switch (this) {
        GroceryDietFlag.vegan => 'نباتي بالكامل',
        GroceryDietFlag.glutenFree => 'خالٍ من الغلوتين',
        GroceryDietFlag.halalCertified => 'معتمد حلال',
        GroceryDietFlag.containsPork => 'يحتوي على مشتقات الخنزير',
      };
}

final class GroceryProduct {
  const GroceryProduct({
    required this.id,
    required this.nameDe,
    required this.nameAr,
    required this.aisleDe,
    required this.aisleAr,
    this.ingredientNoteDe = '',
    this.ingredientNoteAr = '',
    this.dietaryFlags = const <GroceryDietFlag>{},
  });

  final String id;
  final String nameDe;
  final String nameAr;
  final String aisleDe;
  final String aisleAr;
  final String ingredientNoteDe;
  final String ingredientNoteAr;
  final Set<GroceryDietFlag> dietaryFlags;

  bool matches(String query) {
    final needle = _normalize(query);
    if (needle.isEmpty) return true;

    final haystack = _normalize(
      <String>[
        nameDe,
        nameAr,
        aisleDe,
        aisleAr,
        ingredientNoteDe,
        ingredientNoteAr,
        ...dietaryFlags.map((flag) => flag.labelDe),
        ...dietaryFlags.map((flag) => flag.labelAr),
      ].join(' '),
    );
    return haystack.contains(needle);
  }
}

final class GroceryOffer {
  const GroceryOffer({
    required this.id,
    required this.productId,
    required this.labelDe,
    required this.labelAr,
    required this.priceEuro,
    required this.unitLabel,
  });

  final String id;
  final String productId;
  final String labelDe;
  final String labelAr;
  final double priceEuro;
  final String unitLabel;

  bool matches(String query) {
    final needle = _normalize(query);
    if (needle.isEmpty) return true;
    return _normalize('$labelDe $labelAr $unitLabel').contains(needle);
  }
}

final class ReceiptLine {
  const ReceiptLine({
    required this.label,
    required this.quantity,
    required this.unitPriceEuro,
  });

  final String label;
  final int quantity;
  final double unitPriceEuro;

  double get total => quantity * unitPriceEuro;
}

final class Kassenbon {
  const Kassenbon({
    required this.id,
    required this.lines,
  });

  final String id;
  final List<ReceiptLine> lines;

  double get total => lines.fold<double>(
        0,
        (sum, line) => sum + line.total,
      );
}

final class SupermarketModuleRoute {
  const SupermarketModuleRoute({
    required this.id,
    required this.labelDe,
    required this.labelAr,
    required this.relativePath,
  });

  final String id;
  final String labelDe;
  final String labelAr;
  final String relativePath;
}

String _normalize(String value) {
  var normalized = value.toLowerCase();
  normalized = normalized
      .replaceAll('ä', 'a')
      .replaceAll('ö', 'o')
      .replaceAll('ü', 'u')
      .replaceAll('ß', 'ss');
  normalized = normalized.replaceAll(RegExp(r'[^a-z0-9ء-ي ]'), ' ');
  return normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
}
