import 'dart:math';

/// مجالات الهندسة والتقنية المعتمدة في المنهج (خالية من المخاطر القانونية والطبية)
enum DeclensionEngineeringDomain {
  renewableEnergyGrid,
  aerospaceAndAviation,
  industrialRobotics,
  civilInfrastructure,
  materialScience,
  maritimeLogistics,
}

/// تصنيف الحالات الدقيقة لتصريف الصفات والأسماء المشتقة من الصفات (C1–C2)
enum AdjectiveDeclensionEdgeCategory {
  pluralQuantifierStrongVsWeak,   // التمييز بين viele/einige/mehrere (قوي) و alle/beide/sämtliche (ضعيف)
  indefinitePronounNominalized,   // الصفات المؤسمة بعد etwas/nichts/viel (-es) مقابل alles (-e)
  genitiveStrongSingularEnRule,   // المضاف إليه المفرد المذكر والمحايد بدون أداة (نهاية -en للصفات)
  nominalizedParticipleAgreement, // اسم الفاعل واسم المفعول المؤسم (der/ein Leitende, die Betroffenen)
  parallelStackedAdjectives,      // التصريف المتوازي للصفات المتعددة في الجر والمضاف إليه
  invariableCityAndLoanAdjectives,// الصفات غير المتصرفة (-er للمدن، rosa/lila/prima، و ganz/halb بدون أداة)
}

/// نموذج تطبيقي لحالات تصريف الصفات المتقدمة
class AdjectiveDeclensionExemplar {
  final String id;
  final DeclensionEngineeringDomain domain;
  final AdjectiveDeclensionEdgeCategory category;
  final String cefrLevel;
  final String triggerPattern;
  final String germanSentence;
  final String commonErrorTrap;
  final String arabicExplanation;
  final String inflectionType; // 'stark', 'schwach', 'gemischt', 'unflektiert'

  const AdjectiveDeclensionExemplar({
    required this.id,
    required this.domain,
    required this.category,
    required this.cefrLevel,
    required this.triggerPattern,
    required this.germanSentence,
    required this.commonErrorTrap,
    required this.arabicExplanation,
    required this.inflectionType,
  });
}

/// نتيجة الفحص الآلي لصحة تصريف الصفة أو الاسم المشتق
class DeclensionValidationResult {
  final bool isValid;
  final String diagnosedRule;
  final String arabicFeedback;
  final String correctedSuggestion;

  const DeclensionValidationResult({
    required this.isValid,
    required this.diagnosedRule,
    required this.arabicFeedback,
    required this.correctedSuggestion,
  });
}

/// بيانات قياس الأداء والإحصاءات الداخلية للمحرك
class AdjectiveDeclensionTelemetry {
  final int totalExemplars;
  final int validationRuns;
  final int caughtQuantifierDeclensionErrors;
  final int caughtIndefiniteNominalErrors;
  final int caughtGenitiveEndingErrors;

  const AdjectiveDeclensionTelemetry({
    required this.totalExemplars,
    required this.validationRuns,
    required this.caughtQuantifierDeclensionErrors,
    required this.caughtIndefiniteNominalErrors,
    required this.caughtGenitiveEndingErrors,
  });
}

/// المحرك الأساسي لضبط استثناءات تصريف الصفات والأسماء المشتقة (C1–C2)
class AdjectiveNominalizationDeclensionEngine {
  int _validationRuns = 0;
  int _caughtQuantifierDeclensionErrors = 0;
  int _caughtIndefiniteNominalErrors = 0;
  int _caughtGenitiveEndingErrors = 0;

  static const List<AdjectiveDeclensionExemplar> _exemplars = [
    AdjectiveDeclensionExemplar(
      id: 'adj_01',
      domain: DeclensionEngineeringDomain.renewableEnergyGrid,
      category: AdjectiveDeclensionEdgeCategory.pluralQuantifierStrongVsWeak,
      cefrLevel: 'C1',
      triggerPattern: 'alle / sämtliche + [schwache Endung -en]',
      germanSentence:
          'Sämtliche neuen Wechselrichter wurden vor der Netzsynchronisation unter Volllast kalibriert.',
      commonErrorTrap: 'Sämtliche neue Wechselrichter (استخدام النهاية القوية -e بدل الضعيفة -en)',
      arabicExplanation:
          'الكلمات الكمية (alle, beide, sämtliche) تعمل كأدوات تعريف جمعية، لذا تأخذ الصفة بعدها النهاية الضعيفة (-en) في الرفع والنصب.',
      inflectionType: 'schwach',
    ),
    AdjectiveDeclensionExemplar(
      id: 'adj_02',
      domain: DeclensionEngineeringDomain.aerospaceAndAviation,
      category: AdjectiveDeclensionEdgeCategory.pluralQuantifierStrongVsWeak,
      cefrLevel: 'C1',
      triggerPattern: 'viele / einige / mehrere / wenige + [starke Endung -e]',
      germanSentence:
          'Mehrere kritische Sensoren lieferten während des Steigflugs redundante Telemetriedaten.',
      commonErrorTrap: 'Mehrere kritischen Sensoren (إضافة -en خطأً بعد mehrere/viele/einige)',
      arabicExplanation:
          'على عكس alle، تُعامل (viele, wenige, einige, mehrere, etliche) كصفات منسقة، فتأخذ الصفة التالية لها النهاية القوية (-e) في الرفع والنصب.',
      inflectionType: 'stark',
    ),
    AdjectiveDeclensionExemplar(
      id: 'adj_03',
      domain: DeclensionEngineeringDomain.industrialRobotics,
      category: AdjectiveDeclensionEdgeCategory.indefinitePronounNominalized,
      cefrLevel: 'C1',
      triggerPattern: 'etwas / nichts / viel / wenig + [Nominalisiertes Adjektiv auf -es]',
      germanSentence:
          'Bei der Inspektion des Greifarms trat nichts Unvorhergesehenes auf.',
      commonErrorTrap: 'nichts unvorhergesehene / nichts Unvorhergesehene (إهمال النهاية -es أو الحرف الكبير)',
      arabicExplanation:
          'بعد الضمائر المبهمة غير المصرفة (etwas, nichts, viel, wenig) يُكتب الاسم المشتق من الصفة بحرف كبير ويأخذ النهاية القوية للمحايد (-es).',
      inflectionType: 'stark',
    ),
    AdjectiveDeclensionExemplar(
      id: 'adj_04',
      domain: DeclensionEngineeringDomain.materialScience,
      category: AdjectiveDeclensionEdgeCategory.indefinitePronounNominalized,
      cefrLevel: 'C2',
      triggerPattern: 'alles + [Nominalisiertes Adjektiv auf -e]',
      germanSentence:
          'Das Laborprotokoll dokumentiert alles Wesentliche über die Wärmebehandlung der Legierung.',
      commonErrorTrap: 'alles Wesentliches (الخلط بين قاعدة etwas/nichts وقاعدة alles)',
      arabicExplanation:
          'بخلاف etwas و nichts، يُصرف الضمير alles نفسه كأداة، لذا يأخذ الاسم المشتق من الصفة بعده النهاية الضعيفة (-e): alles Wesentliche.',
      inflectionType: 'schwach',
    ),
    AdjectiveDeclensionExemplar(
      id: 'adj_05',
      domain: DeclensionEngineeringDomain.civilInfrastructure,
      category: AdjectiveDeclensionEdgeCategory.genitiveStrongSingularEnRule,
      cefrLevel: 'C2',
      triggerPattern: 'Präposition (trotz/während/infolge) + [starkes Adjektiv -en] + [Mask./Neutr. Genitiv]',
      germanSentence:
          'Trotz hohen Grundwasserdrucks blieb die Schlitzwand der Baugrube vollständig dicht.',
      commonErrorTrap: 'Trotz hohes Grundwasserdrucks (استخدام -es في المضاف إليه المذكر/المحايد)',
      arabicExplanation:
          'في حالة المضاف إليه (Genitiv) للمفرد المذكر والمحايد الخالي من أداة التعريف، تأخذ الصفة النهاية (-en) وليس (-es) لأن الاسم يحمل علامة (-s/-es).',
      inflectionType: 'stark',
    ),
    AdjectiveDeclensionExemplar(
      id: 'adj_06',
      domain: DeclensionEngineeringDomain.maritimeLogistics,
      category: AdjectiveDeclensionEdgeCategory.nominalizedParticipleAgreement,
      cefrLevel: 'C1',
      triggerPattern: 'ein + [Nominalisiertes Partizip I/II -er] / der + [-e]',
      germanSentence:
          'Ein Leitender der Hafenbehörde bestätigte die sichere Ankunft des Containerschiffs.',
      commonErrorTrap: 'Ein Leitende (نسيان التصريف المختلط -er بعد أداة التنكير ein)',
      arabicExplanation:
          'أسماء الفاعل والمفعول المؤسمة (der/ein Leitende, der/ein Beauftragte) تحتفظ بنظام تصريف الصفات كاملاً حسب الأداة والحالة الإعرابية.',
      inflectionType: 'gemischt',
    ),
    AdjectiveDeclensionExemplar(
      id: 'adj_07',
      domain: DeclensionEngineeringDomain.aerospaceAndAviation,
      category: AdjectiveDeclensionEdgeCategory.nominalizedParticipleAgreement,
      cefrLevel: 'C2',
      triggerPattern: 'Dativ Plural: den + [Partizip II -en] / ohne Artikel: [-en]',
      germanSentence:
          'Allen Beteiligten lag der überarbeitete Prüfbericht vor dem Triebwerkstest vor.',
      commonErrorTrap: 'Allen Beteiligte (إسقاط نهاية -en في حالة Dativ الجمع)',
      arabicExplanation:
          'في حالة المجرور الجمع (Dativ Plural) بعد allen، تأخذ الصفة أو اسم المفعول المؤسم النهاية (-en): Allen Beteiligten.',
      inflectionType: 'schwach',
    ),
    AdjectiveDeclensionExemplar(
      id: 'adj_08',
      domain: DeclensionEngineeringDomain.materialScience,
      category: AdjectiveDeclensionEdgeCategory.parallelStackedAdjectives,
      cefrLevel: 'C1',
      triggerPattern: 'mit + [Adjektiv 1 -em], [Adjektiv 2 -em] + [Nomen]',
      germanSentence:
          'Die Brennkammer wurde vor dem Versuch mit reinem, trockenem Stickstoff gespült.',
      commonErrorTrap: 'mit reinem, trockenen Stickstoff (تضعيف الصفة الثانية في حالة الجر القوي)',
      arabicExplanation:
          'الصفان المتوازيان غير المسبوقين بأداة يحملان نفس النهاية القوية في الألمانية المعاصرة (mit reinem, trockenem Stickstoff).',
      inflectionType: 'stark',
    ),
    AdjectiveDeclensionExemplar(
      id: 'adj_09',
      domain: DeclensionEngineeringDomain.renewableEnergyGrid,
      category: AdjectiveDeclensionEdgeCategory.invariableCityAndLoanAdjectives,
      cefrLevel: 'C1',
      triggerPattern: '[Ortsname + -er (unflektiert)] + [Nomen]',
      germanSentence:
          'Die Münchener Forschungsstelle entwickelte einen hocheffizienten Supraleiter für Umspannwerke.',
      commonErrorTrap: 'Die Münchenere Forschungsstelle (محاولة تصريف صفات المدن المنتهية بـ -er)',
      arabicExplanation:
          'الصفات المشتقة من أسماء المدن والمناطق بإضافة (-er) مثل Münchener و Berliner تظل جامدة لا تُصرف أبداً وتُكتب دائماً بحرف كبير.',
      inflectionType: 'unflektiert',
    ),
    AdjectiveDeclensionExemplar(
      id: 'adj_10',
      domain: DeclensionEngineeringDomain.industrialRobotics,
      category: AdjectiveDeclensionEdgeCategory.invariableCityAndLoanAdjectives,
      cefrLevel: 'C2',
      triggerPattern: '[ganz/halb ohne Artikel vor Ortsnamen (unflektiert)] vs. [mit Artikel (flektiert)]',
      germanSentence:
          'Ganz Stuttgart verfolgte den erfolgreichen Probelauf der automatisierten Montagetrasse.',
      commonErrorTrap: 'Ganzes Stuttgart (تصريف ganz أو halb قبل أسماء المدن بدون أداة)',
      arabicExplanation:
          'تبقى كلمتا ganz و halb بدون نهايات تصريفية عندما تسبقان اسم مدينة أو دولة محايداً بدون أداة تعريف.',
      inflectionType: 'unflektiert',
    ),
    AdjectiveDeclensionExemplar(
      id: 'adj_11',
      domain: DeclensionEngineeringDomain.civilInfrastructure,
      category: AdjectiveDeclensionEdgeCategory.pluralQuantifierStrongVsWeak,
      cefrLevel: 'C2',
      triggerPattern: 'beide + [schwache Endung -en] vs. zwei + [starke Endung -e]',
      germanSentence:
          'Beide äußeren Brückenpfeiler wurden mit zusätzlichen Dehnungssensoren ausgestattet.',
      commonErrorTrap: 'Beide äußere Brückenpfeiler',
      arabicExplanation:
          'لفظ beide يفرض التصريف الضعيف (-en) على الصفة التي تليه في الرفع والنصب، على عكس الأعداد الأساسية (zwei äußere Pfeiler).',
      inflectionType: 'schwach',
    ),
    AdjectiveDeclensionExemplar(
      id: 'adj_12',
      domain: DeclensionEngineeringDomain.maritimeLogistics,
      category: AdjectiveDeclensionEdgeCategory.genitiveStrongSingularEnRule,
      cefrLevel: 'C2',
      triggerPattern: 'infolge + [starkes Adjektiv -en] + [starker Genitiv -s]',
      germanSentence:
          'Infolge starken Seegangs musste das Entladen der Schwerlastkräne unterbrochen werden.',
      commonErrorTrap: 'Infolge starkes Seegangs',
      arabicExplanation:
          'في المضاف إليه للمذكر المفرد بدون أداة، تنتهي الصفة بـ (-en) لأن علامة (-s) موجودة بالفعل في نهاية الاسم (Seegangs).',
      inflectionType: 'stark',
    ),
    AdjectiveDeclensionExemplar(
      id: 'adj_13',
      domain: DeclensionEngineeringDomain.aerospaceAndAviation,
      category: AdjectiveDeclensionEdgeCategory.indefinitePronounNominalized,
      cefrLevel: 'C2',
      triggerPattern: 'viel + [Nominalisiertes Adjektiv -es] vs. viele + [Adjektiv -e]',
      germanSentence:
          'Die Flugschreiberdaten enthielten viel Brauchbares für die Optimierung der Aerodynamik.',
      commonErrorTrap: 'viel Brauchbare',
      arabicExplanation:
          'عندما تأتي viel مفردة غير مصرفة، يتبعها الاسم المشتق من الصفة بنهاية المحايد القوية (-es): viel Brauchbares.',
      inflectionType: 'stark',
    ),
    AdjectiveDeclensionExemplar(
      id: 'adj_14',
      domain: DeclensionEngineeringDomain.materialScience,
      category: AdjectiveDeclensionEdgeCategory.parallelStackedAdjectives,
      cefrLevel: 'C2',
      triggerPattern: 'aufgrund + [Adjektiv 1 -en], [Adjektiv 2 -en] + [Mask. Genitiv]',
      germanSentence:
          'Aufgrund gleichmäßigen, kontrollierten Abkühlens bildete sich ein feinkörniges Gefüge.',
      commonErrorTrap: 'Aufgrund gleichmäßiges, kontrolliertes Abkühlens',
      arabicExplanation:
          'حتى مع الصفات المتعددة قبل اسم مصدر مؤسم محايد في حالة المضاف إليه (das Abkühlen -> Abkühlens)، تأخذ كلتا الصفتين نهاية (-en).',
      inflectionType: 'stark',
    ),
    AdjectiveDeclensionExemplar(
      id: 'adj_15',
      domain: DeclensionEngineeringDomain.renewableEnergyGrid,
      category: AdjectiveDeclensionEdgeCategory.nominalizedParticipleAgreement,
      cefrLevel: 'C1',
      triggerPattern: 'die + [Nominalisiertes Adjektiv Plural -en]',
      germanSentence:
          'Die Zuständigen für die Netzstabilität prüften alle Lastspitzen in Echtzeit.',
      commonErrorTrap: 'Die Zuständige für die Netzstabilität (إسقاط -en في الجمع المعرّف)',
      arabicExplanation:
          'الصفة المؤسمة في الجمع المعرّف بـ die تأخذ دائماً النهاية الضعيفة (-en) في الرفع والنصب والجر.',
      inflectionType: 'schwach',
    ),
    AdjectiveDeclensionExemplar(
      id: 'adj_16',
      domain: DeclensionEngineeringDomain.maritimeLogistics,
      category: AdjectiveDeclensionEdgeCategory.invariableCityAndLoanAdjectives,
      cefrLevel: 'C1',
      triggerPattern: 'Farb- und Lehnadjektive (rosa, lila, prima, extra) + [unflektiert]',
      germanSentence:
          'Die Container der Gefahrgutklasse erhielten eine extra Markierung am Bug.',
      commonErrorTrap: 'eine extra-e / extrae Markierung',
      arabicExplanation:
          'الصفات الدخيلة وبعض صفات الألوان مثل (extra, prima, rosa, lila) لا تقبل نهايات التصريف أمام الأسماء في الألمانية القياسية.',
      inflectionType: 'unflektiert',
    ),
  ];

  List<AdjectiveDeclensionExemplar> get allExemplars => List.unmodifiable(_exemplars);

  List<AdjectiveDeclensionExemplar> getByDomain(DeclensionEngineeringDomain domain) {
    return _exemplars.where((e) => e.domain == domain).toList(growable: false);
  }

  List<AdjectiveDeclensionExemplar> getByCategory(AdjectiveDeclensionEdgeCategory category) {
    return _exemplars.where((e) => e.category == category).toList(growable: false);
  }

  AdjectiveDeclensionExemplar pickExemplarForDrill({
    DeclensionEngineeringDomain? domain,
    int seed = 4975,
  }) {
    final pool = domain == null ? _exemplars : getByDomain(domain);
    if (pool.isEmpty) {
      return _exemplars.first;
    }
    final rng = Random(seed);
    return pool[rng.nextInt(pool.length)];
  }

  /// التحقق الذكي من حالات تصريف الصفات الدقيقة في C1–C2
  DeclensionValidationResult validateDeclension(String sentence) {
    _validationRuns++;
    final normalized = sentence.trim();
    final lower = normalized.toLowerCase();

    // 1. كشف خطأ النهاية القوية -e بعد alle / beide / sämtliche في الرفع/النصب الجمع
    final weakQuantifierTrap = RegExp(
      r'\b(alle|beide|sämtliche)\s+[a-zäöüß]+e\s+[A-ZÄÖÜ][a-zäöüß]+',
      caseSensitive: false,
    );
    if (weakQuantifierTrap.hasMatch(normalized)) {
      _caughtQuantifierDeclensionErrors++;
      return const DeclensionValidationResult(
        isValid: false,
        diagnosedRule: 'Schwache Adjektivdeklination (-en) nach alle / beide / sämtliche',
        arabicFeedback:
            'تُعامل (alle / beide / sämtliche) كأدوات تعريف جمعية، لذا يجب أن تنتهي الصفة بعدها بـ (-en) وليس (-e).',
        correctedSuggestion: '[alle/beide/sämtliche] + [Adjektiv auf -en] + [Pluralnomen]',
      );
    }

    // 2. كشف خطأ النهاية -es بعد alles أو النهاية -e بعد etwas/nichts
    if (RegExp(r'\balles\s+[A-ZÄÖÜ][a-zäöüß]+es\b').hasMatch(normalized)) {
      _caughtIndefiniteNominalErrors++;
      return const DeclensionValidationResult(
        isValid: false,
        diagnosedRule: 'Schwache Endung (-e) nach "alles"',
        arabicFeedback:
            'بعد الضمير المصرف alles، يأخذ الاسم المشتق من الصفة النهاية الضعيفة (-e) مثل alles Wesentliche وليس (-es).',
        correctedSuggestion: 'alles + [Nominalisiertes Adjektiv auf -e]',
      );
    }
    if (RegExp(r'\b(etwas|nichts)\s+[A-ZÄÖÜ][a-zäöüß]+e\b').hasMatch(normalized)) {
      _caughtIndefiniteNominalErrors++;
      return const DeclensionValidationResult(
        isValid: false,
        diagnosedRule: 'Starke Neutrum-Endung (-es) nach "etwas / nichts"',
        arabicFeedback:
            'بعد الضمائر المبهمة غير المصرفة (etwas / nichts)، يجب أن ينتهي الاسم المشتق من الصفة بـ (-es) وليس (-e).',
        correctedSuggestion: 'etwas/nichts + [Nominalisiertes Adjektiv auf -es]',
      );
    }

    // 3. كشف خطأ المضاف إليه المفرد المذكر/المحايد بوضع -es للصفة قبل اسم ينتهي بـ -s
    final genitiveEsTrap = RegExp(
      r'\b(trotz|während|infolge|aufgrund|wegen)\s+[a-zäöüß]+es\s+[A-ZÄÖÜ][a-zäöüß]+s\b',
      caseSensitive: false,
    );
    if (genitiveEsTrap.hasMatch(lower)) {
      _caughtGenitiveEndingErrors++;
      return const DeclensionValidationResult(
        isValid: false,
        diagnosedRule: 'Genitiv Singular Mask./Neutr. ohne Artikel: Adjektiv auf -en',
        arabicFeedback:
            'في حالة المضاف إليه المفرد للمذكر والمحايد بدون أداة، تأخذ الصفة نهاية (-en) بدلاً من (-es) لأن الاسم يحمل علامة (-s).',
        correctedSuggestion: '[Präposition] + [Adjektiv auf -en] + [Nomen auf -s/-es]',
      );
    }

    return const DeclensionValidationResult(
      isValid: true,
      diagnosedRule: 'Korrekte C1/C2-Adjektiv- und Nominalisierungsdeklination',
      arabicFeedback: 'تصريف الصفات والأسماء المشتقة سليم ومطابق لقواعد الألمانية القياسية.',
      correctedSuggestion: '',
    );
  }

  AdjectiveDeclensionTelemetry get telemetry => AdjectiveDeclensionTelemetry(
        totalExemplars: _exemplars.length,
        validationRuns: _validationRuns,
        caughtQuantifierDeclensionErrors: _caughtQuantifierDeclensionErrors,
        caughtIndefiniteNominalErrors: _caughtIndefiniteNominalErrors,
        caughtGenitiveEndingErrors: _caughtGenitiveEndingErrors,
      );
}
