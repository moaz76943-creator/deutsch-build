enum TravelAgencyCategory {
  flights,
  hotels,
  holidays,
}

extension TravelAgencyCategoryLabels on TravelAgencyCategory {
  String get labelDe => switch (this) {
        TravelAgencyCategory.flights => 'Flüge',
        TravelAgencyCategory.hotels => 'Hotels',
        TravelAgencyCategory.holidays => 'Urlaubspakete',
      };

  String get labelAr => switch (this) {
        TravelAgencyCategory.flights => 'تذاكر الطيران',
        TravelAgencyCategory.hotels => 'الفنادق',
        TravelAgencyCategory.holidays => 'العطلات والباقات',
      };
}

final class TravelAgencyPhrase {
  const TravelAgencyPhrase({
    required this.id,
    required this.category,
    required this.topicDe,
    required this.topicAr,
    required this.german,
    required this.arabic,
    this.tags = const <String>[],
  });

  final String id;
  final TravelAgencyCategory category;
  final String topicDe;
  final String topicAr;
  final String german;
  final String arabic;
  final List<String> tags;
}

final class TripRequestSummary {
  const TripRequestSummary({
    required this.destination,
    required this.travellers,
    required this.flexibleDates,
  });

  final String destination;
  final int travellers;
  final bool flexibleDates;

  String get german =>
      'Reiseziel: ${destination.isEmpty ? 'noch offen' : destination} · Reisende: $travellers · Flexible Daten: ${flexibleDates ? 'ja' : 'nein'}';

  String get arabic =>
      'الوجهة: ${destination.isEmpty ? 'غير محددة بعد' : destination} · المسافرون: $travellers · التواريخ المرنة: ${flexibleDates ? 'نعم' : 'لا'}';
}

final class TravelAgencyMasterHub {
  TravelAgencyMasterHub({required Iterable<TravelAgencyPhrase> entries})
      : _entries = List<TravelAgencyPhrase>.unmodifiable(entries);

  final List<TravelAgencyPhrase> _entries;
  final Set<TravelAgencyCategory> _selected = <TravelAgencyCategory>{
    TravelAgencyCategory.flights,
    TravelAgencyCategory.hotels,
    TravelAgencyCategory.holidays,
  };

  String _query = '';
  String _destination = '';
  int _travellers = 1;
  bool _flexibleDates = false;

  String get query => _query;
  Set<TravelAgencyCategory> get selected =>
      Set<TravelAgencyCategory>.unmodifiable(_selected);

  TripRequestSummary get tripSummary => TripRequestSummary(
        destination: _destination,
        travellers: _travellers,
        flexibleDates: _flexibleDates,
      );

  List<TravelAgencyPhrase> get visibleEntries {
    final q = _normalize(_query);
    return List<TravelAgencyPhrase>.unmodifiable(
      _entries.where((entry) {
        if (!_selected.contains(entry.category)) return false;
        if (q.isEmpty) return true;
        final text = _normalize(<String>[
          entry.topicDe,
          entry.topicAr,
          entry.german,
          entry.arabic,
          ...entry.tags,
        ].join(' '));
        return text.contains(q);
      }),
    );
  }

  void setQuery(String value) => _query = value.trim();

  void toggleCategory(TravelAgencyCategory category) {
    if (_selected.contains(category)) {
      _selected.remove(category);
    } else {
      _selected.add(category);
    }
  }

  void setDestination(String value) => _destination = value.trim();

  void setTravellers(int value) => _travellers = value.clamp(1, 9);

  void toggleFlexibleDates() => _flexibleDates = !_flexibleDates;

  static String _normalize(String value) {
    var out = value.toLowerCase()
      ..replaceAll('ä', 'a')
      ..replaceAll('ö', 'o')
      ..replaceAll('ü', 'u')
      ..replaceAll('ß', 'ss');
    out = out
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ß', 'ss');
    out = out.replaceAll(RegExp(r'[^a-z0-9ء-ي ]'), ' ');
    return out.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
