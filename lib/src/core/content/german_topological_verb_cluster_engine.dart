import 'dart:math';

/// مجالات الهندسة والتقنية المعتمدة في المنهج (خالية من المخاطر القانونية والطبية)
enum TopologicalEngineeringDomain {
  renewableEnergyGrid,
  aerospaceAndAviation,
  industrialRobotics,
  civilInfrastructure,
  materialScience,
  maritimeLogistics,
}

/// تصنيف الظواهر الطوبولوجية وترتيب العناقيد الفعلية (C1–C2)
enum TopologicalClusterCategory {
  ippErsatzinfinitivSubordinate,   // قلب الفعل المساعد إلى الصدارة (Oberfeldumstellung) مع المصدر المزدوج
  threeAndFourVerbPassiveCluster,  // عناقيد الأفعال الثلاثية والرباعية في المبني للمجهول
  v1ConditionalProtasis,           // الجملة الشرطية بدون wenn (صدارة الفعل V1)
  validNachfeldAusklammerung,      // الإخراج المشروع إلى الحقل الخلفي (Nachfeld) للمقارنات والملحقات الثقيلة
  forbiddenObjectAusklammerung,    // منع إخراج المفعول به المباشر أو المكمل الإجباري خلف القوس الفعلي
  causativeAndPerceptionIpp,       // المصدر البديل مع أفعال السببية والإدراك (lassen, sehen, hören)
}

/// نموذج تطبيقي للتحليل الطوبولوجي وترتيب العناقيد الفعلية
class TopologicalClusterExemplar {
  final String id;
  final TopologicalEngineeringDomain domain;
  final TopologicalClusterCategory category;
  final String cefrLevel;
  final String topologicalPattern;
  final String germanSentence;
  final String commonErrorTrap;
  final String arabicExplanation;
  final bool requiresOberfeldFronting;
  final bool usesNachfeldExtraposition;

  const TopologicalClusterExemplar({
    required this.id,
    required this.domain,
    required this.category,
    required this.cefrLevel,
    required this.topologicalPattern,
    required this.germanSentence,
    required this.commonErrorTrap,
    required this.arabicExplanation,
    required this.requiresOberfeldFronting,
    required this.usesNachfeldExtraposition,
  });
}

/// نتيجة الفحص الطوبولوجي للجملة الألمانية
class TopologicalValidationResult {
  final bool isValid;
  final String diagnosedRule;
  final String arabicFeedback;
  final String correctedSuggestion;

  const TopologicalValidationResult({
    required this.isValid,
    required this.diagnosedRule,
    required this.arabicFeedback,
    required this.correctedSuggestion,
  });
}

/// بيانات قياس الأداء والإحصاءات الداخلية للمحرك
class TopologicalClusterTelemetry {
  final int totalExemplars;
  final int validationRuns;
  final int caughtIppOrderErrors;
  final int caughtPastParticipleModalTraps;
  final int caughtV1WordOrderErrors;

  const TopologicalClusterTelemetry({
    required this.totalExemplars,
    required this.validationRuns,
    required this.caughtIppOrderErrors,
    required this.caughtPastParticipleModalTraps,
    required this.caughtV1WordOrderErrors,
  });
}

/// المحرك الأساسي لتدريب وضبط العناقيد الفعلية والطوبولوجيا الألمانية (C1–C2)
class TopologicalVerbClusterEngine {
  int _validationRuns = 0;
  int _caughtIppOrderErrors = 0;
  int _caughtPastParticipleModalTraps = 0;
  int _caughtV1WordOrderErrors = 0;

  static const List<TopologicalClusterExemplar> _exemplars = [
    TopologicalClusterExemplar(
      id: 'topo_01',
      domain: TopologicalEngineeringDomain.renewableEnergyGrid,
      category: TopologicalClusterCategory.ippErsatzinfinitivSubordinate,
      cefrLevel: 'C1',
      topologicalPattern: 'weil + ... + [hat/hätte] + [Infinitiv] + [Modal-Infinitiv]',
      germanSentence:
          'Die Netzbetreiber griffen ein, weil man den Transformator sonst sofort hätte abschalten müssen.',
      commonErrorTrap: '...sonst sofort abschalten gemusst hätte (استخدام التصريف الثالث بدل المصدر البديل ووضعه في النهاية)',
      arabicExplanation:
          'في الجملة الجانبية مع فعل ناقص ومصدر في الماضي، يُستخدم المصدر البديل (müssen بدل gemusst) ويقفز الفعل المساعد (hätte) إلى صدارة العنقود الفعلي.',
      requiresOberfeldFronting: true,
      usesNachfeldExtraposition: false,
    ),
    TopologicalClusterExemplar(
      id: 'topo_02',
      domain: TopologicalEngineeringDomain.aerospaceAndAviation,
      category: TopologicalClusterCategory.ippErsatzinfinitivSubordinate,
      cefrLevel: 'C2',
      topologicalPattern: 'da + ... + [hat] + [Infinitiv] + [Modal-Infinitiv]',
      germanSentence:
          'Der Testflug wurde verschoben, da die Hydraulikpumpe vorab hat kalibriert werden müssen.',
      commonErrorTrap: '...kalibriert werden müssen hat (ترك الفعل المساعد hat في آخر الجملة الجانبية)',
      arabicExplanation:
          'عند اجتماع ثلاثة أفعال في الجملة الجانبية مع Ersatzinfinitiv، يتقدم الفعل المساعد (hat) على كامل العنقود الفعلي (hat kalibriert werden müssen).',
      requiresOberfeldFronting: true,
      usesNachfeldExtraposition: false,
    ),
    TopologicalClusterExemplar(
      id: 'topo_03',
      domain: TopologicalEngineeringDomain.industrialRobotics,
      category: TopologicalClusterCategory.causativeAndPerceptionIpp,
      cefrLevel: 'C1',
      topologicalPattern: 'obwohl + ... + [hat] + [Infinitiv] + [lassen]',
      germanSentence:
          'Die Fertigungslinie lief weiter, obwohl die Steuerung den Greifarm hat neu anfahren lassen.',
      commonErrorTrap: '...neu anfahren gelassen hat (استخدام gelassen عند وجود مصدر آخر قبله)',
      arabicExplanation:
          'يتبع الفعل lassen قاعدة المصدر البديل (Ersatzinfinitiv) عندما يسبقه مصدر آخر (anfahren)، فيُحول إلى lassen ويتقدم الفعل المساعد hat قبله.',
      requiresOberfeldFronting: true,
      usesNachfeldExtraposition: false,
    ),
    TopologicalClusterExemplar(
      id: 'topo_04',
      domain: TopologicalEngineeringDomain.civilInfrastructure,
      category: TopologicalClusterCategory.threeAndFourVerbPassiveCluster,
      cefrLevel: 'C2',
      topologicalPattern: '[Partizip II] + [worden] + [sein] + [Modal-V2/End]',
      germanSentence:
          'Die Spannbetonbrücke muss bereits vor der Freigabe umfassend vermessen worden sein.',
      commonErrorTrap: '...vermessen geworden sein muss (استخدام geworden بدل worden في المبني للمجهول)',
      arabicExplanation:
          'في المبني للمجهول التام مع فعل ناقص للاستنتاج (muss ... vermessen worden sein)، تُحذف البادئة ge- من worden دائماً.',
      requiresOberfeldFronting: false,
      usesNachfeldExtraposition: false,
    ),
    TopologicalClusterExemplar(
      id: 'topo_05',
      domain: TopologicalEngineeringDomain.materialScience,
      category: TopologicalClusterCategory.threeAndFourVerbPassiveCluster,
      cefrLevel: 'C2',
      topologicalPattern: 'dass + ... + [hätte] + [Partizip II] + [werden] + [können]',
      germanSentence:
          'Die Analyse belegt, dass die Korrosion durch eine Nickelschicht hätte verhindert werden können.',
      commonErrorTrap: '...verhindert werden gekonnt hätte',
      arabicExplanation:
          'في الجملة الجانبية الشرطية الماضية للمجهول، يتصدر hätte العنقود، يليه التصريف الثالث (verhindert) ثم مصدر المبني للمجهول (werden) فالمصدر البديل (können).',
      requiresOberfeldFronting: true,
      usesNachfeldExtraposition: false,
    ),
    TopologicalClusterExemplar(
      id: 'topo_06',
      domain: TopologicalEngineeringDomain.maritimeLogistics,
      category: TopologicalClusterCategory.v1ConditionalProtasis,
      cefrLevel: 'C1',
      topologicalPattern: 'Sollte + [Subjekt] + [Infinitiv], [so/dann] + [V2-Hauptsatz]',
      germanSentence:
          'Sollte der Wellengang im Zielhafen zunehmen, greift automatisch das dynamische Positionierungssystem.',
      commonErrorTrap: 'Sollte der Wellengang zunehmen, das System greift ein (كسر قاعدة V2 في جملة الجواب)',
      arabicExplanation:
          'تحل جملة صدارة الفعل (Sollte ...) محل إذا/لو (wenn)، وتُعد جملة الشرط بأكملها في الموقع الأول، لذا يجب أن يبدأ جواب الشرط بالفعل المصرف مباشرة (greift).',
      requiresOberfeldFronting: false,
      usesNachfeldExtraposition: false,
    ),
    TopologicalClusterExemplar(
      id: 'topo_07',
      domain: TopologicalEngineeringDomain.aerospaceAndAviation,
      category: TopologicalClusterCategory.v1ConditionalProtasis,
      cefrLevel: 'C2',
      topologicalPattern: 'Hätte/Wäre + [Subjekt] + ..., + [hätte/wäre] + [Subjekt]',
      germanSentence:
          'Wäre die Telemetrieverbindung während des Wiedereintritts abgebrochen, hätte das Bordsystem autonom navigiert.',
      commonErrorTrap: 'Wenn wäre die Verbindung abgebrochen (الجمع بين wenn وصدارة الفعل)',
      arabicExplanation:
          'في الشرط الافتراضي غير الواقعي بصدارة الفعل (Wäre ... abgebrochen)، يُحذف رابط wenn تماماً ويبدأ جواب الشرط بالفعل المساعد hätte.',
      requiresOberfeldFronting: false,
      usesNachfeldExtraposition: false,
    ),
    TopologicalClusterExemplar(
      id: 'topo_08',
      domain: TopologicalEngineeringDomain.renewableEnergyGrid,
      category: TopologicalClusterCategory.validNachfeldAusklammerung,
      cefrLevel: 'C1',
      topologicalPattern: '[Rechte Satzklammer] + [als/wie + Vergleichsphrase im Nachfeld]',
      germanSentence:
          'Die neuen Festkörperakkus haben deutlich schneller geladen als die herkömmlichen Lithium-Ionen-Module.',
      commonErrorTrap: '...haben schneller als die Module geladen (حشر عبارة مقارنة طويلة داخل القوس الفعلي)',
      arabicExplanation:
          'يُفضل في الأسلوب الألماني المتقدم إخراج عبارات المقارنة المبدوءة بـ (als / wie) إلى الحقل الخلفي (Nachfeld) بعد نهاية القوس الفعلي (geladen) لتيسير القراءة.',
      requiresOberfeldFronting: false,
      usesNachfeldExtraposition: true,
    ),
    TopologicalClusterExemplar(
      id: 'topo_09',
      domain: TopologicalEngineeringDomain.civilInfrastructure,
      category: TopologicalClusterCategory.validNachfeldAusklammerung,
      cefrLevel: 'C2',
      topologicalPattern: '[Rechte Satzklammer] + [schwere Präpositionalphrase im Nachfeld]',
      germanSentence:
          'Die Sensoren haben jede noch so minimale Schwingung aufgezeichnet im Verlauf des dreistündigen Belastungstests.',
      commonErrorTrap: 'الاعتقاد أن أي عبارة جر بعد الفعل الأخير خطأ نحوي دائماً',
      arabicExplanation:
          'يجوز إخراج شبه جملة الجر الطويلة أو التوضيحية إلى الحقل الخلفي (Nachfeld) بعد القوس الفعلي (aufgezeichnet) لإبرازها أو تخفيف ثقل الجملة.',
      requiresOberfeldFronting: false,
      usesNachfeldExtraposition: true,
    ),
    TopologicalClusterExemplar(
      id: 'topo_10',
      domain: TopologicalEngineeringDomain.industrialRobotics,
      category: TopologicalClusterCategory.forbiddenObjectAusklammerung,
      cefrLevel: 'C1',
      topologicalPattern: '[Subjekt] + [V2] + [Akkusativobjekt im Mittelfeld] + [Rechte Satzklammer]',
      germanSentence:
          'Der Controller hat die exakten Achsenkoordinaten in Echtzeit berechnet.',
      commonErrorTrap: 'Der Controller hat berechnet die exakten Achsenkoordinaten (إخراج المفعول به المباشر إلى Nachfeld)',
      arabicExplanation:
          'يُحظر إخراج المفعول به المنصوب (die exakten Achsenkoordinaten) خلف القوس الفعلي (berechnet)؛ مكانه الإلزامي داخل الحقل الأوسط (Mittelfeld).',
      requiresOberfeldFronting: false,
      usesNachfeldExtraposition: false,
    ),
    TopologicalClusterExemplar(
      id: 'topo_11',
      domain: TopologicalEngineeringDomain.materialScience,
      category: TopologicalClusterCategory.causativeAndPerceptionIpp,
      cefrLevel: 'C2',
      topologicalPattern: 'nachdem + ... + [hatte] + [Infinitiv] + [sehen]',
      germanSentence:
          'Das Team stoppte die Presse, nachdem man feine Haarrisse hatte entstehen sehen.',
      commonErrorTrap: '...entstehen gesehen hatte',
      arabicExplanation:
          'مع فعل الإدراك (sehen) المتبوع بمصدر آخر (entstehen)، نطبق المصدر البديل (sehen بدل gesehen) ونقدم الفعل المساعد (hatte) إلى صدارة العنقود في الجملة الجانبية.',
      requiresOberfeldFronting: true,
      usesNachfeldExtraposition: false,
    ),
    TopologicalClusterExemplar(
      id: 'topo_12',
      domain: TopologicalEngineeringDomain.maritimeLogistics,
      category: TopologicalClusterCategory.ippErsatzinfinitivSubordinate,
      cefrLevel: 'C2',
      topologicalPattern: 'obwohl + ... + [wird] + [Infinitiv] + [Infinitiv] + [müssen]',
      germanSentence:
          'Der Konvoi läuft pünktlich aus, obwohl die Frachtliste nochmals wird geprüft werden müssen.',
      commonErrorTrap: '...geprüft werden müssen wird (تأخير wird في عنقود المستقبل مع فعل ناقص)',
      arabicExplanation:
          'عند استخدام المستقبل (wird) مع مصدرين في الجملة الجانبية، يفضل الأسلوب الفصيح تقديم wird إلى صدارة العنقود الفعلي (wird geprüft werden müssen).',
      requiresOberfeldFronting: true,
      usesNachfeldExtraposition: false,
    ),
    TopologicalClusterExemplar(
      id: 'topo_13',
      domain: TopologicalEngineeringDomain.renewableEnergyGrid,
      category: TopologicalClusterCategory.v1ConditionalProtasis,
      cefrLevel: 'C1',
      topologicalPattern: 'Tritt + [Subjekt] + [Verbpräfix], + [V2-Hauptsatz]',
      germanSentence:
          'Tritt eine Frequenzabweichung über 50,2 Hertz auf, drosseln die Wechselrichter ihre Einspeisung.',
      commonErrorTrap: 'Tritt auf eine Frequenzabweichung... (إخلال بقوس الجملة للفعل المنفصل)',
      arabicExplanation:
          'في الشرط بصدارة الفعل (V1) مع فعل منفصل (auftreten)، يظل الجزء المنفصل (auf) في نهاية جملة الشرط ليغلق القوس الفعلي قبل الفاصلة.',
      requiresOberfeldFronting: false,
      usesNachfeldExtraposition: false,
    ),
    TopologicalClusterExemplar(
      id: 'topo_14',
      domain: TopologicalEngineeringDomain.aerospaceAndAviation,
      category: TopologicalClusterCategory.threeAndFourVerbPassiveCluster,
      cefrLevel: 'C2',
      topologicalPattern: 'weil + ... + [hat] + [Partizip II] + [werden] + [sollen]',
      germanSentence:
          'Die Dokumentation wurde ergänzt, weil das Hitzeschild ursprünglich doppelt hat beschichtet werden sollen.',
      commonErrorTrap: '...beschichtet werden gesollt hat',
      arabicExplanation:
          'مع sollen في صيغة الماضي للمبني للمجهول داخل جملة جانبية، يتحول إلى المصدر البديل sollen ويتقدم الفعل المساعد hat قبله مباشرة.',
      requiresOberfeldFronting: true,
      usesNachfeldExtraposition: false,
    ),
    TopologicalClusterExemplar(
      id: 'topo_15',
      domain: TopologicalEngineeringDomain.civilInfrastructure,
      category: TopologicalClusterCategory.forbiddenObjectAusklammerung,
      cefrLevel: 'C1',
      topologicalPattern: '[Subjekt] + [V2] + [Prädikativ/Objekt im Mittelfeld] + [Partizip II]',
      germanSentence:
          'Das Ingenieurbüro hat die statische Berechnung termingerecht abgeschlossen.',
      commonErrorTrap: 'Das Ingenieurbüro hat abgeschlossen die statische Berechnung.',
      arabicExplanation:
          'تُغلق الجملة الألمانية بالمكمل الفعلي (abgeschlossen)؛ ولا يُسمح بإخراج المفعول به الاسمي البسيط إلى ما بعد الفعل.',
      requiresOberfeldFronting: false,
      usesNachfeldExtraposition: false,
    ),
    TopologicalClusterExemplar(
      id: 'topo_16',
      domain: TopologicalEngineeringDomain.industrialRobotics,
      category: TopologicalClusterCategory.validNachfeldAusklammerung,
      cefrLevel: 'C2',
      topologicalPattern: '[Rechte Satzklammer] + [zu-Infinitivsatz im Nachfeld]',
      germanSentence:
          'Die Sicherheitssteuerung hat rechtzeitig verhindert, dass der Roboterarm mit der Schutzhaube kollidiert.',
      commonErrorTrap: 'حشر جملة dass كاملة قبل verhindert',
      arabicExplanation:
          'الجمل الجانبية (dass / ob / wenn) وجمل المصدر (um ... zu) مكانها الطبيعي في الحقل الخلفي (Nachfeld) بعد نهاية القوس الفعلي (verhindert).',
      requiresOberfeldFronting: false,
      usesNachfeldExtraposition: true,
    ),
  ];

  List<TopologicalClusterExemplar> get allExemplars => List.unmodifiable(_exemplars);

  List<TopologicalClusterExemplar> getByDomain(TopologicalEngineeringDomain domain) {
    return _exemplars.where((e) => e.domain == domain).toList(growable: false);
  }

  List<TopologicalClusterExemplar> getByCategory(TopologicalClusterCategory category) {
    return _exemplars.where((e) => e.category == category).toList(growable: false);
  }

  TopologicalClusterExemplar pickExemplarForDrill({
    TopologicalEngineeringDomain? domain,
    int seed = 4974,
  }) {
    final pool = domain == null ? _exemplars : getByDomain(domain);
    if (pool.isEmpty) {
      return _exemplars.first;
    }
    final rng = Random(seed);
    return pool[rng.nextInt(pool.length)];
  }

  /// التحقق الذكي من ترتيب العناقيد الفعلية وقواعد الطوبولوجيا الألمانية
  TopologicalValidationResult validateClusterSyntax(String sentence) {
    _validationRuns++;
    final normalized = sentence.trim();
    final lower = normalized.toLowerCase();

    // 1. كشف استخدام Partizip II للأفعال الناقصة (gemusst / gekonnt / gedurft / gesollt / gewollt) مع فعل مصدر قبله
    final modalParticipleTrap = RegExp(
      r'\b[a-zäöüß]+en\s+(gemusst|gekonnt|gedurft|gesollt|gewollt|gemocht|gelassen)\s+(hat|habe|hatte|hätte|haben|hätten)\b',
      caseSensitive: false,
    );
    if (modalParticipleTrap.hasMatch(lower)) {
      _caughtPastParticipleModalTraps++;
      return const TopologicalValidationResult(
        isValid: false,
        diagnosedRule: 'Ersatzinfinitiv (IPP) statt Partizip II + Oberfeldumstellung',
        arabicFeedback:
            'خطأ في المصدر البديل: عند اجتماع فعل ناقص أو lassen مع مصدر آخر في الماضي، يُستخدم المصدر البديل (مثل müssen / können / lassen) ويتقدم الفعل المساعد (hat/hätte) إلى صدارة العنقود الفعلي.',
        correctedSuggestion: '[hat/hätte] + [Infinitiv] + [Modal-Infinitiv]',
      );
    }

    // 2. كشف تأخير الفعل المساعد hat/hätte/hatte بعد مصدرين متتاليين في الجملة الجانبية
    final delayedAuxAfterDoubleInf = RegExp(
      r'\b[a-zäöüß]+en\s+(können|müssen|dürfen|sollen|wollen|lassen|sehen|hören)\s+(hat|hätte|hatte|haben|hätten|hatten)\b',
      caseSensitive: false,
    );
    if (delayedAuxAfterDoubleInf.hasMatch(lower)) {
      _caughtIppOrderErrors++;
      return const TopologicalValidationResult(
        isValid: false,
        diagnosedRule: 'Oberfeldumstellung bei doppeltem Infinitiv',
        arabicFeedback:
            'خطأ في الترتيب الطوبولوجي: في الجملة الجانبية ذات المصدر المزدوج، يجب تقديم الفعل المساعد (hat / hätte / hatte) إلى ما قبل المصدرين.',
        correctedSuggestion: '[hat/hätte/hatte] + [Vollverb-Infinitiv] + [Modal/AcI-Infinitiv]',
      );
    }

    // 3. كشف الجمع الخاطئ بين wenn وصدارة الفعل المساعد في الشرط (مثل: Wenn sollte / Wenn hätte)
    final doubleConditionalMarker = RegExp(
      r'\bwenn\s+(sollte|hätte|wäre|würde)\s+[A-ZÄÖÜa-zäöüß]+',
      caseSensitive: false,
    );
    if (doubleConditionalMarker.hasMatch(lower)) {
      _caughtV1WordOrderErrors++;
      return const TopologicalValidationResult(
        isValid: false,
        diagnosedRule: 'V1-Konditionalsatz ohne "wenn" vs. Verbendstellung mit "wenn"',
        arabicFeedback:
            'خطأ في تركيب جملة الشرط: إما أن تبدأ بالفعل مباشرة بدون wenn (صدارة الفعل V1)، أو تستخدم wenn مع إرسال الفعل المصرف إلى نهاية جملة الشرط.',
        correctedSuggestion: 'Sollte/Hätte/Wäre ... [Infinitiv/Partizip], [V2-Hauptsatz]',
      );
    }

    return const TopologicalValidationResult(
      isValid: true,
      diagnosedRule: 'Korrekte C1/C2-Verbcluster-Topologie',
      arabicFeedback: 'ترتيب العنقود الفعلي والقوس الطوبولوجي سليم وفق قواعد الألمانية القياسية.',
      correctedSuggestion: '',
    );
  }

  TopologicalClusterTelemetry get telemetry => TopologicalClusterTelemetry(
        totalExemplars: _exemplars.length,
        validationRuns: _validationRuns,
        caughtIppOrderErrors: _caughtIppOrderErrors,
        caughtPastParticipleModalTraps: _caughtPastParticipleModalTraps,
        caughtV1WordOrderErrors: _caughtV1WordOrderErrors,
      );
}
