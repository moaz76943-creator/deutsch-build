enum MobilityLevel { a1a2, b1, b2 }

extension MobilityLevelLabels on MobilityLevel {
  String get label => switch (this) {
        MobilityLevel.a1a2 => 'A1/A2',
        MobilityLevel.b1 => 'B1',
        MobilityLevel.b2 => 'B2',
      };
}

enum MobilityMode { longDistance, localTransit }

extension MobilityModeLabels on MobilityMode {
  String get labelDe => switch (this) {
        MobilityMode.longDistance => 'Deutsche Bahn & Fernverkehr',
        MobilityMode.localTransit => 'ÖPNV: Bus & U-Bahn',
      };

  String get labelAr => switch (this) {
        MobilityMode.longDistance => 'القطارات والسفر بين المدن',
        MobilityMode.localTransit => 'النقل المحلي: الحافلة والمترو',
      };
}

enum MobilityTopic {
  platformChange,
  delay,
  seatReservation,
  localTicket,
  deutschlandticket,
  busConnection,
}

extension MobilityTopicLabels on MobilityTopic {
  String get labelDe => switch (this) {
        MobilityTopic.platformChange => 'Gleiswechsel',
        MobilityTopic.delay => 'Verspätung',
        MobilityTopic.seatReservation => 'Sitzplatzreservierung',
        MobilityTopic.localTicket => 'Fahrkarten vor Ort',
        MobilityTopic.deutschlandticket => 'Deutschlandticket',
        MobilityTopic.busConnection => 'Bus- & U-Bahn-Verbindung',
      };

  String get labelAr => switch (this) {
        MobilityTopic.platformChange => 'تغيير الرصيف',
        MobilityTopic.delay => 'التأخير',
        MobilityTopic.seatReservation => 'حجز المقعد',
        MobilityTopic.localTicket => 'التذاكر المحلية',
        MobilityTopic.deutschlandticket => 'تذكرة ألمانيا',
        MobilityTopic.busConnection => 'وصلات الحافلة والمترو',
      };
}

class MobilityLesson {
  const MobilityLesson({
    required this.id,
    required this.level,
    required this.mode,
    required this.topic,
    required this.titleDe,
    required this.phraseDe,
    required this.meaningAr,
    required this.actionAr,
    this.keywords = const <String>[],
  });

  final String id;
  final MobilityLevel level;
  final MobilityMode mode;
  final MobilityTopic topic;
  final String titleDe;
  final String phraseDe;
  final String meaningAr;
  final String actionAr;
  final List<String> keywords;

  String get searchableText => <String>[
        titleDe,
        phraseDe,
        meaningAr,
        actionAr,
        topic.labelDe,
        topic.labelAr,
        mode.labelDe,
        mode.labelAr,
        ...keywords,
      ].join(' ');
}

class PlatformPanicStep {
  const PlatformPanicStep({
    required this.titleDe,
    required this.instructionAr,
  });

  final String titleDe;
  final String instructionAr;
}
