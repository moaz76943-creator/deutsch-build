enum UtilitiesCategory {
  meterReadingsInvoices,
  contractsSwitching,
}

extension UtilitiesCategoryLabels on UtilitiesCategory {
  String get labelDe => switch (this) {
        UtilitiesCategory.meterReadingsInvoices =>
          'Zählerstände & Rechnungen',
        UtilitiesCategory.contractsSwitching =>
          'Verträge & Anbieterwechsel',
      };

  String get labelAr => switch (this) {
        UtilitiesCategory.meterReadingsInvoices =>
          'قراءات العدادات والفواتير',
        UtilitiesCategory.contractsSwitching =>
          'العقود وتغيير المزوّد',
      };
}

final class UtilitiesPhrase {
  const UtilitiesPhrase({
    required this.id,
    required this.category,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final UtilitiesCategory category;
  final String german;
  final String arabic;
  final String contextDe;
  final String contextAr;
  final List<String> keywords;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    final haystack = <String>[
      id,
      german,
      arabic,
      contextDe,
      contextAr,
      category.labelDe,
      category.labelAr,
      ...keywords,
    ].join(' ').toLowerCase();

    return haystack.contains(needle);
  }
}
