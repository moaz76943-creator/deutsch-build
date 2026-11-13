import 'dart:math';

/// مجالات الهندسة والتقنية المعتمدة في المنهج (خالية من المخاطر القانونية والطبية)
enum KongruenzEngineeringDomain {
  renewableEnergyGrid,
  aerospaceAndAviation,
  industrialRobotics,
  civilInfrastructure,
  materialScience,
  maritimeLogistics,
}

/// تصنيف الحالات الدقيقة للمطابقة الفعلية (Kongruenz) في الألمانية (C1–C2)
enum KongruenzCategory {
  copulaDasEsDiesPlural,       // مطابقة الفعل مع المسند الجمع بعد das / es / dies
  parentheticalMitSamtNebst,    // الإلحاق بحرف جر (mit / samt / nebst / einschließlich) لا يجمع الفاعل
  collectiveAndPercentSubject,  // أسماء الجمع والنسب المئوية (eine Reihe von / 30 Prozent / die Hälfte)
  disjunctiveWederNochOder,     // الفاعل المعطوف بأدوات التخيير والنفي (weder...noch / entweder...oder)
  percentageAndMeasureUnits,    // وحدات القياس والكميات (100 Megawatt / zwei Tonnen)
  personHierarchyCoordination,  // أولوية الشخص النحوي (الأول > الثاني > الثالث) عند تعدد الضمائر
}

/// نموذج تطبيقي لمطابقة الفعل والفاعل في التراكيب المعقدة
class KongruenzExemplar {
  final String id;
  final KongruenzEngineeringDomain domain;
  final KongruenzCategory category;
  final String cefrLevel;
  final String agreementRule;
  final String germanSentence;
  final String commonErrorTrap;
  final String arabicExplanation;
  final String expectedVerbNumber; // 'Singular', 'Plural', 'Beides (Kontextabhängig)'

  const KongruenzExemplar({
    required this.id,
    required this.domain,
    required this.category,
    required this.cefrLevel,
    required this.agreementRule,
    required this.germanSentence,
    required this.commonErrorTrap,
    required this.arabicExplanation,
    required this.expectedVerbNumber,
  });
}

/// نتيجة التحقق الذكي من مطابقة الفعل والفاعل
class KongruenzValidationResult {
  final bool isValid;
  final String diagnosedRule;
  final String arabicFeedback;
  final String correctedSuggestion;

  const KongruenzValidationResult({
    required this.isValid,
    required this.diagnosedRule,
    required this.arabicFeedback,
    required this.correctedSuggestion,
  });
}

/// بيانات قياس الأداء والإحصاءات الداخلية للمحرك
class KongruenzTelemetry {
  final int totalExemplars;
  final int validationRuns;
  final int caughtCopulaPluralErrors;
  final int caughtParentheticalPluralTraps;
  final int caughtVorfeldEsErrors;

  const KongruenzTelemetry({
    required this.totalExemplars,
    required this.validationRuns,
    required this.caughtCopulaPluralErrors,
    required this.caughtParentheticalPluralTraps,
    required this.caughtVorfeldEsErrors,
  });
}

/// المحرك الأساسي لضبط مطابقة الفاعل والفعل (Kongruenz) في C1–C2
class SubjectVerbAgreementKongruenzEngine {
  int _validationRuns = 0;
  int _caughtCopulaPluralErrors = 0;
  int _caughtParentheticalPluralTraps = 0;
  int _caughtVorfeldEsErrors = 0;

  static const List<KongruenzExemplar> _exemplars = [
    KongruenzExemplar(
      id: 'kong_01',
      domain: KongruenzEngineeringDomain.renewableEnergyGrid,
      category: KongruenzCategory.copulaDasEsDiesPlural,
      cefrLevel: 'C1',
      agreementRule: 'Das / Dies + [Plural-Kopula: sind/waren/bleiben] + [Pluralnomen]',
      germanSentence:
          'Das sind die aktuellen Lastprofile der drei regionalen Umspannwerke.',
      commonErrorTrap: 'Das ist die aktuellen Lastprofile (إبقاء الفعل مفرداً بعد Das)',
      arabicExplanation:
          'عندما يربط الفعل sein/werden/bleiben بين das/es/dies واسم خبر جمع (die aktuellen Lastprofile)، يجب تصريف الفعل في الجمع (sind / waren).',
      expectedVerbNumber: 'Plural',
    ),
    KongruenzExemplar(
      id: 'kong_02',
      domain: KongruenzEngineeringDomain.aerospaceAndAviation,
      category: KongruenzCategory.copulaDasEsDiesPlural,
      cefrLevel: 'C1',
      agreementRule: 'Vorfeld-es + [Pluralverb] + [Plural-Subjekt]',
      germanSentence:
          'Es wurden während des Windkanaltests insgesamt zwölf Drucksensoren neu kalibriert.',
      commonErrorTrap: 'Es wurde insgesamt zwölf Drucksensoren kalibriert (مطابقة الفعل مع es الشكلية)',
      arabicExplanation:
          'كلمة es في بداية الجملة مجرد عنصر نائب شكلي (Vorfeld-es)، أما الفاعل الحقيقي فهو (zwölf Drucksensoren)، لذا يجب جمع الفعل (wurden).',
      expectedVerbNumber: 'Plural',
    ),
    KongruenzExemplar(
      id: 'kong_03',
      domain: KongruenzEngineeringDomain.industrialRobotics,
      category: KongruenzCategory.parentheticalMitSamtNebst,
      cefrLevel: 'C2',
      agreementRule: '[Singular-Subjekt] + [samt/nebst/einschließlich + Nomen] + [Singularverb]',
      germanSentence:
          'Der Hauptcontroller samt seinen vier angeschlossenen Servoachsen wurde erfolgreich aktualisiert.',
      commonErrorTrap: 'Der Hauptcontroller samt seinen vier Achsen wurden aktualisiert',
      arabicExplanation:
          'الإضافات المسبوقة بحروف الجر (samt, nebst, mitsamt, einschließlich, zusammen mit) لا تغير عدد الفاعل النحوي المفرد (Der Hauptcontroller)، فيبقى الفعل مفرداً (wurde).',
      expectedVerbNumber: 'Singular',
    ),
    KongruenzExemplar(
      id: 'kong_04',
      domain: KongruenzEngineeringDomain.civilInfrastructure,
      category: KongruenzCategory.parentheticalMitSamtNebst,
      cefrLevel: 'C2',
      agreementRule: '[Singular-Subjekt], [einschließlich + Genitiv/Dativ], + [Singularverb]',
      germanSentence:
          'Die gesamte Brückenfahrbahn einschließlich der beidseitigen Entwässerungsrinnen wird versiegelt.',
      commonErrorTrap: 'Die Brückenfahrbahn einschließlich der Rinnen werden versiegelt',
      arabicExplanation:
          'بما أن الفاعل الرئيسي مفرد (Die gesamte Brückenfahrbahn)، فإن العبارة الملحقة بـ einschließlich لا تفرض صيغة الجمع على الفعل (wird).',
      expectedVerbNumber: 'Singular',
    ),
    KongruenzExemplar(
      id: 'kong_05',
      domain: KongruenzEngineeringDomain.materialScience,
      category: KongruenzCategory.collectiveAndPercentSubject,
      cefrLevel: 'C2',
      agreementRule: 'Eine Vielzahl / Reihe von + [Plural] -> Singular (streng) oder Plural (häufig)',
      germanSentence:
          'Eine große Anzahl hochfester Verbundwerkstoffe wird derzeit im Kryolabor getestet.',
      commonErrorTrap: 'الخلط بين الفاعل الشكلي المفرد (Anzahl) والاسم المضاف إليه الجمع (Werkstoffe)',
      arabicExplanation:
          'في الأسلوب العلمي الرسمي، يميل الفعل إلى المفرد (wird) لمطابقة النواة الاسمية المفردة (Anzahl)، مع جواز الجمع أحياناً حسب المعنى عند وجود صفة جمعية.',
      expectedVerbNumber: 'Singular',
    ),
    KongruenzExemplar(
      id: 'kong_06',
      domain: KongruenzEngineeringDomain.maritimeLogistics,
      category: KongruenzCategory.collectiveAndPercentSubject,
      cefrLevel: 'C1',
      agreementRule: 'Ein Großteil + [Pluralnomen] + [Singularverb] vs. Die meisten + [Pluralverb]',
      germanSentence:
          'Ein Großteil der verschifften Container erreicht den Zielhafen über das automatisierte Terminal.',
      commonErrorTrap: 'Ein Großteil der Container erreichen (تغليب الجمع خطأً على النواة المفردة Großteil)',
      arabicExplanation:
          'اللفظ المركب ein Großteil اسم مفرد مذكر، لذا يأخذ الفعل صيغة المفرد (erreicht) في الألمانية القياسية حتى لو تلاه مضاف إليه جمع.',
      expectedVerbNumber: 'Singular',
    ),
    KongruenzExemplar(
      id: 'kong_07',
      domain: KongruenzEngineeringDomain.renewableEnergyGrid,
      category: KongruenzCategory.percentageAndMeasureUnits,
      cefrLevel: 'C1',
      agreementRule: 'Prozentangabe + [Singular-Bezugsgröße] -> [Singularverb]',
      germanSentence:
          'Genau 42 Prozent der erzeugten Solarenergie fließen bzw. fließt je nach Bezug in den Speicher — hier: fließt direkt in den Batteriespeicher.',
      commonErrorTrap: '42 Prozent der Solarenergie fließen (الاعتماد على العدد 42 دون النظر إلى المرجع المفرد Solarenergie)',
      arabicExplanation:
          'عند اقتران النسبة المئوية باسم مفرد غير معدود (der Solarenergie)، يتبع الفعل الاسم المرجعي المفرد فيكون مفرداً (fließt).',
      expectedVerbNumber: 'Singular',
    ),
    KongruenzExemplar(
      id: 'kong_08',
      domain: KongruenzEngineeringDomain.aerospaceAndAviation,
      category: KongruenzCategory.percentageAndMeasureUnits,
      cefrLevel: 'C2',
      agreementRule: 'Prozentangabe + [Plural-Bezugsgröße] -> [Pluralverb]',
      germanSentence:
          'Rund 85 Prozent der eingesetzten Turbinenschaufeln bestehen aus einkristallinem Nickel.',
      commonErrorTrap: '85 Prozent der Schaufeln besteht (استخدام المفرد مع مرجع معدود جمع)',
      arabicExplanation:
          'عندما تتبع النسبة المئوية بمرجع جمع معدود (der Turbinenschaufeln)، يأخذ الفعل صيغة الجمع (bestehen) في الأسلوب القياسي.',
      expectedVerbNumber: 'Plural',
    ),
    KongruenzExemplar(
      id: 'kong_09',
      domain: KongruenzEngineeringDomain.industrialRobotics,
      category: KongruenzCategory.disjunctiveWederNochOder,
      cefrLevel: 'C2',
      agreementRule: 'weder [Singular] noch [Singular] -> [Singularverb] (Standard)',
      germanSentence:
          'Weder der optische Encoder noch der Endschalter meldet eine Abweichung.',
      commonErrorTrap: 'Weder der Encoder noch der Endschalter melden (جمع الفعل مع weder...noch لمفردين)',
      arabicExplanation:
          'في الربط بـ weder ... noch بين اسمين مفردين، يلتزم الأسلوب القياسي الدقيق بصيغة المفرد (meldet).',
      expectedVerbNumber: 'Singular',
    ),
    KongruenzExemplar(
      id: 'kong_10',
      domain: KongruenzEngineeringDomain.civilInfrastructure,
      category: KongruenzCategory.disjunctiveWederNochOder,
      cefrLevel: 'C2',
      agreementRule: 'weder [Singular] noch [Plural] -> [Pluralverb nach dem näheren Subjekt]',
      germanSentence:
          'Weder der Hauptträger noch die seitlichen Stützpfeiler weisen Setzungsrisse auf.',
      commonErrorTrap: 'Weder der Hauptträger noch die Stützpfeiler weist auf',
      arabicExplanation:
          'عند اختلاف العدد في weder ... noch (مفرد ثم جمع)، يتطابق الفعل مع الفاعل الأقرب إليه (die seitlichen Stützpfeiler -> weisen auf).',
      expectedVerbNumber: 'Plural',
    ),
    KongruenzExemplar(
      id: 'kong_11',
      domain: KongruenzEngineeringDomain.materialScience,
      category: KongruenzCategory.personHierarchyCoordination,
      cefrLevel: 'C1',
      agreementRule: '2. Person + 1. Person -> 1. Person Plural (wir)',
      germanSentence:
          'Sowohl du als auch ich übernehmen die Kalibrierung der Spektrometer.',
      commonErrorTrap: 'Sowohl du als auch ich übernimmt / übernehmt',
      arabicExplanation:
          'عند عطف ضمير المتكلم (ich) على المخاطب (du) بـ und أو sowohl... als auch، يغلب ضمير المتكلم الجمع (wir -> übernehmen).',
      expectedVerbNumber: 'Plural',
    ),
    KongruenzExemplar(
      id: 'kong_12',
      domain: KongruenzEngineeringDomain.maritimeLogistics,
      category: KongruenzCategory.copulaDasEsDiesPlural,
      cefrLevel: 'C2',
      agreementRule: 'Welches / Was + [Kopula Plural] + [Plural-Prädikativ]',
      germanSentence:
          'Welche beiden Faktoren waren ausschlaggebend für die Verkürzung der Liegezeit?',
      commonErrorTrap: 'Was war die beiden Faktoren? (إبقاء war مفرداً مع خبر جمع)',
      arabicExplanation:
          'حتى في صيغة السؤال، إذا جاء الخبر جمعاً (die beiden Faktoren)، يُجمع فعل الكينونة (waren).',
      expectedVerbNumber: 'Plural',
    ),
    KongruenzExemplar(
      id: 'kong_13',
      domain: KongruenzEngineeringDomain.renewableEnergyGrid,
      category: KongruenzCategory.percentageAndMeasureUnits,
      cefrLevel: 'C2',
      agreementRule: 'Mengenangabe als geschlossene Einheit -> [Singularverb]',
      germanSentence:
          'Eine Leistung von 250 Megawatt reicht für die Versorgung des gesamten Industrieparks aus.',
      commonErrorTrap: 'Eine Leistung von 250 Megawatt reichen aus',
      arabicExplanation:
          'النواة النحوية للفاعل هي (Eine Leistung) المفردة، لذا يأتي الفعل مفرداً (reicht aus) بغض النظر عن العدد 250 في شبه الجملة.',
      expectedVerbNumber: 'Singular',
    ),
    KongruenzExemplar(
      id: 'kong_14',
      domain: KongruenzEngineeringDomain.aerospaceAndAviation,
      category: KongruenzCategory.parentheticalMitSamtNebst,
      cefrLevel: 'C2',
      agreementRule: '[Subjekt], nicht aber [zweites Subjekt], + [Verb nach erstem Subjekt]',
      germanSentence:
          'Das zentrale Steuergerät, nicht aber die sekundären Funkmodule, bleibt aktiv.',
      commonErrorTrap: 'Das zentrale Steuergerät, nicht aber die Funkmodule, bleiben aktiv',
      arabicExplanation:
          'الجملة المعترضة المنفية (nicht aber die sekundären Funkmodule) لا تؤثر على مطابقة الفعل مع الفاعل المثبت المفرد (bleibt).',
      expectedVerbNumber: 'Singular',
    ),
    KongruenzExemplar(
      id: 'kong_15',
      domain: KongruenzEngineeringDomain.industrialRobotics,
      category: KongruenzCategory.collectiveAndPercentSubject,
      cefrLevel: 'C1',
      agreementRule: 'Der Großteil / Die Hälfte + [Singular-Substanz] -> [Singularverb]',
      germanSentence:
          'Die Hälfte des benötigten Hydrauliköls wurde bereits über das Filtersystem geleitet.',
      commonErrorTrap: 'Die Hälfte des Öls wurden geleitet',
      arabicExplanation:
          'الفاعل (Die Hälfte) مفرد والمرجع غير المعدود (des Hydrauliköls) مفرد أيضاً، لذا يُصرف الفعل في المفرد قطعاً (wurde).',
      expectedVerbNumber: 'Singular',
    ),
    KongruenzExemplar(
      id: 'kong_16',
      domain: KongruenzEngineeringDomain.civilInfrastructure,
      category: KongruenzCategory.copulaDasEsDiesPlural,
      cefrLevel: 'C1',
      agreementRule: 'Dies + [Plural-Kopula: bleiben/sind] + [Plural-Prädikativ]',
      germanSentence:
          'Dies bleiben die zentralen Sicherheitsvorgaben für den Tunnelvortrieb.',
      commonErrorTrap: 'Dies bleibt die zentralen Sicherheitsvorgaben',
      arabicExplanation:
          'مع الإشارة الجمعية غير المصرفة dies، يتبع الفعلُ الخبرَ الجمعَ (die zentralen Sicherheitsvorgaben) فيأتي بصيغة الجمع (bleiben).',
      expectedVerbNumber: 'Plural',
    ),
  ];

  List<KongruenzExemplar> get allExemplars => List.unmodifiable(_exemplars);

  List<KongruenzExemplar> getByDomain(KongruenzEngineeringDomain domain) {
    return _exemplars.where((e) => e.domain == domain).toList(growable: false);
  }

  List<KongruenzExemplar> getByCategory(KongruenzCategory category) {
    return _exemplars.where((e) => e.category == category).toList(growable: false);
  }

  KongruenzExemplar pickExemplarForDrill({
    KongruenzEngineeringDomain? domain,
    int seed = 4977,
  }) {
    final pool = domain == null ? _exemplars : getByDomain(domain);
    if (pool.isEmpty) {
      return _exemplars.first;
    }
    final rng = Random(seed);
    return pool[rng.nextInt(pool.length)];
  }

  /// التحقق الذكي من مطابقة الفاعل والفعل (Kongruenz)
  KongruenzValidationResult validateKongruenz(
    String sentence, {
    required bool predicateOrRealSubjectIsPlural,
  }) {
    _validationRuns++;
    final normalized = sentence.trim();
    final lower = normalized.toLowerCase();

    // 1. كشف استخدام فعل مفرد مع das / dies عندما يكون المسند جمعاً
    final copulaSingularTrap = RegExp(
      r'^(das|dies|es)\s+(ist|war|bleibt)\s+(die|alle|beide|viele|einige|mehrere|drei|vier|fünf|zwölf)\b',
      caseSensitive: false,
    );
    if (predicateOrRealSubjectIsPlural && copulaSingularTrap.hasMatch(lower)) {
      _caughtCopulaPluralErrors++;
      final fixed = normalized
          .replaceFirst(RegExp(r'\bist\b', caseSensitive: false), 'sind')
          .replaceFirst(RegExp(r'\bwar\b', caseSensitive: false), 'waren')
          .replaceFirst(RegExp(r'\bbleibt\b', caseSensitive: false), 'bleiben');
      return KongruenzValidationResult(
        isValid: false,
        diagnosedRule: 'Numeruskongruenz der Kopula mit Plural-Prädikativ',
        arabicFeedback:
            'عندما يكون الخبر بعد (das / dies) جمعاً، يجب أن يطابقه فعل الكينونة في الجمع (sind / waren / bleiben).',
        correctedSuggestion: fixed,
      );
    }

    // 2. كشف مطابقة الفعل المفرد مع Vorfeld-es رغم وجود فاعل حقيقي جمع
    final vorfeldEsTrap = RegExp(
      r'^es\s+(wurde|wird|ist|war|hat)\b',
      caseSensitive: false,
    );
    if (predicateOrRealSubjectIsPlural && vorfeldEsTrap.hasMatch(lower)) {
      _caughtVorfeldEsErrors++;
      final fixed = normalized
          .replaceFirst(RegExp(r'\bwurde\b', caseSensitive: false), 'wurden')
          .replaceFirst(RegExp(r'\bwird\b', caseSensitive: false), 'werden')
          .replaceFirst(RegExp(r'\bist\b', caseSensitive: false), 'sind')
          .replaceFirst(RegExp(r'\bwar\b', caseSensitive: false), 'waren')
          .replaceFirst(RegExp(r'\bhat\b', caseSensitive: false), 'haben');
      return KongruenzValidationResult(
        isValid: false,
        diagnosedRule: 'Vorfeld-es: Verb richtet sich nach dem nachgestellten Subjekt',
        arabicFeedback:
            'العنصر es في بداية الجملة نائب شكلي لا يحدد عدد الفعل؛ الفعل يطابق الفاعل الحقيقي المتأخر، لذا يجب تصريفه في الجمع.',
        correctedSuggestion: fixed,
      );
    }

    // 3. كشف جمع الفعل خطأً بعد الفاعل المفرد الملحق بـ samt / nebst / einschließlich
    final parentheticalPluralTrap = RegExp(
      r'^(der|die|das)\s+[a-zäöüß]+\s+(samt|nebst|einschließlich|mitsamt)\s+.+\s+(wurden|werden|sind|waren|haben)\b',
      caseSensitive: false,
    );
    if (!predicateOrRealSubjectIsPlural && parentheticalPluralTrap.hasMatch(lower)) {
      _caughtParentheticalPluralTraps++;
      return const KongruenzValidationResult(
        isValid: false,
        diagnosedRule: 'Präpositionaler Zusatz (samt/nebst/einschließlich) ändert den Subjektnumerus nicht',
        arabicFeedback:
            'العبارة المسبوقة بـ (samt / nebst / einschließlich) ليست فاعلاً معطوفاً، لذا يبقى الفعل مفرداً ليطابق الفاعل الأساسي المفرد.',
        correctedSuggestion: '[Singular-Subjekt] + [samt/nebst/einschließlich ...] + [Singularverb]',
      );
    }

    return const KongruenzValidationResult(
      isValid: true,
      diagnosedRule: 'Korrekte C1/C2-Subjekt-Verb-Kongruenz',
      arabicFeedback: 'مطابقة الفعل والفاعل سليمة تماماً وفق قواعد الألمانية القياسية.',
      correctedSuggestion: '',
    );
  }

  KongruenzTelemetry get telemetry => KongruenzTelemetry(
        totalExemplars: _exemplars.length,
        validationRuns: _validationRuns,
        caughtCopulaPluralErrors: _caughtCopulaPluralErrors,
        caughtParentheticalPluralTraps: _caughtParentheticalPluralTraps,
        caughtVorfeldEsErrors: _caughtVorfeldEsErrors,
      );
}
