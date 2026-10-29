enum PetsCategory { veterinary, regulationsAdoption }

extension PetsCategoryLabels on PetsCategory {
  String get labelDe => switch (this) {
        PetsCategory.veterinary => 'Tierarzt',
        PetsCategory.regulationsAdoption => 'Regeln & Tierheim',
      };

  String get labelAr => switch (this) {
        PetsCategory.veterinary => 'الرعاية البيطرية',
        PetsCategory.regulationsAdoption => 'القوانين والتبنّي',
      };
}

final class PetPhrase {
  const PetPhrase({
    required this.id,
    required this.category,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final PetsCategory category;
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
