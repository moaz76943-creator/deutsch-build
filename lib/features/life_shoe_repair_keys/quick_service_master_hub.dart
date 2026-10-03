enum QuickServiceCategory {
  shoeRepair,
  keyService,
}

extension QuickServiceCategoryLabels on QuickServiceCategory {
  String get labelDe => switch (this) {
        QuickServiceCategory.shoeRepair => 'Schuhreparatur',
        QuickServiceCategory.keyService => 'Schlüsselservice',
      };

  String get labelAr => switch (this) {
        QuickServiceCategory.shoeRepair => 'تصليح الأحذية',
        QuickServiceCategory.keyService => 'خدمة المفاتيح',
      };
}

enum QuickServiceUrgency {
  normal,
  sameDay,
  urgentLockout,
}

extension QuickServiceUrgencyLabels on QuickServiceUrgency {
  String get labelDe => switch (this) {
        QuickServiceUrgency.normal => 'Normal',
        QuickServiceUrgency.sameDay => 'Heute',
        QuickServiceUrgency.urgentLockout => 'Dringend',
      };

  String get labelAr => switch (this) {
        QuickServiceUrgency.normal => 'عادي',
        QuickServiceUrgency.sameDay => 'اليوم',
        QuickServiceUrgency.urgentLockout => 'عاجل',
      };
}

final class QuickServicePhrase {
  const QuickServicePhrase({
    required this.id,
    required this.category,
    required this.topicDe,
    required this.topicAr,
    required this.german,
    required this.arabic,
    this.tags = const <String>[],
  });

  final String id;
  final QuickServiceCategory category;
  final String topicDe;
  final String topicAr;
  final String german;
  final String arabic;
  final List<String> tags;
}

final class QuickServiceMasterHub {
  QuickServiceMasterHub({required Iterable<QuickServicePhrase> entries})
      : _entries = List<QuickServicePhrase>.unmodifiable(entries);

  final List<QuickServicePhrase> _entries;
  final Set<QuickServiceCategory> _selected = <QuickServiceCategory>{
    QuickServiceCategory.shoeRepair,
    QuickServiceCategory.keyService,
  };

  String _query = '';
  QuickServiceUrgency _urgency = QuickServiceUrgency.normal;

  String get query => _query;
  QuickServiceUrgency get urgency => _urgency;
  Set<QuickServiceCategory> get selected =>
      Set<QuickServiceCategory>.unmodifiable(_selected);

  List<QuickServicePhrase> get visibleEntries {
    final q = _normalize(_query);
    return List<QuickServicePhrase>.unmodifiable(
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

  void toggleCategory(QuickServiceCategory category) {
    if (_selected.contains(category)) {
      _selected.remove(category);
    } else {
      _selected.add(category);
    }
  }

  void setUrgency(QuickServiceUrgency value) => _urgency = value;

  String get urgencyPromptDe => switch (_urgency) {
        QuickServiceUrgency.normal =>
          'Wann wäre die Reparatur oder Anfertigung voraussichtlich fertig?',
        QuickServiceUrgency.sameDay =>
          'Wäre eine Fertigstellung noch heute möglich, und kostet der Expressservice extra?',
        QuickServiceUrgency.urgentLockout =>
          'Ich bin ausgesperrt. Können Sie mir bitte den Gesamtpreis inklusive Anfahrt vorab nennen?',
      };

  String get urgencyPromptAr => switch (_urgency) {
        QuickServiceUrgency.normal =>
          'متى يُتوقع أن تكون عملية الإصلاح أو التجهيز جاهزة؟',
        QuickServiceUrgency.sameDay =>
          'هل يمكن إنهاء الخدمة اليوم، وهل توجد رسوم إضافية للخدمة السريعة؟',
        QuickServiceUrgency.urgentLockout =>
          'أنا خارج المنزل ولا أستطيع الدخول. هل يمكنكم إخباري بالسعر الإجمالي مع أجرة الوصول مسبقاً؟',
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
