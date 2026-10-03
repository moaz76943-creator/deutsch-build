enum SecondhandDomain { fleaMarketsAndAds, donationAndSocialStores }

extension SecondhandDomainLabels on SecondhandDomain {
  String get labelDe => switch (this) {
        SecondhandDomain.fleaMarketsAndAds => 'Flohmarkt & Kleinanzeigen',
        SecondhandDomain.donationAndSocialStores =>
          'Sozialkaufhaus & Kleidercontainer',
      };

  String get labelAr => switch (this) {
        SecondhandDomain.fleaMarketsAndAds => 'أسواق المستعمل والإعلانات المحلية',
        SecondhandDomain.donationAndSocialStores =>
          'المتاجر الاجتماعية وحاويات الملابس',
      };
}

final class SecondhandBargainingTip {
  const SecondhandBargainingTip({
    required this.german,
    required this.arabic,
  });

  final String german;
  final String arabic;
}

final class SecondhandEntry {
  const SecondhandEntry({
    required this.id,
    required this.domain,
    required this.titleDe,
    required this.titleAr,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final SecondhandDomain domain;
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

    final haystack = <String>[
      titleDe,
      titleAr,
      german,
      arabic,
      contextDe,
      contextAr,
      ...keywords,
    ].join(' ').toLowerCase();

    return haystack.contains(needle);
  }
}
