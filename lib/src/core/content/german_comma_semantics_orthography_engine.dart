import 'dart:math';

/// مجالات الهندسة والتقنية المعتمدة في المنهج (خالية من المخاطر القانونية والطبية)
enum OrthographyEngineeringDomain {
  renewableEnergyGrid,
  aerospaceAndAviation,
  industrialRobotics,
  civilInfrastructure,
  materialScience,
  maritimeLogistics,
}

/// تصنيف قواعد الترقيم الدلالي والفصل والوصل الإملائي في الألمانية (C1–C2)
enum CommaOrthographyCategory {
  mandatoryInfinitiveComma,       // الفاصلة الإلزامية قبل الجملة المصدرية (um/ohne/statt/اسم/رابط)
  subordinateEndBeforeUndComma,   // الفاصلة الإلزامية لغلق الجملة الجانبية قبل und / oder
  appositivePairedCommas,         // الفاصلتان المزدوجتان لعطف البيان والبدل التوضيحي
  getrenntVsZusammenSemanticShift,// تغير المعنى بين الفصل والوصل (freisprechen vs. frei sprechen)
  soDassVsSoDegreeDass,           // التمييز بين sodass (نتيجة) و so [Adjektiv], dass (درجة)
  nominalizedFixedPhrasesCap,     // الحرف الكبير الإلزامي في العبارات الاسمية (im Folgenden, im Voraus)
}

/// نموذج تطبيقي للترقيم الدلالي والفصل والوصل
class CommaOrthographyExemplar {
  final String id;
  final OrthographyEngineeringDomain domain;
  final CommaOrthographyCategory category;
  final String cefrLevel;
  final String ruleSignature;
  final String germanSentence;
  final String commonErrorTrap;
  final String arabicExplanation;
  final bool commaIsMandatory;
  final bool changesMeaningOnSplit;

  const CommaOrthographyExemplar({
    required this.id,
    required this.domain,
    required this.category,
    required this.cefrLevel,
    required this.ruleSignature,
    required this.germanSentence,
    required this.commonErrorTrap,
    required this.arabicExplanation,
    required this.commaIsMandatory,
    required this.changesMeaningOnSplit,
  });
}

/// نتيجة الفحص الآلي للترقيم الدلالي والإملاء المتقدم
class OrthographyValidationResult {
  final bool isValid;
  final String diagnosedRule;
  final String arabicFeedback;
  final String correctedSuggestion;

  const OrthographyValidationResult({
    required this.isValid,
    required this.diagnosedRule,
    required this.arabicFeedback,
    required this.correctedSuggestion,
  });
}

/// بيانات قياس الأداء والإحصاءات الداخلية للمحرك
class CommaOrthographyTelemetry {
  final int totalExemplars;
  final int validationRuns;
  final int caughtMissingInfinitiveCommas;
  final int caughtNominalizedCapErrors;
  final int caughtSplitCompoundErrors;

  const CommaOrthographyTelemetry({
    required this.totalExemplars,
    required this.validationRuns,
    required this.caughtMissingInfinitiveCommas,
    required this.caughtNominalizedCapErrors,
    required this.caughtSplitCompoundErrors,
  });
}

/// المحرك الأساسي لضبط الترقيم الدلالي والفصل والوصل الإملائي (C1–C2)
class CommaSemanticsOrthographyEngine {
  int _validationRuns = 0;
  int _caughtMissingInfinitiveCommas = 0;
  int _caughtNominalizedCapErrors = 0;
  int _caughtSplitCompoundErrors = 0;

  static const List<CommaOrthographyExemplar> _exemplars = [
    CommaOrthographyExemplar(
      id: 'orth_01',
      domain: OrthographyEngineeringDomain.renewableEnergyGrid,
      category: CommaOrthographyCategory.mandatoryInfinitiveComma,
      cefrLevel: 'C1',
      ruleSignature: 'Kommapflicht vor um / ohne / (an)statt ... zu + Infinitiv',
      germanSentence:
          'Der Wechselrichter drosselt die Blindleistung, um das regionale Verteilnetz zu entlasten.',
      commonErrorTrap: '...die Blindleistung um das Verteilnetz zu entlasten (حذف الفاصلة قبل um ... zu)',
      arabicExplanation:
          'تُعد الفاصلة إلزامية قبل الجملة المصدرية المبدوءة بـ (um / ohne / statt / anstatt / außer / als) + zu.',
      commaIsMandatory: true,
      changesMeaningOnSplit: false,
    ),
    CommaOrthographyExemplar(
      id: 'orth_02',
      domain: OrthographyEngineeringDomain.aerospaceAndAviation,
      category: CommaOrthographyCategory.mandatoryInfinitiveComma,
      cefrLevel: 'C1',
      ruleSignature: 'Kommapflicht bei Infinitivgruppe nach Bezugsnomen oder Korrelat',
      germanSentence:
          'Das Ingenieurteam fasste den Entschluss, die Telemetrieantenne neu zu justieren.',
      commonErrorTrap: '...fasste den Entschluss die Telemetrieantenne neu zu justieren',
      arabicExplanation:
          'عندما تعتمد الجملة المصدرية على اسم مرجعي (den Entschluss / die Absicht) أو ضمير رابط (darauf / es)، تصبح الفاصلة إلزامية.',
      commaIsMandatory: true,
      changesMeaningOnSplit: false,
    ),
    CommaOrthographyExemplar(
      id: 'orth_03',
      domain: OrthographyEngineeringDomain.industrialRobotics,
      category: CommaOrthographyCategory.subordinateEndBeforeUndComma,
      cefrLevel: 'C2',
      ruleSignature: 'Schließendes Komma eines Nebensatzes vor "und" / "oder"',
      germanSentence:
          'Sobald der Greifarm die Endposition erreicht, öffnet sich das Ventil, und der Zyklus beginnt erneut.',
      commonErrorTrap: '...öffnet sich das Ventil und der Zyklus beginnt (نسيان فاصلة إغلاق الجملة الجانبية أو الجملة المدمجة)',
      arabicExplanation:
          'إذا تلت جملة جانبية جملةً أخرى معطوفة بـ und، أو للفصل الدلالي الواضح بين جملتين رئيسيتين متعاقبتين، تُغلق الفواصل بدقة لمنع التداخل النحوي.',
      commaIsMandatory: true,
      changesMeaningOnSplit: false,
    ),
    CommaOrthographyExemplar(
      id: 'orth_04',
      domain: OrthographyEngineeringDomain.civilInfrastructure,
      category: CommaOrthographyCategory.appositivePairedCommas,
      cefrLevel: 'C1',
      ruleSignature: 'Paarige Kommas bei nachgestellter Apposition',
      germanSentence:
          'Das zentrale Widerlager, ein massiv bewehrter Stahlbetonblock, nimmt die gesamte Horizontalkraft auf.',
      commonErrorTrap: '...ein massiv bewehrter Stahlbetonblock nimmt die Kraft auf (إسقاط الفاصلة الثانية للبدل)',
      arabicExplanation:
          'يجب إحاطة البدل أو العطف التوضيحي (Apposition) بفاصلتين مزدوجتين؛ إغفال الفاصلة الثانية خطأ ترقيم شائع في النصوص الهندسية.',
      commaIsMandatory: true,
      changesMeaningOnSplit: false,
    ),
    CommaOrthographyExemplar(
      id: 'orth_05',
      domain: OrthographyEngineeringDomain.materialScience,
      category: CommaOrthographyCategory.getrenntVsZusammenSemanticShift,
      cefrLevel: 'C2',
      ruleSignature: 'zusammenarbeiten (kooperieren) vs. zusammen arbeiten (gemeinsam am selben Ort)',
      germanSentence:
          'Die beiden Werkstofflabore arbeiten bei der Ermüdungsprüfung eng zusammen.',
      commonErrorTrap: 'zusammenzuarbeiten vs. zusammen zu arbeiten (الخلط بين التعاون المؤسسي والعمل في نفس المكان)',
      arabicExplanation:
          'تُكتب zusammenarbeiten متصلةً عندما تعني "التعاون المهني/التنسيق" (معنى مجازي)، وتُكتب منفصلةً إذا عنت العمل في نفس الغرفة حرفياً.',
      commaIsMandatory: false,
      changesMeaningOnSplit: true,
    ),
    CommaOrthographyExemplar(
      id: 'orth_06',
      domain: OrthographyEngineeringDomain.maritimeLogistics,
      category: CommaOrthographyCategory.getrenntVsZusammenSemanticShift,
      cefrLevel: 'C2',
      ruleSignature: 'schwerfallen (Mühe bereiten) vs. schwer fallen (heftig stürzen)',
      germanSentence:
          'Die manuelle Umstellung auf das neue Leitsystem fiel den Kranführern zunächst nicht schwer.',
      commonErrorTrap: 'schwer zufallen vs. schwerzufallen (في المصدر: schwerzufallen متصلة)',
      arabicExplanation:
          'الفعل schwerfallen بمعنى "يصعب على شخص" يُكتب متصلاً في المصدر (schwerzufallen)، بينما يُكتب منفصلاً في المعنى الحرفي للسقوط الثقيل.',
      commaIsMandatory: false,
      changesMeaningOnSplit: true,
    ),
    CommaOrthographyExemplar(
      id: 'orth_07',
      domain: OrthographyEngineeringDomain.renewableEnergyGrid,
      category: CommaOrthographyCategory.soDassVsSoDegreeDass,
      cefrLevel: 'C1',
      ruleSignature: 'sodass (Konsekutiv) vs. so [Adjektiv/Adverb], dass (Gradangabe)',
      germanSentence:
          'Die Netzfrequenz wurde präzise geregelt, sodass kein einziger Transformator abschaltete.',
      commonErrorTrap: 'Die Netzfrequenz wurde so präzise geregelt sodass... (الخلط بين السببية المجردة ودرجة الصفة)',
      arabicExplanation:
          'تُستخدم sodass (أو so dass) بعد فاصلة للتعبير عن النتيجة المباشرة، أما إذا سبقتها صفة مقترنة بـ so (so präzise, dass) فتأتي الفاصلة قبل dass مباشرة.',
      commaIsMandatory: true,
      changesMeaningOnSplit: false,
    ),
    CommaOrthographyExemplar(
      id: 'orth_08',
      domain: OrthographyEngineeringDomain.aerospaceAndAviation,
      category: CommaOrthographyCategory.nominalizedFixedPhrasesCap,
      cefrLevel: 'C1',
      ruleSignature: 'Großschreibung substantivierter Adjektive nach Präposition: im Voraus / im Folgenden / des Weiteren',
      germanSentence:
          'Im Folgenden werden die Schubwerte des Triebwerks im Voraus rechnerisch abgeglichen.',
      commonErrorTrap: 'im folgenden / im voraus / des weiteren (الكتابة بحرف صغير)',
      arabicExplanation:
          'تُكتب العبارات الاسمية المسبوقة بحرف جر أو أداة تعريف (im Folgenden, im Voraus, im Allgemeinen, des Weiteren) دائماً بحرف كبير.',
      commaIsMandatory: false,
      changesMeaningOnSplit: false,
    ),
    CommaOrthographyExemplar(
      id: 'orth_09',
      domain: OrthographyEngineeringDomain.industrialRobotics,
      category: CommaOrthographyCategory.getrenntVsZusammenSemanticShift,
      cefrLevel: 'C2',
      ruleSignature: 'frei sprechen (ohne Manuskript) vs. freisprechen (von Schuld/Pflicht entbinden)',
      germanSentence:
          'Der Systemarchitekt konnte bei der Abnahmepräsentation völlig frei sprechen.',
      commonErrorTrap: 'völlig freisprechen',
      arabicExplanation:
          'تُكتب frei sprechen منفصلةً عندما تعني التحدث ارتجالاً دون ورق، أما freisprechen متصلةً فتعني التبرئة أو الإعفاء.',
      commaIsMandatory: false,
      changesMeaningOnSplit: true,
    ),
    CommaOrthographyExemplar(
      id: 'orth_10',
      domain: OrthographyEngineeringDomain.civilInfrastructure,
      category: CommaOrthographyCategory.mandatoryInfinitiveComma,
      cefrLevel: 'C2',
      ruleSignature: 'Komma bei Korrelat "es" / "darauf" + erweiterter Infinitiv',
      germanSentence:
          'Die Bauleitung legte großen Wert darauf, die Bewehrungsabstände lückenlos zu dokumentieren.',
      commonErrorTrap: '...großen Wert darauf die Bewehrungsabstände zu dokumentieren',
      arabicExplanation:
          'وجود الضمير الرابط (darauf) في الجملة الرئيسية يفرض وضع الفاصلة وجوباً قبل الجملة المصدرية اللاحقة.',
      commaIsMandatory: true,
      changesMeaningOnSplit: false,
    ),
    CommaOrthographyExemplar(
      id: 'orth_11',
      domain: OrthographyEngineeringDomain.materialScience,
      category: CommaOrthographyCategory.nominalizedFixedPhrasesCap,
      cefrLevel: 'C2',
      ruleSignature: 'im Wesentlichen / auf dem Laufenden / bis auf Weiteres',
      germanSentence:
          'Die Messreihe bestätigt im Wesentlichen die Annahmen; das Team bleibt bis auf Weiteres auf dem Laufenden.',
      commonErrorTrap: 'im wesentlichen / bis auf weiteres / auf dem laufenden',
      arabicExplanation:
          'العبارات الاصطلاحية (im Wesentlichen, bis auf Weiteres, auf dem Laufenden) تُعامل كصفات مؤسمة وتبدأ بحرف كبير إلزامياً.',
      commaIsMandatory: false,
      changesMeaningOnSplit: false,
    ),
    CommaOrthographyExemplar(
      id: 'orth_12',
      domain: OrthographyEngineeringDomain.maritimeLogistics,
      category: CommaOrthographyCategory.soDassVsSoDegreeDass,
      cefrLevel: 'C1',
      ruleSignature: 'so [Adjektiv], dass (mit Komma direkt vor dass)',
      germanSentence:
          'Der Containerkran ist so konstruiert, dass er Windböen bis Stärke neun problemlos standhält.',
      commonErrorTrap: 'Der Containerkran ist konstruiert, so dass er...',
      arabicExplanation:
          'عندما تأتي so قبل الصفة أو اسم المفعول (so konstruiert) للدلالة على الكيفية والدرجة، توضع الفاصلة قبل dass وليس قبل so.',
      commaIsMandatory: true,
      changesMeaningOnSplit: false,
    ),
    CommaOrthographyExemplar(
      id: 'orth_13',
      domain: OrthographyEngineeringDomain.renewableEnergyGrid,
      category: CommaOrthographyCategory.appositivePairedCommas,
      cefrLevel: 'C2',
      ruleSignature: 'Eingeschobener Relativsatz mit paarigen Kommas',
      germanSentence:
          'Die Speicherbatterie, deren Kapazität über zehn Megawattstunden beträgt, stabilisiert die Frequenz.',
      commonErrorTrap: 'Die Speicherbatterie, deren Kapazität zehn MWh beträgt stabilisiert...',
      arabicExplanation:
          'الجملة الموصولة المعترضة وسط الجملة الرئيسية تحتاج إلى فاصلة افتتاحية وأخرى إغلاقية قبل الفعل الرئيسي (stabilisiert).',
      commaIsMandatory: true,
      changesMeaningOnSplit: false,
    ),
    CommaOrthographyExemplar(
      id: 'orth_14',
      domain: OrthographyEngineeringDomain.aerospaceAndAviation,
      category: CommaOrthographyCategory.getrenntVsZusammenSemanticShift,
      cefrLevel: 'C2',
      ruleSignature: 'richtigstellen (korrigieren) vs. richtig stellen (an den richtigen Platz stellen)',
      germanSentence:
          'Der Flugingenieur musste die fehlerhafte Kalibrierungskurve im Protokoll richtigstellen.',
      commonErrorTrap: 'die Kurve im Protokoll richtig stellen',
      arabicExplanation:
          'تُكتب richtigstellen متصلةً في المعنى الاصطلاحي (تصحيح خطأ أو معلومة)، ومنفصلةً فقط في المعنى المكاني الحرفي.',
      commaIsMandatory: false,
      changesMeaningOnSplit: true,
    ),
    CommaOrthographyExemplar(
      id: 'orth_15',
      domain: OrthographyEngineeringDomain.industrialRobotics,
      category: CommaOrthographyCategory.subordinateEndBeforeUndComma,
      cefrLevel: 'C1',
      ruleSignature: 'Komma vor entgegensetzenden Konjunktionen (aber, sondern, doch, jedoch)',
      germanSentence:
          'Der Sensor lieferte zwar Rohdaten, jedoch waren diese durch elektromagnetische Störungen verzerrt.',
      commonErrorTrap: 'Der Sensor lieferte Rohdaten jedoch waren diese verzerrt',
      arabicExplanation:
          'أمام أدوات الاستدراك والمقابلة (aber, sondern, doch, jedoch) تُوضع الفاصلة دائماً وبشكل إلزامي.',
      commaIsMandatory: true,
      changesMeaningOnSplit: false,
    ),
    CommaOrthographyExemplar(
      id: 'orth_16',
      domain: OrthographyEngineeringDomain.civilInfrastructure,
      category: CommaOrthographyCategory.nominalizedFixedPhrasesCap,
      cefrLevel: 'C2',
      ruleSignature: 'in Bezug auf / mit Bezug auf (Großschreibung von Bezug)',
      germanSentence:
          'In Bezug auf die Erdbebensicherheit erfüllt das Bauwerk sämtliche aktuellen Normen.',
      commonErrorTrap: 'in bezug auf (كتابة bezug بحرف صغير حسب الإملاء القديم)',
      arabicExplanation:
          'في الإملاء الألماني الحديث، يُكتب الاسم Bezug في عبارة (in Bezug auf) بحرف كبير دائماً.',
      commaIsMandatory: false,
      changesMeaningOnSplit: false,
    ),
  ];

  List<CommaOrthographyExemplar> get allExemplars => List.unmodifiable(_exemplars);

  List<CommaOrthographyExemplar> getByDomain(OrthographyEngineeringDomain domain) {
    return _exemplars.where((e) => e.domain == domain).toList(growable: false);
  }

  List<CommaOrthographyExemplar> getByCategory(CommaOrthographyCategory category) {
    return _exemplars.where((e) => e.category == category).toList(growable: false);
  }

  CommaOrthographyExemplar pickExemplarForDrill({
    OrthographyEngineeringDomain? domain,
    int seed = 4978,
  }) {
    final pool = domain == null ? _exemplars : getByDomain(domain);
    if (pool.isEmpty) {
      return _exemplars.first;
    }
    final rng = Random(seed);
    return pool[rng.nextInt(pool.length)];
  }

  /// التحقق الذكي من الترقيم الدلالي والإملاء المتقدم
  OrthographyValidationResult validateOrthographyAndComma(String sentence) {
    _validationRuns++;
    final normalized = sentence.trim();

    // 1. كشف غياب الفاصلة الإلزامية قبل um / ohne / statt / anstatt في الجمل المصدرية
    final missingInfComma = RegExp(
      r'[^,]\s+\b(um|ohne|statt|anstatt)\s+[^.!?]+\bzu\s+[a-zäöüß]+en\b',
      caseSensitive: false,
    );
    if (missingInfComma.hasMatch(normalized)) {
      _caughtMissingInfinitiveCommas++;
      final fixed = normalized.replaceFirstMapped(
        RegExp(r'(\S)\s+\b(um|ohne|statt|anstatt)\b', caseSensitive: false),
        (m) => '${m.group(1)}, ${m.group(2)}',
      );
      return OrthographyValidationResult(
        isValid: false,
        diagnosedRule: 'Kommapflicht vor eingeleiteter Infinitivgruppe (um/ohne/statt ... zu)',
        arabicFeedback:
            'الفاصلة إلزامية قبل الجمل المصدرية المبدوءة بـ (um / ohne / statt / anstatt).',
        correctedSuggestion: fixed,
      );
    }

    // 2. كشف كتابة العبارات الاسمية الثابتة بحرف صغير
    final lowercaseNominalTrap = RegExp(
      r'\b(im\s+voraus|im\s+folgenden|im\s+wesentlichen|im\s+allgemeinen|des\s+weiteren|in\s+bezug\s+auf)\b',
    );
    if (lowercaseNominalTrap.hasMatch(normalized)) {
      _caughtNominalizedCapErrors++;
      return const OrthographyValidationResult(
        isValid: false,
        diagnosedRule: 'Großschreibung substantivierter Ausdrücke (im Voraus, im Folgenden, in Bezug auf)',
        arabicFeedback:
            'يجب كتابة الأسماء والصفات المؤسمة في هذه العبارات الثابتة بحرف كبير (مثل: im Voraus, im Folgenden, im Wesentlichen, des Weiteren, in Bezug auf).',
        correctedSuggestion: 'im Voraus / im Folgenden / im Wesentlichen / des Weiteren / in Bezug auf',
      );
    }

    // 3. كشف كتابة richtig stellen منفصلة في المعنى المجازي للتصحيح
    final splitCompoundTrap = RegExp(
      r'\b(kurve|fehler|angabe|protokoll|wert)\b.*\brichtig\s+stellen\b',
      caseSensitive: false,
    );
    if (splitCompoundTrap.hasMatch(normalized)) {
      _caughtSplitCompoundErrors++;
      final fixed = normalized.replaceFirst(
        RegExp(r'\brichtig\s+stellen\b', caseSensitive: false),
        'richtigstellen',
      );
      return OrthographyValidationResult(
        isValid: false,
        diagnosedRule: 'Zusammenschreibung bei übertragener Bedeutung (richtigstellen)',
        arabicFeedback:
            'عندما يعني الفعل "تصحيح معلومة أو قياس" (معنى غير مكاني)، يُكتب متصلاً: richtigstellen.',
        correctedSuggestion: fixed,
      );
    }

    return const OrthographyValidationResult(
      isValid: true,
      diagnosedRule: 'Korrekte C1/C2-Zeichensetzung und Rechtschreibung',
      arabicFeedback: 'الترقيم والإملاء الدلالي سليمان تماماً وفق القواعد القياسية الحديثة.',
      correctedSuggestion: '',
    );
  }

  CommaOrthographyTelemetry get telemetry => CommaOrthographyTelemetry(
        totalExemplars: _exemplars.length,
        validationRuns: _validationRuns,
        caughtMissingInfinitiveCommas: _caughtMissingInfinitiveCommas,
        caughtNominalizedCapErrors: _caughtNominalizedCapErrors,
        caughtSplitCompoundErrors: _caughtSplitCompoundErrors,
      );
}
