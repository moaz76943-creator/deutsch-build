import 'dart:math';

/// مجالات الهندسة والتقنية المعتمدة في المنهج (خالية من المخاطر القانونية والطبية)
enum MorphologyEngineeringDomain {
  renewableEnergyGrid,
  aerospaceAndAviation,
  industrialRobotics,
  civilInfrastructure,
  materialScience,
  maritimeLogistics,
}

/// تصنيف أنماط الإعراب الضعيف (n-Deklination) وتمايز الجنس الدلالي (C1–C2)
enum DeclensionHomonymCategory {
  technicalWeakMasculineN,       // الأسماء المذكرة الضعيفة التقنية (Automat, Satellit, Magnet, Quotient)
  animateProfessionalWeakN,      // المهن والصفات المذكرة الضعيفة (Spezialist, Lieferant, Absolvent)
  mixedGenitiveNsException,      // الاستثناءات المختلطة بـ -ns في المضاف إليه (Name, Gedanke, Funke, Herz)
  strongVsWeakLookalikeTrap,     // التمييز بين الأسماء القوية المشابهة والضعيفة (Apparat -s مقابل Automat -en)
  technicalGenderHomonymPair,    // المتجانسات اللفظية متغيرة المعنى بتغير الجنس (der/das Moment, der/das Band)
  materialAndMaritimeHomonyms,   // متجانسات المواد والملاحة (der/das Gehalt, der/das Tau, der/die Leiter, der/das Schild)
}

/// نموذج تطبيقي للأسماء الضعيفة والمتجانسات متغيرة الجنس
class DeclensionHomonymExemplar {
  final String id;
  final MorphologyEngineeringDomain domain;
  final DeclensionHomonymCategory category;
  final String cefrLevel;
  final String targetLexeme;
  final String germanSentence;
  final String commonErrorTrap;
  final String arabicExplanation;
  final bool usesNDeclension;
  final bool hasGenderHomonymContrast;

  const DeclensionHomonymExemplar({
    required this.id,
    required this.domain,
    required this.category,
    required this.cefrLevel,
    required this.targetLexeme,
    required this.germanSentence,
    required this.commonErrorTrap,
    required this.arabicExplanation,
    required this.usesNDeclension,
    required this.hasGenderHomonymContrast,
  });
}

/// نتيجة الفحص الآلي لصحة الإعراب الضعيف واختيار الجنس الدلالي
class MorphologyValidationResult {
  final bool isValid;
  final String diagnosedRule;
  final String arabicFeedback;
  final String correctedSuggestion;

  const MorphologyValidationResult({
    required this.isValid,
    required this.diagnosedRule,
    required this.arabicFeedback,
    required this.correctedSuggestion,
  });
}

/// بيانات قياس الأداء والإحصاءات الداخلية للمحرك
class NDeclensionHomonymTelemetry {
  final int totalExemplars;
  final int validationRuns;
  final int caughtMissingNDeclensionErrors;
  final int caughtMixedGenitiveNsErrors;
  final int caughtGenderHomonymErrors;

  const NDeclensionHomonymTelemetry({
    required this.totalExemplars,
    required this.validationRuns,
    required this.caughtMissingNDeclensionErrors,
    required this.caughtMixedGenitiveNsErrors,
    required this.caughtGenderHomonymErrors,
  });
}

/// المحرك الأساسي لضبط الإعراب الضعيف (n-Deklination) والمتجانسات متغيرة الجنس (C1–C2)
class NDeclensionGenderHomonymEngine {
  int _validationRuns = 0;
  int _caughtMissingNDeclensionErrors = 0;
  int _caughtMixedGenitiveNsErrors = 0;
  int _caughtGenderHomonymErrors = 0;

  static const List<DeclensionHomonymExemplar> _exemplars = [
    DeclensionHomonymExemplar(
      id: 'morph_01',
      domain: MorphologyEngineeringDomain.aerospaceAndAviation,
      category: DeclensionHomonymCategory.technicalWeakMasculineN,
      cefrLevel: 'C1',
      targetLexeme: 'der Satellit -> des / dem / den Satelliten',
      germanSentence:
          'Die Bodenstation korrigierte die Umlaufbahn des niedrig fliegenden Satelliten präzise.',
      commonErrorTrap: 'des Satellits (إضافة -s القوية بدلاً من -en الضعيفة)',
      arabicExplanation:
          'الاسم التقني der Satellit يتبع الإعراب الضعيف (n-Deklination)، لذا يأخذ النهاية (-en) في جميع الحالات غير الرفع (Genitiv, Dativ, Akkusativ).',
      usesNDeclension: true,
      hasGenderHomonymContrast: false,
    ),
    DeclensionHomonymExemplar(
      id: 'morph_02',
      domain: MorphologyEngineeringDomain.industrialRobotics,
      category: DeclensionHomonymCategory.technicalWeakMasculineN,
      cefrLevel: 'C1',
      targetLexeme: 'der Automat -> des / dem / den Automaten',
      germanSentence:
          'Der Techniker überprüfte die Sicherheitsverriegelung des industriellen Bestückungsautomaten.',
      commonErrorTrap: 'des Bestückungsautomats (نسيان -en في الأسماء المنتهية بـ -at)',
      arabicExplanation:
          'معظم الأسماء المذكرة المنتهية بـ (-at) مثل der Automat تتبع الإعراب الضعيف، فتنتهي بـ (-en) في المضاف إليه والمجرور والمنصوب.',
      usesNDeclension: true,
      hasGenderHomonymContrast: false,
    ),
    DeclensionHomonymExemplar(
      id: 'morph_03',
      domain: MorphologyEngineeringDomain.renewableEnergyGrid,
      category: DeclensionHomonymCategory.technicalWeakMasculineN,
      cefrLevel: 'C2',
      targetLexeme: 'der Magnet -> des / dem / den Magneten',
      germanSentence:
          'Die Flussdichte des supraleitenden Magneten im Generator blieb über Stunden konstant.',
      commonErrorTrap: 'des Magnets (استخدام نهاية قوية مع Magnet)',
      arabicExplanation:
          'في الألمانية القياسية التقنية، يتبع der Magnet الإعراب الضعيف (des Magneten, dem Magneten, den Magneten).',
      usesNDeclension: true,
      hasGenderHomonymContrast: false,
    ),
    DeclensionHomonymExemplar(
      id: 'morph_04',
      domain: MorphologyEngineeringDomain.civilInfrastructure,
      category: DeclensionHomonymCategory.animateProfessionalWeakN,
      cefrLevel: 'C1',
      targetLexeme: 'der Lieferant -> des / dem / den Lieferanten',
      germanSentence:
          'Die Bauleitung forderte vom zertifizierten Lieferanten ein aktuelles Materialprüfzeugnis an.',
      commonErrorTrap: 'vom zertifizierten Lieferant (إسقاط -en في حالة Dativ)',
      arabicExplanation:
          'الأسماء المذكرة المنتهية بـ (-ant) مثل der Lieferant تأخذ النهاية (-en) في الجر (vom Lieferanten) والنصب والمضاف إليه.',
      usesNDeclension: true,
      hasGenderHomonymContrast: false,
    ),
    DeclensionHomonymExemplar(
      id: 'morph_05',
      domain: MorphologyEngineeringDomain.renewableEnergyGrid,
      category: DeclensionHomonymCategory.mixedGenitiveNsException,
      cefrLevel: 'C2',
      targetLexeme: 'der Funke -> des Funkens (Dat./Akk.: dem/den Funken)',
      germanSentence:
          'Die Entstehung eines elektrischen Funkens im Schaltfeld wurde durch die Schutzgasfüllung verhindert.',
      commonErrorTrap: 'eines elektrischen Funken (حذف -s من النهاية المختلطة -ns في المضاف إليه)',
      arabicExplanation:
          'الأسماء المختلطة (Funke, Name, Gedanke, Wille, Buchstabe) تأخذ (-ns) في المضاف إليه المفرد (des Funkens) و(-n) في الجر والنصب.',
      usesNDeclension: true,
      hasGenderHomonymContrast: false,
    ),
    DeclensionHomonymExemplar(
      id: 'morph_06',
      domain: MorphologyEngineeringDomain.industrialRobotics,
      category: DeclensionHomonymCategory.strongVsWeakLookalikeTrap,
      cefrLevel: 'C2',
      targetLexeme: 'der Apparat -> des Apparats (stark!) vs. der Automat -> des Automaten (schwach)',
      germanSentence:
          'Die Kalibrierung des optischen Messapparats dauerte weniger als fünf Minuten.',
      commonErrorTrap: 'des optischen Messapparaten (تعميم الإعراب الضعيف على Apparat)',
      arabicExplanation:
          'رغم انتهائه بـ -at، فإن der Apparat اسم قوي (stark) يأخذ (-s) في المضاف إليه (des Apparats) وليس (-en).',
      usesNDeclension: false,
      hasGenderHomonymContrast: false,
    ),
    DeclensionHomonymExemplar(
      id: 'morph_07',
      domain: MorphologyEngineeringDomain.industrialRobotics,
      category: DeclensionHomonymCategory.technicalGenderHomonymPair,
      cefrLevel: 'C1',
      targetLexeme: 'das Drehmoment (Physik/Technik) vs. der Moment (Augenblick)',
      germanSentence:
          'Das maximale Drehmoment des Servomotors wird bereits bei niedriger Drehzahl erreicht.',
      commonErrorTrap: 'Der maximale Drehmoment (الخلط بين اللحظة الزمنية المذكرة وعزم الدوران المحايد)',
      arabicExplanation:
          'كلمة Moment مذكرة (der Moment) عندما تعني "اللحظة الزمنية"، لكنها محايدة (das Moment / das Drehmoment) في الفيزياء والهندسة بمعنى "العزم".',
      usesNDeclension: false,
      hasGenderHomonymContrast: true,
    ),
    DeclensionHomonymExemplar(
      id: 'morph_08',
      domain: MorphologyEngineeringDomain.materialScience,
      category: DeclensionHomonymCategory.materialAndMaritimeHomonyms,
      cefrLevel: 'C1',
      targetLexeme: 'der Gehalt (Anteil/Konzentration) vs. das Gehalt (Lohn)',
      germanSentence:
          'Der genaue Kohlenstoffgehalt des Stahls bestimmt maßgeblich dessen Schweißbarkeit.',
      commonErrorTrap: 'Das genaue Kohlenstoffgehalt (استخدام das للمحتوى الكيميائي بدلاً من الراتب)',
      arabicExplanation:
          'يأتي الاسم Gehalt مذكراً (der Gehalt) للدلالة على النسبة أو المحتوى المادي (مثل محتوى الكربون)، ومحايداً (das Gehalt) بمعنى الراتب الشهري.',
      usesNDeclension: false,
      hasGenderHomonymContrast: true,
    ),
    DeclensionHomonymExemplar(
      id: 'morph_09',
      domain: MorphologyEngineeringDomain.renewableEnergyGrid,
      category: DeclensionHomonymCategory.materialAndMaritimeHomonyms,
      cefrLevel: 'C2',
      targetLexeme: 'der Leiter (elektrischer Leiter / Vorgesetzter) vs. die Leiter (Steighilfe)',
      germanSentence:
          'Ein supraleitender elektrischer Leiter transportiert hohe Gleichströme nahezu verlustfrei.',
      commonErrorTrap: 'Eine supraleitende Leiter (الخلط بين الموصل الكهربائي المذكر والسلم المؤنث)',
      arabicExplanation:
          'كلمة Leiter مذكرة (der Leiter) للموصل الكهربائي أو مدير القسم، ومؤنثة (die Leiter) للسلم الخشبي أو المعدني.',
      usesNDeclension: false,
      hasGenderHomonymContrast: true,
    ),
    DeclensionHomonymExemplar(
      id: 'morph_10',
      domain: MorphologyEngineeringDomain.maritimeLogistics,
      category: DeclensionHomonymCategory.materialAndMaritimeHomonyms,
      cefrLevel: 'C2',
      targetLexeme: 'das Tau (Schiffsseil/Trosse) vs. der Tau (Kondenswasser)',
      germanSentence:
          'Das armdicke Festmachertau wurde mit einer hydraulischen Winde straff gespannt.',
      commonErrorTrap: 'Der armdicke Tau (استخدام المذكر لحبل رسو السفينة)',
      arabicExplanation:
          'في الملاحة، حبل السفن السميك محايد (das Tau)، بينما الندى أو التكثف المائي مذكر (der Tau).',
      usesNDeclension: false,
      hasGenderHomonymContrast: true,
    ),
    DeclensionHomonymExemplar(
      id: 'morph_11',
      domain: MorphologyEngineeringDomain.civilInfrastructure,
      category: DeclensionHomonymCategory.technicalGenderHomonymPair,
      cefrLevel: 'C1',
      targetLexeme: 'das Band (Förderband/Klebeband) vs. der Band (Buchband)',
      germanSentence:
          'Das automatische Förderband transportiert den Abraum kontinuierlich aus dem Tunnel.',
      commonErrorTrap: 'Der automatische Förderband',
      arabicExplanation:
          'الاسم Band محايد (das Band) للسير الناقل أو الشريط، ومذكر (der Band) للمجلد الكتابي، ومؤنث (die Band) للفرقة.',
      usesNDeclension: false,
      hasGenderHomonymContrast: true,
    ),
    DeclensionHomonymExemplar(
      id: 'morph_12',
      domain: MorphologyEngineeringDomain.aerospaceAndAviation,
      category: DeclensionHomonymCategory.technicalGenderHomonymPair,
      cefrLevel: 'C2',
      targetLexeme: 'das Schild (Typenschild/Warnschild) vs. der Schild (Schutzschild)',
      germanSentence:
          'Das metallene Typenschild am Triebwerksgehäuse enthält alle Seriennummern.',
      commonErrorTrap: 'Der metallene Typenschild (الخلط مع der Hitzeschild الذي يعني الدرع الواقي)',
      arabicExplanation:
          'اللوحة التعريفية أو التحذيرية محايدة (das Schild / Typenschild)، بينما الدرع الواقي مذكر (der Schild / Hitzeschild).',
      usesNDeclension: false,
      hasGenderHomonymContrast: true,
    ),
    DeclensionHomonymExemplar(
      id: 'morph_13',
      domain: MorphologyEngineeringDomain.materialScience,
      category: DeclensionHomonymCategory.technicalWeakMasculineN,
      cefrLevel: 'C2',
      targetLexeme: 'der Quotient -> des / dem / den Quotienten',
      germanSentence:
          'Das Rechenmodell ermittelt den exakten Elastizitätsquotienten der Verbundfaser.',
      commonErrorTrap: 'den exakten Elastizitätsquotient',
      arabicExplanation:
          'الأسماء المذكرة المنتهية بـ (-ent) مثل Quotient و Koeffizient تتبع الإعراب الضعيف فتأخذ (-en) في النصب والجر والمضاف إليه.',
      usesNDeclension: true,
      hasGenderHomonymContrast: false,
    ),
    DeclensionHomonymExemplar(
      id: 'morph_14',
      domain: MorphologyEngineeringDomain.civilInfrastructure,
      category: DeclensionHomonymCategory.mixedGenitiveNsException,
      cefrLevel: 'C2',
      targetLexeme: 'der Gedanke -> des Gedankens',
      germanSentence:
          'Die Umsetzung dieses konstruktiven Gedankens sparte zwanzig Prozent Bewehrungsstahl ein.',
      commonErrorTrap: 'dieses konstruktiven Gedanken (نسيان -s في المضاف إليه المفرد)',
      arabicExplanation:
          'يُعرب der Gedanke إعراباً مختلطاً، فيأخذ (-ns) وجوباً في حالة المضاف إليه المفرد (des/dieses Gedankens).',
      usesNDeclension: true,
      hasGenderHomonymContrast: false,
    ),
    DeclensionHomonymExemplar(
      id: 'morph_15',
      domain: MorphologyEngineeringDomain.maritimeLogistics,
      category: DeclensionHomonymCategory.animateProfessionalWeakN,
      cefrLevel: 'C1',
      targetLexeme: 'der Lotse -> des / dem / den Lotsen',
      germanSentence:
          'Der Kapitän übergab die Navigation in der engen Fahrrinne an den erfahrenen Hafenlotsen.',
      commonErrorTrap: 'an den erfahrenen Hafenlotse (إسقاط -n في حالة Akkusativ)',
      arabicExplanation:
          'الاسم المذكر المنتهي بـ (-e) والدال على وظيفة (der Lotse) يتبع الإعراب الضعيف فيأخذ (-n) في النصب: an den Hafenlotsen.',
      usesNDeclension: true,
      hasGenderHomonymContrast: false,
    ),
    DeclensionHomonymExemplar(
      id: 'morph_16',
      domain: MorphologyEngineeringDomain.aerospaceAndAviation,
      category: DeclensionHomonymCategory.strongVsWeakLookalikeTrap,
      cefrLevel: 'C2',
      targetLexeme: 'das Herz -> des Herzens, dem Herzen (einziges schwaches Neutrum)',
      germanSentence:
          'Der Flugdatenrekorder bildet das technologische Herz — im Genitiv: das Auslesen des Herzens der Avionik.',
      commonErrorTrap: 'des Herzes (تصريف Herz تصريفاً قوياً)',
      arabicExplanation:
          'كلمة das Herz هي الاسم المحايد الوحيد الذي يتبع تصريفاً خاصاً مختلطاً: des Herzens في المضاف إليه و dem Herzen في الجر.',
      usesNDeclension: true,
      hasGenderHomonymContrast: false,
    ),
  ];

  List<DeclensionHomonymExemplar> get allExemplars => List.unmodifiable(_exemplars);

  List<DeclensionHomonymExemplar> getByDomain(MorphologyEngineeringDomain domain) {
    return _exemplars.where((e) => e.domain == domain).toList(growable: false);
  }

  List<DeclensionHomonymExemplar> getByCategory(DeclensionHomonymCategory category) {
    return _exemplars.where((e) => e.category == category).toList(growable: false);
  }

  DeclensionHomonymExemplar pickExemplarForDrill({
    MorphologyEngineeringDomain? domain,
    int seed = 4980,
  }) {
    final pool = domain == null ? _exemplars : getByDomain(domain);
    if (pool.isEmpty) {
      return _exemplars.first;
    }
    final rng = Random(seed);
    return pool[rng.nextInt(pool.length)];
  }

  /// التحقق الذكي من الإعراب الضعيف وتمايز الجنس الدلالي
  MorphologyValidationResult validateMorphology(String sentence) {
    _validationRuns++;
    final normalized = sentence.trim();
    final lower = normalized.toLowerCase();

    // 1. كشف استخدام النهاية القوية -s أو عدم تصريف الأسماء الضعيفة (Satellit, Automat, Magnet, Lieferant)
    final missingWeakNTrap = RegExp(
      r'\b(des|dem|den|eines|einem|einen|vom|zum)\s+([a-zäöüß]+\s+)?(satellits?|automats?|magnets?|lieferant|quotient|hafenlotse)\b',
      caseSensitive: false,
    );
    if (missingWeakNTrap.hasMatch(lower)) {
      _caughtMissingNDeclensionErrors++;
      return const MorphologyValidationResult(
        isValid: false,
        diagnosedRule: 'n-Deklination: Endung -(e)n im Genitiv, Dativ und Akkusativ Singular',
        arabicFeedback:
            'هذا الاسم المذكر يتبع الإعراب الضعيف (n-Deklination)، لذا يجب أن ينتهي بـ (-en / -n) في المضاف إليه والمجرور والمنصوب.',
        correctedSuggestion: 'des/dem/den Satelliten | Automaten | Magneten | Lieferanten | Quotienten',
      );
    }

    // 2. كشف سقوط -s في المضاف إليه للأسماء المختلطة (des Funken / des Gedanken / des Namen)
    final missingNsGenitiveTrap = RegExp(
      r'\b(des|eines|dieses)\s+([a-zäöüß]+\s+)?(funken|gedanken|namen|willen|buchstaben)\b',
      caseSensitive: false,
    );
    if (missingNsGenitiveTrap.hasMatch(lower)) {
      _caughtMixedGenitiveNsErrors++;
      return const MorphologyValidationResult(
        isValid: false,
        diagnosedRule: 'Gemischte Deklination: Genitiv Singular auf -ns (des Funkens / Gedankens / Namens)',
        arabicFeedback:
            'الأسماء المختلطة (Funke, Gedanke, Name, Wille, Buchstabe) تأخذ (-ns) في حالة المضاف إليه المفرد (des Funkens / des Gedankens).',
        correctedSuggestion: 'des/eines Funkens | Gedankens | Namens',
      );
    }

    // 3. كشف الخلط الدلالي في جنس المتجانسات التقنية (der Drehmoment / das Kohlenstoffgehalt / der Förderband)
    if (RegExp(r'\b(der|den|dem)\s+([a-zäöüß]+\s+)?drehmoment\b', caseSensitive: false).hasMatch(lower) ||
        RegExp(r'\b(das)\s+([a-zäöüß]+\s+)?kohlenstoffgehalt\b', caseSensitive: false).hasMatch(lower) ||
        RegExp(r'\b(der)\s+([a-zäöüß]+\s+)?förderband\b', caseSensitive: false).hasMatch(lower)) {
      _caughtGenderHomonymErrors++;
      return const MorphologyValidationResult(
        isValid: false,
        diagnosedRule: 'Genus-Bedeutungsunterscheidung bei technischen Homonymen',
        arabicFeedback:
            'تنبه إلى جنس الكلمة المرتبط بمعناها الهندسي: das Drehmoment (محايد)، der Kohlenstoffgehalt (مذكر)، das Förderband (محايد).',
        correctedSuggestion: 'das Drehmoment / der Kohlenstoffgehalt / das Förderband',
      );
    }

    return const MorphologyValidationResult(
      isValid: true,
      diagnosedRule: 'Korrekte C1/C2-n-Deklination und Genus-Homonymwahl',
      arabicFeedback: 'الإعراب الضعيف واختيار الجنس الدلالي سليمان تماماً.',
      correctedSuggestion: '',
    );
  }

  NDeclensionHomonymTelemetry get telemetry => NDeclensionHomonymTelemetry(
        totalExemplars: _exemplars.length,
        validationRuns: _validationRuns,
        caughtMissingNDeclensionErrors: _caughtMissingNDeclensionErrors,
        caughtMixedGenitiveNsErrors: _caughtMixedGenitiveNsErrors,
        caughtGenderHomonymErrors: _caughtGenderHomonymErrors,
      );
}
