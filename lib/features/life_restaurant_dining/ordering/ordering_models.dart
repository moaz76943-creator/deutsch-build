enum OrderingStage { reservationSeating, menuOrdering }

enum SeatingPreference { indoor, outdoor, any }

extension SeatingPreferenceLabels on SeatingPreference {
  String get german => switch (this) {
        SeatingPreference.indoor => 'drinnen',
        SeatingPreference.outdoor => 'draußen',
        SeatingPreference.any => 'egal ob drinnen oder draußen',
      };

  String get arabic => switch (this) {
        SeatingPreference.indoor => 'في الداخل',
        SeatingPreference.outdoor => 'في الخارج',
        SeatingPreference.any => 'لا فرق بين الداخل والخارج',
      };
}

final class ReservationPlan {
  const ReservationPlan({
    required this.partySize,
    this.seating = SeatingPreference.any,
  }) : assert(partySize > 0);

  final int partySize;
  final SeatingPreference seating;
}

final class OrderingPhrase {
  const OrderingPhrase({
    required this.id,
    required this.stage,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final OrderingStage stage;
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
