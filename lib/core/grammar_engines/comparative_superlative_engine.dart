import 'grammar_engine_models.dart';

final class ComparativeSuperlativeEngine {
  const ComparativeSuperlativeEngine();

  static const Map<String, ({String comparative, String superStem})>
      _irregular = <String, ({String comparative, String superStem})>{
    'gut': (comparative: 'besser', superStem: 'best'),
    'viel': (comparative: 'mehr', superStem: 'meist'),
    'gern': (comparative: 'lieber', superStem: 'liebst'),
    'hoch': (comparative: 'höher', superStem: 'höchst'),
    'nah': (comparative: 'näher', superStem: 'nächst'),
    'groß': (comparative: 'größer', superStem: 'größt'),
    'wenig': (comparative: 'weniger', superStem: 'wenigst'),
  };

  static const Map<String, String> _umlautBases = <String, String>{
    'alt': 'ält',
    'arm': 'ärm',
    'dumm': 'dümm',
    'gesund': 'gesünd',
    'hart': 'härt',
    'kalt': 'kält',
    'krank': 'kränk',
    'kurz': 'kürz',
    'lang': 'läng',
    'jung': 'jüng',
    'klug': 'klüg',
    'scharf': 'schärf',
    'schwach': 'schwäch',
    'stark': 'stärk',
    'warm': 'wärm',
  };

  static const Map<String, String> _contractedComparatives = <String, String>{
    'dunkel': 'dunkler',
    'edel': 'edler',
    'teuer': 'teurer',
    'sauer': 'saurer',
  };

  ComparisonForms formsFor(String adjective) {
    final positive = _normalizeAdjective(adjective);
    final irregular = _irregular[positive];
    if (irregular != null) {
      return ComparisonForms(
        positive: positive,
        comparative: irregular.comparative,
        superlativeStem: irregular.superStem,
        adverbialSuperlative: 'am ${irregular.superStem}en',
        ruleLabelAr: 'صيغة غير منتظمة يجب حفظها كوحدة واحدة.',
      );
    }

    final umlautBase = _umlautBases[positive];
    final comparative = _contractedComparatives[positive] ??
        _regularComparative(positive, umlautBase ?? positive);
    final superBase = umlautBase ?? positive;
    final superStem = '$superBase${_needsEpentheticE(superBase) ? 'est' : 'st'}';

    return ComparisonForms(
      positive: positive,
      comparative: comparative,
      superlativeStem: superStem,
      adverbialSuperlative: 'am ${superStem}en',
      ruleLabelAr: _ruleLabel(
        umlauted: umlautBase != null,
        contracted: _contractedComparatives.containsKey(positive),
        epentheticE: _needsEpentheticE(superBase),
      ),
    );
  }

  String formFor(
    String adjective,
    ComparisonPattern pattern, {
    String attributiveEnding = 'e',
  }) {
    final forms = formsFor(adjective);
    return switch (pattern) {
      ComparisonPattern.equality => forms.positive,
      ComparisonPattern.comparative => forms.comparative,
      ComparisonPattern.superlative =>
        '${forms.superlativeStem}${_validateEnding(attributiveEnding)}',
    };
  }

  String adverbialFormFor(
    String adjective,
    ComparisonPattern pattern,
  ) {
    final forms = formsFor(adjective);
    return switch (pattern) {
      ComparisonPattern.equality => forms.positive,
      ComparisonPattern.comparative => forms.comparative,
      ComparisonPattern.superlative => forms.adverbialSuperlative,
    };
  }

  String connectorFor(ComparisonPattern pattern) => switch (pattern) {
        ComparisonPattern.equality => 'wie',
        ComparisonPattern.comparative => 'als',
        ComparisonPattern.superlative => '',
      };

  bool validateForm({
    required String adjective,
    required ComparisonPattern pattern,
    required String candidate,
    bool adverbial = true,
    String attributiveEnding = 'e',
  }) {
    final expected = adverbial
        ? adverbialFormFor(adjective, pattern)
        : formFor(
            adjective,
            pattern,
            attributiveEnding: attributiveEnding,
          );
    return normalizeGermanInput(candidate) ==
        normalizeGermanInput(expected);
  }

  bool validateConnector({
    required ComparisonPattern pattern,
    required String candidate,
  }) {
    if (pattern == ComparisonPattern.superlative) {
      return candidate.trim().isEmpty;
    }
    return normalizeGermanInput(candidate) ==
        connectorFor(pattern);
  }

  String buildComparisonSentence({
    required String subject,
    required String adjective,
    required String reference,
    required ComparisonPattern pattern,
    String copula = 'ist',
  }) {
    final cleanSubject = _cleanPhrase(subject);
    final cleanReference = _cleanPhrase(reference);
    final cleanCopula = _cleanPhrase(copula);
    if (cleanSubject.isEmpty || cleanCopula.isEmpty) {
      throw ArgumentError(
        'subject and copula must contain visible text.',
      );
    }

    if (pattern == ComparisonPattern.superlative) {
      return '$cleanSubject $cleanCopula '
          '${adverbialFormFor(adjective, pattern)}.';
    }

    if (cleanReference.isEmpty) {
      throw ArgumentError(
        'reference is required for equality and comparative sentences.',
      );
    }

    final form = adverbialFormFor(adjective, pattern);
    final connector = connectorFor(pattern);
    final intensifier =
        pattern == ComparisonPattern.equality ? 'genauso ' : '';
    return '$cleanSubject $cleanCopula $intensifier$form '
        '$connector $cleanReference.';
  }

  List<GrammarTrainingItem> generateExamples({
    required int seed,
    int count = 6,
    ComparisonPattern? pattern,
  }) {
    if (count <= 0) return const <GrammarTrainingItem>[];
    return List<GrammarTrainingItem>.generate(
      count,
      (index) => generateTrainingItem(
        seed: seed + index * 19,
        pattern: pattern,
      ),
      growable: false,
    );
  }

  GrammarTrainingItem generateTrainingItem({
    required int seed,
    ComparisonPattern? pattern,
  }) {
    final selectedPattern = pattern ??
        ComparisonPattern.values[_index(seed, ComparisonPattern.values.length)];
    const scenarios = <({
      String adjective,
      String subject,
      String reference,
      String prompt,
    })>[
      (
        adjective: 'schnell',
        subject: 'Der Zug',
        reference: 'der Bus',
        prompt: 'قارن سرعة القطار بالحافلة',
      ),
      (
        adjective: 'groß',
        subject: 'Berlin',
        reference: 'Bonn',
        prompt: 'قارن الحجم',
      ),
      (
        adjective: 'teuer',
        subject: 'Dieses Hotel',
        reference: 'die Pension',
        prompt: 'قارن السعر',
      ),
      (
        adjective: 'gut',
        subject: 'Diese Lösung',
        reference: 'die erste Lösung',
        prompt: 'قارن الجودة',
      ),
      (
        adjective: 'kalt',
        subject: 'Der Januar',
        reference: 'der März',
        prompt: 'قارن درجة البرودة',
      ),
      (
        adjective: 'breit',
        subject: 'Diese Straße',
        reference: 'die Nebenstraße',
        prompt: 'قارن العرض',
      ),
      (
        adjective: 'dunkel',
        subject: 'Dieses Zimmer',
        reference: 'der Flur',
        prompt: 'قارن شدة الظلام',
      ),
    ];
    final scenario = scenarios[_index(seed, scenarios.length)];
    final full = buildComparisonSentence(
      subject: scenario.subject,
      adjective: scenario.adjective,
      reference: scenario.reference,
      pattern: selectedPattern,
    );
    final expected = adverbialFormFor(
      scenario.adjective,
      selectedPattern,
    );
    final blank = full.replaceFirst(expected, '___');
    final forms = formsFor(scenario.adjective);
    final alternatives = selectedPattern == ComparisonPattern.equality
        ? <String>[forms.positive]
        : const <String>[];

    return GrammarTrainingItem(
      id: 'cmp_${selectedPattern.name}_${_index(seed, 100000)}',
      category: selectedPattern.labelAr,
      promptAr: scenario.prompt,
      sentenceWithBlank: blank,
      expectedAnswer: expected,
      fullSentence: full,
      explanationAr: _trainingExplanation(
        forms: forms,
        pattern: selectedPattern,
      ),
      acceptedAlternatives: alternatives,
    );
  }

  String _regularComparative(String positive, String transformedBase) {
    if (positive.endsWith('e')) {
      return '${positive}r';
    }
    return '${transformedBase}er';
  }

  bool _needsEpentheticE(String base) {
    const endings = <String>['d', 't', 's', 'ß', 'x', 'z', 'sch'];
    return endings.any(base.endsWith);
  }

  String _validateEnding(String value) {
    final ending = value.trim().toLowerCase();
    const allowed = <String>{'e', 'en', 'em', 'er', 'es'};
    if (!allowed.contains(ending)) {
      throw ArgumentError.value(
        value,
        'attributiveEnding',
        'Expected one of e, en, em, er, es.',
      );
    }
    return ending;
  }

  String _trainingExplanation({
    required ComparisonForms forms,
    required ComparisonPattern pattern,
  }) {
    return switch (pattern) {
      ComparisonPattern.equality =>
        'للمساواة نستخدم genauso/so + الصفة الأساسية + wie. ${forms.ruleLabelAr}',
      ComparisonPattern.comparative =>
        'للمقارنة غير المتساوية نستخدم Komparativ + als: ${forms.comparative} als ... ${forms.ruleLabelAr}',
      ComparisonPattern.superlative =>
        'عند استعمال الصفة خبراً أو ظرفاً نستخدم am + Superlativ + -en: ${forms.adverbialSuperlative}. ${forms.ruleLabelAr}',
    };
  }

  String _ruleLabel({
    required bool umlauted,
    required bool contracted,
    required bool epentheticE,
  }) {
    final notes = <String>[];
    if (umlauted) {
      notes.add('يتغير حرف العلة إلى Umlaut في درجتي المقارنة والتفضيل');
    } else {
      notes.add('تتبع الصفة القاعدة الإنتاجية -er / -(e)st');
    }
    if (contracted) {
      notes.add('تُحذف e داخلية في صيغة المقارنة');
    }
    if (epentheticE) {
      notes.add('تدخل e قبل -st لتسهيل النطق');
    }
    return '${notes.join('؛ ')}.';
  }

  String _normalizeAdjective(String value) {
    final result = value.trim().toLowerCase();
    if (result.isEmpty || result.contains(RegExp(r'\s'))) {
      throw ArgumentError.value(
        value,
        'adjective',
        'Expected one German adjective token.',
      );
    }
    return result;
  }

  String _cleanPhrase(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');

  int _index(int seed, int length) {
    final nonNegative = seed < 0 ? -seed : seed;
    return nonNegative % length;
  }
}
