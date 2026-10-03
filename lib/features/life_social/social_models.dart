enum SocialTone { du, sie }

enum SocialCategory { neighborhood, occasions }

extension SocialToneLabels on SocialTone {
  String get labelDe => switch (this) {
        SocialTone.du => 'Du',
        SocialTone.sie => 'Sie',
      };

  String get labelAr => switch (this) {
        SocialTone.du => 'غير رسمي',
        SocialTone.sie => 'رسمي',
      };
}

extension SocialCategoryLabels on SocialCategory {
  String get labelDe => switch (this) {
        SocialCategory.neighborhood => 'Nachbarschaft',
        SocialCategory.occasions => 'Anlässe',
      };

  String get labelAr => switch (this) {
        SocialCategory.neighborhood => 'الجيرة',
        SocialCategory.occasions => 'المناسبات',
      };
}

final class SocialPhrase {
  const SocialPhrase({
    required this.id,
    required this.category,
    required this.germanDu,
    required this.germanSie,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.keywords = const <String>[],
  });

  final String id;
  final SocialCategory category;
  final String germanDu;
  final String germanSie;
  final String arabic;
  final String contextDe;
  final String contextAr;
  final List<String> keywords;

  String germanFor(SocialTone tone) => switch (tone) {
        SocialTone.du => germanDu,
        SocialTone.sie => germanSie,
      };

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    final haystack = <String>[
      germanDu,
      germanSie,
      arabic,
      contextDe,
      contextAr,
      ...keywords,
    ].join(' ').toLowerCase();

    return haystack.contains(needle);
  }
}
