enum GermanPronoun {
  ich,
  du,
  erSieEs,
  wir,
  ihr,
  sieSie;

  String get label => switch (this) {
    GermanPronoun.ich => 'ich',
    GermanPronoun.du => 'du',
    GermanPronoun.erSieEs => 'er/sie/es',
    GermanPronoun.wir => 'wir',
    GermanPronoun.ihr => 'ihr',
    GermanPronoun.sieSie => 'sie/Sie',
  };

  String get arabicLabel => switch (this) {
    GermanPronoun.ich => 'أنا (ich)',
    GermanPronoun.du => 'أنتَ/أنتِ (du)',
    GermanPronoun.erSieEs => 'هو/هي/هو للمحايد (er/sie/es)',
    GermanPronoun.wir => 'نحن (wir)',
    GermanPronoun.ihr => 'أنتم (ihr)',
    GermanPronoun.sieSie => 'هم/حضرتك بصيغة الاحترام (sie/Sie)',
  };
}

class ConjugatedVerbForms {
  final String infinitive;
  final bool isSeparable;
  final String? prefix;
  final String baseVerb;
  final Map<GermanPronoun, String> presentForms;
  final Map<GermanPronoun, String> mainClauseV2Forms; // مع فصل السابقة المنفصلة
  final String pastParticiple; // Partizip II
  final String auxiliary; // haben أو sein
  final String explanation;

  const ConjugatedVerbForms({
    required this.infinitive,
    this.isSeparable = false,
    this.prefix,
    required this.baseVerb,
    required this.presentForms,
    required this.mainClauseV2Forms,
    required this.pastParticiple,
    required this.auxiliary,
    required this.explanation,
  });
}

/// محرك تصريف الأفعال الألمانية ومعالجة الأفعال المنفصلة (Topics 9 & 10)
/// يدعم الأفعال النظامية، أفعال الإمالة في الجذع (Vokalwechsel)، الأفعال الشاذة والمنفصلة
class GermanVerbConjugator {
  static const Set<String> _separablePrefixes = {
    'ab', 'an', 'auf', 'aus', 'bei', 'ein', 'fern', 'fest', 'fort',
    'her', 'hin', 'los', 'mit', 'nach', 'vor', 'weg', 'weiter',
    'zu', 'zurück', 'zusammen',
  };

  /// تصريف الأفعال المساعدة الأساسية (Hilfsverben)
  static const Map<String, Map<GermanPronoun, String>> _auxiliaries = {
    'sein': {
      GermanPronoun.ich: 'bin',
      GermanPronoun.du: 'bist',
      GermanPronoun.erSieEs: 'ist',
      GermanPronoun.wir: 'sind',
      GermanPronoun.ihr: 'seid',
      GermanPronoun.sieSie: 'sind',
    },
    'haben': {
      GermanPronoun.ich: 'habe',
      GermanPronoun.du: 'hast',
      GermanPronoun.erSieEs: 'hat',
      GermanPronoun.wir: 'haben',
      GermanPronoun.ihr: 'habt',
      GermanPronoun.sieSie: 'haben',
    },
    'werden': {
      GermanPronoun.ich: 'werde',
      GermanPronoun.du: 'wirst',
      GermanPronoun.erSieEs: 'wird',
      GermanPronoun.wir: 'werden',
      GermanPronoun.ihr: 'werdet',
      GermanPronoun.sieSie: 'werden',
    },
  };

  /// تصريف الأفعال الناقصة (Modalverben)
  static const Map<String, Map<GermanPronoun, String>> _modals = {
    'können': {
      GermanPronoun.ich: 'kann',
      GermanPronoun.du: 'kannst',
      GermanPronoun.erSieEs: 'kann',
      GermanPronoun.wir: 'können',
      GermanPronoun.ihr: 'könnt',
      GermanPronoun.sieSie: 'können',
    },
    'müssen': {
      GermanPronoun.ich: 'muss',
      GermanPronoun.du: 'musst',
      GermanPronoun.erSieEs: 'muss',
      GermanPronoun.wir: 'müssen',
      GermanPronoun.ihr: 'müsst',
      GermanPronoun.sieSie: 'müssen',
    },
    'dürfen': {
      GermanPronoun.ich: 'darf',
      GermanPronoun.du: 'darfst',
      GermanPronoun.erSieEs: 'darf',
      GermanPronoun.wir: 'dürfen',
      GermanPronoun.ihr: 'dürft',
      GermanPronoun.sieSie: 'dürfen',
    },
    'wollen': {
      GermanPronoun.ich: 'will',
      GermanPronoun.du: 'willst',
      GermanPronoun.erSieEs: 'will',
      GermanPronoun.wir: 'wollen',
      GermanPronoun.ihr: 'wollt',
      GermanPronoun.sieSie: 'wollen',
    },
    'sollen': {
      GermanPronoun.ich: 'soll',
      GermanPronoun.du: 'sollst',
      GermanPronoun.erSieEs: 'soll',
      GermanPronoun.wir: 'sollen',
      GermanPronoun.ihr: 'sollt',
      GermanPronoun.sieSie: 'sollen',
    },
    'mögen': {
      GermanPronoun.ich: 'mag',
      GermanPronoun.du: 'magst',
      GermanPronoun.erSieEs: 'mag',
      GermanPronoun.wir: 'mögen',
      GermanPronoun.ihr: 'mögt',
      GermanPronoun.sieSie: 'mögen',
    },
  };

  /// أفعال الإمالة في الجذع (e -> i / e -> ie / a -> ä) في ضمائر du و er/sie/es
  static const Map<String, ({String du, String er})> _vowelChangeStems = {
    'helfen': (du: 'hilfst', er: 'hilft'),
    'geben': (du: 'gibst', er: 'gibt'),
    'sprechen': (du: 'sprichst', er: 'spricht'),
    'treffen': (du: 'triffst', er: 'trifft'),
    'nehmen': (du: 'nimmst', er: 'nimmt'),
    'essen': (du: 'isst', er: 'isst'),
    'vergessen': (du: 'vergisst', er: 'vergisst'),
    'sehen': (du: 'siehst', er: 'sieht'),
    'lesen': (du: 'liest', er: 'liest'),
    'fahren': (du: 'fährst', er: 'fährt'),
    'schlafen': (du: 'schläfst', er: 'schläft'),
    'tragen': (du: 'trägst', er: 'trägt'),
    'waschen': (du: 'wäschst', er: 'wäscht'),
    'laufen': (du: 'läufst', er: 'läuft'),
    'fallen': (du: 'fällst', er: 'fällt'),
  };

  /// تصريف الفعل في صيغة المضارع مع الكشف عن الانفصال والسوابق
  static ConjugatedVerbForms conjugate(String verb) {
    final lower = verb.trim().toLowerCase();

    // 1. فحص الأفعال المساعدة الأساسية
    if (_auxiliaries.containsKey(lower)) {
      final forms = _auxiliaries[lower]!;
      return ConjugatedVerbForms(
        infinitive: verb,
        baseVerb: verb,
        presentForms: forms,
        mainClauseV2Forms: forms,
        pastParticiple: switch (lower) {
          'sein' => 'gewesen',
          'haben' => 'gehabt',
          _ => 'geworden',
        },
        auxiliary: lower == 'sein' ? 'sein' : 'haben',
        explanation: 'فعل مساعد شاذ أساسي في قواعد اللغة الألمانية.',
      );
    }

    // 2. فحص الأفعال الناقصة (Modalverben)
    if (_modals.containsKey(lower)) {
      final forms = _modals[lower]!;
      return ConjugatedVerbForms(
        infinitive: verb,
        baseVerb: verb,
        presentForms: forms,
        mainClauseV2Forms: forms,
        pastParticiple: 'ge$lower',
        auxiliary: 'haben',
        explanation: 'فعل ناقص (Modalverb) يتميز بتطابق تصريف المفرد ich مع er/sie/es وبدون نهاية -t.',
      );
    }

    // 3. فحص الأفعال المنفصلة (Trennbare Verben)
    String? foundPrefix;
    String baseVerb = lower;

    for (final prefix in _separablePrefixes) {
      if (lower.startsWith(prefix) && lower.length > prefix.length + 3) {
        final candidateBase = lower.substring(prefix.length);
        if (candidateBase.endsWith('en') || candidateBase.endsWith('ern') || candidateBase.endsWith('eln')) {
          foundPrefix = prefix;
          baseVerb = candidateBase;
          break;
        }
      }
    }

    // 4. تصريف الفعل الأساسي (الجذع)
    final baseForms = _conjugateBaseVerb(baseVerb);

    final presentForms = <GermanPronoun, String>{};
    final mainClauseForms = <GermanPronoun, String>{};

    for (final p in GermanPronoun.values) {
      final conjugatedBase = baseForms[p]!;
      if (foundPrefix != null) {
        // في الجملة الفرعية أو المصدر: السابقة متصلة
        presentForms[p] = '$foundPrefix$conjugatedBase';
        // في الجملة الرئيسية (V2): الفعل المصرف في الموقع 2 والسابقة في نهاية الجملة
        mainClauseForms[p] = '$conjugatedBase ... $foundPrefix';
      } else {
        presentForms[p] = conjugatedBase;
        mainClauseForms[p] = conjugatedBase;
      }
    }

    final isSeinAuxiliary = _isSeinAuxiliary(lower, baseVerb);
    final aux = isSeinAuxiliary ? 'sein' : 'haben';
    final participle = _buildParticiple(baseVerb, foundPrefix);

    final sepText = foundPrefix != null
        ? 'فعل منفصل (trennbares Verb): السابقة "$foundPrefix" تنفصل في الجملة الرئيسية وتأتي في نهاية الجملة.'
        : 'فعل قياسي متصل.';

    return ConjugatedVerbForms(
      infinitive: verb,
      isSeparable: foundPrefix != null,
      prefix: foundPrefix,
      baseVerb: baseVerb,
      presentForms: presentForms,
      mainClauseV2Forms: mainClauseForms,
      pastParticiple: participle,
      auxiliary: aux,
      explanation: sepText,
    );
  }

  static Map<GermanPronoun, String> _conjugateBaseVerb(String verb) {
    if (_auxiliaries.containsKey(verb)) return _auxiliaries[verb]!;
    if (_modals.containsKey(verb)) return _modals[verb]!;

    // استخراج الجذع (Stamm)
    String stem = verb;
    if (verb.endsWith('en')) {
      stem = verb.substring(0, verb.length - 2);
    } else if (verb.endsWith('n')) {
      stem = verb.substring(0, verb.length - 1);
    }

    // فحص الإمالة في الجذع (Vokalwechsel)
    final vowelChange = _vowelChangeStems[verb];

    final isDentals = stem.endsWith('t') || stem.endsWith('d');
    final isSibilant = stem.endsWith('s') || stem.endsWith('ss') || stem.endsWith('ß') || stem.endsWith('z');

    final eConnector = isDentals ? 'e' : '';

    final ichForm = '${stem}e';
    final duForm = vowelChange?.du ?? (isSibilant ? '${stem}t' : '$stem${eConnector}st');
    final erForm = vowelChange?.er ?? '$stem${eConnector}t';
    final wirForm = verb;
    final ihrForm = '$stem${eConnector}t';
    final sieForm = verb;

    return {
      GermanPronoun.ich: ichForm,
      GermanPronoun.du: duForm,
      GermanPronoun.erSieEs: erForm,
      GermanPronoun.wir: wirForm,
      GermanPronoun.ihr: ihrForm,
      GermanPronoun.sieSie: sieForm,
    };
  }

  static const Map<String, String> _irregularBaseParticiples = {
    'stehen': 'gestanden',
    'gehen': 'gegangen',
    'kommen': 'gekommen',
    'fahren': 'gefahren',
    'sehen': 'gesehen',
    'lesen': 'gelesen',
    'schreiben': 'geschrieben',
    'sprechen': 'gesprochen',
    'treffen': 'getroffen',
    'nehmen': 'genommen',
    'helfen': 'geholfen',
    'geben': 'gegeben',
    'essen': 'gegessen',
    'trinken': 'getrunken',
    'schlafen': 'geschlafen',
    'finden': 'gefunden',
    'bleiben': 'geblieben',
    'bringen': 'gebracht',
    'denken': 'gedacht',
    'wissen': 'gewusst',
  };

  static String _buildParticiple(String baseVerb, String? prefix) {
    if (_irregularBaseParticiples.containsKey(baseVerb)) {
      final basePart = _irregularBaseParticiples[baseVerb]!;
      if (prefix != null) {
        return '$prefix$basePart';
      }
      return basePart;
    }

    String stem = baseVerb;
    if (baseVerb.endsWith('en')) {
      stem = baseVerb.substring(0, baseVerb.length - 2);
    } else if (baseVerb.endsWith('n')) {
      stem = baseVerb.substring(0, baseVerb.length - 1);
    }

    // الأفعال المنتهية بـ -ieren لا تأخذ ge- في البداية (مثل studieren -> studiert)
    if (baseVerb.endsWith('ieren')) {
      return '${baseVerb.substring(0, baseVerb.length - 2)}t';
    }

    if (prefix != null) {
      return '${prefix}ge${stem}t';
    }

    return 'ge${stem}t';
  }

  static bool _isSeinAuxiliary(String fullVerb, String baseVerb) {
    const movementOrStateChange = {
      'gehen', 'fahren', 'kommen', 'laufen', 'reisen', 'fliegen',
      'schwimmen', 'springen', 'fallen', 'steigen', 'bleiben', 'sein',
      'aufstehen', 'aufwachen', 'einschlafen', 'sterben', 'wachsen',
      'passieren', 'geschehen', 'verschwinden', 'erscheinen',
    };
    return movementOrStateChange.contains(fullVerb) ||
        movementOrStateChange.contains(baseVerb);
  }
}
