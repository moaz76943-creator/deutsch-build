import '../postal_models.dart';

enum ShippingScenario {
  send,
  pickup;

  String get labelDe => switch (this) {
        ShippingScenario.send => 'Versenden',
        ShippingScenario.pickup => 'Abholen',
      };

  String get labelAr => switch (this) {
        ShippingScenario.send => 'إرسال',
        ShippingScenario.pickup => 'استلام',
      };
}

final class ShippingPhrase {
  const ShippingPhrase({
    required this.id,
    required this.scenario,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    required this.carriers,
    this.keywords = const <String>[],
  });

  final String id;
  final ShippingScenario scenario;
  final String german;
  final String arabic;
  final String contextDe;
  final String contextAr;
  final List<PostalCarrier> carriers;
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
      ...carriers.map((carrier) => carrier.labelDe),
    ].join(' ').toLowerCase().contains(needle);
  }
}
