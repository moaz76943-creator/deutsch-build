import 'grammar_engine_models.dart';

final class KonjunktivIiEngine {
  const KonjunktivIiEngine();

  static const List<String> _endings = <String>[
    'e', 'est', 'e', 'en', 'et', 'en',
  ];

  static const List<String> _wuerdeForms = <String>[
    'würde', 'würdest', 'würde', 'würden', 'würdet', 'würden',
  ];

  static const Map<String, List<String>> _specialParadigms =
      <String, List<String>>{
    'sein': <String>['wäre', 'wärst', 'wäre', 'wären', 'wärt', 'wären'],
  };

  static const Set<String> _defaultSyntheticVerbs = <String>{
    'sein', 'haben', 'werden', 'können', 'müssen', 'dürfen',
    'sollen', 'wollen', 'mögen', 'wissen', 'brauchen',
  };

  static const Map<String, String> _syntheticStems = <String, String>{
    'sein': 'wär',
    'haben': 'hätt',
    'werden': 'würd',
    'können': 'könnt',
    'müssen': 'müsst',
    'dürfen': 'dürft',
    'sollen': 'sollt',
    'wollen': 'wollt',
    'mögen': 'möcht',
    'wissen': 'wüsst',
    'brauchen': 'bräucht',
    'kommen': 'käm',
    'gehen': 'ging',
    'fahren': 'führ',
    'finden': 'fänd',
    'geben': 'gäb',
    'nehmen': 'nähm',
    'lassen': 'ließ',
    'bleiben': 'blieb',
    'stehen': 'stünd',
    'tun': 'tät',
    'sehen': 'säh',
    'sprechen': 'spräch',
    'helfen': 'hülf',
    'schreiben': 'schrieb',
    'lesen': 'läs',
    'schlafen': 'schlief',
    'tragen': 'trüg',
    'essen': 'äß',
  };

  KonjunktivForm conjugate(
    String infinitive,
    GermanPerson person, {
    bool forceSynthetic = false,
  }) {
    final verb = _normalizeInfinitive(infinitive);
    final special = _specialParadigms[verb];
    final stem = _syntheticStems[verb];
    final useSynthetic = forceSynthetic || _defaultSyntheticVerbs.contains(verb);

    if (useSynthetic && special != null) {
      final surface = special[person.paradigmIndex];
      return KonjunktivForm(
        infinitive: verb,
        person: person,
        surface: surface,
        construction: KonjunktivConstruction.synthetic,
        explanationAr:
            'هذه صيغة Konjunktiv II أصلية شائعة للفعل $verb، وتُستخدم مباشرة دون würde.',
      );
    }

    if (useSynthetic && stem != null) {
      final surface = '${stem}${_endings[person.paradigmIndex]}';
      return KonjunktivForm(
        infinitive: verb,
        person: person,
        surface: surface,
        construction: KonjunktivConstruction.synthetic,
        explanationAr:
            'هذه صيغة Konjunktiv II أصلية شائعة للفعل $verb، لذلك تُفضّل على würde + Infinitiv في الاستعمال الطبيعي.',
      );
    }

    final finiteWuerde = _wuerdeForms[person.paradigmIndex];
    return KonjunktivForm(
      infinitive: verb,
      person: person,
      surface: '$finiteWuerde $verb',
      construction: KonjunktivConstruction.wuerdeInfinitive,
      explanationAr:
          'يُستخدم $finiteWuerde مع المصدر $verb لأن würde + Infinitiv هو البناء العملي الواضح لهذا الفعل.',
    );
  }

  bool validateForm({
    required String infinitive,
    required GermanPerson person,
    required String candidate,
    bool forceSynthetic = false,
  }) {
    final expected = conjugate(
      infinitive,
      person,
      forceSynthetic: forceSynthetic,
    );
    return normalizeGermanInput(candidate) ==
        normalizeGermanInput(expected.surface);
  }

  String buildPreference({
    String nounPhrase = '',
    GermanPerson person = GermanPerson.ich,
    String infinitive = 'haben',
  }) {
    final verb = _normalizeInfinitive(infinitive);
    final complement = _cleanPhrase(nounPhrase);
    final form = conjugate(verb, person);
    final subject = person.sentenceSubject;

    if (form.construction == KonjunktivConstruction.synthetic) {
      return _sentence(
        '$subject ${form.surface} gern'
        '${complement.isEmpty ? '' : ' $complement'}',
      );
    }

    final finite = _wuerdeForms[person.paradigmIndex];
    return _sentence(
      '$subject $finite gern'
      '${complement.isEmpty ? '' : ' $complement'} $verb',
    );
  }

  String buildWish({
    required GermanPerson person,
    required String infinitive,
    required String complement,
    bool withGern = true,
  }) {
    final verb = _normalizeInfinitive(infinitive);
    final cleanComplement = _cleanPhrase(complement);
    final form = conjugate(verb, person);
    final subject = person.sentenceSubject;
    final gern = withGern ? ' gern' : '';

    if (form.construction == KonjunktivConstruction.synthetic) {
      return _sentence(
        '$subject ${form.surface}$gern'
        '${cleanComplement.isEmpty ? '' : ' $cleanComplement'}',
      );
    }

    final finite = _wuerdeForms[person.paradigmIndex];
    return _sentence(
      '$subject $finite$gern'
      '${cleanComplement.isEmpty ? '' : ' $cleanComplement'} $verb',
    );
  }

  String buildPoliteRequest({
    required String infinitive,
    required String complement,
    bool formal = true,
    bool abilityStyle = false,
    bool includeBitte = true,
  }) {
    final verb = _normalizeInfinitive(infinitive);
    final cleanComplement = _cleanPhrase(complement);
    final person = formal ? GermanPerson.sieFormal : GermanPerson.du;
    final subject = person.pronoun;
    final finite = abilityStyle
        ? conjugate('können', person).surface
        : _wuerdeForms[person.paradigmIndex];
    final leading = _capitalize(finite);
    final middle = <String>[
      if (cleanComplement.isNotEmpty) cleanComplement,
      if (includeBitte) 'bitte',
    ].join(' ');

    return '$leading $subject'
        '${middle.isEmpty ? '' : ' $middle'} $verb?';
  }

  String buildHypothetical({
    required GermanPerson conditionPerson,
    required String conditionInfinitive,
    required String conditionComplement,
    required GermanPerson resultPerson,
    required String resultInfinitive,
    required String resultComplement,
  }) {
    final conditionVerb = _normalizeInfinitive(conditionInfinitive);
    final resultVerb = _normalizeInfinitive(resultInfinitive);
    final conditionForm = conjugate(conditionVerb, conditionPerson);
    final resultForm = conjugate(resultVerb, resultPerson);
    final cleanCondition = _cleanPhrase(conditionComplement);
    final conditionTail = _subordinateTail(conditionForm);
    final resultClause = _mainClause(
      form: resultForm,
      complement: _cleanPhrase(resultComplement),
    );

    return 'Wenn ${conditionPerson.pronoun}'
        '${cleanCondition.isEmpty ? '' : ' $cleanCondition'}'
        ' $conditionTail, $resultClause.';
  }

  String buildAdvice({
    required String infinitive,
    required String complement,
    bool formalAddressee = false,
  }) {
    final verb = _normalizeInfinitive(infinitive);
    final cleanComplement = _cleanPhrase(complement);
    final opening = formalAddressee ? 'An Ihrer Stelle' : 'An deiner Stelle';
    return _sentence(
      '$opening würde ich'
      '${cleanComplement.isEmpty ? '' : ' $cleanComplement'} $verb',
    );
  }

  GrammarTrainingItem generateTrainingItem({
    required int seed,
    KonjunktivUsage? usage,
  }) {
    final selectedUsage =
        usage ?? KonjunktivUsage.values[_index(seed, KonjunktivUsage.values.length)];
    return switch (selectedUsage) {
      KonjunktivUsage.politeRequest => _politeRequestItem(seed),
      KonjunktivUsage.wish => _wishItem(seed),
      KonjunktivUsage.hypotheticalCondition => _hypotheticalItem(seed),
      KonjunktivUsage.advice => _adviceItem(seed),
    };
  }

  List<GrammarTrainingItem> generateExamples({
    required int seed,
    int count = 6,
    KonjunktivUsage? usage,
  }) {
    if (count <= 0) return const <GrammarTrainingItem>[];
    return List<GrammarTrainingItem>.generate(
      count,
      (index) => generateTrainingItem(
        seed: seed + index * 17,
        usage: usage,
      ),
      growable: false,
    );
  }

  GrammarTrainingItem _politeRequestItem(int seed) {
    const scenarios = <({String verb, String complement, bool ability, String ar})>[
      (verb: 'bringen', complement: 'mir die Rechnung', ability: false, ar: 'اطلب الفاتورة بلطف'),
      (verb: 'helfen', complement: 'mir', ability: true, ar: 'اطلب المساعدة بصيغة مهذبة'),
      (verb: 'schließen', complement: 'das Fenster', ability: false, ar: 'اطلب إغلاق النافذة بلطف'),
      (verb: 'erklären', complement: 'mir den Weg', ability: true, ar: 'اطلب شرح الطريق بلطف'),
    ];
    final item = scenarios[_index(seed, scenarios.length)];
    final full = buildPoliteRequest(
      infinitive: item.verb,
      complement: item.complement,
      abilityStyle: item.ability,
    );
    final expected = full.split(' ').first;
    final blank = full.replaceFirst(expected, '___');

    return GrammarTrainingItem(
      id: 'k2_request_${_index(seed, 100000)}',
      category: KonjunktivUsage.politeRequest.labelAr,
      promptAr: item.ar,
      sentenceWithBlank: blank,
      expectedAnswer: expected,
      fullSentence: full,
      explanationAr: item.ability
          ? 'في الطلب المهذب مع Sie نستخدم könnten + فاعل + بقية الجملة، ثم يأتي المصدر في النهاية.'
          : 'würden + Sie تخفف مباشرة الطلب، ويبقى الفعل الأساسي في صيغة المصدر في النهاية.',
    );
  }

  GrammarTrainingItem _wishItem(int seed) {
    const scenarios = <({String verb, String complement, String ar})>[
      (verb: 'haben', complement: 'mehr Zeit', ar: 'تمنَّ وقتاً أكثر'),
      (verb: 'sein', complement: 'am Meer', ar: 'تمنَّ أن تكون عند البحر'),
      (verb: 'bleiben', complement: 'länger', ar: 'عبّر عن رغبتك بالبقاء مدة أطول'),
      (verb: 'reisen', complement: 'öfter', ar: 'عبّر عن رغبتك بالسفر أكثر'),
    ];
    final item = scenarios[_index(seed, scenarios.length)];
    final full = buildWish(
      person: GermanPerson.ich,
      infinitive: item.verb,
      complement: item.complement,
    );
    final parts = full.split(' ');
    final expected = parts.length > 1 ? parts[1] : '';
    final blank = full.replaceFirst(expected, '___');

    return GrammarTrainingItem(
      id: 'k2_wish_${_index(seed, 100000)}',
      category: KonjunktivUsage.wish.labelAr,
      promptAr: item.ar,
      sentenceWithBlank: blank,
      expectedAnswer: expected,
      fullSentence: full,
      explanationAr: conjugate(item.verb, GermanPerson.ich).explanationAr,
    );
  }

  GrammarTrainingItem _hypotheticalItem(int seed) {
    const scenarios = <({
      String conditionVerb,
      String conditionComplement,
      String resultVerb,
      String resultComplement,
      String ar,
    })>[
      (
        conditionVerb: 'haben',
        conditionComplement: 'mehr Zeit',
        resultVerb: 'reisen',
        resultComplement: 'öfter',
        ar: 'لو كان لدي وقت أكثر لسافرت أكثر',
      ),
      (
        conditionVerb: 'sein',
        conditionComplement: 'näher',
        resultVerb: 'kommen',
        resultComplement: 'jeden Tag',
        ar: 'لو كنت أقرب لأتيت كل يوم',
      ),
      (
        conditionVerb: 'können',
        conditionComplement: 'früher gehen',
        resultVerb: 'helfen',
        resultComplement: 'dir danach',
        ar: 'لو استطعت المغادرة أبكر لساعدتك بعدها',
      ),
    ];
    final item = scenarios[_index(seed, scenarios.length)];
    final full = buildHypothetical(
      conditionPerson: GermanPerson.ich,
      conditionInfinitive: item.conditionVerb,
      conditionComplement: item.conditionComplement,
      resultPerson: GermanPerson.ich,
      resultInfinitive: item.resultVerb,
      resultComplement: item.resultComplement,
    );
    final condition = conjugate(item.conditionVerb, GermanPerson.ich);
    final expected = condition.construction == KonjunktivConstruction.synthetic
        ? condition.surface
        : _wuerdeForms[GermanPerson.ich.paradigmIndex];
    final blank = full.replaceFirst(expected, '___');

    return GrammarTrainingItem(
      id: 'k2_hyp_${_index(seed, 100000)}',
      category: KonjunktivUsage.hypotheticalCondition.labelAr,
      promptAr: item.ar,
      sentenceWithBlank: blank,
      expectedAnswer: expected,
      fullSentence: full,
      explanationAr:
          'في جملة wenn يذهب الجزء المصرف إلى نهاية الجملة الفرعية؛ وفي الجملة الرئيسية يبقى الفعل المصرف في الموقع الثاني.',
    );
  }

  GrammarTrainingItem _adviceItem(int seed) {
    const scenarios = <({String verb, String complement, String ar})>[
      (verb: 'lernen', complement: 'jeden Tag etwas', ar: 'انصح بالدراسة يومياً'),
      (verb: 'schlafen', complement: 'mehr', ar: 'انصح بالنوم أكثر'),
      (verb: 'sprechen', complement: 'öfter Deutsch', ar: 'انصح بالتحدث بالألمانية أكثر'),
      (verb: 'machen', complement: 'regelmäßig eine Pause', ar: 'انصح بأخذ استراحة بانتظام'),
    ];
    final item = scenarios[_index(seed, scenarios.length)];
    final full = buildAdvice(
      infinitive: item.verb,
      complement: item.complement,
    );
    final blank = full.replaceFirst('würde', '___');

    return GrammarTrainingItem(
      id: 'k2_advice_${_index(seed, 100000)}',
      category: KonjunktivUsage.advice.labelAr,
      promptAr: item.ar,
      sentenceWithBlank: blank,
      expectedAnswer: 'würde',
      fullSentence: full,
      explanationAr:
          'An deiner Stelle + würde ich + Infinitiv صيغة شائعة لتقديم نصيحة دون تحويلها إلى أمر مباشر.',
    );
  }

  String _subordinateTail(KonjunktivForm form) {
    if (form.construction == KonjunktivConstruction.synthetic) {
      return form.surface;
    }
    return '${form.infinitive} ${_wuerdeForms[form.person.paradigmIndex]}';
  }

  String _mainClause({
    required KonjunktivForm form,
    required String complement,
  }) {
    final subject = form.person.pronoun;
    if (form.construction == KonjunktivConstruction.synthetic) {
      return '$subject ${form.surface}'
          '${complement.isEmpty ? '' : ' $complement'}';
    }
    final finite = _wuerdeForms[form.person.paradigmIndex];
    return '$subject $finite'
        '${complement.isEmpty ? '' : ' $complement'} ${form.infinitive}';
  }

  String _normalizeInfinitive(String value) {
    final result = value.trim().toLowerCase();
    if (result.isEmpty || result.contains(RegExp(r'\s'))) {
      throw ArgumentError.value(
        value,
        'infinitive',
        'Expected one German infinitive token.',
      );
    }
    return result;
  }

  String _cleanPhrase(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');

  String _sentence(String body) => '${body.trim()}.';

  String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';


  int _index(int seed, int length) {
    final nonNegative = seed < 0 ? -seed : seed;
    return nonNegative % length;
  }
}
