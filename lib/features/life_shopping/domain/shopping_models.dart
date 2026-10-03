enum ShoppingLevel {
  a1a2,
  b1,
  b2,
}

extension ShoppingLevelLabels on ShoppingLevel {
  String get germanLabel => switch (this) {
        ShoppingLevel.a1a2 => 'A1 / A2',
        ShoppingLevel.b1 => 'B1',
        ShoppingLevel.b2 => 'B2',
      };

  String get arabicLabel => switch (this) {
        ShoppingLevel.a1a2 => 'أساسي A1/A2',
        ShoppingLevel.b1 => 'متوسط B1',
        ShoppingLevel.b2 => 'متقدم B2',
      };
}

enum ShoppingAgentType {
  grocery,
  returnWarranty,
}

extension ShoppingAgentTypeLabels on ShoppingAgentType {
  String get germanLabel => switch (this) {
        ShoppingAgentType.grocery => 'Supermarkt & Lebensmittel',
        ShoppingAgentType.returnWarranty => 'Umtausch & Reklamation',
      };

  String get arabicLabel => switch (this) {
        ShoppingAgentType.grocery => 'السوبرماركت والمواد الغذائية',
        ShoppingAgentType.returnWarranty => 'الاستبدال والشكاوى والضمان',
      };
}

final class ShoppingPhrase {
  const ShoppingPhrase({
    required this.id,
    required this.level,
    required this.agent,
    required this.german,
    required this.arabic,
    required this.usageArabic,
    required this.searchTags,
    this.isPanicPhrase = false,
  });

  final String id;
  final ShoppingLevel level;
  final ShoppingAgentType agent;
  final String german;
  final String arabic;
  final String usageArabic;
  final List<String> searchTags;
  final bool isPanicPhrase;

  bool matches(String query) {
    final normalized = normalizeShoppingSearch(query);
    if (normalized.isEmpty) return true;

    final searchable = <String>[
      german,
      arabic,
      usageArabic,
      ...searchTags,
    ].map(normalizeShoppingSearch);

    return searchable.any((value) => value.contains(normalized));
  }
}

abstract interface class ShoppingSubAgent {
  ShoppingAgentType get type;

  List<ShoppingPhrase> get phrases;

  List<ShoppingPhrase> search(
    String query, {
    ShoppingLevel? level,
  });

  List<ShoppingPhrase> get panicPhrases;
}

String normalizeShoppingSearch(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[.!?,;:()\[\]{}"“”„]'), '')
    .replaceAll(RegExp(r'\s+'), ' ');
