import 'dart:collection';

/// Classification of two-part correlative connector pairs with topological asymmetries.
enum CorrelativePairType {
  jeDestoUmso(
    'je ... desto / umso (Proportional-Komparativ)',
    'كلما ... زاد / كان ... (العطف التناسبي المقارن)',
    'Vordersatz: "je" + Komparativ leitet Nebensatz mit Verb-Endstellung ein; Nachsatz: "desto/umso" + Komparativ besetzt das Vorfeld, gefolgt vom finiten Verb (V2).',
  ),
  wederNoch(
    'weder ... noch (Doppelte Negation & Disjunktion)',
    'لا ... ولا ... (العطف السلبي المزدوج مع قلب الفعل إجبارياً بعد noch)',
    'Erster Teilsatz: "weder"; Zweiter Teilsatz: "noch" steht im Vorfeld und erzwingt zwingend Inversion (Finitum vor Subjekt). Doppelnegation mit "nicht" verboten.',
  ),
  entwederOder(
    'entweder ... oder (Alternative Disjunktion mit Wortstellungsverzweigung)',
    'إما ... أو ... (العطف التخييري مع اختلاف رتبة الفعل بين الشطرين)',
    '"entweder" kann Vorfeld besetzen (Inversion) oder auf Position 0 stehen; "oder" steht im Folgesatz ausnahmslos auf Position 0 (keine Inversion!).',
  ),
  nichtNurSondernAuch(
    'nicht nur ... sondern auch (Kopulative Emphase & Steigerung)',
    'ليس فقط ... بل أيضاً ... (العطف التراكمي المؤكد)',
    'Bei Voranstellung von "nicht nur" erfolgt Inversion im Hauptsatz; "sondern" besetzt Position 0, "auch" steht im Mittelfeld vor dem Fokuselement.',
  ),
  zwarAber(
    'zwar ... aber (Konzessive Einschränkung & Adversativität)',
    'صحيح أن ... لكن ... (الاستدراك المقيد مع تباين الرتبة التركيبية)',
    '"zwar" im Vorfeld erzwingt Inversion; "aber" im Folgesatz besetzt Position 0 (reguläre Subjekt-Verb-Folge).',
  ),
  einerseitsAndererseits(
    'einerseits ... andererseits (Antithetische Doppelperspektive)',
    'من ناحية ... ومن ناحية أخرى ... (التقابل المتناظر مع قلب الفعل في كلا الشطرين)',
    'Beide Konnektoren besetzen das Vorfeld ihrer jeweiligen Teilsätze und erzwingen symmetrisch die Inversion des finiten Verbs.',
  ),
  sowohlAlsAuch(
    'sowohl ... als auch (Neutrale Satzglied- & Phrasenkoordination)',
    'سواء ... أو ... / كلاً من ... و ... (الجمع المتكافئ للوحدات التركيبية)',
    'Verbindet syntaktisch gleichwertige Satzglieder oder Teilsätze ohne Modifikation der Grundwortstellung.',
  );

  final String germanTitle;
  final String arabicTitle;
  final String topologicalRule;
  const CorrelativePairType(
    this.germanTitle,
    this.arabicTitle,
    this.topologicalRule,
  );
}

/// Structural topological behavior of clauses connected by correlatives.
enum ClauseTopologyBehavior {
  inversionForced(
    'Erzwungene Inversion (Finitum vor Subjekt)',
    'قلب الفعل حتماً قبل الفاعل (تقديم المسند)',
  ),
  positionZeroRegular(
    'Position 0 (Reguläre Subjekt-Verb-Reihenfolge)',
    'الموقع الصفري (الحفاظ على الترتيب الطبيعي: فاعل ثم فعل)',
  ),
  subordinateVerbFinal(
    'Nebensatz mit Verb-Endstellung',
    'جملة ثانوية بوقوع الفعل في نهاية الشطر',
  ),
  flexiblePositionZeroOrOne(
    'Flexibel (Position 0 oder Vorfeld-Inversion zulässig)',
    'مرن (يقبل الموقع الصفري أو تقديم الصدر مع قلب الفاعل)',
  );

  final String de;
  final String ar;
  const ClauseTopologyBehavior(this.de, this.ar);
}

/// Professional and engineering domains free of legal/medical liability.
enum CommunicativeDomain {
  renewableEnergyGrid('Erneuerbare Energien & Netztechnik', 'الطاقة المتجددة وهندسة الشبكات'),
  aerospaceAndAviation('Luft- & Raumfahrttechnik', 'هندسة الطيران واستكشاف الفضاء'),
  industrialRobotics('Industrierobotik & Automatisierung', 'الروبوتات الصناعية والأتمتة'),
  civilInfrastructure('Bauingenieurwesen & Statik', 'الهندسة المدنية والمنشآت'),
  materialScience('Werkstoffkunde & Nanostrukturen', 'علم المواد والتراكيب النانوية'),
  maritimeLogistics('Maritime Schifffahrt & Hafenumschlag', 'الملاحة البحرية والشحن الدولي');

  final String de;
  final String ar;
  const CommunicativeDomain(this.de, this.ar);
}

/// Model representing a specific correlative connector sentence and its topological rules.
class CorrelativeConnectorModel {
  final String id;
  final CorrelativePairType pairType;
  final String firstConnector;
  final String secondConnector;
  final ClauseTopologyBehavior firstClauseTopology;
  final ClauseTopologyBehavior secondClauseTopology;
  final CommunicativeDomain domain;
  final String fullSentence;
  final String arabicTranslation;
  final String grammaticalAnalysisArabic;
  final String grammaticalAnalysisGerman;
  final String commonWordOrderMistake;
  final String topologicalRuleSummary;

  const CorrelativeConnectorModel({
    required this.id,
    required this.pairType,
    required this.firstConnector,
    required this.secondConnector,
    required this.firstClauseTopology,
    required this.secondClauseTopology,
    required this.domain,
    required this.fullSentence,
    required this.arabicTranslation,
    required this.grammaticalAnalysisArabic,
    required this.grammaticalAnalysisGerman,
    required this.commonWordOrderMistake,
    required this.topologicalRuleSummary,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'pairType': pairType.name,
    'firstConnector': firstConnector,
    'secondConnector': secondConnector,
    'firstClauseTopology': firstClauseTopology.name,
    'secondClauseTopology': secondClauseTopology.name,
    'domain': domain.name,
    'fullSentence': fullSentence,
    'arabicTranslation': arabicTranslation,
    'grammaticalAnalysisArabic': grammaticalAnalysisArabic,
    'grammaticalAnalysisGerman': grammaticalAnalysisGerman,
    'commonWordOrderMistake': commonWordOrderMistake,
    'topologicalRuleSummary': topologicalRuleSummary,
  };
}

/// Verification report container for correlative connector validation.
class CorrelativeValidationReport {
  final bool isValid;
  final bool isVerbPositionCompliant;
  final bool isPolarityRespected;
  final List<String> issues;
  final List<String> recommendations;
  final String arabicDiagnosticVerdict;

  const CorrelativeValidationReport({
    required this.isValid,
    required this.isVerbPositionCompliant,
    required this.isPolarityRespected,
    required this.issues,
    required this.recommendations,
    required this.arabicDiagnosticVerdict,
  });
}

/// Sovereign engine governing German Correlative Connectors & Topological Asymmetry.
class GermanCorrelativeConnectorsEngine {
  final List<CorrelativeConnectorModel> _catalog = [];

  GermanCorrelativeConnectorsEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<CorrelativeConnectorModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    // 1. je ... desto (Proportional Comparative) - Renewable Energy
    _catalog.add(
      const CorrelativeConnectorModel(
        id: 'CORR-JE-DESTO-ENERGY-01',
        pairType: CorrelativePairType.jeDestoUmso,
        firstConnector: 'je',
        secondConnector: 'desto',
        firstClauseTopology: ClauseTopologyBehavior.subordinateVerbFinal,
        secondClauseTopology: ClauseTopologyBehavior.inversionForced,
        domain: CommunicativeDomain.renewableEnergyGrid,
        fullSentence:
            'Je präziser die Windleistungsprognosen der meteorologischen Modelle ausfallen, desto effizienter kann der Netzbetreiber die zuschaltbaren Gaskraftwerke drosseln.',
        arabicTranslation:
            'كلما جاءت توقعات طاقة الرياح الصادرة عن النماذج الجوية أكثر دقة، زادت قدرة مشغل الشبكة على خفض تشغيل محطات الغاز الاحتياطية بكفاءة أكبر.',
        grammaticalAnalysisArabic:
            'رابط تناسبي مركب: جملة "je" جملة ثانوية يقع فعلها في الختام (ausfallen)، بينما شطر "desto" يحتل صدارته صفة المقارنة (desto effizienter) ويليه الفعل الناقص فوراً (kann) ثم الفاعل.',
        grammaticalAnalysisGerman:
            'Proportionale Satzverflechtung: Der je-Satz weist strikte Verb-Endstellung auf. Im desto-Satz bildet "desto + Komparativ" das Vorfeld, worauf unmittelbar das finite Hilfsverb in V2 folgt.',
        commonWordOrderMistake:
            'Subjekt vor Verb im Folgesatz: "*desto der Netzbetreiber kann effizienter drosseln" (Verletzung der V2-Regel!).',
        topologicalRuleSummary:
            'Regel: Je + Komparativ ... [Verb am Ende], desto/umso + Komparativ + [Finites Verb] + [Subjekt] ...',
      ),
    );

    // 2. je ... umso (Proportional Comparative) - Material Science
    _catalog.add(
      const CorrelativeConnectorModel(
        id: 'CORR-JE-UMSO-MAT-02',
        pairType: CorrelativePairType.jeDestoUmso,
        firstConnector: 'je',
        secondConnector: 'umso',
        firstClauseTopology: ClauseTopologyBehavior.subordinateVerbFinal,
        secondClauseTopology: ClauseTopologyBehavior.inversionForced,
        domain: CommunicativeDomain.materialScience,
        fullSentence:
            'Je homogener die Nanopartikel in der Trägermatrix verteilt sind, umso höher ist die thermische Leitfähigkeit des Verbundwerkstoffs.',
        arabicTranslation:
            'كلما توزع الجسيمات النانوية بصورة أكثر تجانساً داخل المصفوفة الحاملة، زادت الموصلية الحرارية للمادة المركبة وارتفعت.',
        grammaticalAnalysisArabic:
            'استعمال "umso" كمرادف تام لـ desto؛ تقديم اسم التفضيل (umso höher) متبوعاً بالفعل المصرف (ist) في المركز الثاني.',
        grammaticalAnalysisGerman:
            '"umso" ist absolut gleichwertig zu "desto". Zwingende V2-Position des Prädikats "ist" direkt nach der Vorfeld-Komparativphrase.',
        commonWordOrderMistake:
            'Falsche Verb-Endstellung im Nachsatz: "*umso die thermische Leitfähigkeit höher ist".',
        topologicalRuleSummary:
            'Duden: "desto" und "umso" sind standardsprachlich vollkommen synonym.',
      ),
    );

    // 3. weder ... noch (Forced Inversion in Second Clause) - Aerospace Engineering
    _catalog.add(
      const CorrelativeConnectorModel(
        id: 'CORR-WEDER-NOCH-AERO-03',
        pairType: CorrelativePairType.wederNoch,
        firstConnector: 'weder',
        secondConnector: 'noch',
        firstClauseTopology: ClauseTopologyBehavior.inversionForced,
        secondClauseTopology: ClauseTopologyBehavior.inversionForced,
        domain: CommunicativeDomain.aerospaceAndAviation,
        fullSentence:
            'Weder verzeichneten die Bordsensoren während des Wiedereintritts einen kritischen Temperaturanstieg, noch registrierte die Bodenstation jegliche Abweichung vom Sollkurs.',
        arabicTranslation:
            'لا المستشعرات الموجودة على متن المركبة سجلت أي ارتفاع حرج في درجات الحرارة أثناء العودة للغلاف الجوي، ولا المحطة الأرضية رصدت أي انحراف عن المسار المستهدف.',
        grammaticalAnalysisArabic:
            'رابط النفي المزدوج: "noch" في الشطر الثاني يشغل موقع الصدر حتماً ويفرض قلب الفاعل بعد الفعل المصرف (noch registrierte die Bodenstation...).',
        grammaticalAnalysisGerman:
            'Bei selbstständigen Hauptsätzen erzwingt "noch" im Nachsatz zwingend die V2-Inversion des Verbs vor das Subjekt. Im Vordersatz steht "weder" ebenfalls im Vorfeld.',
        commonWordOrderMistake:
            'Keine Inversion nach noch: "*noch die Bodenstation registrierte" oder unzulässige Doppelnegation: "*noch registrierte sie keine Abweichung".',
        topologicalRuleSummary:
            'Regel: Noch steht im Vorfeld und verlangt zwingend V2-Inversion; zusätzliche Verneinungswörter sind verboten.',
      ),
    );

    // 4. weder ... noch (Coordination of Noun Phrases) - Industrial Robotics
    _catalog.add(
      const CorrelativeConnectorModel(
        id: 'CORR-WEDER-NOCH-PHRASE-04',
        pairType: CorrelativePairType.wederNoch,
        firstConnector: 'weder',
        secondConnector: 'noch',
        firstClauseTopology: ClauseTopologyBehavior.positionZeroRegular,
        secondClauseTopology: ClauseTopologyBehavior.positionZeroRegular,
        domain: CommunicativeDomain.industrialRobotics,
        fullSentence:
            'Die vollautomatische Schweißzelle toleriert weder mechanische Erschütterungen noch unzulässige Spannungsschwankungen im Versorgungsnetz.',
        arabicTranslation:
            'لا تتسامح خلية اللحام المؤتمتة بالكامل مع الاهتزازات الميكانيكية ولا مع التقلبات غير المسموح بها في جهد شبكة التغذية.',
        grammaticalAnalysisArabic:
            'عطف مفعولين بهما: "weder ... noch" يربط المفعولين بالتوازي التام (mechanische Erschütterungen / Spannungsschwankungen) دون التأثير على رتبة الفعل والفاعل.',
        grammaticalAnalysisGerman:
            'Satzgliedkoordination von zwei Akkusativobjekten mittels "weder ... noch". Die Satzklammer des Hauptsatzes bleibt unberührt.',
        commonWordOrderMistake:
            'Einfügen von "nicht": "*toleriert nicht weder Erschütterungen...".',
        topologicalRuleSummary:
            'Bei Satzgliedverbindung bleibt die Satzklammer des übergeordneten Satzes unverändert.',
      ),
    );

    // 5. entweder ... oder (Inversion in First vs. Position 0 in Second) - Civil Infrastructure
    _catalog.add(
      const CorrelativeConnectorModel(
        id: 'CORR-ENTWEDER-ODER-CIVIL-05',
        pairType: CorrelativePairType.entwederOder,
        firstConnector: 'entweder',
        secondConnector: 'oder',
        firstClauseTopology: ClauseTopologyBehavior.inversionForced,
        secondClauseTopology: ClauseTopologyBehavior.positionZeroRegular,
        domain: CommunicativeDomain.civilInfrastructure,
        fullSentence:
            'Entweder verstärken die Bauingenieure das Fundament mit zusätzlichen Mikropfählen, oder die vorgesehene Traglast des Gebäudes muss reduziert werden.',
        arabicTranslation:
            'إما أن يقوم مهندسو البناء بتدعيم الأساس بركائز دقيقة إضافية، أو أنه سيتعين تخفيض الحمولة الإنشائية المقررة للمبنى.',
        grammaticalAnalysisArabic:
            'عدم التناظر الطوبولوجي الحاسم: "Entweder" تصدرت الشطر الأول وفرضت قلب الفاعل (verstärken die Bauingenieure)، بينما "oder" في الشطر الثاني تشغل الموقع الصفري (Position 0) ويأتي بعدها الفاعل ثم الفعل (die Traglast muss...).',
        grammaticalAnalysisGerman:
            'Topologische Asymmetrie: "entweder" steht im Vorfeld und erzwingt Inversion (Finitum vor Subjekt). "oder" fungiert als koordinierende Konjunktion auf Position 0; danach folgt reguläre Wortstellung (Subjekt + Finitum).',
        commonWordOrderMistake:
            'Fälschliche Inversion nach oder: "*oder muss die Traglast reduziert werden".',
        topologicalRuleSummary:
            'Regel: Entweder [Verb] [Subjekt] ... , oder [Subjekt] [Verb] ... (oder = Position 0).',
      ),
    );

    // 6. entweder ... oder (Position 0 in both clauses) - Maritime Logistics
    _catalog.add(
      const CorrelativeConnectorModel(
        id: 'CORR-ENTWEDER-POS0-06',
        pairType: CorrelativePairType.entwederOder,
        firstConnector: 'entweder',
        secondConnector: 'oder',
        firstClauseTopology: ClauseTopologyBehavior.flexiblePositionZeroOrOne,
        secondClauseTopology: ClauseTopologyBehavior.positionZeroRegular,
        domain: CommunicativeDomain.maritimeLogistics,
        fullSentence:
            'Entweder das Frachtschiff erreicht die Schleuse vor Niedrigwasser, oder die Schiffsleitung muss auf die nächste Flutwelle warten.',
        arabicTranslation:
            'إما أن تصل سفينة الشحن إلى هويس الملاحة قبل حلول الجزر، أو سيتعين على ربان السفينة الانتظار حتى موجة المد القادمة.',
        grammaticalAnalysisArabic:
            'وقوع "entweder" في الموقع الصفري (Position 0) دون قلب، متبوعة بالفاعل (das Frachtschiff) ثم الفعل (erreicht).',
        grammaticalAnalysisGerman:
            '"entweder" kann im modernen Deutsch auch als Konnektor auf Position 0 vor das Subjekt treten, ohne Inversion auszulösen.',
        commonWordOrderMistake:
            'Verunsicherung über die Zulässigkeit von Position 0 bei entweder; beides ist standardsprachlich korrekt.',
        topologicalRuleSummary:
            'Duden: "Entweder" darf auf Position 0 oder im Vorfeld (mit Inversion) stehen.',
      ),
    );

    // 7. nicht nur ... sondern auch (Fronted with Inversion) - Renewable Energy
    _catalog.add(
      const CorrelativeConnectorModel(
        id: 'CORR-NICHT-NUR-ENERGY-07',
        pairType: CorrelativePairType.nichtNurSondernAuch,
        firstConnector: 'nicht nur',
        secondConnector: 'sondern auch',
        firstClauseTopology: ClauseTopologyBehavior.inversionForced,
        secondClauseTopology: ClauseTopologyBehavior.positionZeroRegular,
        domain: CommunicativeDomain.renewableEnergyGrid,
        fullSentence:
            'Nicht nur dämpfen die modernen Wechselrichter kurzzeitige Netzfrequenzschwankungen, sondern sie stellen auch unverzüglich Blindleistung zur Spannungsstabilisierung bereit.',
        arabicTranslation:
            'لا تقتصر المحولات الكهربائية الحديثة على إخماد تقلبات تردد الشبكة اللحظية، بل إنها تضخ أيضاً على الفور طاقة غير فعالة لتثبيت الجهد الكهربائي.',
        grammaticalAnalysisArabic:
            'تقدم "Nicht nur" في الصدر يفرض قلب الفاعل بعد الفعل (Nicht nur dämpfen die Wechselrichter...). أما الشطر الثاني فتبدأ بـ "sondern" (موقع صفر) ثم الفاعل (sie) والفعل (stellen) مع وضع "auch" في حشو الجملة.',
        grammaticalAnalysisGerman:
            'Topikalisierung von "nicht nur" im Vorfeld erzwingt Satzinversion. "sondern" besetzt Position 0; "auch" platziert sich als Fokuspartikel im Mittelfeld.',
        commonWordOrderMistake:
            'Keine Inversion im Vordersatz: "*Nicht nur die Wechselrichter dämpfen..." oder "aber auch" statt "sondern auch" nach Verneinung.',
        topologicalRuleSummary:
            'Regel: Nicht nur + [Finitum] + [Subjekt] ... , sondern + [Subjekt] + [Finitum] + auch ...',
      ),
    );

    // 8. nicht nur ... sondern auch (Coordinating Predicate Infinitives) - Industrial Robotics
    _catalog.add(
      const CorrelativeConnectorModel(
        id: 'CORR-NICHT-NUR-INF-08',
        pairType: CorrelativePairType.nichtNurSondernAuch,
        firstConnector: 'nicht nur',
        secondConnector: 'sondern auch',
        firstClauseTopology: ClauseTopologyBehavior.positionZeroRegular,
        secondClauseTopology: ClauseTopologyBehavior.positionZeroRegular,
        domain: CommunicativeDomain.industrialRobotics,
        fullSentence:
            'Die intelligente Fertigungssoftware kann Bauteildefekte nicht nur präzise erkennen, sondern auch autonom korrigieren.',
        arabicTranslation:
            'تستطيع برمجية التصنيع الذكية ليس فقط رصد عيوب القطع الإنشائية بدقة، بل أيضاً تصحيحها ومعالجتها ذاتياً.',
        grammaticalAnalysisArabic:
            'عطف مصدرين فعليين في نهاية القوس الفعلي: (nicht nur erkennen, sondern auch korrigieren) داخل إطار الفعل الناقص (kann).',
        grammaticalAnalysisGerman:
            'Satzinterne Verbalkoordination am rechten Satzrand innerhalb der Modalverbklammer "kann ... korrigieren".',
        commonWordOrderMistake:
            'Falsches Komma-Weglassen vor "sondern" (Kommasetzung ist zwingend).',
        topologicalRuleSummary:
            'Komma ist vor "sondern" bei Teilsätzen und erweiterten Infinitiven obligatorisch.',
      ),
    );

    // 9. zwar ... aber (Concessive-Adversative) - Material Science
    _catalog.add(
      const CorrelativeConnectorModel(
        id: 'CORR-ZWAR-ABER-MAT-09',
        pairType: CorrelativePairType.zwarAber,
        firstConnector: 'zwar',
        secondConnector: 'aber',
        firstClauseTopology: ClauseTopologyBehavior.inversionForced,
        secondClauseTopology: ClauseTopologyBehavior.positionZeroRegular,
        domain: CommunicativeDomain.materialScience,
        fullSentence:
            'Zwar zeichnet sich die Graphenbeschichtung durch eine außergewöhnliche Zugfestigkeit aus, aber ihre industrielle Großserienfertigung erfordert noch erhebliche Prozessoptimierungen.',
        arabicTranslation:
            'صحيحٌ أن طلاء الغرافين يتميز بمتانة شد استثنائية، لكن تصنيعه الصناعي واسع النطاق لا يزال يتطلب تحسينات إجرائية جوهرية.',
        grammaticalAnalysisArabic:
            'تقديم "Zwar" في صدر الشطر الأول يوجب تقديم الفعل المصرف (zeichnet sich aus)، بينما "aber" في الشطر الثاني تربط الجملة كأداة في الموقع الصفري متبوعة بالمبتدأ الاسمي ثم الفعل.',
        grammaticalAnalysisGerman:
            '"zwar" besetzt das Vorfeld und erzwingt Inversion. "aber" fungiert als Beiordnungskonjunktion auf Position 0 ohne Einfluss auf die Abfolge Subjekt-Prädikat.',
        commonWordOrderMistake:
            'Inversion nach aber: "*aber erfordert ihre Großserienfertigung".',
        topologicalRuleSummary:
            'Regel: Zwar [Verb] [Subjekt] ... , aber [Subjekt] [Verb] ... (aber = Position 0).',
      ),
    );

    // 10. einerseits ... andererseits (Dual Inversion Symmetry) - Aerospace Engineering
    _catalog.add(
      const CorrelativeConnectorModel(
        id: 'CORR-EINERS-ANDERS-AERO-10',
        pairType: CorrelativePairType.einerseitsAndererseits,
        firstConnector: 'einerseits',
        secondConnector: 'andererseits',
        firstClauseTopology: ClauseTopologyBehavior.inversionForced,
        secondClauseTopology: ClauseTopologyBehavior.inversionForced,
        domain: CommunicativeDomain.aerospaceAndAviation,
        fullSentence:
            'Einerseits verringert die neuartige Flügelgeometrie den induzierten Luftwiderstand beträchtlich, andererseits erhöht sie das Leergewicht der Tragflächenstruktur.',
        arabicTranslation:
            'من ناحية يقلل التصميم الهندسي المبتكر للجناح من مقاومة الهواء المستحثة بشكل ملحوظ، ومن ناحية أخرى يزيد من الوزن الفارغ لهيكل الجناح.',
        grammaticalAnalysisArabic:
            'تناظر تركيبي تام: "einerseits" في الشطر الأول و"andererseits" في الشطر الثاني كلاهما يشغل موقع الصدر ويفرض قلب الفاعل بعد الفعل (verringert die Geometrie / erhöht sie).',
        grammaticalAnalysisGerman:
            'Volle topologische Symmetrie: Beide Konnektoradverbien beanspruchen das Vorfeld ihres jeweiligen Hauptsatzes und erzwingen V2-Inversion.',
        commonWordOrderMistake:
            'Subjekt vor Verb nach andererseits: "*andererseits sie erhöht das Leergewicht".',
        topologicalRuleSummary:
            'Regel: Einerseits [Verb] [Subjekt] ... , andererseits [Verb] [Subjekt] ... (beide fordern V2-Inversion).',
      ),
    );

    // 11. sowohl ... als auch (Homogeneous Coordination) - Maritime Logistics
    _catalog.add(
      const CorrelativeConnectorModel(
        id: 'CORR-SOWOHL-ALS-AUCH-11',
        pairType: CorrelativePairType.sowohlAlsAuch,
        firstConnector: 'sowohl',
        secondConnector: 'als auch',
        firstClauseTopology: ClauseTopologyBehavior.positionZeroRegular,
        secondClauseTopology: ClauseTopologyBehavior.positionZeroRegular,
        domain: CommunicativeDomain.maritimeLogistics,
        fullSentence:
            'Das automatische Terminalleitsystem überwacht sowohl den Liegeplatzbetrieb der Seeschiffe als auch die fahrplanmäßige Beladung der Güterzüge.',
        arabicTranslation:
            'تراقب منظومة إدارة المحطة الآلية كلاً من عمليات رسو السفن البحرية على الأرصفة وأعمال شحن قطارات البضائع المجدولة.',
        grammaticalAnalysisArabic:
            'عطف متكافئ لمركبين اسميين مفعولين بهما (den Liegeplatzbetrieb / die Beladung) دون أي فاصلة في الاستعمال القياسي.',
        grammaticalAnalysisGerman:
            'Reine Satzgliedverknüpfung zweier Akkusativobjekte. Bei reiner Satzgliedkoordination wird im Deutschen kein Komma vor "als auch" gesetzt.',
        commonWordOrderMistake:
            'Setzen eines unzulässigen Kommas vor "als auch" bei reiner Satzgliedkoordination.',
        topologicalRuleSummary:
            'Duden: Kein Komma vor "als auch" bei einfachen Satzgliedern; Komma nur bei vollständigen Hauptsätzen.',
      ),
    );

    // 12. je ... desto (Multiple Comparatives) - Industrial Robotics
    _catalog.add(
      const CorrelativeConnectorModel(
        id: 'CORR-JE-DESTO-ROBOT-12',
        pairType: CorrelativePairType.jeDestoUmso,
        firstConnector: 'je',
        secondConnector: 'desto',
        firstClauseTopology: ClauseTopologyBehavior.subordinateVerbFinal,
        secondClauseTopology: ClauseTopologyBehavior.inversionForced,
        domain: CommunicativeDomain.industrialRobotics,
        fullSentence:
            'Je schneller und feinfühliger die optischen Sensoren die Oberflächenunebenheiten erfassen, desto fehlerfreier vollzieht der Roboterarm den Poliervorgang.',
        arabicTranslation:
            'كلما رصدت المستشعرات البصرية تفاوتات السطح وتعرجاته بسرعة وحساسية أكبر، أنجز ذراع الروبوت عملية الصقل بدقة أعلى وخلو تام من الأخطاء.',
        grammaticalAnalysisArabic:
            'استعمال صفتي مقارنة معطوفتين بعد je (schneller und feinfühliger)، والتمسك بوقوع الفعل في نهاية جملة الصلة (erfassen)، يليه في جواب الشرط صفة التفضيل فالفعل المصرف (vollzieht).',
        grammaticalAnalysisGerman:
            'Koordinierte Komparative im Vorfeld des je-Nebensatzes; zwingendes V2-Prädikat "vollzieht" im desto-Hauptsatz.',
        commonWordOrderMistake:
            'Weglassen der Komparativendung oder falsche Verbposition.',
        topologicalRuleSummary:
            'Auch bei mehreren Komparativen bleibt die topologische Asymmetrie (Nebensatz vs. V2-Hauptsatz) strikt gewahrt.',
      ),
    );

    // 13. zwar ... aber (Embedded in Subordinate Clause) - Civil Infrastructure
    _catalog.add(
      const CorrelativeConnectorModel(
        id: 'CORR-ZWAR-ABER-SUB-13',
        pairType: CorrelativePairType.zwarAber,
        firstConnector: 'zwar',
        secondConnector: 'aber',
        firstClauseTopology: ClauseTopologyBehavior.positionZeroRegular,
        secondClauseTopology: ClauseTopologyBehavior.positionZeroRegular,
        domain: CommunicativeDomain.civilInfrastructure,
        fullSentence:
            'Die Prüfingenieure stellten fest, dass der Zement zwar termingerecht geliefert wurde, aber noch nicht die geforderte Druckfestigkeit aufwies.',
        arabicTranslation:
            'أكد مهندسو التدقيق أن الأسمنت، وإن كان قد سُلِّم في الموعد المحدد، إلا أنه لم يكن قد اكتسب بعد مقاومة الضغط المطلوبة.',
        grammaticalAnalysisArabic:
            'دخول "zwar ... aber" داخل جملة ثانوية مصدرة بـ dass: يخضع كلا المعطوفين لقاعدة الفعل في النهاية (geliefert wurde / aufwies).',
        grammaticalAnalysisGerman:
            'Verbindung zweier koordinierter Nebensätze unter einer gemeinsamen Subjunktion "dass". Beide Teilsätze behalten Verb-Endstellung.',
        commonWordOrderMistake:
            'Ausbruch aus der Nebensatzklammer nach aber (*aber wies er nicht auf).',
        topologicalRuleSummary:
            'Im Nebensatz unter "dass" dominiert die Verb-Endstellung über die reguläre Hauptsatzordnung.',
      ),
    );

    // 14. entweder ... oder (Inversion with Modal Verbs) - Renewable Energy
    _catalog.add(
      const CorrelativeConnectorModel(
        id: 'CORR-ENTWEDER-MODAL-14',
        pairType: CorrelativePairType.entwederOder,
        firstConnector: 'entweder',
        secondConnector: 'oder',
        firstClauseTopology: ClauseTopologyBehavior.inversionForced,
        secondClauseTopology: ClauseTopologyBehavior.positionZeroRegular,
        domain: CommunicativeDomain.renewableEnergyGrid,
        fullSentence:
            'Entweder müssen die Transformatorenstationen bis zum Sommer modernisiert werden, oder das regionale Verteilnetz wird den steigenden Solarstrom nicht aufnehmen können.',
        arabicTranslation:
            'إما أن يتم تحديث وتطوير محطات المحولات قبل حلول الصيف، أو أن شبكة التوزيع الإقليمية لن تكون قادرة على استيعاب الطاقة الشمسية المتزايدة.',
        grammaticalAnalysisArabic:
            'الشطر الأول مصدَّر بـ Entweder متبوعاً بالفعل الناقص (müssen) ثم نائب الفاعل، بينما الشطر الثاني يبدأ بـ oder يليه المبتدأ الاسمي (das Netz) ثم الفعل المصرف (wird).',
        grammaticalAnalysisGerman:
            'Modalverbkonstruktion im Passiv: "entweder" löst Inversion des finiten "müssen" aus. Der oder-Satz folgt strikt S-V-O.',
        commonWordOrderMistake:
            'Vorbewusste Inversion im Folgesatz (*oder wird das Netz nicht können).',
        topologicalRuleSummary:
            'Modalverben folgen den exakt gleichen topologischen Inversionsgesetzen.',
      ),
    );

    // 15. nicht nur ... sondern auch (Subject Focus) - Aerospace Engineering
    _catalog.add(
      const CorrelativeConnectorModel(
        id: 'CORR-NICHT-NUR-SUBJ-15',
        pairType: CorrelativePairType.nichtNurSondernAuch,
        firstConnector: 'nicht nur',
        secondConnector: 'sondern auch',
        firstClauseTopology: ClauseTopologyBehavior.positionZeroRegular,
        secondClauseTopology: ClauseTopologyBehavior.positionZeroRegular,
        domain: CommunicativeDomain.aerospaceAndAviation,
        fullSentence:
            'Nicht nur die Hauptdüsen, sondern auch die seitlichen Steuerungsraketen zündeten absolut synchron.',
        arabicTranslation:
            'ليس فقط النفاثات الرئيسية، بل أيضاً صواريخ التوجيه الجانبية اشتعلت بتزامن وتوافق مطلق.',
        grammaticalAnalysisArabic:
            'عطف فاعلين بالصدر: "Nicht nur die Hauptdüsen, sondern auch die Steuerungsraketen" يشكلان معاً مبتدأ الجملة يليه الفعل (zündeten) في المركز الثاني.',
        grammaticalAnalysisGerman:
            'Vorfeldfokussierung eines koordinierten Subjektkomplexes; das finite Verb "zündeten" folgt auf das gesamte Vorfeldgefüge.',
        commonWordOrderMistake:
            'Einschub des Verbs zwischen die beiden Subjekte.',
        topologicalRuleSummary:
            'Bilden beide Glieder das Subjekt im Vorfeld, folgt das finite Verb erst nach dem gesamten Komplex.',
      ),
    );

    // 16. weder ... noch (Triple Disjunction) - Material Science
    _catalog.add(
      const CorrelativeConnectorModel(
        id: 'CORR-WEDER-NOCH-TRIPLE-16',
        pairType: CorrelativePairType.wederNoch,
        firstConnector: 'weder',
        secondConnector: 'noch ... noch',
        firstClauseTopology: ClauseTopologyBehavior.positionZeroRegular,
        secondClauseTopology: ClauseTopologyBehavior.positionZeroRegular,
        domain: CommunicativeDomain.materialScience,
        fullSentence:
            'Das hochentwickelte Isolierharz zeigte im Laborversuch weder Rissbildungen noch thermische Verformungen noch die geringste Feuchtigkeitsaufnahme.',
        arabicTranslation:
            'لم يُظهر الراتنج العازل المتطور في التجربة المخبرية أي تشققات ولا تشوهات حرارية ولا أدنى امتصاص للرطوبة.',
        grammaticalAnalysisArabic:
            'عطف سلبي ثلاثي بتكرار noch: تتابع المفاعيل المنفية (weder X noch Y noch Z) في حشو الجملة محافظاً على إعراب النصب.',
        grammaticalAnalysisGerman:
            'Mehrfache Disjunktion durch rekursives "noch". Sämtliche Nominalglieder stehen im Akkusativ als Objekte zu "zeigte".',
        commonWordOrderMistake:
            'Falsches Ersetzen des zweiten noch durch "oder" (*weder X noch Y oder Z).',
        topologicalRuleSummary:
            'Kardinalregel: Bei fortgesetzter Aufzählung muss stets "noch" wiederholt werden, niemals "oder".',
      ),
    );
  }

  /// Evaluates an input correlative sentence for topological asymmetry and word-order compliance.
  CorrelativeValidationReport validateCorrelativeSentence({
    required CorrelativePairType pairType,
    required bool isVerbInSecondPositionAfterNoch,
    required bool hasPositionZeroAfterOder,
    required bool isJeClauseVerbFinal,
    required bool hasProhibitedDoubleNegation,
  }) {
    final issues = <String>[];
    final recommendations = <String>[];

    if (pairType == CorrelativePairType.wederNoch) {
      if (hasProhibitedDoubleNegation) {
        issues.add(
          'Grammatikalischer Fehler (Unzulässige Doppelnegation): "weder ... noch" schließt Negationspartikeln wie "nicht" oder "kein" kategorisch aus.',
        );
        recommendations.add('Entfernen Sie "nicht" oder "kein" aus den Teilsätzen.');
      }
      if (!isVerbInSecondPositionAfterNoch) {
        issues.add(
          'Topologischer Fehler nach "noch": Wenn "noch" einen Hauptsatz einleitet, muss das finite Verb zwingend vor dem Subjekt stehen (Inversion).',
        );
        recommendations.add('Stellen Sie das finite Verb direkt hinter "noch" (z. B. "noch registrierte die Station").');
      }
    } else if (pairType == CorrelativePairType.entwederOder) {
      if (!hasPositionZeroAfterOder) {
        issues.add(
          'Wortstellungsfehler nach "oder": Die Konjunktion "oder" besetzt Position 0; eine Inversion (Verb vor Subjekt) ist standardsprachlich unzulässig.',
        );
        recommendations.add('Verwenden Sie nach "oder" die reguläre Abfolge: Subjekt + finites Verb.');
      }
    } else if (pairType == CorrelativePairType.jeDestoUmso) {
      if (!isJeClauseVerbFinal) {
        issues.add(
          'Topologischer Fehler im je-Satz: Der Nebensatz mit "je" verlangt ausnahmslos Verb-Endstellung.',
        );
        recommendations.add('Verschieben Sie das finite Verb des je-Satzes an das absolute Satzende vor das Komma.');
      }
    }

    final isValid = issues.isEmpty;
    final verdict = isValid
        ? 'التركيب النحوي للعطف المتلازم وتوزيع رتبة الفعل المصرف متطابق تماماً مع معايير الفصاحة الألمانية (C1-C2).'
        : 'تم رصد خلل في عدم التناظر الطوبولوجي أو في رتبة الفعل والفاعل في أحد شطري الجملة.';

    return CorrelativeValidationReport(
      isValid: isValid,
      isVerbPositionCompliant: issues.where((e) => e.contains('Wortstellungsfehler') || e.contains('Topologischer')).isEmpty,
      isPolarityRespected: !hasProhibitedDoubleNegation,
      issues: issues,
      recommendations: recommendations,
      arabicDiagnosticVerdict: verdict,
    );
  }

  List<CorrelativeConnectorModel> filterByPairType(CorrelativePairType type) {
    return _catalog.where((item) => item.pairType == type).toList();
  }

  List<CorrelativeConnectorModel> filterByDomain(CommunicativeDomain domain) {
    return _catalog.where((item) => item.domain == domain).toList();
  }
}
