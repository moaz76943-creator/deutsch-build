enum FuelPaymentTopic {
  all,
  fuelChoice,
  pumpUse,
  payment,
  receiptHelp;

  String get labelDe => switch (this) {
        FuelPaymentTopic.all => 'Alle Themen',
        FuelPaymentTopic.fuelChoice => 'Kraftstoff wählen',
        FuelPaymentTopic.pumpUse => 'Zapfsäule',
        FuelPaymentTopic.payment => 'Bezahlen',
        FuelPaymentTopic.receiptHelp => 'Beleg & Hilfe',
      };

  String get labelAr => switch (this) {
        FuelPaymentTopic.all => 'كل المواضيع',
        FuelPaymentTopic.fuelChoice => 'اختيار الوقود',
        FuelPaymentTopic.pumpUse => 'استخدام المضخة',
        FuelPaymentTopic.payment => 'الدفع',
        FuelPaymentTopic.receiptHelp => 'الإيصال والمساعدة',
      };
}

final class FuelPaymentPhrase {
  const FuelPaymentPhrase({
    required this.id,
    required this.topic,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final FuelPaymentTopic topic;
  final String german;
  final String arabic;
  final String contextDe;
  final String contextAr;
  final List<String> keywords;

  bool matches(String query) {
    final needle = _normalize(query);
    if (needle.isEmpty) return true;
    return _normalize(<String>[
      topic.labelDe,
      topic.labelAr,
      german,
      arabic,
      contextDe,
      contextAr,
      ...keywords,
    ].join(' ')).contains(needle);
  }

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll('ä', 'a')
      .replaceAll('ö', 'o')
      .replaceAll('ü', 'u')
      .replaceAll('ß', 'ss')
      .replaceAll('ـ', '');
}
