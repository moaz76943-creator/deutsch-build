enum OutdoorsCategory {
  accommodation,
  natureHiking,
}

enum OutdoorsTopic {
  hostelBooking,
  familyRoom,
  breakfast,
  houseRules,
  checkInOut,
  trailMarkers,
  trailEtiquette,
  barbecueArea,
  natureReserve,
}

extension OutdoorsCategoryLabels on OutdoorsCategory {
  String get germanLabel => switch (this) {
        OutdoorsCategory.accommodation => 'Unterkunft',
        OutdoorsCategory.natureHiking => 'Natur & Wandern',
      };

  String get arabicLabel => switch (this) {
        OutdoorsCategory.accommodation => 'الإقامة',
        OutdoorsCategory.natureHiking => 'الطبيعة والمشي',
      };
}

extension OutdoorsTopicLabels on OutdoorsTopic {
  String get germanLabel => switch (this) {
        OutdoorsTopic.hostelBooking => 'Jugendherberge buchen',
        OutdoorsTopic.familyRoom => 'Familienzimmer',
        OutdoorsTopic.breakfast => 'Frühstück',
        OutdoorsTopic.houseRules => 'Hausordnung',
        OutdoorsTopic.checkInOut => 'Check-in & Check-out',
        OutdoorsTopic.trailMarkers => 'Wegmarkierungen',
        OutdoorsTopic.trailEtiquette => 'Wanderregeln',
        OutdoorsTopic.barbecueArea => 'Grillplätze',
        OutdoorsTopic.natureReserve => 'Naturschutzgebiet',
      };

  String get arabicLabel => switch (this) {
        OutdoorsTopic.hostelBooking => 'حجز بيت شباب',
        OutdoorsTopic.familyRoom => 'غرفة عائلية',
        OutdoorsTopic.breakfast => 'الإفطار',
        OutdoorsTopic.houseRules => 'قواعد المكان',
        OutdoorsTopic.checkInOut => 'الدخول والمغادرة',
        OutdoorsTopic.trailMarkers => 'علامات المسار',
        OutdoorsTopic.trailEtiquette => 'آداب المشي',
        OutdoorsTopic.barbecueArea => 'أماكن الشواء',
        OutdoorsTopic.natureReserve => 'المحمية الطبيعية',
      };
}

final class OutdoorsPhrase {
  const OutdoorsPhrase({
    required this.id,
    required this.category,
    required this.topic,
    required this.titleDe,
    required this.textDe,
    required this.explanationAr,
    this.tags = const <String>[],
  });

  final String id;
  final OutdoorsCategory category;
  final OutdoorsTopic topic;
  final String titleDe;
  final String textDe;
  final String explanationAr;
  final List<String> tags;
}

final class TrailRule {
  const TrailRule({
    required this.id,
    required this.german,
    required this.arabic,
  });

  final String id;
  final String german;
  final String arabic;
}
