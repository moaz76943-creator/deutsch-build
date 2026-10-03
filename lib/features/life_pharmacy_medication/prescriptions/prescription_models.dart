enum PrescriptionChannel {
  ePrescription,
  privatePrescription,
  greenRecommendation,
}

extension PrescriptionChannelLabels on PrescriptionChannel {
  String get labelDe => switch (this) {
        PrescriptionChannel.ePrescription => 'E-Rezept',
        PrescriptionChannel.privatePrescription => 'Privatrezept',
        PrescriptionChannel.greenRecommendation =>
          'Grünes Rezept · Empfehlung',
      };

  String get labelAr => switch (this) {
        PrescriptionChannel.ePrescription => 'الوصفة الإلكترونية',
        PrescriptionChannel.privatePrescription => 'الوصفة الخاصة',
        PrescriptionChannel.greenRecommendation =>
          'الوصفة الخضراء · توصية',
      };
}

final class PrescriptionPhrase {
  const PrescriptionPhrase({
    required this.id,
    required this.channel,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final PrescriptionChannel channel;
  final String german;
  final String arabic;
  final String contextDe;
  final String contextAr;
  final List<String> keywords;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    return <String>[
      id,
      channel.labelDe,
      channel.labelAr,
      german,
      arabic,
      contextDe,
      contextAr,
      ...keywords,
    ].join(' ').toLowerCase().contains(needle);
  }
}
