import 'dart:math';

/// مجالات الهندسة والتقنية المعتمدة في المنهج (خالية من المخاطر القانونية والطبية)
enum ModalEngineeringDomain {
  renewableEnergyGrid,
  aerospaceAndAviation,
  industrialRobotics,
  civilInfrastructure,
  materialScience,
  maritimeLogistics,
}

/// تصنيف تعدد المعاني في الأفعال الناقصة الألمانية (C1–C2)
enum ModalPolysemyCategory {
  negationPolarityShift,        // التحول الدلالي للنفي (nicht müssen = عدم اللزوم مقابل nicht dürfen = المنع)
  epistemicPastDeduction,       // الاستنتاج المرجح في الماضي (muss/dürfte + Partizip II + haben/sein)
  deonticPastVsEpistemicPast,   // التمييز بين الضرورة الماضية (musste) والاستنتاج الماضي (muss gewesen sein)
  inanimateSubjectVolitionIdiom,// دلالة المقاومة مع الفاعل غير العاقل (Der Motor will nicht anspringen)
  substituteModalHabenSeinZu,   // بدائل الأفعال الناقصة (haben + zu + Inf. / sein + zu + Inf.)
  brauchenWithZuInfinitive,     // قاعدة brauchen مع zu في النفي والحصر (nur / nicht brauchen zu)
}

/// نموذج تطبيقي لتعدد معاني الأفعال الناقصة وتفاعلها مع النفي والزمن
class ModalPolysemyExemplar {
  final String id;
  final ModalEngineeringDomain domain;
  final ModalPolysemyCategory category;
  final String cefrLevel;
  final String modalPattern;
  final String germanSentence;
  final String commonErrorTrap;
  final String arabicExplanation;
  final bool isEpistemicReading;
  final String certaintyLevel; // 'hoch (95%)', 'mittel (75%)', 'spekulativ (50%)', 'deontisch'

  const ModalPolysemyExemplar({
    required this.id,
    required this.domain,
    required this.category,
    required this.cefrLevel,
    required this.modalPattern,
    required this.germanSentence,
    required this.commonErrorTrap,
    required this.arabicExplanation,
    required this.isEpistemicReading,
    required this.certaintyLevel,
  });
}

/// نتيجة الفحص الآلي لصحة استخدام الفعل الناقص والنفي والزمن
class ModalPolysemyValidationResult {
  final bool isValid;
  final String diagnosedRule;
  final String arabicFeedback;
  final String correctedSuggestion;

  const ModalPolysemyValidationResult({
    required this.isValid,
    required this.diagnosedRule,
    required this.arabicFeedback,
    required this.correctedSuggestion,
  });
}

/// بيانات قياس الأداء والإحصاءات الداخلية للمحرك
class ModalPolysemyTelemetry {
  final int totalExemplars;
  final int validationRuns;
  final int caughtBrauchenMissingZuErrors;
  final int caughtNegationPolarityErrors;
  final int caughtEpistemicTenseErrors;

  const ModalPolysemyTelemetry({
    required this.totalExemplars,
    required this.validationRuns,
    required this.caughtBrauchenMissingZuErrors,
    required this.caughtNegationPolarityErrors,
    required this.caughtEpistemicTenseErrors,
  });
}

/// المحرك الأساسي لتدريب وضبط تعدد معاني الأفعال الناقصة الألمانية (C1–C2)
class ModalPolysemyEpistemicEngine {
  int _validationRuns = 0;
  int _caughtBrauchenMissingZuErrors = 0;
  int _caughtNegationPolarityErrors = 0;
  int _caughtEpistemicTenseErrors = 0;

  static const List<ModalPolysemyExemplar> _exemplars = [
    ModalPolysemyExemplar(
      id: 'mod_01',
      domain: ModalEngineeringDomain.renewableEnergyGrid,
      category: ModalPolysemyCategory.negationPolarityShift,
      cefrLevel: 'C1',
      modalPattern: 'nicht müssen (= nicht brauchen zu) vs. nicht dürfen (Verbot)',
      germanSentence:
          'Bei aktivierter Netzautomatik muss der Techniker die Phasenwinkel nicht manuell nachregeln.',
      commonErrorTrap: '...darf die Phasenwinkel nicht nachregeln (استخدام darf nicht بمعنى عدم الحاجة)',
      arabicExplanation:
          'التعبير muss nicht يعني "لا يلزم / لا حاجة إلى" (انتفاء الإلزام)، بينما darf nicht يعني "ممنوع قطعاً"؛ الخلط بينهما يقلب التعليمات الهندسية.',
      isEpistemicReading: false,
      certaintyLevel: 'deontisch',
    ),
    ModalPolysemyExemplar(
      id: 'mod_02',
      domain: ModalEngineeringDomain.aerospaceAndAviation,
      category: ModalPolysemyCategory.epistemicPastDeduction,
      cefrLevel: 'C1',
      modalPattern: 'muss + [Partizip II] + haben/sein (nahezu sichere Schlussfolgerung)',
      germanSentence:
          'Der Drucksensor im Frachtraum muss bereits vor dem Start ausgefallen sein.',
      commonErrorTrap: 'Der Drucksensor musste vor dem Start ausfallen (استخدام الماضي الفعلي بدل الاستنتاج)',
      arabicExplanation:
          'للاستنتاج شبه اليقيني (95%) حول حدث وقع في الماضي، نستخدم المضارع (muss) متبوعاً بمصدر الماضي (ausgefallen sein) وليس musste.',
      isEpistemicReading: true,
      certaintyLevel: 'hoch (95%)',
    ),
    ModalPolysemyExemplar(
      id: 'mod_03',
      domain: ModalEngineeringDomain.industrialRobotics,
      category: ModalPolysemyCategory.epistemicPastDeduction,
      cefrLevel: 'C2',
      modalPattern: 'dürfte + [Partizip II] + haben/sein (wahrscheinliche Vermutung)',
      germanSentence:
          'Die kurzzeitige Latenzspitze dürfte durch eine elektromagnetische Störung verursacht worden sein.',
      commonErrorTrap: 'darf verursacht worden sein (استخدام الصيغة الإخبارية darf للاستنتاج الاحتمالي)',
      arabicExplanation:
          'يُستخدم الفعل dürfte (صيغة Konjunktiv II من dürfen) حصراً للتعبير عن الترجيح العالي (نحو 75%)، سواء في الحاضر أو مع مصدر الماضي للمبني للمجهول.',
      isEpistemicReading: true,
      certaintyLevel: 'mittel (75%)',
    ),
    ModalPolysemyExemplar(
      id: 'mod_04',
      domain: ModalEngineeringDomain.civilInfrastructure,
      category: ModalPolysemyCategory.deonticPastVsEpistemicPast,
      cefrLevel: 'C1',
      modalPattern: 'musste + [Infinitiv] (historische Notwendigkeit) vs. muss + [Infinitiv II]',
      germanSentence:
          'Die Bauleitung musste den Betoniervorgang wegen des Frosts um zwölf Stunden verschieben.',
      commonErrorTrap: 'الخلط بين الاضطرار الواقعي في الماضي (musste verschieben) والاستنتاج (muss verschoben haben)',
      arabicExplanation:
          'الصيغة musste + Infinitiv تصف ضرورة أو اضطراراً حدث فعلاً في الماضي، أما الاستنتاج العقلي بعد وقوع الحدث فيُصاغ بـ muss + Infinitiv II.',
      isEpistemicReading: false,
      certaintyLevel: 'deontisch',
    ),
    ModalPolysemyExemplar(
      id: 'mod_05',
      domain: ModalEngineeringDomain.materialScience,
      category: ModalPolysemyCategory.brauchenWithZuInfinitive,
      cefrLevel: 'C1',
      modalPattern: 'nicht / nur brauchen + ... + zu + Infinitiv',
      germanSentence:
          'Für diese Zugprüfung braucht man die Probe nicht zusätzlich vorzuwärmen.',
      commonErrorTrap: 'braucht man die Probe nicht vorwärmen (حذف zu مع brauchen المنفية)',
      arabicExplanation:
          'في الألمانية القياسية المكتوبة، يأخذ الفعل brauchen (عند النفي بـ nicht/kein أو الحصر بـ nur) أداة المصدر zu قبل الفعل الأخير: vorzuwärmen.',
      isEpistemicReading: false,
      certaintyLevel: 'deontisch',
    ),
    ModalPolysemyExemplar(
      id: 'mod_06',
      domain: ModalEngineeringDomain.maritimeLogistics,
      category: ModalPolysemyCategory.inanimateSubjectVolitionIdiom,
      cefrLevel: 'C2',
      modalPattern: '[Unbelebtes Subjekt] + will einfach nicht + [Infinitiv]',
      germanSentence:
          'Das hydraulische Bugstrahlruder will bei diesen Minusgraden einfach nicht anspringen.',
      commonErrorTrap: 'ترجمة will حرفياً بمعنى الإرادة البشرية مع الآلات',
      arabicExplanation:
          'عندما يسند الفعل wollen المنفي إلى آلة أو مادة غير عاقلة، فإنه يعبر اصطلاحاً عن تعصّي الآلة عن الاستجابة رغم المحاولات.',
      isEpistemicReading: false,
      certaintyLevel: 'deontisch',
    ),
    ModalPolysemyExemplar(
      id: 'mod_07',
      domain: ModalEngineeringDomain.renewableEnergyGrid,
      category: ModalPolysemyCategory.substituteModalHabenSeinZu,
      cefrLevel: 'C1',
      modalPattern: 'haben + zu + Infinitiv (= müssen / sollen im Aktiv)',
      germanSentence:
          'Das Schichtteam hat bei jedem Spannungsabfall sofort das Notstromaggregat zu prüfen.',
      commonErrorTrap: 'hat das Aggregat prüfen (إغفال zu في تركيب haben + zu + Infinitiv)',
      arabicExplanation:
          'التركيب (haben + zu + Infinitiv) يؤدي معنى الإلزام والوجوب (müssen / sollen) بصيغة المبني للمعلوم وبأسلوب إداري رفيع.',
      isEpistemicReading: false,
      certaintyLevel: 'deontisch',
    ),
    ModalPolysemyExemplar(
      id: 'mod_08',
      domain: ModalEngineeringDomain.aerospaceAndAviation,
      category: ModalPolysemyCategory.substituteModalHabenSeinZu,
      cefrLevel: 'C2',
      modalPattern: 'sein + zu + Infinitiv (= können / müssen + Passiv)',
      germanSentence:
          'Sämtliche Dichtungsringe des Triebwerks sind alle 500 Flugstunden zwingend auszutauschen.',
      commonErrorTrap: 'sind zwingend austauschen (نسيان zu في تركيب المبني للمجهول البديل)',
      arabicExplanation:
          'التركيب (sein + zu + Infinitiv) يعادل المبني للمجهول مع فعل ناقص (müssen/können ausgetauscht werden)، ويظهر مع الأفعال المنفصلة بتوسط zu: auszutauschen.',
      isEpistemicReading: false,
      certaintyLevel: 'deontisch',
    ),
    ModalPolysemyExemplar(
      id: 'mod_09',
      domain: ModalEngineeringDomain.industrialRobotics,
      category: ModalPolysemyCategory.epistemicPastDeduction,
      cefrLevel: 'C2',
      modalPattern: 'kann nicht + [Partizip II] + haben/sein (Unmöglichkeitsschluss)',
      germanSentence:
          'Der Servomotor kann unmöglich überhitzt gewesen sein, da die Kühlmittelpumpe voll lief.',
      commonErrorTrap: 'darf unmöglich überhitzt gewesen sein',
      arabicExplanation:
          'لنفي الاحتمال بشكل قاطع في الاستنتاج (مستحيل أن يكون قد...) نستخدم kann/könnte nicht (أو unmöglich) وليس darf nicht.',
      isEpistemicReading: true,
      certaintyLevel: 'hoch (95%)',
    ),
    ModalPolysemyExemplar(
      id: 'mod_10',
      domain: ModalEngineeringDomain.civilInfrastructure,
      category: ModalPolysemyCategory.epistemicPastDeduction,
      cefrLevel: 'C1',
      modalPattern: 'könnte / mag + [Partizip II] + haben/sein (offene Hypothese)',
      germanSentence:
          'Ein minimaler Setzungsunterschied könnte den Riss im Putz ausgelöst haben.',
      commonErrorTrap: 'kann ausgelöst hat (تصريف الفعل الثاني بدلاً من المصدر الماضي)',
      arabicExplanation:
          'في الفرضية المفتوحة (نحو 50%) نستخدم könnte أو mag مع المصدر الماضي (ausgelöst haben) في نهاية الجملة.',
      isEpistemicReading: true,
      certaintyLevel: 'spekulativ (50%)',
    ),
    ModalPolysemyExemplar(
      id: 'mod_11',
      domain: ModalEngineeringDomain.materialScience,
      category: ModalPolysemyCategory.negationPolarityShift,
      cefrLevel: 'C2',
      modalPattern: 'nicht dürfen (strenges Verbot) vs. nicht sollen (Empfehlung)',
      germanSentence:
          'Die Titanlegierung darf während des Schweißvorgangs keinesfalls mit Sauerstoff in Kontakt kommen.',
      commonErrorTrap: 'muss keinesfalls in Kontakt kommen (استخدام muss المنفية بدل darf المنفية للمنع)',
      arabicExplanation:
          'للمنع الصارم والتحذير الهندسي نستخدم (darf nicht / keinesfalls)، لأن (muss nicht) تعني فقط عدم الوجوب.',
      isEpistemicReading: false,
      certaintyLevel: 'deontisch',
    ),
    ModalPolysemyExemplar(
      id: 'mod_12',
      domain: ModalEngineeringDomain.maritimeLogistics,
      category: ModalPolysemyCategory.brauchenWithZuInfinitive,
      cefrLevel: 'C1',
      modalPattern: 'nur brauchen + zu + Infinitiv (Einschränkung)',
      germanSentence:
          'Der Kranführer braucht lediglich die Zielkoordinate am Terminal zu bestätigen.',
      commonErrorTrap: 'braucht lediglich die Koordinate bestätigen',
      arabicExplanation:
          'مع أدوات الحصر (nur / lediglich / bloß) يأخذ الفعل brauchen أداة المصدر zu قبل الفعل الأخير في اللغة القياسية.',
      isEpistemicReading: false,
      certaintyLevel: 'deontisch',
    ),
    ModalPolysemyExemplar(
      id: 'mod_13',
      domain: ModalEngineeringDomain.renewableEnergyGrid,
      category: ModalPolysemyCategory.epistemicPastDeduction,
      cefrLevel: 'C2',
      modalPattern: 'müsste + [Partizip II] + sein (erwartete Folgerung)',
      germanSentence:
          'Nach dieser langen Sonnenscheindauer müsste der Batteriespeicher längst vollgeladen sein.',
      commonErrorTrap: 'müsste vollgeladen gewesen ist',
      arabicExplanation:
          'يعبر müsste (Konjunktiv II) عن استنتاج منطقي متوقع بناءً على المعطيات، ويتبعه المصدر أو الصفة في حالة تمام الفعل.',
      isEpistemicReading: true,
      certaintyLevel: 'mittel (75%)',
    ),
    ModalPolysemyExemplar(
      id: 'mod_14',
      domain: ModalEngineeringDomain.aerospaceAndAviation,
      category: ModalPolysemyCategory.substituteModalHabenSeinZu,
      cefrLevel: 'C2',
      modalPattern: 'nicht zu + Infinitiv + sein (= nicht können + Passiv)',
      germanSentence:
          'Eine leichte Verzerrung des Funksignals ist in dieser Flughöhe kaum zu vermeiden.',
      commonErrorTrap: 'ist kaum vermeiden',
      arabicExplanation:
          'يؤدي التركيب (ist kaum zu vermeiden) معنى الاستحالة أو الصعوبة في المبني للمجهول (kann kaum vermieden werden).',
      isEpistemicReading: false,
      certaintyLevel: 'deontisch',
    ),
    ModalPolysemyExemplar(
      id: 'mod_15',
      domain: ModalEngineeringDomain.industrialRobotics,
      category: ModalPolysemyCategory.deonticPastVsEpistemicPast,
      cefrLevel: 'C1',
      modalPattern: 'konnte + [Infinitiv] (Fähigkeit/Möglichkeit) vs. könnte + [Infinitiv II]',
      germanSentence:
          'Die Steuerung konnte den Ausfall eines einzelnen Encoders problemlos kompensieren.',
      commonErrorTrap: 'الخلط بين القدرة المتحققة في الماضي (konnte) والاحتمال غير المؤكد (könnte)',
      arabicExplanation:
          'تثبت صيغة konnte بدون إمالة (Umlaut) تحقق القدرة في الماضي، بينما تفيد könnte مع الإمالة الشك والاحتمال.',
      isEpistemicReading: false,
      certaintyLevel: 'deontisch',
    ),
    ModalPolysemyExemplar(
      id: 'mod_16',
      domain: ModalEngineeringDomain.civilInfrastructure,
      category: ModalPolysemyCategory.inanimateSubjectVolitionIdiom,
      cefrLevel: 'C2',
      modalPattern: 'müssen / sollen mit unbelebtem Subjekt + Passiv-Infinitiv',
      germanSentence:
          'Die Entwässerungsrinne sollte vor der Frostperiode noch einmal gründlich gespült werden.',
      commonErrorTrap: 'sollte spülen (استخدام المبني للمعلوم مع فاعل غير عاقل)',
      arabicExplanation:
          'مع الفاعل غير العاقل (Die Entwässerungsrinne)، تتطلب صيغة التوصية (sollte) إكمالها بالمبني للمجهول (gespült werden).',
      isEpistemicReading: false,
      certaintyLevel: 'deontisch',
    ),
  ];

  List<ModalPolysemyExemplar> get allExemplars => List.unmodifiable(_exemplars);

  List<ModalPolysemyExemplar> getByDomain(ModalEngineeringDomain domain) {
    return _exemplars.where((e) => e.domain == domain).toList(growable: false);
  }

  List<ModalPolysemyExemplar> getByCategory(ModalPolysemyCategory category) {
    return _exemplars.where((e) => e.category == category).toList(growable: false);
  }

  ModalPolysemyExemplar pickExemplarForDrill({
    ModalEngineeringDomain? domain,
    int seed = 4981,
  }) {
    final pool = domain == null ? _exemplars : getByDomain(domain);
    if (pool.isEmpty) {
      return _exemplars.first;
    }
    final rng = Random(seed);
    return pool[rng.nextInt(pool.length)];
  }

  /// التحقق الذكي من تعدد معاني الأفعال الناقصة وقواعد النفي والاستنتاج
  ModalPolysemyValidationResult validateModalUsage(
    String sentence, {
    required bool expressesStrictProhibition,
  }) {
    _validationRuns++;
    final normalized = sentence.trim();
    final lower = normalized.toLowerCase();

    // 1. كشف إسقاط zu مع brauchen المنفية أو المحصورة
    if (RegExp(r'\bbraucht?\b.*\b(nicht|kein|keine|keinen|nur|lediglich)\b', caseSensitive: false)
            .hasMatch(lower) &&
        !RegExp(r'\b(zu\s+[a-zäöüß]+|[a-zäöüß]+zu[a-zäöüß]+en)\b', caseSensitive: false)
            .hasMatch(lower)) {
      _caughtBrauchenMissingZuErrors++;
      return const ModalPolysemyValidationResult(
        isValid: false,
        diagnosedRule: 'brauchen + nicht/nur + zu + Infinitiv (Standardsprache)',
        arabicFeedback:
            'في الألمانية القياسية، يتطلب الفعل brauchen (عند النفي أو الحصر بـ nur/lediglich) وجود أداة المصدر zu قبل الفعل الأخير.',
        correctedSuggestion: 'braucht ... nicht/nur + ... + zu + [Infinitiv]',
      );
    }

    // 2. كشف استخدام muss nicht عند قصد التحريم/المنع الصارم
    if (expressesStrictProhibition &&
        RegExp(r'\b(muss|müssen)\b.*\b(nicht|keinesfalls)\b', caseSensitive: false).hasMatch(lower)) {
      _caughtNegationPolarityErrors++;
      return const ModalPolysemyValidationResult(
        isValid: false,
        diagnosedRule: 'darf nicht (Verbot) statt muss nicht (keine Pflicht)',
        arabicFeedback:
            'تنبه: عبارة muss nicht تعني "لا يلزم" وليس "ممنوع". للمنع الصارم والتحذير يجب استخدام darf nicht / keinesfalls.',
        correctedSuggestion: 'darf ... nicht / keinesfalls',
      );
    }

    // 3. كشف تصريف الفعل الأخير في الاستنتاج الماضي بدلاً من مصدر الماضي (haben / sein)
    if (RegExp(r'\b(muss|dürfte|könnte|kann)\b.*\b(hat|ist|wurde)\.$', caseSensitive: false)
        .hasMatch(lower)) {
      _caughtEpistemicTenseErrors++;
      return const ModalPolysemyValidationResult(
        isValid: false,
        diagnosedRule: 'Epistemisches Modalverb + Infinitiv II (Partizip II + haben/sein)',
        arabicFeedback:
            'بعد الفعل الناقص الاستنتاجي في الماضي، يجب وضع المساعد النهائي في صيغة المصدر (haben / sein / worden sein) وليس مصرفاً.',
        correctedSuggestion: '[Modalverb] + ... + [Partizip II] + haben / sein / worden sein',
      );
    }

    return const ModalPolysemyValidationResult(
      isValid: true,
      diagnosedRule: 'Korrekte C1/C2-Modalverbpolysemie und Negationspolarität',
      arabicFeedback: 'استخدام الفعل الناقص ودلالته الزمنية والنفي سليم تماماً.',
      correctedSuggestion: '',
    );
  }

  ModalPolysemyTelemetry get telemetry => ModalPolysemyTelemetry(
        totalExemplars: _exemplars.length,
        validationRuns: _validationRuns,
        caughtBrauchenMissingZuErrors: _caughtBrauchenMissingZuErrors,
        caughtNegationPolarityErrors: _caughtNegationPolarityErrors,
        caughtEpistemicTenseErrors: _caughtEpistemicTenseErrors,
      );
}
