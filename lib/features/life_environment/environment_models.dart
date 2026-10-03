enum EnvironmentCategory { severeWeather, gardeningBalcony }

enum UrgentWeatherKind { unwetter, glaette }

extension EnvironmentCategoryLabels on EnvironmentCategory {
  String get labelDe => switch (this) {
        EnvironmentCategory.severeWeather => 'Unwetter & Warnungen',
        EnvironmentCategory.gardeningBalcony => 'Garten & Balkon',
      };

  String get labelAr => switch (this) {
        EnvironmentCategory.severeWeather => 'الطقس والتحذيرات',
        EnvironmentCategory.gardeningBalcony => 'الحديقة والشرفة',
      };
}

final class EnvironmentUrgentAlert {
  const EnvironmentUrgentAlert({
    required this.kind,
    required this.titleDe,
    required this.titleAr,
    required this.scriptDe,
    required this.scriptAr,
  });

  final UrgentWeatherKind kind;
  final String titleDe;
  final String titleAr;
  final String scriptDe;
  final String scriptAr;
}

final class EnvironmentEntry {
  const EnvironmentEntry({
    required this.id,
    required this.category,
    required this.titleDe,
    required this.titleAr,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.sourceLabel,
    this.keywords = const <String>[],
  });

  final String id;
  final EnvironmentCategory category;
  final String titleDe;
  final String titleAr;
  final String german;
  final String arabic;
  final String contextDe;
  final String contextAr;
  final String? sourceLabel;
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
      if (sourceLabel != null) sourceLabel!,
      ...keywords,
    ].join(' ').toLowerCase();

    return haystack.contains(needle);
  }
}
