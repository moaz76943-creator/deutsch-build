import 'dart:collection';

/// Classification of concessive (Einräumung) and adversative (Gegensatz) connectors.
enum ConcessiveConnectorType {
  subordinatingConjunction(
    'Subjunktionen (obwohl, obgleich, obschon)',
    'حروف العطف التبعية الدالة على الاستدراك والتنازل (obwohl, obgleich)',
    'Leitet einen echten Nebensatz mit obligatorischer Verb-Endstellung ein: Obwohl die Lastspitzen stiegen, blieb das Netz stabil.',
  ),
  adverbialInversionConnector(
    'Konnektionaladverbien (dennoch, trotzdem, gleichwohl, dessen ungeachtet)',
    'الظروف الرابطة الدالة على الاستدراك مع قلب الفعل وجوباً (dennoch, trotzdem)',
    'Besetzt das Vorfeld eines Hauptsatzes und erzwingt V2-Inversion: Die Lastspitzen stiegen; dennoch blieb das Netz stabil.',
  ),
  prepositionalGenitivePhrase(
    'Konzessivpräpositionen (trotz, ungeachtet + Genitiv)',
    'حروف الجر الاستدراكية المتبوعة بحالة الإضافة (trotz, ungeachtet)',
    'Verdichtet den Nebensatz zu einer Nominalphrase im Genitiv: Trotz der gestiegenen Lastspitzen...',
  ),
  scalarGeneralizingConcessive(
    'Skalare Verallgemeinerung (so... auch, wie... auch)',
    'الاستدراك التعميمي التصاعدي مهما بلغت الدرجة (so [Adjektiv] auch...)',
    'Adjektiv/Adverb nach "so/wie" mit obligatorischer Partikel "auch": So komplex die Architektur auch sein mag...',
  ),
  adversativeContrast(
    'Adversative Kontrastierung (während, wohingegen)',
    'المقابلة التباينية البحتة دون علاقة سببية متناقضة (während, wohingegen)',
    'Stellt zwei gegensätzliche Fakten gegenüber: Turbine A läuft mit Gas, während Turbine B mit Wasserstoff betrieben wird.',
  );

  final String germanTitle;
  final String arabicTitle;
  final String syntaxRule;
  const ConcessiveConnectorType(
    this.germanTitle,
    this.arabicTitle,
    this.syntaxRule,
  );
}

/// Syntactic packaging format.
enum SyntacticFormType {
  subordinateClause(
    'Nebensatz (Verb-Ende)',
    'جملة ثانوية بوقوع الفعل المصرف في الختام',
  ),
  inversionMainClause(
    'Hauptsatz mit V2-Inversion',
    'جملة رئيسية بتقديم الظرف وقلب الفعل قبل الفاعل',
  ),
  nominalGenitivePhrase(
    'Nominalphrase (Präposition + Genitiv)',
    'شبه جملة اسمية مكثفة بحرف جر وإضافة',
  ),
  scalarModifierClause(
    'Skalarpartikel-Nebensatz',
    'جملة وصفية تعميمية بأداة التدرج auch',
  );

  final String de;
  final String ar;
  const SyntacticFormType(this.de, this.ar);
}

/// Professional and engineering domains free of legal/medical liability.
enum CommunicativeDomain {
  renewableEnergyGrid('Erneuerbare Energien & Netztechnik', 'الطاقة المتجددة وهندسة الشبكات'),
  aerospaceAndAviation('Luft- & Raumfahrttechnik', 'هندسة الطيران واستكشاف الفضاء'),
  industrialRobotics('Industrierobotik & Mechatronik', 'الروبوتات الصناعية والميكاترونكس'),
  civilInfrastructure('Bauingenieurwesen & Statik', 'الهندسة المدنية والمنشآت'),
  materialScience('Materialwissenschaft & Nanotechnologie', 'علم المواد والتراكيب النانوية'),
  maritimeLogistics('Maritime Schifffahrt & Hafenumschlag', 'الملاحة البحرية والشحن الدولي');

  final String de;
  final String ar;
  const CommunicativeDomain(this.de, this.ar);
}

/// Structural model of a concessive/adversative construction with transformation dynamics.
class ConcessiveConnectorModel {
  final String id;
  final ConcessiveConnectorType connectorType;
  final String connectorWord;
  final SyntacticFormType formType;
  final CommunicativeDomain domain;
  final String basePropositionP; // Der Grund / die erschwerende Bedingung
  final String counterExpectationQ; // Das unerwartete Ergebnis
  final String sampleSentence;
  final String arabicTranslation;
  final String grammaticalAnalysisArabic;
  final String grammaticalAnalysisGerman;
  final String triWayTransformationFormula;
  final String diagnosticTrapWarning;

  const ConcessiveConnectorModel({
    required this.id,
    required this.connectorType,
    required this.connectorWord,
    required this.formType,
    required this.domain,
    required this.basePropositionP,
    required this.counterExpectationQ,
    required this.sampleSentence,
    required this.arabicTranslation,
    required this.grammaticalAnalysisArabic,
    required this.grammaticalAnalysisGerman,
    required this.triWayTransformationFormula,
    required this.diagnosticTrapWarning,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'connectorType': connectorType.name,
    'connectorWord': connectorWord,
    'formType': formType.name,
    'domain': domain.name,
    'basePropositionP': basePropositionP,
    'counterExpectationQ': counterExpectationQ,
    'sampleSentence': sampleSentence,
    'arabicTranslation': arabicTranslation,
    'grammaticalAnalysisArabic': grammaticalAnalysisArabic,
    'grammaticalAnalysisGerman': grammaticalAnalysisGerman,
    'triWayTransformationFormula': triWayTransformationFormula,
    'diagnosticTrapWarning': diagnosticTrapWarning,
  };
}

/// Validation report container for concessive/adversative syntax.
class ConcessiveValidationReport {
  final bool isValid;
  final bool isVerbPositionCompliant;
  final bool avoidsColloquialTrotzdem;
  final List<String> issues;
  final List<String> recommendations;
  final String arabicDiagnosticVerdict;

  const ConcessiveValidationReport({
    required this.isValid,
    required this.isVerbPositionCompliant,
    required this.avoidsColloquialTrotzdem,
    required this.issues,
    required this.recommendations,
    required this.arabicDiagnosticVerdict,
  });
}

/// Sovereign engine governing German Concessive & Adversative Syntax Architecture.
class GermanConcessiveAdversativeEngine {
  final List<ConcessiveConnectorModel> _catalog = [];

  GermanConcessiveAdversativeEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<ConcessiveConnectorModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    // 1. obwohl (Subordinating Conjunction - Verb-Final) - Renewable Energy
    _catalog.add(
      const ConcessiveConnectorModel(
        id: 'CONC-OBWOHL-ENERGY-01',
        connectorType: ConcessiveConnectorType.subordinatingConjunction,
        connectorWord: 'obwohl',
        formType: SyntacticFormType.subordinateClause,
        domain: CommunicativeDomain.renewableEnergyGrid,
        basePropositionP: 'Die Windgeschwindigkeit fiel während der Flaute stark ab.',
        counterExpectationQ: 'Die Netzfrequenz blieb absolut stabil.',
        sampleSentence:
            'Obwohl die Windgeschwindigkeit während der Flaute stark abfiel, blieb die Netzfrequenz dank der Großakkumulatoren absolut stabil.',
        arabicTranslation:
            'على الرغم من أن سرعة الرياح انخفضت بشدة أثناء فترة السكون، إلا أن تردد الشبكة الكهربائية ظل مستقراً تماماً بفضل المدخرات الضخمة.',
        grammaticalAnalysisArabic:
            'أداة ربط تبعية استدراكية (obwohl): تدخل على الجملة الثانوية لتضع الفعل المصرف (abfiel) في الختام، يليه في الجملة الرئيسية تقديم الفعل (blieb) التزاماً بالترتيب V2.',
        grammaticalAnalysisGerman:
            'Konzessive Subjunktion "obwohl" regiert zwingende Verb-Endstellung im Nebensatz. Im nachgestellten Hauptsatz rückt das finite Verb "blieb" auf Position 2 direkt nach dem Komma.',
        triWayTransformationFormula:
            'Obwohl-Satz: Obwohl [S] ... [V-Ende]  <-->  Dennoch: [S] ... [V]; dennoch [V] [S]  <-->  Trotz: Trotz + Genitiv',
        diagnosticTrapWarning:
            'Kein "aber" im nachgestellten Hauptsatz! Die Konstruktion "*Obwohl ..., aber die Frequenz blieb stabil" ist ungrammatisch.',
      ),
    );

    // 2. dennoch (Adverbial Inversion - V2) - Aerospace Aviation
    _catalog.add(
      const ConcessiveConnectorModel(
        id: 'CONC-DENNOCH-AERO-02',
        connectorType: ConcessiveConnectorType.adverbialInversionConnector,
        connectorWord: 'dennoch',
        formType: SyntacticFormType.inversionMainClause,
        domain: CommunicativeDomain.aerospaceAndAviation,
        basePropositionP: 'Die äußere Hitzeschildschicht erlitt mikroskopische Risse.',
        counterExpectationQ: 'Die Kapsel hielt dem aerodynamischen Druck stand.',
        sampleSentence:
            'Die äußere Hitzeschildschicht erlitt mikroskopische Risse; dennoch hielt die Kapsel dem gewaltigen aerodynamischen Druck stand.',
        arabicTranslation:
            'تعرضت طبقة الدرع الحراري الخارجية لشروخ مجهرية دقيقة؛ ومع ذلك صمدت الكبسولة في وجه الضغط الهوائي الإيروديناميكي الهائل.',
        grammaticalAnalysisArabic:
            'ظرف ربط استدراكي فصيح (dennoch): يشغل صدر الجملة الثانية (Vorfeld) ويفرض قلب الفاعل بعد الفعل المصرف مباشرة (hielt die Kapsel...).',
        grammaticalAnalysisGerman:
            'Konnektionaladverb "dennoch" im Vorfeld des Folgesatzes erzwingt V2-Inversion des finiten Prädikats ("hielt") vor das Subjekt ("die Kapsel").',
        triWayTransformationFormula:
            'Hauptsatz A ; dennoch + [Finitum] + [Subjekt] ...',
        diagnosticTrapWarning:
            'Niemals Subjekt vor Verb nach dennoch: "*dennoch die Kapsel hielt stand" verletzt die universelle deutsche V2-Regel.',
      ),
    );

    // 3. trotz + Genitiv (Prepositional Synthesis) - Civil Infrastructure
    _catalog.add(
      const ConcessiveConnectorModel(
        id: 'CONC-TROTZ-CIVIL-03',
        connectorType: ConcessiveConnectorType.prepositionalGenitivePhrase,
        connectorWord: 'trotz',
        formType: SyntacticFormType.nominalGenitivePhrase,
        domain: CommunicativeDomain.civilInfrastructure,
        basePropositionP: 'Der Baugrund war stark durchnässt.',
        counterExpectationQ: 'Die Bohrpfähle erreichten die tragfähige Felsschicht.',
        sampleSentence:
            'Trotz der starken Durchnässung des Baugrunds erreichten die Bohrpfähle termingerecht die tragfähige Felsschicht.',
        arabicTranslation:
            'على الرغم من التشبع الشديد لتربة البناء بالمياه، وصلت ركائز الحفر في الموعد المحدد إلى طبقة الصخور الحاملة.',
        grammaticalAnalysisArabic:
            'حرف جر استدراكي (trotz): يجر الاسم بالمعيار الفصيح بالإضافة (Genitiv: der starken Durchnässung)، ويكثف جملة كاملة في شبه جملة رشيقة.',
        grammaticalAnalysisGerman:
            'Konzessivpräposition "trotz" regiert in der gepflegten Standardsprache den Genitiv. Ersetzt den Nebensatz durch eine dichte Nominalkonstruktion.',
        triWayTransformationFormula:
            'Trotz + [Genitivphrase] , [Finites Verb] + [Subjekt] ...',
        diagnosticTrapWarning:
            'Umgangssprachlich tritt manchmal der Dativ auf ("trotz dem Wetter"), in der anspruchsvollen Fachsprache gilt ausschließlich der Genitiv als makellos.',
      ),
    );

    // 4. so ... auch (Scalar Generalizing Concessive) - Software Engineering
    _catalog.add(
      const ConcessiveConnectorModel(
        id: 'CONC-SO-AUCH-SOFT-04',
        connectorType: ConcessiveConnectorType.scalarGeneralizingConcessive,
        connectorWord: 'so ... auch',
        formType: SyntacticFormType.scalarModifierClause,
        domain: CommunicativeDomain.softwareEngineering,
        basePropositionP: 'Die verteilte Systemarchitektur ist hochgradig komplex.',
        counterExpectationQ: 'Die automatisierten CI/CD-Pipelines sichern fehlerfreie Releases.',
        sampleSentence:
            'So komplex die verteilte Systemarchitektur auch sein mag, die automatisierten Pipelines sichern fehlerfreie Releases.',
        arabicTranslation:
            'مهما بلغت معمارية المنظومة الموزعة من درجة التعقيد، فإن خطوط الإنتاج والدمج الآلية تضمن إصدارات برمجية خالية من العيوب.',
        grammaticalAnalysisArabic:
            'التركيب الاستدراكي التعميمي التصاعدي: "So + صفة (komplex) + المبتدأ + auch + الفعل المصرف في الختام (sein mag)". يعبر عن شمول التحدي وتجاوزه.',
        grammaticalAnalysisGerman:
            'Skalarer Konzessivsatz mit Vorfeldadjektiv nach "so" und obligatorischer Fokuspartikel "auch" vor dem finiten Verb am Satzende ("sein mag").',
        triWayTransformationFormula:
            'So + [Adjektiv] + [Subjekt] + auch + [Verb am Ende] , [Hauptsatz] ...',
        diagnosticTrapWarning:
            'Vergessen der Partikel "auch": "*So komplex die Architektur sein mag" ist unvollständig; "auch" ist syntaktisch konstitutiv.',
      ),
    );

    // 5. ungeachtet + Genitiv (Elevated Administrative/Technical Preposition) - Maritime Logistics
    _catalog.add(
      const ConcessiveConnectorModel(
        id: 'CONC-UNGEACHTET-MARITIME-05',
        connectorType: ConcessiveConnectorType.prepositionalGenitivePhrase,
        connectorWord: 'ungeachtet',
        formType: SyntacticFormType.nominalGenitivePhrase,
        domain: CommunicativeDomain.maritimeLogistics,
        basePropositionP: 'Die Sichtverhältnisse waren durch dichten Nebel extrem eingeschränkt.',
        counterExpectationQ: 'Das Großcontainerschiff lief sicher in die Hafenmündung ein.',
        sampleSentence:
            'Ungeachtet der dichten Nebelbänke auf der Außenweser navigierte der Hafenlotse das Großcontainerschiff sicher zur Kaimauer.',
        arabicTranslation:
            'بصرف النظر عن سحب الضباب الكثيف في المجرى الملاحي الخارجي، وجه مرشد الميناء سفينة الحاويات العملاقة بأمان نحو رصيف الرسو.',
        grammaticalAnalysisArabic:
            'حرف جر استدراكي فصيح راقٍ (ungeachtet): يجر الاسم بالإضافة (Genitiv: der dichten Nebelbänke) ويعبر عن المضي قدماً دون الاكتراث بالعائق.',
        grammaticalAnalysisGerman:
            'Gehobene Konzessivpräposition "ungeachtet" mit obligatorischem Genitiv. Bezeichnet ein Hindernis, das die Durchführung nicht aufhalten konnte.',
        triWayTransformationFormula:
            'Ungeachtet + [Genitivattribut] , [Verb] + [Subjekt] ...',
        diagnosticTrapWarning:
            '"Ungeachtet" kann auch nachgestellt werden ("der Nebelbänke ungeachtet"), regiert aber stets den Genitiv.',
      ),
    );

    // 6. obgleich (Elevated Subjunction) - Material Science
    _catalog.add(
      const ConcessiveConnectorModel(
        id: 'CONC-OBGLEICH-MAT-06',
        connectorType: ConcessiveConnectorType.subordinatingConjunction,
        connectorWord: 'obgleich',
        formType: SyntacticFormType.subordinateClause,
        domain: CommunicativeDomain.materialScience,
        basePropositionP: 'Die Keramikbeschichtung ist extrem dünn.',
        counterExpectationQ: 'Sie widersteht aggressiven Säuren dauerhaft.',
        sampleSentence:
            'Obgleich die Nanobeschichtung lediglich wenige Mikrometer misst, widersteht sie hochkonzentrierten Säuren dauerhaft.',
        arabicTranslation:
            'مع أن طلاء النانو لا يتجاوز سُمكه بضعة ميكرومترات فحسب، إلا أنه يقاوم الأحماض عالية التركيز بشكل دائم ومستمر.',
        grammaticalAnalysisArabic:
            'أداة الربط الفصيحة "obgleich": مرادفة لـ obwohl في النثر الأكاديمي والعلمي الراقي، وتلزم الفعل المصرف بموقع النهاية (misst).',
        grammaticalAnalysisGerman:
            'Stilistisch gehobene Variante zu "obwohl". Erzwingt strikte Verb-Endstellung ("misst") und Hauptsatz-V2-Anschluss ("widersteht sie").',
        triWayTransformationFormula:
            'Obgleich [S] ... [V-Ende] , [V] + [S] ...',
        diagnosticTrapWarning:
            'Gilt in der Wissenschaftssprache als eleganter als das alltägliche "obwohl".',
      ),
    );

    // 7. gleichwohl (Elevated Adverbial Inversion) - Industrial Robotics
    _catalog.add(
      const ConcessiveConnectorModel(
        id: 'CONC-GLEICHWOHL-ROBOT-07',
        connectorType: ConcessiveConnectorType.adverbialInversionConnector,
        connectorWord: 'gleichwohl',
        formType: SyntacticFormType.inversionMainClause,
        domain: CommunicativeDomain.industrialRobotics,
        basePropositionP: 'Der Anschaffungspreis des Sechsachsroboters ist beträchtlich.',
        counterExpectationQ: 'Die Investition amortisiert sich binnen vierzehn Monaten.',
        sampleSentence:
            'Die Anschaffungskosten der autonomen Roboterschweißzelle sind beträchtlich; gleichwohl amortisiert sich die Investition bereits binnen vierzehn Monaten.',
        arabicTranslation:
            'إن تكاليف اقتناء خلية اللحام الروبوتية المستقلة باهظة وكبيرة؛ غير أن هذا الاستثمار يسترد تكلفته بالفعل في غضون أربعة عشر شهراً.',
        grammaticalAnalysisArabic:
            'ظرف الربط الاستدراكي الرفيع (gleichwohl): يفيد الاستدراك البرهاني مع قلب الفاعل والمسند (amortisiert sich die Investition).',
        grammaticalAnalysisGerman:
            'Wissenschaftliches und kaufmännisches Konnektionaladverb "gleichwohl" mit V2-Stellung des Verbs ("amortisiert sich").',
        triWayTransformationFormula:
            'Aussage A ; gleichwohl + [Verb] + [Subjekt] ...',
        diagnosticTrapWarning:
            'Wird im anspruchsvollen Fachbericht bevorzugt, um repetitive Verwendungen von "trotzdem" zu vermeiden.',
      ),
    );

    // 8. während (Adversative Contrast vs. Concessive) - Renewable Energy
    _catalog.add(
      const ConcessiveConnectorModel(
        id: 'CONC-WAEHREND-ADVERS-08',
        connectorType: ConcessiveConnectorType.adversativeContrast,
        connectorWord: 'während',
        formType: SyntacticFormType.subordinateClause,
        domain: CommunicativeDomain.renewableEnergyGrid,
        basePropositionP: 'Photovoltaikanlagen erzeugen vor allem mittags Strom.',
        counterExpectationQ: 'Windkraftanlagen liefern kontinuierlich bei Tag und Nacht Energie.',
        sampleSentence:
            'Während Photovoltaikanlagen ihren Erzeugungspeak in den Mittagsstunden erreichen, liefern Offshore-Windparks kontinuierlich bei Tag und Nacht Energie.',
        arabicTranslation:
            'في حين تبلغ محطات الطاقة الكهروضوئية ذروة إنتاجها في ساعات الظهيرة، توفر مزارع الرياح البحرية الطاقة باستمرار ليلاً ونهاراً.',
        grammaticalAnalysisArabic:
            'المقابلة التباينية (Adversative Kontrastierung): الأداة "während" هنا لا تفيد التزامن الزمني المحض، بل تقابل بين حقيقتين متمايزتين دون تناقض سببي.',
        grammaticalAnalysisGerman:
            'Adversatives "während" leitet einen Nebensatz mit Verb-Endstellung ("erreichen") ein. Stellt einen sachlichen Kontrast dar, keine logische Einräumung.',
        triWayTransformationFormula:
            'Während [Satz A mit Verb am Ende] , [Satz B mit V2] ...',
        diagnosticTrapWarning:
            'Kardinaler Unterschied: "während" = reiner sachlicher Gegensatz; "obwohl" = unerwarteter Bruch einer Kausalitätskette.',
      ),
    );

    // 9. dessen ungeachtet (Pronominal Adverbial Concessive) - Civil Infrastructure
    _catalog.add(
      const ConcessiveConnectorModel(
        id: 'CONC-DESSEN-UNGEACHTET-09',
        connectorType: ConcessiveConnectorType.adverbialInversionConnector,
        connectorWord: 'dessen ungeachtet',
        formType: SyntacticFormType.inversionMainClause,
        domain: CommunicativeDomain.civilInfrastructure,
        basePropositionP: 'Die Lieferfristen für den Spezialstahl verzögerten sich um Wochen.',
        counterExpectationQ: 'Die Montagekolonne vollendete das Dachsegment fristgemäß.',
        sampleSentence:
            'Die Lieferfristen für den hochfesten Spezialstahl verzögerten sich um Wochen; dessen ungeachtet vollendete die Montagekolonne das Dachsegment fristgemäß.',
        arabicTranslation:
            'تأخرت مواعيد تسليم الفولاذ الخاص فائق المتانة عدة أسابيع؛ وبصرف النظر عن ذلك أتم فريق التركيب إنجاز قطاع السقف في الموعد المحدد.',
        grammaticalAnalysisArabic:
            'مركب ظرفي إحالي استدراكي (dessen ungeachtet): يشير إلى مضمون الجملة السابقة بضمير الإضافة dessen مع أداة ungeachtet، ويليه الفعل فوراً.',
        grammaticalAnalysisGerman:
            'Pronominales Konnektoradverb "dessen ungeachtet" mit anaphorischem Genitivpronomen. Erzwingt reguläre V2-Inversion ("vollendete die Montagekolonne").',
        triWayTransformationFormula:
            'Satz A ; dessen ungeachtet + [Finitum] + [Subjekt] ...',
        diagnosticTrapWarning:
            'Gilt in Ingenieursgutachten als Zeichen höchster sprachlicher Präzision.',
      ),
    );

    // 10. wie ... auch (Scalar Concessive with Manner Adverb) - Aerospace Aviation
    _catalog.add(
      const ConcessiveConnectorModel(
        id: 'CONC-WIE-AUCH-AERO-10',
        connectorType: ConcessiveConnectorType.scalarGeneralizingConcessive,
        connectorWord: 'wie ... auch',
        formType: SyntacticFormType.scalarModifierClause,
        domain: CommunicativeDomain.aerospaceAndAviation,
        basePropositionP: 'Die Triebwerkstests im Prüfstand werden intensiv variiert.',
        counterExpectationQ: 'Die Kühlmitteltemperatur darf den Schwellenwert niemals überschreiten.',
        sampleSentence:
            'Wie intensiv die Triebwerkstests auf dem Prüfstand auch variiert werden, die Kühlmitteltemperatur darf die kritische Schwelle niemals überschreiten.',
        arabicTranslation:
            'مهما نُوِّعت اختبارات المحركات على منصة الفحص وكُثِّفت، فلا يجوز لدرجة حرارة سائل التبريد أن تتجاوز العتبة الحرجة تحت أي ظرف.',
        grammaticalAnalysisArabic:
            'استدراك تعميمي بكيفية الفعل: "Wie + ظرف الحال (intensiv) + الفاعل + auch + الفعل المبني للمجهول في الختام (variiert werden)".',
        grammaticalAnalysisGerman:
            'Modaler Verallgemeinerungssatz mit "wie" und Partikel "auch". Drückt aus, dass das Hauptsatzgebot unabhängig von allen Parametern ausnahmslos gilt.',
        triWayTransformationFormula:
            'Wie + [Adverb] + [Subjekt] + auch + [Verb am Ende] , [Hauptsatz] ...',
        diagnosticTrapWarning:
            'Typische Struktur für sicherheitskritische Systemanforderungen in der Luft- und Raumfahrt.',
      ),
    );

    // 11. trotzdem (Pitfall: Colloquial Verb-End vs. Standard Inversion) - Industrial Robotics
    _catalog.add(
      const ConcessiveConnectorModel(
        id: 'CONC-TROTZDEM-ROBOT-11',
        connectorType: ConcessiveConnectorType.adverbialInversionConnector,
        connectorWord: 'trotzdem',
        formType: SyntacticFormType.inversionMainClause,
        domain: CommunicativeDomain.industrialRobotics,
        basePropositionP: 'Die optische Sensorik war leicht verstaubt.',
        counterExpectationQ: 'Der Greifarm positionierte das Bauteil mikrometergenau.',
        sampleSentence:
            'Die optische Sensorik war leicht verstaubt; trotzdem positionierte der Greifarm das empfindliche Bauteil mikrometergenau.',
        arabicTranslation:
            'كانت منظومة الاستشعار البصري مغبرة قليلاً؛ ورغم ذلك قام الذراع القابض بضبط موضع القطعة الحساسة بدقة الميكرومتر.',
        grammaticalAnalysisArabic:
            'الظرف "trotzdem": يربط جملتين رئيسيتين ويفرض تقديم الفعل (positionierte) على الفاعل (der Greifarm). استخدام trotzdem كأداة عطف تضع الفعل في النهاية خطأ دارج يُمنع في الفصحى.',
        grammaticalAnalysisGerman:
            'Konnektionaladverb "trotzdem" verlangt standardsprachlich ausnahmslos V2-Inversion. Der umgangssprachliche Nebensatzgebrauch (*trotzdem der Greifarm positionierte) ist in der Schriftsprache unzulässig.',
        triWayTransformationFormula:
            'Standardsprache: ... ; trotzdem + [Verb] + [Subjekt]  (NICHT: *trotzdem [Subjekt] ... [Verb])',
        diagnosticTrapWarning:
            'Kardinaler Prüfungsfehler: "trotzdem" mit Verb am Satzende ist schwere Umgangssprache; standardsprachlich gehört "obwohl" dorthin!',
      ),
    );

    // 12. wenn ... auch (Discontinuous Concessive Subjunction) - Material Science
    _catalog.add(
      const ConcessiveConnectorModel(
        id: 'CONC-WENN-AUCH-MAT-12',
        connectorType: ConcessiveConnectorType.subordinatingConjunction,
        connectorWord: 'wenn ... auch',
        formType: SyntacticFormType.subordinateClause,
        domain: CommunicativeDomain.materialScience,
        basePropositionP: 'Die Produktionskosten der Titan-Nanoröhrchen sind hoch.',
        counterExpectationQ: 'Ihre Haltbarkeit rechtfertigt den Einsatz.',
        sampleSentence:
            'Wenn die Herstellungskosten der Titan-Nanoröhrchen gegenwärtig auch noch hoch sind, rechtfertigt ihre überragende Dauerfestigkeit den Einsatz.',
        arabicTranslation:
            'وإن كانت تكاليف تصنيع أنابيب التيتانيوم النانوية لا تزال مرتفعة في الوقت الراهن، فإن متانتها الفائقة وطول عمرها الافتراضي يبرران استخدامها.',
        grammaticalAnalysisArabic:
            'أداة الربط المنفصلة "wenn ... auch": تعمل كأداة شرط استدراكية تفيد معنى "وإن كان / حتى لو كان"، وتضع الفعل المصرف في النهاية (sind).',
        grammaticalAnalysisGerman:
            'Diskontinuierliche Konzessivsubjunktion "wenn ... auch". Steht funktional für "selbst wenn / obgleich" mit Verb-Endstellung.',
        triWayTransformationFormula:
            'Wenn [Subjekt] ... auch [Verb am Ende] , [Verb] + [Subjekt] ...',
        diagnosticTrapWarning:
            'Trennt man "wenn" und "auch", wirkt die Aussage diplomatischer und abwägender als mit dem schroffen "obwohl".',
      ),
    );

    // 13. wohingegen (Pure Contrastive Subjunction) - Civil Infrastructure
    _catalog.add(
      const ConcessiveConnectorModel(
        id: 'CONC-WOHINGEGEN-CIVIL-13',
        connectorType: ConcessiveConnectorType.adversativeContrast,
        connectorWord: 'wohingegen',
        formType: SyntacticFormType.subordinateClause,
        domain: CommunicativeDomain.civilInfrastructure,
        basePropositionP: 'Bewehrungsstahl eine hohe Zugfestigkeit aufweist.',
        counterExpectationQ: 'Unbewehrter Beton vor allem Druckkräfte aufnimmt.',
        sampleSentence:
            'Bewehrungsstahl weist eine exzellente Zugfestigkeit auf, wohingegen unbewehrter Konstruktionsbeton vor allem hohe Druckkräfte absorbieren kann.',
        arabicTranslation:
            'يتميز حديد التسليح بمقاومة شد ممتازة، في حين أن الخرسانة الإنشائية غير المسلحة بمقدورها امتصاص قوى الضغط العالية بالدرجة الأولى.',
        grammaticalAnalysisArabic:
            'أداة المقابلة التناظرية الفصيحة "wohingegen": تبرز التباين والافتراق في الخصائص الفيزيائية مع نقل الفعل الناقص والمصدر لنهاية الجملة (absorbieren kann).',
        grammaticalAnalysisGerman:
            'Gehobene adversative Subjunktion "wohingegen" zur scharfen Trennung zweier komplementärer Materialeigenschaften mit Verb-Endstellung.',
        triWayTransformationFormula:
            'Hauptsatz A , wohingegen [Subjekt] ... [Verb am Ende]',
        diagnosticTrapWarning:
            'Darf nicht mit konzessivem "obwohl" verwechselt werden; es liegt kein Ursache-Wirkungs-Widerspruch vor.',
      ),
    );

    // 14. obschon (Archaic/Elevated Literary Subjunction) - Maritime Logistics
    _catalog.add(
      const ConcessiveConnectorModel(
        id: 'CONC-OBSCHON-MARITIME-14',
        connectorType: ConcessiveConnectorType.subordinatingConjunction,
        connectorWord: 'obschon',
        formType: SyntacticFormType.subordinateClause,
        domain: CommunicativeDomain.maritimeLogistics,
        basePropositionP: 'Die Strömungsverhältnisse in der Flussmündung waren tückisch.',
        counterExpectationQ: 'Der Schleppverband passierte die Engstelle ohne Zwischenfall.',
        sampleSentence:
            'Obschon die Strömungsverhältnisse in der engen Flussmündung äußerst tückisch waren, passierte der Schleppverband die Passage ohne Zwischenfall.',
        arabicTranslation:
            'مع أن تيارات المياه في مصب النهر الضيق كانت بالغة الغدر والخطورة، عبر موكب القطر المائي الممر الملاحي دون وقوع أي حادث.',
        grammaticalAnalysisArabic:
            'أداة الربط الاستدراكية التراثية الرفيعة "obschon": تماثل obwohl تماماً في العمل النحوي (الفعل في النهاية: waren) لكنها تضفي طابعاً أدبياً وتاريخياً موثوقاً.',
        grammaticalAnalysisGerman:
            'Seltenere, historisch geprägte Konzessivsubjunktion mit strikter Verb-Endstellung ("waren"). Synonym zu "obgleich".',
        triWayTransformationFormula:
            'Obschon [S] ... [V-Ende] , [V] + [S] ...',
        diagnosticTrapWarning:
            'Wird im modernen Alltagsdeutsch kaum gesprochen, begegnet aber häufig in klassischen Berichten und Schifffahrtschroniken.',
      ),
    );

    // 15. wenn auch (Elliptical Parenthetical Concessive) - Renewable Energy
    _catalog.add(
      const ConcessiveConnectorModel(
        id: 'CONC-WENN-AUCH-ELLIP-15',
        connectorType: ConcessiveConnectorType.subordinatingConjunction,
        connectorWord: 'wenn auch',
        formType: SyntacticFormType.scalarModifierClause,
        domain: CommunicativeDomain.renewableEnergyGrid,
        basePropositionP: 'Die Umrüstung der Umspannwerke ist mit hohen Anfangsinvestitionen verbunden.',
        counterExpectationQ: 'Sie ist eine zukunftssichere Maßnahme.',
        sampleSentence:
            'Die Umrüstung der Umspannwerke auf digitale Leittechnik ist eine zukunftssichere, wenn auch kurzfristig kostenintensive Maßnahme.',
        arabicTranslation:
            'يُعد تحويل محطات المحولات الكهربائية إلى تقنيات التحكم الرقمي تدبيراً مستداماً للمستقبل، وإن كان مكلفاً ومستهلكاً للمال على المدى القصير.',
        grammaticalAnalysisArabic:
            'اعتراض استدراكي محذوف الفعل (Elliptische Konzessivphrase): "wenn auch + Adjektiv" محصورة بين فاصلتين داخل المركب الاسمي كقيد وصفي موجز.',
        grammaticalAnalysisGerman:
            'Elliptische Konzessivfügung "wenn auch" ohne eigenes finites Verb zur attributiven Einschränkung vor dem Nomen.',
        triWayTransformationFormula:
            '..., wenn auch + [Adjektivphrase] , [Nomen] ...',
        diagnosticTrapWarning:
            'Sehr elegante syntaktische Verdichtung, vermeidet schwerfällige Relativ- oder Nebensätze.',
      ),
    );

    // 16. nichtsdestoweniger (Formal Double Concessive Adverb) - Aerospace Aviation
    _catalog.add(
      const ConcessiveConnectorModel(
        id: 'CONC-NICHTSDESTO-AERO-16',
        connectorType: ConcessiveConnectorType.adverbialInversionConnector,
        connectorWord: 'nichtsdestoweniger',
        formType: SyntacticFormType.inversionMainClause,
        domain: CommunicativeDomain.aerospaceAndAviation,
        basePropositionP: 'Der erste Triebwerksprototyp verfehlte den avisierten Schubwert knapp.',
        counterExpectationQ: 'Die Messdaten lieferten unverzichtbare Grundlagen für die Serienreife.',
        sampleSentence:
            'Der erste Triebwerksprototyp verfehlte den avisierten Schubwert um zwei Prozent; nichtsdestoweniger lieferten die Messdaten unverzichtbare Grundlagen für die Serienreife.',
        arabicTranslation:
            'أخفق النموذج الأولي للمحرك في تحقيق قوة الدفع المستهدفة بنسبة اثنين بالمائة؛ ومع ذلك ورغم ذلك وفرت بيانات القياس أسساً لا غنى عنها لبلوغ مرحلة الإنتاج التسلسلي.',
        grammaticalAnalysisArabic:
            'ظرف ربط استدراكي رسمي عالي الرتبة (nichtsdestoweniger): يشغل موقع الصدر ويوجب تقديم الفعل المصرف (lieferten) على الفاعل (die Messdaten).',
        grammaticalAnalysisGerman:
            'Konnektionaladverb gehobener Kanzlei- und Wissenschaftssprache mit regulärer Inversion (V2). Synonym zu "trotzdem", jedoch mit maximalem Formregisterniveau.',
        triWayTransformationFormula:
            'Aussage A ; nichtsdestoweniger + [Verb] + [Subjekt] ...',
        diagnosticTrapWarning:
            'Wird im juristischen und patentrechtlichen Schriftverkehr als rhetorisches Schwergewicht geschätzt.',
      ),
    );
  }

  /// Evaluates an input concessive sentence candidate for verb position and avoidance of colloquial pitfalls.
  ConcessiveValidationReport validateConcessiveSentence({
    required String connectorUsed,
    required bool isVerbInFinalPosition,
    required bool isVerbInSecondPositionWithInversion,
    required bool isColloquialTrotzdemSubjunction,
  }) {
    final issues = <String>[];
    final recommendations = <String>[];

    final isSubjunction =
        connectorUsed.toLowerCase() == 'obwohl' ||
        connectorUsed.toLowerCase() == 'obgleich' ||
        connectorUsed.toLowerCase() == 'obschon' ||
        connectorUsed.toLowerCase() == 'während' ||
        connectorUsed.toLowerCase() == 'wohingegen';

    final isAdverb =
        connectorUsed.toLowerCase() == 'dennoch' ||
        connectorUsed.toLowerCase() == 'trotzdem' ||
        connectorUsed.toLowerCase() == 'gleichwohl' ||
        connectorUsed.toLowerCase() == 'dessen ungeachtet' ||
        connectorUsed.toLowerCase() == 'nichtsdestoweniger';

    if (isColloquialTrotzdemSubjunction) {
      issues.add(
        'Schwerer stilistischer Fehler: "trotzdem" darf in der Standardsprache NIEMALS als Subjunktion mit Verb-Endstellung verwendet werden (*trotzdem es regnete).',
      );
      recommendations.add(
        'Ersetzen Sie "trotzdem" durch die Subjunktion "obwohl" oder nutzen Sie "trotzdem" als Adverb mit Inversion im Hauptsatz ("...; trotzdem regnete es").',
      );
    }

    if (isSubjunction && !isVerbInFinalPosition) {
      issues.add(
        'Topologischer Fehler: Nach der Subjunktion "$connectorUsed" muss das finite Verb zwingend an der letzten Satzposition stehen.',
      );
      recommendations.add('Verschieben Sie das finite Verb an das Ende des Nebensatzes vor das Komma.');
    }

    if (isAdverb && !isVerbInSecondPositionWithInversion) {
      issues.add(
        'Inversionsfehler: Das Konnektionaladverb "$connectorUsed" besetzt das Vorfeld und verlangt zwingend Inversion (Finitum vor Subjekt).',
      );
      recommendations.add('Platzieren Sie das finite Verb unmittelbar nach "$connectorUsed" vor dem Subjekt.');
    }

    final isValid = issues.isEmpty;
    final verdict = isValid
        ? 'التركيب النحوي للجملة الاستدراكية/التقابلية ورتبة الفعل المصرف متطابقان تماماً مع أرقى معايير الفصاحة الألمانية (C1-C2).'
        : 'تم رصد خلل في الموقع الطوبولوجي للفعل المصرف أو استخدام عامي غير فصيح للظرف trotzdem كأداة تبعية.';

    return ConcessiveValidationReport(
      isValid: isValid,
      isVerbPositionCompliant: issues.where((e) => e.contains('Topologischer') || e.contains('Inversionsfehler')).isEmpty,
      avoidsColloquialTrotzdem: !isColloquialTrotzdemSubjunction,
      issues: issues,
      recommendations: recommendations,
      arabicDiagnosticVerdict: verdict,
    );
  }

  List<ConcessiveConnectorModel> filterByType(ConcessiveConnectorType type) {
    return _catalog.where((item) => item.connectorType == type).toList();
  }

  List<ConcessiveConnectorModel> filterByDomain(CommunicativeDomain domain) {
    return _catalog.where((item) => item.domain == domain).toList();
  }
}
