enum IntercityTravelCategory {
  iceBooking,
  delaySupport,
  bahnCard,
}

extension IntercityTravelCategoryLabels on IntercityTravelCategory {
  String get labelDe => switch (this) {
        IntercityTravelCategory.iceBooking => 'ICE-Buchung',
        IntercityTravelCategory.delaySupport => 'Verspätung & Umstieg',
        IntercityTravelCategory.bahnCard => 'BahnCard',
      };

  String get labelAr => switch (this) {
        IntercityTravelCategory.iceBooking => 'حجز قطارات ICE',
        IntercityTravelCategory.delaySupport => 'التأخير وتبديل القطارات',
        IntercityTravelCategory.bahnCard => 'بطاقة BahnCard',
      };
}

enum JourneySituation {
  planning,
  delayed,
  missedConnection,
  bahnCardQuestion,
}

extension JourneySituationLabels on JourneySituation {
  String get labelDe => switch (this) {
        JourneySituation.planning => 'Reise planen',
        JourneySituation.delayed => 'Zug verspätet',
        JourneySituation.missedConnection => 'Anschluss verpasst',
        JourneySituation.bahnCardQuestion => 'BahnCard-Frage',
      };

  String get labelAr => switch (this) {
        JourneySituation.planning => 'تخطيط الرحلة',
        JourneySituation.delayed => 'القطار متأخر',
        JourneySituation.missedConnection => 'فاتني القطار التالي',
        JourneySituation.bahnCardQuestion => 'استفسار BahnCard',
      };
}

final class IntercityPhrase {
  const IntercityPhrase({
    required this.id,
    required this.category,
    required this.topicDe,
    required this.topicAr,
    required this.german,
    required this.arabic,
    this.tags = const <String>[],
  });

  final String id;
  final IntercityTravelCategory category;
  final String topicDe;
  final String topicAr;
  final String german;
  final String arabic;
  final List<String> tags;
}

final class IntercityTrainTravelMasterHub {
  IntercityTrainTravelMasterHub({required Iterable<IntercityPhrase> entries})
      : _entries = List<IntercityPhrase>.unmodifiable(entries);

  final List<IntercityPhrase> _entries;
  final Set<IntercityTravelCategory> _selected = <IntercityTravelCategory>{
    IntercityTravelCategory.iceBooking,
    IntercityTravelCategory.delaySupport,
    IntercityTravelCategory.bahnCard,
  };

  String _query = '';
  JourneySituation _situation = JourneySituation.planning;

  String get query => _query;
  JourneySituation get situation => _situation;
  Set<IntercityTravelCategory> get selected =>
      Set<IntercityTravelCategory>.unmodifiable(_selected);

  List<IntercityPhrase> get visibleEntries {
    final q = _normalize(_query);
    return List<IntercityPhrase>.unmodifiable(
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

  void toggleCategory(IntercityTravelCategory category) {
    if (_selected.contains(category)) {
      _selected.remove(category);
    } else {
      _selected.add(category);
    }
  }

  void setSituation(JourneySituation value) => _situation = value;

  String get situationPromptDe => switch (_situation) {
        JourneySituation.planning =>
          'Ich möchte eine ICE-Verbindung buchen. Können Sie mir Fahrpreis, Umstiege und Reservierungsoptionen erklären?',
        JourneySituation.delayed =>
          'Mein ICE hat Verspätung. Welche aktuelle Verbindung kann ich für die Weiterfahrt nutzen?',
        JourneySituation.missedConnection =>
          'Wegen der Verspätung habe ich meinen Anschluss verpasst. Welche nächste Verbindung soll ich nehmen?',
        JourneySituation.bahnCardQuestion =>
          'Ich möchte wissen, welche BahnCard zu meinen Fahrten passt und welche Vertragsbedingungen gelten.',
      };

  String get situationPromptAr => switch (_situation) {
        JourneySituation.planning =>
          'أريد حجز رحلة بقطار ICE. هل يمكنكم شرح السعر والتبديلات وخيارات حجز المقعد؟',
        JourneySituation.delayed =>
          'قطار ICE الخاص بي متأخر. ما الرحلة الحالية التي يمكنني استخدامها لمتابعة السفر؟',
        JourneySituation.missedConnection =>
          'بسبب التأخير فاتني القطار التالي. ما الرحلة التالية التي ينبغي أن أستخدمها؟',
        JourneySituation.bahnCardQuestion =>
          'أريد معرفة أي بطاقة BahnCard تناسب رحلاتي وما شروط العقد.',
      };

  static String _normalize(String value) {
    var out = value.toLowerCase()
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ß', 'ss');
    out = out.replaceAll(RegExp(r'[^a-z0-9ء-ي ]'), ' ');
    return out.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
