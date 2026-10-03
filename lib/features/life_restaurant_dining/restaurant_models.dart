enum DiningVenueType { restaurant, cafe, fastFood }

enum MealOption { vegetarian, vegan, glutenFree, halalRequested }

enum BillSplitMode { together, separate }

extension DiningVenueLabels on DiningVenueType {
  String get labelDe => switch (this) {
        DiningVenueType.restaurant => 'Restaurant',
        DiningVenueType.cafe => 'Café',
        DiningVenueType.fastFood => 'Schnellrestaurant',
      };

  String get labelAr => switch (this) {
        DiningVenueType.restaurant => 'مطعم',
        DiningVenueType.cafe => 'مقهى',
        DiningVenueType.fastFood => 'وجبات سريعة',
      };
}

extension MealOptionLabels on MealOption {
  String get labelDe => switch (this) {
        MealOption.vegetarian => 'Vegetarisch',
        MealOption.vegan => 'Vegan',
        MealOption.glutenFree => 'Glutenfrei',
        MealOption.halalRequested => 'Halal erfragen',
      };

  String get labelAr => switch (this) {
        MealOption.vegetarian => 'نباتي',
        MealOption.vegan => 'نباتي بالكامل',
        MealOption.glutenFree => 'خالٍ من الغلوتين',
        MealOption.halalRequested => 'الاستفسار عن الحلال',
      };
}

final class RestaurantMenuItem {
  const RestaurantMenuItem({
    required this.id,
    required this.nameDe,
    required this.nameAr,
    required this.descriptionDe,
    required this.descriptionAr,
    this.options = const <MealOption>{},
    this.keywords = const <String>[],
  });

  final String id;
  final String nameDe;
  final String nameAr;
  final String descriptionDe;
  final String descriptionAr;
  final Set<MealOption> options;
  final List<String> keywords;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return <String>[
      nameDe,
      nameAr,
      descriptionDe,
      descriptionAr,
      ...keywords,
    ].join(' ').toLowerCase().contains(needle);
  }
}

final class BillTipPhrase {
  const BillTipPhrase({
    required this.id,
    required this.german,
    required this.arabic,
    required this.contextDe,
    this.splitMode,
  });

  final String id;
  final String german;
  final String arabic;
  final String contextDe;
  final BillSplitMode? splitMode;
}
