enum RentHousingSection { contractAndCosts, handoverAndDefects }

extension RentHousingSectionLabels on RentHousingSection {
  String get labelDe => switch (this) {
        RentHousingSection.contractAndCosts => 'Mietvertrag & Nebenkosten',
        RentHousingSection.handoverAndDefects => 'Übergabe & Mängel',
      };

  String get labelAr => switch (this) {
        RentHousingSection.contractAndCosts => 'عقد الإيجار والتكاليف',
        RentHousingSection.handoverAndDefects => 'التسليم والعيوب',
      };
}

final class RentHousingEntry {
  const RentHousingEntry({
    required this.id,
    required this.section,
    required this.titleDe,
    required this.titleAr,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final RentHousingSection section;
  final String titleDe;
  final String titleAr;
  final String german;
  final String arabic;
  final String contextDe;
  final String contextAr;
  final List<String> keywords;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    return <String>[
      titleDe,
      titleAr,
      german,
      arabic,
      contextDe,
      contextAr,
      ...keywords,
    ].join(' ').toLowerCase().contains(needle);
  }
}

final class RentContractRecord {
  const RentContractRecord({
    required this.kaltmiete,
    required this.nebenkostenAdvance,
    required this.heatingAdvance,
    required this.kaution,
    this.currencyCode = 'EUR',
  });

  final double kaltmiete;
  final double nebenkostenAdvance;
  final double heatingAdvance;
  final double kaution;
  final String currencyCode;

  double get monthlyPlannedOutlay =>
      kaltmiete + nebenkostenAdvance + heatingAdvance;
}

final class NebenkostenItem {
  const NebenkostenItem({
    required this.labelDe,
    required this.labelAr,
    required this.amount,
  });

  final String labelDe;
  final String labelAr;
  final double amount;
}

final class MeterReading {
  const MeterReading({
    required this.labelDe,
    required this.value,
  });

  final String labelDe;
  final String value;
}

final class HandoverProtocolRecord {
  const HandoverProtocolRecord({
    required this.addressLabel,
    required this.meterReadings,
    required this.keysCount,
    required this.notes,
  });

  final String addressLabel;
  final List<MeterReading> meterReadings;
  final int keysCount;
  final String notes;
}
