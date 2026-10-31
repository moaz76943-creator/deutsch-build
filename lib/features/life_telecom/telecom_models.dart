enum TelecomDomain {
  homeInternet,
  mobilePrepaid,
}

extension TelecomDomainLabels on TelecomDomain {
  String get labelDe => switch (this) {
        TelecomDomain.homeInternet => 'Internet zu Hause · DSL/Glasfaser',
        TelecomDomain.mobilePrepaid => 'Mobilfunk & Prepaid',
      };

  String get labelAr => switch (this) {
        TelecomDomain.homeInternet => 'إنترنت المنزل · DSL/ألياف',
        TelecomDomain.mobilePrepaid => 'الهاتف المحمول والدفع المسبق',
      };
}

final class TelecomPhrase {
  const TelecomPhrase({
    required this.id,
    required this.domain,
    required this.topicDe,
    required this.topicAr,
    required this.german,
    required this.arabic,
    this.keywords = const <String>[],
  });

  final String id;
  final TelecomDomain domain;
  final String topicDe;
  final String topicAr;
  final String german;
  final String arabic;
  final List<String> keywords;

  bool matches(String query) {
    final needle = _normalize(query);
    if (needle.isEmpty) return true;

    final searchable = _normalize(
      <String>[
        topicDe,
        topicAr,
        german,
        arabic,
        ...keywords,
      ].join(' '),
    );
    return searchable.contains(needle);
  }

  static String _normalize(String value) {
    var normalized = value.toLowerCase();
    normalized = normalized
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ß', 'ss');
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9ء-ي ]'), ' ');
    return normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

final class NetworkOutageStep {
  const NetworkOutageStep({
    required this.german,
    required this.arabic,
  });

  final String german;
  final String arabic;
}

final class NetworkOutagePrompt {
  const NetworkOutagePrompt({
    required this.german,
    required this.arabic,
  });

  final String german;
  final String arabic;
}
