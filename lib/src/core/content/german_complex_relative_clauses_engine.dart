import 'dart:math';

/// مجالات الهندسة والتقنية المعتمدة في المنهج (خالية من المخاطر القانونية والطبية)
enum EngineeringRelativeDomain {
  renewableEnergyGrid,
  aerospaceAndAviation,
  industrialRobotics,
  civilInfrastructure,
  materialScience,
  maritimeLogistics,
}

/// تصنيف أنماط الجمل الموصولة المعقدة في الألمانية (C1–C2)
enum RelativeClauseCategory {
  genitiveMascNeutDessen,        // الموصول المضاف للمذكر والمحايد المفرد (dessen)
  genitiveFemPluralDeren,        // الموصول المضاف للمؤنث المفرد والجمع (deren)
  prepositionPlusGenitiveRelative,// حرف جر + dessen / deren + اسم (بدون أداة تعريف)
  pronominalAdverbWoRClause,     // الظرف الموصول wo(r)- لإحالة جملة كاملة أو ضمير مبهم
  concretePrepRelativePronoun,   // حرف جر + ضمير موصول للأسماء الملموسة (منع wo(r)-)
  indefiniteAndSuperlativeWas,   // استخدام was بعد alles, nichts, etwas, الصفات التفضيلية، أو جملة كاملة
  freeRelativeAndSpatialWo,      // الجمل الموصولة الحرة (wer/wessen) والمكانية (wo/wohin)
}

/// نموذج تفصيلي لمثال تطبيقي في الجمل الموصولة المعقدة
class ComplexRelativeExemplar {
  final String id;
  final EngineeringRelativeDomain domain;
  final RelativeClauseCategory category;
  final String cefrLevel;
  final String antecedent;
  final String relativeMarker;
  final String germanSentence;
  final String commonErrorTrap;
  final String arabicExplanation;
  final bool dropsFollowingArticle;
  final bool refersToWholeClause;

  const ComplexRelativeExemplar({
    required this.id,
    required this.domain,
    required this.category,
    required this.cefrLevel,
    required this.antecedent,
    required this.relativeMarker,
    required this.germanSentence,
    required this.commonErrorTrap,
    required this.arabicExplanation,
    required this.dropsFollowingArticle,
    required this.refersToWholeClause,
  });
}

/// نتيجة التحقق التلقائي من صحة صياغة الجملة الموصولة
class RelativeValidationResult {
  final bool isValid;
  final String diagnosedRule;
  final String arabicFeedback;
  final String correctedSuggestion;

  const RelativeValidationResult({
    required this.isValid,
    required this.diagnosedRule,
    required this.arabicFeedback,
    required this.correctedSuggestion,
  });
}

/// بيانات قياس الأداء والإحصاءات الداخلية للمحرك
class ComplexRelativeTelemetry {
  final int totalExemplars;
  final int validationRuns;
  final int caughtGenitiveArticleErrors;
  final int caughtWoRConcreteErrors;
  final int caughtWasDasMismatches;

  const ComplexRelativeTelemetry({
    required this.totalExemplars,
    required this.validationRuns,
    required this.caughtGenitiveArticleErrors,
    required this.caughtWoRConcreteErrors,
    required this.caughtWasDasMismatches,
  });
}

/// المحرك الأساسي لتحليل وتدريب الجمل الموصولة المعقدة والمضاف إليها (C1–C2)
class ComplexRelativeClauseEngine {
  int _validationRuns = 0;
  int _caughtGenitiveArticleErrors = 0;
  int _caughtWoRConcreteErrors = 0;
  int _caughtWasDasMismatches = 0;

  static const List<ComplexRelativeExemplar> _exemplars = [
    ComplexRelativeExemplar(
      id: 'rel_01',
      domain: EngineeringRelativeDomain.renewableEnergyGrid,
      category: RelativeClauseCategory.genitiveMascNeutDessen,
      cefrLevel: 'C1',
      antecedent: 'der Wechselrichter (مذكر مفرد)',
      relativeMarker: 'dessen',
      germanSentence:
          'Der Wechselrichter, dessen Wirkungsgrad unter Volllast bei 98,4 Prozent liegt, speist das Netz stabil.',
      commonErrorTrap: 'dessen der Wirkungsgrad (إضافة أداة تعريف بعد dessen)',
      arabicExplanation:
          'يعود الضمير dessen على المذكر المفرد (der Wechselrichter) ويحل محل أداة التعريف للاسم الذي يليه (Wirkungsgrad) مباشرةً دون أي أداة.',
      dropsFollowingArticle: true,
      refersToWholeClause: false,
    ),
    ComplexRelativeExemplar(
      id: 'rel_02',
      domain: EngineeringRelativeDomain.aerospaceAndAviation,
      category: RelativeClauseCategory.genitiveFemPluralDeren,
      cefrLevel: 'C1',
      antecedent: 'die Turbine (مؤنث مفرد)',
      relativeMarker: 'deren',
      germanSentence:
          'Die Turbine, deren Schaufeln aus einer Titanlegierung bestehen, hält extremen Temperaturen stand.',
      commonErrorTrap: 'dessen Schaufeln (الخلط بين جنس المضاف وجنس المضاف إليه)',
      arabicExplanation:
          'يتطابق الضمير الموصول المضاف مع الاسم المرجعي السابق (die Turbine - مؤنث مفرد) فنختار deren، بغض النظر عن كون الاسم اللاحق (Schaufeln) جمعاً.',
      dropsFollowingArticle: true,
      refersToWholeClause: false,
    ),
    ComplexRelativeExemplar(
      id: 'rel_03',
      domain: EngineeringRelativeDomain.industrialRobotics,
      category: RelativeClauseCategory.genitiveFemPluralDeren,
      cefrLevel: 'C1',
      antecedent: 'die Aktuatoren (جمع)',
      relativeMarker: 'deren',
      germanSentence:
          'Die neuen Aktuatoren, deren Reaktionszeit im Mikrosekundenbereich liegt, optimieren die Montagebahn.',
      commonErrorTrap: 'dessen Reaktionszeit (تجاهل صيغة الجمع للاسم المرجعي)',
      arabicExplanation:
          'عندما يكون الاسم المرجعي جمعاً (die Aktuatoren)، نستخدم دائماً deren حتى لو كان الاسم المملوك اللاحق مفرداً (die Reaktionszeit).',
      dropsFollowingArticle: true,
      refersToWholeClause: false,
    ),
    ComplexRelativeExemplar(
      id: 'rel_04',
      domain: EngineeringRelativeDomain.civilInfrastructure,
      category: RelativeClauseCategory.prepositionPlusGenitiveRelative,
      cefrLevel: 'C2',
      antecedent: 'das Tragwerk (محايد مفرد)',
      relativeMarker: 'auf dessen Basis',
      germanSentence:
          'Das Tragwerk, auf dessen Basis die gesamte Brücke berechnet wurde, zeigt keinerlei Ermüdungsrisse.',
      commonErrorTrap: 'auf der Basis dessen (ترتيب غير طبيعي في الأسلوب الهندسي الرسمي)',
      arabicExplanation:
          'في التراكيب الرسمية، يسبق حرف الجر (auf) الضمير الموصول المضاف (dessen) مباشرةً قبل الاسم الخالي من أداة التعريف (Basis).',
      dropsFollowingArticle: true,
      refersToWholeClause: false,
    ),
    ComplexRelativeExemplar(
      id: 'rel_05',
      domain: EngineeringRelativeDomain.materialScience,
      category: RelativeClauseCategory.prepositionPlusGenitiveRelative,
      cefrLevel: 'C2',
      antecedent: 'die Legierung (مؤنث مفرد)',
      relativeMarker: 'infolge deren',
      germanSentence:
          'Die Legierung, infolge deren geringer Dichte das Gesamtgewicht sinkt, wird im Prototyp verbaut.',
      commonErrorTrap: 'infolge deren der geringen Dichte (إقحام أداة تعريف أو تصريف خاطئ للصفة)',
      arabicExplanation:
          'بعد deren تسقط أداة التعريف تماماً، وتأخذ الصفة اللاحقة (geringer) نهاية المضاف إليه القوية (-er) للمؤنث المفرد لأنها غير مسبوقة بأداة.',
      dropsFollowingArticle: true,
      refersToWholeClause: false,
    ),
    ComplexRelativeExemplar(
      id: 'rel_06',
      domain: EngineeringRelativeDomain.maritimeLogistics,
      category: RelativeClauseCategory.pronominalAdverbWoRClause,
      cefrLevel: 'C1',
      antecedent: 'جملة رئيسية كاملة (إحالة حدث كامل)',
      relativeMarker: 'wodurch',
      germanSentence:
          'Der Tiefgang des Frachters wurde digital überwacht, wodurch Grundberührungen zuverlässig verhindert wurden.',
      commonErrorTrap: 'durch das (استخدام ضمير موصول عادي بدلاً من الظرف الموصول لإحالة جملة كاملة)',
      arabicExplanation:
          'عندما تعود الجملة الموصولة على مضمون الجملة السابقة بأكملها، نستخدم الظرف الموصول المركب (wodurch = وبفضل ذلك / مما أدى إلى).',
      dropsFollowingArticle: false,
      refersToWholeClause: true,
    ),
    ComplexRelativeExemplar(
      id: 'rel_07',
      domain: EngineeringRelativeDomain.renewableEnergyGrid,
      category: RelativeClauseCategory.pronominalAdverbWoRClause,
      cefrLevel: 'C1',
      antecedent: 'جملة رئيسية كاملة (إحالة إجراء تقني)',
      relativeMarker: 'wobei',
      germanSentence:
          'Die Batteriezellen werden aktiv gekühlt, wobei die Abwärme direkt in das Fernwärmenetz fließt.',
      commonErrorTrap: 'bei dem (عند عدم وجود اسم محايد محدد في الجملة الأولى)',
      arabicExplanation:
          'يفيد الظرف الموصول wobei الربط التزامني أو التفصيلي لعملية ذُكرت في الجملة السابقة كاملةً دون الإشارة إلى اسم مفرد بعينه.',
      dropsFollowingArticle: false,
      refersToWholeClause: true,
    ),
    ComplexRelativeExemplar(
      id: 'rel_08',
      domain: EngineeringRelativeDomain.industrialRobotics,
      category: RelativeClauseCategory.concretePrepRelativePronoun,
      cefrLevel: 'C1',
      antecedent: 'der Lasersensor (اسم مادي محدد)',
      relativeMarker: 'mit dem',
      germanSentence:
          'Der Lasersensor, mit dem die Schweißnaht vermessen wird, arbeitet berührungslos.',
      commonErrorTrap: 'womit (استخدام wo(r)- مع اسم مادي ملموس في اللغة الفصحى)',
      arabicExplanation:
          'يُمنع استخدام womit أو worauf عند الإشارة إلى اسم مادي محدد (der Lasersensor)؛ يجب استخدام حرف الجر متبوعاً بضمير الموصول المطابق (mit dem).',
      dropsFollowingArticle: false,
      refersToWholeClause: false,
    ),
    ComplexRelativeExemplar(
      id: 'rel_09',
      domain: EngineeringRelativeDomain.aerospaceAndAviation,
      category: RelativeClauseCategory.concretePrepRelativePronoun,
      cefrLevel: 'C1',
      antecedent: 'die Messdaten (اسم محدد جمع)',
      relativeMarker: 'auf denen',
      germanSentence:
          'Die Telemetriedaten, auf denen die Flugbahnkorrektur beruht, werden dreifach redundant gespeichert.',
      commonErrorTrap: 'worauf (استخدام worauf لإحالة اسم جمع ملموس)',
      arabicExplanation:
          'بما أن المرجع اسم جمع محدد (die Telemetriedaten)، نلتزم بالصيغة القياسية (auf denen) مع بقاء الفعل beruhen في حالة الجر.',
      dropsFollowingArticle: false,
      refersToWholeClause: false,
    ),
    ComplexRelativeExemplar(
      id: 'rel_10',
      domain: EngineeringRelativeDomain.materialScience,
      category: RelativeClauseCategory.indefiniteAndSuperlativeWas,
      cefrLevel: 'C1',
      antecedent: 'alles (ضمير مبهم)',
      relativeMarker: 'was',
      germanSentence:
          'Alles, was die Strukturfestigkeit unter Kryogenbedingungen beeinträchtigt, wird im Vorfeld ausgesondert.',
      commonErrorTrap: 'alles, das (استخدام das بعد الضمائر المبهمة alles / nichts / etwas)',
      arabicExplanation:
          'بعد الضمائر المبهمة غير المحددة مثل (alles, nichts, etwas, vieles) نستخدم دائماً الضمير الموصول was وليس das.',
      dropsFollowingArticle: false,
      refersToWholeClause: false,
    ),
    ComplexRelativeExemplar(
      id: 'rel_11',
      domain: EngineeringRelativeDomain.civilInfrastructure,
      category: RelativeClauseCategory.indefiniteAndSuperlativeWas,
      cefrLevel: 'C2',
      antecedent: 'das Beste (اسم محايد مشتق من صيغة التفضيل)',
      relativeMarker: 'was',
      germanSentence:
          'Das Effektivste, was bei diesem Bodenprofil eingesetzt werden kann, ist eine Tiefengründung.',
      commonErrorTrap: 'Das Effektivste, das (الخلط بين الاسم المحايد المشتق من التفضيل والاسم الجامد)',
      arabicExplanation:
          'الأسماء المحايدة المشتقة من صفات التفضيل (das Beste, das Effektivste, das Wichtigste) تتطلب الضمير الموصول was.',
      dropsFollowingArticle: false,
      refersToWholeClause: false,
    ),
    ComplexRelativeExemplar(
      id: 'rel_12',
      domain: EngineeringRelativeDomain.maritimeLogistics,
      category: RelativeClauseCategory.indefiniteAndSuperlativeWas,
      cefrLevel: 'C1',
      antecedent: 'جملة رئيسية كاملة (فاعل أو مفعول غير مسبوق بحرف جر)',
      relativeMarker: 'was',
      germanSentence:
          'Die Entladezeit konnte halbiert werden, was die gesamte Hafenkapazität spürbar entlastet.',
      commonErrorTrap: 'das die gesamte Hafenkapazität entlastet',
      arabicExplanation:
          'عندما تحيل الجملة الموصولة إلى فكرة الجملة السابقة بأكملها دون حرف جر، نستخدم was حصراً.',
      dropsFollowingArticle: false,
      refersToWholeClause: true,
    ),
    ComplexRelativeExemplar(
      id: 'rel_13',
      domain: EngineeringRelativeDomain.renewableEnergyGrid,
      category: RelativeClauseCategory.pronominalAdverbWoRClause,
      cefrLevel: 'C2',
      antecedent: 'nichts (ضمير مبهم + حرف جر)',
      relativeMarker: 'worauf',
      germanSentence:
          'Es gibt nichts im Lastprofil, worauf der Algorithmus nicht rechtzeitig reagieren könnte.',
      commonErrorTrap: 'auf das (بعد nichts يفضل ويُعتمد الظرف الموصول worauf)',
      arabicExplanation:
          'عند اقتران ضمير مبهم (nichts / alles / etwas) بفعل يتطلب حرف جر (reagieren auf)، ندمج حرف الجر مع wo(r)- لنحصل على worauf.',
      dropsFollowingArticle: false,
      refersToWholeClause: false,
    ),
    ComplexRelativeExemplar(
      id: 'rel_14',
      domain: EngineeringRelativeDomain.industrialRobotics,
      category: RelativeClauseCategory.freeRelativeAndSpatialWo,
      cefrLevel: 'C2',
      antecedent: 'جملة موصولة حرة (غير مسبوقة باسم مرجعي)',
      relativeMarker: 'Wer ... der / Wem ... dem',
      germanSentence:
          'Wem die Kalibrierungsdaten vorliegen, der kann die Abweichung sofort kompensieren.',
      commonErrorTrap: 'Wer die Kalibrierungsdaten vorliegen (نسيان توافق الحالة الإعرابية مع الفعل الأول)',
      arabicExplanation:
          'في الجمل الموصولة الحرة، يأخذ الضمير الموصول (Wem) حالة الإعراب التي يفرضها فعل جملته (vorliegen + Dativ)، بينما يأخذ الضمير الرابط في الجملة الرئيسية (der) حالته من فعلها (Nominativ).',
      dropsFollowingArticle: false,
      refersToWholeClause: false,
    ),
    ComplexRelativeExemplar(
      id: 'rel_15',
      domain: EngineeringRelativeDomain.aerospaceAndAviation,
      category: RelativeClauseCategory.freeRelativeAndSpatialWo,
      cefrLevel: 'C1',
      antecedent: 'der Prüfstand (مكان محدد)',
      relativeMarker: 'wo / auf dem',
      germanSentence:
          'Auf dem Prüfstand, wo die Schubvektorsteuerung getestet wird, herrschen strenge Sicherheitsabstände.',
      commonErrorTrap: 'wohin die Steuerung getestet wird (الخلط بين السكون والحركة)',
      arabicExplanation:
          'للإشارة إلى موقع ساكن بعد اسم مكان، يمكن استخدام wo (أو حرف الجر + ضمير الموصول على سبيل الدقة الرسمية: auf dem)، أما الحركة فتتطلب wohin.',
      dropsFollowingArticle: false,
      refersToWholeClause: false,
    ),
    ComplexRelativeExemplar(
      id: 'rel_16',
      domain: EngineeringRelativeDomain.civilInfrastructure,
      category: RelativeClauseCategory.genitiveMascNeutDessen,
      cefrLevel: 'C2',
      antecedent: 'das Fundament (محايد مفرد)',
      relativeMarker: 'mit dessen',
      germanSentence:
          'Das Fundament, mit dessen Sanierung bereits begonnen wurde, trägt die gesamte Last des Viadukts.',
      commonErrorTrap: 'mit deren Sanierung (الخلط بين جنس Sanierung المؤنث وجنس Fundament المحايد)',
      arabicExplanation:
          'الضمير الموصول المضاف يتبع الاسم السابق (das Fundament - محايد مفرد) فيكون dessen، رغم أن الاسم المملوك (Sanierung) مؤنث.',
      dropsFollowingArticle: true,
      refersToWholeClause: false,
    ),
  ];

  List<ComplexRelativeExemplar> get allExemplars => List.unmodifiable(_exemplars);

  List<ComplexRelativeExemplar> getByDomain(EngineeringRelativeDomain domain) {
    return _exemplars.where((e) => e.domain == domain).toList(growable: false);
  }

  List<ComplexRelativeExemplar> getByCategory(RelativeClauseCategory category) {
    return _exemplars.where((e) => e.category == category).toList(growable: false);
  }

  ComplexRelativeExemplar pickExemplarForDrill({
    EngineeringRelativeDomain? domain,
    int seed = 4973,
  }) {
    final pool = domain == null ? _exemplars : getByDomain(domain);
    if (pool.isEmpty) {
      return _exemplars.first;
    }
    final rng = Random(seed);
    return pool[rng.nextInt(pool.length)];
  }

  /// التحقق الذكي من الجملة الموصولة واكتشاف أخطاء C1–C2 الشائعة
  RelativeValidationResult validateRelativeSentence(
    String sentence, {
    required bool antecedentIsConcreteNoun,
    required bool antecedentIsIndefiniteOrClause,
  }) {
    _validationRuns++;
    final normalized = sentence.trim();
    final lower = normalized.toLowerCase();

    // 1. كشف خطأ إقحام أداة تعريف بعد dessen / deren
    final genitiveArticleRegex = RegExp(
      r'\b(dessen|deren)\s+(der|die|das|den|dem|des|ein|eine|einen|einem|einer|eines)\b',
      caseSensitive: false,
    );
    if (genitiveArticleRegex.hasMatch(lower)) {
      _caughtGenitiveArticleErrors++;
      final fixed = normalized.replaceAllMapped(
        genitiveArticleRegex,
        (m) => m.group(1)!,
      );
      return RelativeValidationResult(
        isValid: false,
        diagnosedRule: 'Nullartikel nach Genitiv-Relativpronomen (dessen/deren)',
        arabicFeedback:
            'خطأ نحوي شائع: الضمير الموصول المضاف (dessen / deren) يغني عن أداة التعريف أو التنكير، لذا يجب حذف الأداة التالية له مباشرة.',
        correctedSuggestion: fixed,
      );
    }

    // 2. كشف استخدام wo(r)- مع اسم مادي ملموس
    final worRegex = RegExp(
      r',\s*(wobei|wodurch|wofür|womit|worauf|woraus|worüber|wovon|wozu|woran|worin)\b',
      caseSensitive: false,
    );
    if (antecedentIsConcreteNoun && !antecedentIsIndefiniteOrClause && worRegex.hasMatch(lower)) {
      _caughtWoRConcreteErrors++;
      return RelativeValidationResult(
        isValid: false,
        diagnosedRule: 'Präposition + Relativpronomen statt wo(r)- bei konkreten Nomen',
        arabicFeedback:
            'عند الإشارة إلى اسم مادي محدد، لا يُستخدم الظرف الموصول (wo(r)-) في الألمانية القياسية؛ استبدله بحرف الجر + ضمير الموصول المطابق (مثل: mit dem / auf denen).',
        correctedSuggestion:
            normalized.replaceAll(worRegex, ', [Präposition + der/die/das/dem/denen]'),
      );
    }

    // 3. كشف استخدام das بدلاً من was بعد الضمائر المبهمة أو إحالة جملة كاملة
    final indefiniteWasTrapRegex = RegExp(
      r'\b(alles|nichts|etwas|vieles|manches|das Beste|das Wichtigste|das Effektivste),\s+das\b',
      caseSensitive: false,
    );
    if (indefiniteWasTrapRegex.hasMatch(lower) ||
        (antecedentIsIndefiniteOrClause && RegExp(r',\s+das\b', caseSensitive: false).hasMatch(lower))) {
      _caughtWasDasMismatches++;
      final fixed = normalized.replaceFirst(RegExp(r',\s+das\b', caseSensitive: false), ', was');
      return RelativeValidationResult(
        isValid: false,
        diagnosedRule: 'Relativpronomen "was" nach Indefinitpronomen / Superlativ / Satzinhalt',
        arabicFeedback:
            'بعد الضمائر المبهمة (alles, nichts, etwas) أو أسماء التفضيل المحايدة أو الجملة الكاملة، يجب استخدام الضمير الموصول was بدلاً من das.',
        correctedSuggestion: fixed,
      );
    }

    return const RelativeValidationResult(
      isValid: true,
      diagnosedRule: 'Korrekte C1/C2-Relativsatzstruktur',
      arabicFeedback: 'الصياغة سليمة ومطابقة لقواعد الجمل الموصولة المتقدمة.',
      correctedSuggestion: '',
    );
  }

  ComplexRelativeTelemetry get telemetry => ComplexRelativeTelemetry(
        totalExemplars: _exemplars.length,
        validationRuns: _validationRuns,
        caughtGenitiveArticleErrors: _caughtGenitiveArticleErrors,
        caughtWoRConcreteErrors: _caughtWoRConcreteErrors,
        caughtWasDasMismatches: _caughtWasDasMismatches,
      );
}
