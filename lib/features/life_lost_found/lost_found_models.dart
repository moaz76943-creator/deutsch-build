enum LostFoundDomain { municipal, publicTransit }

enum LostFoundTopic {
  onlineCatalog,
  lossReport,
  ownershipAndFees,
  dbFundservice,
  stationRecovery,
  localTransit,
  finderReward,
}

extension LostFoundDomainLabels on LostFoundDomain {
  String get labelDe => switch (this) {
        LostFoundDomain.municipal => 'Kommunales Fundbüro',
        LostFoundDomain.publicTransit => 'ÖPNV & Bahn',
      };

  String get labelAr => switch (this) {
        LostFoundDomain.municipal => 'مكتب المفقودات البلدي',
        LostFoundDomain.publicTransit => 'المواصلات العامة والقطارات',
      };
}

final class LostFoundItem {
  const LostFoundItem({
    required this.id,
    required this.domain,
    required this.topic,
    required this.titleDe,
    required this.titleAr,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.tags = const <String>[],
  });

  final String id;
  final LostFoundDomain domain;
  final LostFoundTopic topic;
  final String titleDe;
  final String titleAr;
  final String german;
  final String arabic;
  final String contextDe;
  final String contextAr;
  final List<String> tags;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    final haystack = <String>[
      titleDe,
      titleAr,
      german,
      arabic,
      contextDe,
      contextAr,
      ...tags,
    ].join(' ').toLowerCase();

    return haystack.contains(needle);
  }
}

final class ImmediateLostAction {
  const ImmediateLostAction({
    required this.id,
    required this.titleDe,
    required this.titleAr,
    required this.detailAr,
  });

  final String id;
  final String titleDe;
  final String titleAr;
  final String detailAr;
}
