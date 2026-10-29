import '../postal_models.dart';

enum PackstationScenario {
  packstation,
  deliveryProblems;

  String get labelDe => switch (this) {
        PackstationScenario.packstation => 'Packstation',
        PackstationScenario.deliveryProblems => 'Zustellung & Retoure',
      };

  String get labelAr => switch (this) {
        PackstationScenario.packstation => 'ماكينة الطرود',
        PackstationScenario.deliveryProblems => 'التسليم والإرجاع',
      };
}

final class PackstationPhrase {
  const PackstationPhrase({
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
  final PackstationScenario scenario;
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
