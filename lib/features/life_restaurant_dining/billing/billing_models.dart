enum BillingPhraseKind { payment, tipping, feedback }

enum PaymentSplitMode { together, separate }

enum PaymentMethod { cash, card }

final class BillingPhrase {
  const BillingPhrase({
    required this.id,
    required this.kind,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final BillingPhraseKind kind;
  final String german;
  final String arabic;
  final String contextDe;
  final String contextAr;
  final List<String> keywords;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return <String>[
      german,
      arabic,
      contextDe,
      contextAr,
      ...keywords,
    ].join(' ').toLowerCase().contains(needle);
  }
}
