enum DrogerieCategory {
  householdCleaning,
  personalCare,
  loyalty;

  String get german => switch (this) {
        DrogerieCategory.householdCleaning => 'Haushalt & Reinigung',
        DrogerieCategory.personalCare => 'Körperpflege',
        DrogerieCategory.loyalty => 'Kundenkarte & Vorteile',
      };

  String get arabic => switch (this) {
        DrogerieCategory.householdCleaning => 'المنظفات المنزلية',
        DrogerieCategory.personalCare => 'العناية الشخصية',
        DrogerieCategory.loyalty => 'النقاط والكوبونات',
      };
}

enum DrogerieBrand {
  neutral,
  dm,
  rossmann;

  String get label => switch (this) {
        DrogerieBrand.neutral => 'Drogeriemarkt',
        DrogerieBrand.dm => 'dm',
        DrogerieBrand.rossmann => 'ROSSMANN',
      };
}

final class DrogeriePhrase {
  const DrogeriePhrase({
    required this.id,
    required this.category,
    required this.german,
    required this.arabic,
    required this.tags,
    this.brand = DrogerieBrand.neutral,
  });

  final String id;
  final DrogerieCategory category;
  final String german;
  final String arabic;
  final List<String> tags;
  final DrogerieBrand brand;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return german.toLowerCase().contains(needle) ||
        arabic.toLowerCase().contains(needle) ||
        brand.label.toLowerCase().contains(needle) ||
        tags.any((tag) => tag.toLowerCase().contains(needle));
  }
}
