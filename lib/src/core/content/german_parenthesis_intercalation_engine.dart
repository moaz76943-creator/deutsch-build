import 'dart:collection';

/// Classification of parenthetical and intercalated structures in German syntax.
enum IntercalationType {
  verbalSchaltsatz(
    'Verbaler Schaltsatz (mit eigenem finiten Verb)',
    'الجملة الاعتراضية الفعلية المستقلة',
    'Eingeschobener Satz mit Verb: so scheint es, wie allgemein bekannt ist, sagte der Ingenieur',
  ),
  nominalParenthesis(
    'Nominale / Adjektivische Parenthese',
    'الاعتراض الاسمي أو الوصفي',
    'Einschub ohne finites Verb: – ein bahnbrechender Meilenstein –, (allesamt Neuentwicklungen)',
  ),
  epistemicComment(
    'Epistemischer Modalitätskommentar',
    'التعليق المعرفي الدال على درجة اليقين أو الرأي',
    'meines Erachtens, wenn man so sagen darf, aller Voraussicht nach',
  ),
  metalinguisticFormula(
    'Metasprachliche Erläuterungsformel',
    'الصيغة التوضيحية البيانية / التفسيرية',
    'das heißt, genauer formuliert, mit anderen Worten, wohlgemerkt',
  );

  final String germanTitle;
  final String arabicTitle;
  final String structuralPattern;
  const IntercalationType(
    this.germanTitle,
    this.arabicTitle,
    this.structuralPattern,
  );
}

/// Punctuation framing for parenthetical insertions.
enum PunctuationStyle {
  pairedDashes(
    'Paarige Gedankenstriche (– ... –)',
    'الشرطتان المعكوفان',
    'Starke visuelle und rhythmische Zäsur, hebt den Einschub deutlich hervor.',
  ),
  pairedCommas(
    'Paarige Kommas (, ... ,)',
    'الفاصلتان الحاصرتان',
    'Fließende Einbettung in den Satzrhythmus, Standard bei Schaltsätzen.',
  ),
  parenthesesBrackets(
    'Runde Klammern (( ... ))',
    'القوسان الهلاليان',
    'Kennzeichnet Zusatzinformationen, die für den Satzbau sekundär sind.',
  );

  final String de;
  final String ar;
  final String stylisticEffect;
  const PunctuationStyle(this.de, this.ar, this.stylisticEffect);
}

/// Topological placement of the parenthesis within the sentence topology.
enum SyntacticPosition {
  mittelfeldInterruption(
    'Mittelfeld-Interkalation',
    'اعتراض داخل حشو الجملة (بين الفاعلين والمفاعيل)',
  ),
  vorfeldPostposition(
    'Direkt nach dem Vorfeld',
    'اعتراض مباشر بعد المكون المتقدم (قبل الفعل المصرف)',
  ),
  satzklammerInterruption(
    'Unterbrechung der Verbklammer',
    'اعتراض يقطع القوس الفعلي (بين الفعل المساعد والفعل الأساسي)',
  ),
  nachfeldAttachment(
    'Nachfeld-Parenthese',
    'اعتراض لاحق ملحق بنهاية الجملة بعد القوس الفعلي',
  );

  final String de;
  final String ar;
  const SyntacticPosition(this.de, this.ar);
}

/// Professional and life domains free of legal/medical liability.
enum CommunicativeDomain {
  industrialEngineering('Industrie- & Fertigungstechnik', 'الهندسة الصناعية والإنتاج'),
  aerospaceTech('Luft- & Raumfahrttechnologie', 'تقنيات الطيران واستكشاف الفضاء'),
  logisticsCoordination('Logistik & Lieferkettensteuerung', 'إدارة اللوجستيات وسلاسل الإمداد'),
  environmentalScience('Umweltanalytik & Geowissenschaften', 'علوم البيئة والتحليلات الجغرافية'),
  commercialEnterprise('Handel & Unternehmensführung', 'التجارة وإدارة المنشآت'),
  practicalEveryday('Alltägliche Fachpraxis & Handwerk', 'التطبيقات الحرفية والمهنية اليومية');

  final String de;
  final String ar;
  const CommunicativeDomain(this.de, this.ar);
}

/// Concrete model representing a parenthetical or intercalated sentence.
class ParenthesisModel {
  final String id;
  final String hostSentencePrefix;
  final String intercalatedContent;
  final String hostSentenceSuffix;
  final IntercalationType intercalationType;
  final PunctuationStyle punctuationStyle;
  final SyntacticPosition position;
  final CommunicativeDomain domain;
  final String fullCombinedSentence;
  final String arabicTranslation;
  final String grammaticalAnalysisArabic;
  final String grammaticalAnalysisGerman;
  final String topologicalIntegrityRule;
  final String punctuationRule;

  const ParenthesisModel({
    required this.id,
    required this.hostSentencePrefix,
    required this.intercalatedContent,
    required this.hostSentenceSuffix,
    required this.intercalationType,
    required this.punctuationStyle,
    required this.position,
    required this.domain,
    required this.fullCombinedSentence,
    required this.arabicTranslation,
    required this.grammaticalAnalysisArabic,
    required this.grammaticalAnalysisGerman,
    required this.topologicalIntegrityRule,
    required this.punctuationRule,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'hostSentencePrefix': hostSentencePrefix,
    'intercalatedContent': intercalatedContent,
    'hostSentenceSuffix': hostSentenceSuffix,
    'intercalationType': intercalationType.name,
    'punctuationStyle': punctuationStyle.name,
    'position': position.name,
    'domain': domain.name,
    'fullCombinedSentence': fullCombinedSentence,
    'arabicTranslation': arabicTranslation,
    'grammaticalAnalysisArabic': grammaticalAnalysisArabic,
    'grammaticalAnalysisGerman': grammaticalAnalysisGerman,
    'topologicalIntegrityRule': topologicalIntegrityRule,
    'punctuationRule': punctuationRule,
  };
}

/// Validation report for parenthetical structure and punctuation symmetry.
class ParenthesisValidationReport {
  final bool isValid;
  final bool hasSymmetricalPunctuation;
  final bool hostSentenceSyntacticallySound;
  final List<String> errorList;
  final List<String> stylisticRecommendations;
  final String arabicSummary;

  const ParenthesisValidationReport({
    required this.isValid,
    required this.hasSymmetricalPunctuation,
    required this.hostSentenceSyntacticallySound,
    required this.errorList,
    required this.stylisticRecommendations,
    required this.arabicSummary,
  });
}

/// Sovereign engine governing German Parentheses, Schaltsätze, and Topological Boundary markers.
class GermanParenthesisIntercalationEngine {
  final List<ParenthesisModel> _catalog = [];

  GermanParenthesisIntercalationEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<ParenthesisModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    // 1. Industrial Engineering: Paired Dashes with Nominal Parenthesis
    _catalog.add(
      const ParenthesisModel(
        id: 'PAR-ENG-DASH-01',
        hostSentencePrefix: 'Die vollautomatische Fertigungsstraße',
        intercalatedContent: '– ein bemerkenswertes Meisterwerk moderner Robotik –',
        hostSentenceSuffix: 'produziert stündlich über fünfhundert Präzisionsbauteile.',
        intercalationType: IntercalationType.nominalParenthesis,
        punctuationStyle: PunctuationStyle.pairedDashes,
        position: SyntacticPosition.vorfeldPostposition,
        domain: CommunicativeDomain.industrialEngineering,
        fullCombinedSentence:
            'Die vollautomatische Fertigungsstraße – ein bemerkenswertes Meisterwerk moderner Robotik – produziert stündlich über fünfhundert Präzisionsbauteile.',
        arabicTranslation:
            'ينتج خط الإنتاج الآلي بالكامل – وهو تحفة لافتة في مجال الروبوتات الحديثة – أكثر من خمسمائة قطعة دقيقة كل ساعة.',
        grammaticalAnalysisArabic:
            'اعتراض اسمي محصور بين شرطتين (– ... –) يقع مباشرة بعد المبتدأ (Vorfeld)، دون أن يغير ترتيب الفعل المصرف (produziert) في المركز الثاني للجملة الرئيسية.',
        grammaticalAnalysisGerman:
            'Nominale Appositions-Parenthese durch paarige Gedankenstriche isoliert. Das finite Verb "produziert" verbleibt unberührt in V2-Position.',
        topologicalIntegrityRule:
            'Die Parenthese zählt syntaktisch nicht als eigenständiges Vorfeldglied; das finite Verb folgt unmittelbar auf das Vorfeldgefüge.',
        punctuationRule:
            'Gedankenstriche müssen zwingend paarig gesetzt werden, mit beidseitigem Leerzeichen in modernem Schriftsatz.',
      ),
    );

    // 2. Aerospace Technology: Verbal Schaltsatz with Paired Commas
    _catalog.add(
      const ParenthesisModel(
        id: 'PAR-AERO-COMMA-02',
        hostSentencePrefix: 'Die Telemetriedaten des Satelliten haben',
        intercalatedContent: ', so bestätigten die Missionsingenieure heute früh,',
        hostSentenceSuffix: 'keinerlei Abweichungen vom berechneten Orbit aufgezeigt.',
        intercalationType: IntercalationType.verbalSchaltsatz,
        punctuationStyle: PunctuationStyle.pairedCommas,
        position: SyntacticPosition.satzklammerInterruption,
        domain: CommunicativeDomain.aerospaceTech,
        fullCombinedSentence:
            'Die Telemetriedaten des Satelliten haben, so bestätigten die Missionsingenieure heute früh, keinerlei Abweichungen vom berechneten Orbit aufgezeigt.',
        arabicTranslation:
            'لم تُظهر بيانات القياس عن بعد الخاصة بالقمر الاصطناعي، كما أكد مهندسو المهمة صباح اليوم، أي انحرافات عن المدار المحسوب.',
        grammaticalAnalysisArabic:
            'جملة اعتراضية فعلية (Schaltsatz: so bestätigten...) تقطع القوس الفعلي بين الفعل المساعد (haben) واسم المفعول (aufgezeigt) ومحصورة بين فاصلتين.',
        grammaticalAnalysisGerman:
            'Verbaler Schaltsatz mit V1-Inversion ("so bestätigten...") unterbricht die Satzklammer (Perfekt: haben ... aufgezeigt).',
        topologicalIntegrityRule:
            'Die Satzklammer wird durch den Schaltsatz gedehnt, behält aber ihre zwingende schließende Verbklammer bei.',
        punctuationRule:
            'Ein verbaler Schaltsatz wird im Deutschen standardsprachlich durch paarige Kommas eingefasst.',
      ),
    );

    // 3. Environmental Science: Metalinguistic Formula in Mittelfeld
    _catalog.add(
      const ParenthesisModel(
        id: 'PAR-ENV-META-03',
        hostSentencePrefix: 'Die Grundwasserproben weisen',
        intercalatedContent: ', das heißt genauer formuliert,',
        hostSentenceSuffix: 'eine signifikant verringerte Nitratbelastung auf.',
        intercalationType: IntercalationType.metalinguisticFormula,
        punctuationStyle: PunctuationStyle.pairedCommas,
        position: SyntacticPosition.mittelfeldInterruption,
        domain: CommunicativeDomain.environmentalScience,
        fullCombinedSentence:
            'Die Grundwasserproben weisen, das heißt genauer formuliert, eine signifikant verringerte Nitratbelastung auf.',
        arabicTranslation:
            'تُظهر عينات المياه الجوفية، وبصياغة أكثر دقة وتحديداً، انخفاضاً ذا دلالة إحصائية في نسبة النترات.',
        grammaticalAnalysisArabic:
            'صيغة توضيحية اعتراضية (das heißt...) تتوسط حشو الجملة لتعديل المعنى بدقة دون الإخلال بانتهاء الفعل المنفصل بلاحقته (auf).',
        grammaticalAnalysisGerman:
            'Metasprachliche Schaltformel im Mittelfeld zur semantischen Präzisierung vor dem Akkusativobjekt.',
        topologicalIntegrityRule:
            'Trennbares Verb "aufweisen": "weisen" in V2, Präfix "auf" am Satzende unberührt von der Parenthese.',
        punctuationRule:
            'Paarige Kommasetzung trennt die Erläuterungsformel grammatikalisch sauber ab.',
      ),
    );

    // 4. Logistics & Supply Chain: Epistemic Comment with Dashes
    _catalog.add(
      const ParenthesisModel(
        id: 'PAR-LOG-EPIST-04',
        hostSentencePrefix: 'Die internationalen Frachtcontainer werden',
        intercalatedContent: '– meines Erachtens ein unschätzbarer logistischer Vorteil –',
        hostSentenceSuffix: 'direkt am Schienenterminal ohne Zwischenlagerung umgeladen.',
        intercalationType: IntercalationType.epistemicComment,
        punctuationStyle: PunctuationStyle.pairedDashes,
        position: SyntacticPosition.mittelfeldInterruption,
        domain: CommunicativeDomain.logisticsCoordination,
        fullCombinedSentence:
            'Die internationalen Frachtcontainer werden – meines Erachtens ein unschätzbarer logistischer Vorteil – direkt am Schienenterminal ohne Zwischenlagerung umgeladen.',
        arabicTranslation:
            'يتم تفريغ حاويات الشحن الدولية – في تقديري وهي ميزة لوجستية لا تقدر بثمن – مباشرة في المحطة الحديدية دون تخزين وسيط.',
        grammaticalAnalysisArabic:
            'اعتراض دال على التقدير الشخصي (meines Erachtens...) محاط بشرطتين لإبراز الميزة التنافسية للعملية التشغيلية.',
        grammaticalAnalysisGerman:
            'Epistemische Einschätzung mit Genitivattribut ("meines Erachtens") als emphase-starke Gedankenstrich-Parenthese.',
        topologicalIntegrityRule:
            'Passivkonstruktion "werden ... umgeladen" bleibt syntaktisch vollständig intakt.',
        punctuationRule:
            'Gedankenstriche heben subjektive Wertungen stilistisch elegant vom objektiven Sachbericht ab.',
      ),
    );

    // 5. Commercial Enterprise: Parentheses Brackets with Technical Specifications
    _catalog.add(
      const ParenthesisModel(
        id: 'PAR-COMM-BRACK-05',
        hostSentencePrefix: 'Der Jahresabschlussbericht des Konsortiums',
        intercalatedContent: '(einschließlich aller konsolidierten Tochtergesellschaften)',
        hostSentenceSuffix: 'weist einen stabilen Zuwachs des operativen Betriebsergebnisses aus.',
        intercalationType: IntercalationType.nominalParenthesis,
        punctuationStyle: PunctuationStyle.parenthesesBrackets,
        position: SyntacticPosition.vorfeldPostposition,
        domain: CommunicativeDomain.commercialEnterprise,
        fullCombinedSentence:
            'Der Jahresabschlussbericht des Konsortiums (einschließlich aller konsolidierten Tochtergesellschaften) weist einen stabilen Zuwachs des operativen Betriebsergebnisses aus.',
        arabicTranslation:
            'يُظهر تقرير الحساب الختامي السنوي للتحالف التجاري (بما في ذلك كافة الشركات التابعة الموحدة) نمواً مستقراً في نتائج التشغيل.',
        grammaticalAnalysisArabic:
            'اعتراض حصري موضوع بين قوسين هلاليين لتضمين تفصيل إيضاحي ثانوي دون تشويش تسلسل القراءة.',
        grammaticalAnalysisGerman:
            'Klammerparenthese zur Ergänzung institutioneller Reichweite mittels Genitiv-Präposition "einschließlich".',
        topologicalIntegrityRule:
            'Klammern eignen sich im gehobenen kaufmännischen Schriftverkehr für juristisch-formelle Präzisierungen.',
        punctuationRule:
            'Kein Komma vor oder nach der Klammer, wenn der umgebende Satzbau keines verlangt.',
      ),
    );

    // 6. Practical Everyday Craft & Architecture: Verbal Schaltsatz with "wie man weiß"
    _catalog.add(
      const ParenthesisModel(
        id: 'PAR-CRAFT-SCHALT-06',
        hostSentencePrefix: 'Hartholz wie Eiche oder Buche muss',
        intercalatedContent: ', wie jeder erfahrene Schreinermeister weiß,',
        hostSentenceSuffix: 'über mehrere Jahre hinweg langsam und schonend getrocknet werden.',
        intercalationType: IntercalationType.verbalSchaltsatz,
        punctuationStyle: PunctuationStyle.pairedCommas,
        position: SyntacticPosition.mittelfeldInterruption,
        domain: CommunicativeDomain.practicalEveryday,
        fullCombinedSentence:
            'Hartholz wie Eiche oder Buche muss, wie jeder erfahrene Schreinermeister weiß, über mehrere Jahre hinweg langsam und schonend getrocknet werden.',
        arabicTranslation:
            'يجب تجفيف الأخشاب الصلبة مثل السنديان أو الزان، كما يعلم كل نجار خبير ومحترف، ببطء وعناية على مدار عدة سنوات.',
        grammaticalAnalysisArabic:
            'جملة اعتراضية مصدرة بـ wie تبرز الحكمة المهنية والتجربة العملية المكتسبة، محصورة بفاصلتين.',
        grammaticalAnalysisGerman:
            'Schaltsatz mit subordinierender Konjunktion "wie" und Verb-Endstellung ("weiß") als Expertenreferenz.',
        topologicalIntegrityRule:
            'Modalverb-Passivklammer "muss ... getrocknet werden" schließt das Prädikat fehlerfrei ab.',
        punctuationRule:
            'Einschub muss vorne und hinten durch Kommas sauber abgegrenzt werden.',
      ),
    );

    // 7. Aerospace Engineering: Intercalated Question Clause
    _catalog.add(
      const ParenthesisModel(
        id: 'PAR-AERO-INTER-07',
        hostSentencePrefix: 'Die neu entwickelte Hitzeschutzkachel',
        intercalatedContent: '– wer hätte das vor fünf Jahren für möglich gehalten? –',
        hostSentenceSuffix: 'überstand den thermischen Wiedereintrittstest ohne die geringste Beschädigung.',
        intercalationType: IntercalationType.verbalSchaltsatz,
        punctuationStyle: PunctuationStyle.pairedDashes,
        position: SyntacticPosition.vorfeldPostposition,
        domain: CommunicativeDomain.aerospaceTech,
        fullCombinedSentence:
            'Die neu entwickelte Hitzeschutzkachel – wer hätte das vor fünf Jahren für möglich gehalten? – überstand den thermischen Wiedereintrittstest ohne die geringste Beschädigung.',
        arabicTranslation:
            'اجتازت بلاطة الحماية الحرارية المطورة حديثاً – من كان يظن ذلك ممكناً قبل خمس سنوات؟ – اختبار إعادة الدخول الحراري دون أدنى تلف.',
        grammaticalAnalysisArabic:
            'اعتراض بلاغي استفهامي بصيغة Konjunktiv II محصور بين شرطتين، مع احتفاظ علامة الاستفهام بمكانها قبل الشرطة الختامية.',
        grammaticalAnalysisGerman:
            'Rhetorische Fragesatz-Parenthese mit Fragezeichen vor dem schließenden Gedankenstrich.',
        topologicalIntegrityRule:
            'Trotz Fragezeichen im Einschub bleibt der Hauptsatz ein Aussagesatz mit V2 ("überstand").',
        punctuationRule:
            'Satzzeichen des Einschubs (?!.) bleiben vor dem zweiten Gedankenstrich erhalten.',
      ),
    );

    // 8. Industrial Robotics: Short Elliptic Schaltsatz
    _catalog.add(
      const ParenthesisModel(
        id: 'PAR-ROBOT-SHORT-08',
        hostSentencePrefix: 'Die sensorische Kalibrierung verlief',
        intercalatedContent: ', wenn man so will,',
        hostSentenceSuffix: 'nach einem völlig neuartigen mathematischen Algorithmus.',
        intercalationType: IntercalationType.epistemicComment,
        punctuationStyle: PunctuationStyle.pairedCommas,
        position: SyntacticPosition.mittelfeldInterruption,
        domain: CommunicativeDomain.industrialEngineering,
        fullCombinedSentence:
            'Die sensorische Kalibrierung verlief, wenn man so will, nach einem völlig neuartigen mathematischen Algorithmus.',
        arabicTranslation:
            'سارت المعايرة الاستشعارية، إن صح التعبير، وفق خوارزمية رياضية مبتكرة تماماً.',
        grammaticalAnalysisArabic:
            'جملة اعتراضية ملطفة لحدة التعبير (wenn man so will) محصورة بين فاصلتين في حشو الجملة.',
        grammaticalAnalysisGerman:
            'Konditionaler Schaltkommentar ("wenn man so will") zur Relativierung einer metaphorischen Aussage.',
        topologicalIntegrityRule:
            'Verbindet Verb und Präpositionalobjekt flüssig ohne hierarchische Verschiebung.',
        punctuationRule: 'Umschließung durch Kommas obligatorisch.',
      ),
    );

    // 9. Environmental Analytics: Post-Verb Complex Attribution
    _catalog.add(
      const ParenthesisModel(
        id: 'PAR-ENV-ATTRIB-09',
        hostSentencePrefix: 'Die Renaturierung des Flussdeltas wurde',
        intercalatedContent: '– trotz aller anfänglichen topografischen Schwierigkeiten –',
        hostSentenceSuffix: 'binnen drei Jahren mit größtem Erfolg vollendet.',
        intercalationType: IntercalationType.nominalParenthesis,
        punctuationStyle: PunctuationStyle.pairedDashes,
        position: SyntacticPosition.satzklammerInterruption,
        domain: CommunicativeDomain.environmentalScience,
        fullCombinedSentence:
            'Die Renaturierung des Flussdeltas wurde – trotz aller anfänglichen topografischen Schwierigkeiten – binnen drei Jahren mit größtem Erfolg vollendet.',
        arabicTranslation:
            'اكتملت إعادة تأهيل دلتا النهر بيئياً – على الرغم من جميع الصعوبات الطبوغرافية الأولية – في غضون ثلاث سنوات بنجاح باهر.',
        grammaticalAnalysisArabic:
            'شبه جملة اعتراضية دالة على المقاومة وتجاوز العقبات (trotz + Genitiv) محصورة بين شرطتين داخل القوس الفعلي للمجهول.',
        grammaticalAnalysisGerman:
            'Konzessive Präpositional-Parenthese mit Genitiv ("trotz aller Schwierigkeiten") sprengt die Verbklammer wirkungsvoll.',
        topologicalIntegrityRule:
            'Passivklammer "wurde ... vollendet" schirmt die parenthetische Information stabil ab.',
        punctuationRule:
            'Gedankenstriche betonen den Kontrast zwischen anfänglichen Hürden und schnellem Erfolg.',
      ),
    );

    // 10. Commercial Enterprise: Asyndetic Intercalated Assertion
    _catalog.add(
      const ParenthesisModel(
        id: 'PAR-COMM-ASYND-10',
        hostSentencePrefix: 'Die strategische Partnerschaft wird',
        intercalatedContent: ', da sind sich alle Marktbeobachter einig,',
        hostSentenceSuffix: 'den europäischen Solarmarkt tiefgreifend transformieren.',
        intercalationType: IntercalationType.verbalSchaltsatz,
        punctuationStyle: PunctuationStyle.pairedCommas,
        position: SyntacticPosition.satzklammerInterruption,
        domain: CommunicativeDomain.commercialEnterprise,
        fullCombinedSentence:
            'Die strategische Partnerschaft wird, da sind sich alle Marktbeobachter einig, den europäischen Solarmarkt tiefgreifend transformieren.',
        arabicTranslation:
            'إن الشراكة الاستراتيجية، وهنا يتفق جميع مراقبي السوق، ستحدث تحولاً عميقاً وجذرياً في سوق الطاقة الشمسية الأوروبية.',
        grammaticalAnalysisArabic:
            'جملة اعتراضية رئيسية مصغرة غير مقترنة بحرف ربط (asyndetischer Hauptsatz: da sind sich einig) محصورة بين فاصلتين.',
        grammaticalAnalysisGerman:
            'Asyndetischer Hauptsatz-Einschub mit Spitzenstellung des Pronominaladverbs "da" und finitem Verb "sind".',
        topologicalIntegrityRule:
            'Futur-I-Klammer: Hilfsverb "wird" in V2, Infinitiv "transformieren" am rechten Satzrand.',
        punctuationRule:
            'Streng paarige Kommasetzung zwingend vorgeschrieben.',
      ),
    );

    // 11. Logistics Coordination: Nachfeld-Attachment with Dashes
    _catalog.add(
      const ParenthesisModel(
        id: 'PAR-LOG-NACHFELD-11',
        hostSentencePrefix: 'Die Kühlkette blieb während des gesamten Transports lückenlos aufrechterhalten',
        intercalatedContent: '– eine logistische Glanztat bei Außentemperaturen von über vierzig Grad.',
        hostSentenceSuffix: '',
        intercalationType: IntercalationType.nominalParenthesis,
        punctuationStyle: PunctuationStyle.pairedDashes,
        position: SyntacticPosition.nachfeldAttachment,
        domain: CommunicativeDomain.logisticsCoordination,
        fullCombinedSentence:
            'Die Kühlkette blieb während des gesamten Transports lückenlos aufrechterhalten – eine logistische Glanztat bei Außentemperaturen von über vierzig Grad.',
        arabicTranslation:
            'ظلت سلسلة التبريد مستمرة دون انقطاع طوال فترة النقل بأكملها – وهو إنجاز لوجستي رائع في ظل درجات حرارة خارجية تجاوزت الأربعين مئوية.',
        grammaticalAnalysisArabic:
            'اعتراض لاحق ملحق بعد اكتمال الجملة (Nachfeld-Parenthese) مفصول بشرطة واحدة لإضافة تعليق تقييمي ختامي قوي.',
        grammaticalAnalysisGerman:
            'Ausklammerung ins Nachfeld mittels einfachem Gedankenstrich zur nachgestellten Emphase.',
        topologicalIntegrityRule:
            'Am Satzende entfällt der zweite Gedankenstrich; der Schlusspunkt beendet die Gesamtaussage.',
        punctuationRule:
            'Einfacher Gedankenstrich bei Satzend-Stellung; danach folgt der reguläre Satzschlusspunkt.',
      ),
    );

    // 12. Practical Craftsmanship: Metasprachliche Parenthese mit "wohlgemerkt"
    _catalog.add(
      const ParenthesisModel(
        id: 'PAR-CRAFT-WOHL-12',
        hostSentencePrefix: 'Diese antike Standuhr funktioniert nach der Generalüberholung',
        intercalatedContent: ', wohlgemerkt ohne ein einziges elektronisches Bauteil,',
        hostSentenceSuffix: 'auf die Sekunde genau.',
        intercalationType: IntercalationType.metalinguisticFormula,
        punctuationStyle: PunctuationStyle.pairedCommas,
        position: SyntacticPosition.mittelfeldInterruption,
        domain: CommunicativeDomain.practicalEveryday,
        fullCombinedSentence:
            'Diese antike Standuhr funktioniert nach der Generalüberholung, wohlgemerkt ohne ein einziges elektronisches Bauteil, auf die Sekunde genau.',
        arabicTranslation:
            'تعمل هذه الساعة الأثرية ذات الصندوق الطويل بعد الصيانة الشاملة، وننوه هنا إلى أنها تعمل دون أي قطعة إلكترونية على الإطلاق، بدقة متناهية تصل إلى أجزاء الثانية.',
        grammaticalAnalysisArabic:
            'اعتراض تنبيهي توكيدي بالأداة "wohlgemerkt" (جدير بالذكر / للملاحظة) متبوعاً بحرف الجر الاستثنائي ohne.',
        grammaticalAnalysisGerman:
            'Aufmerksamkeitslenkende Partikelparenthese mit "wohlgemerkt" und präpositionaler Ausgrenzung.',
        topologicalIntegrityRule:
            'Präzisiert das Adverbial "auf die Sekunde genau" im Mittelfeld vor dem Satzabschluss.',
        punctuationRule:
            'Paarige Kommasetzung sichert den harmonischen Sprachfluss.',
      ),
    );
  }

  /// Validates a parenthetical sentence for symmetrical punctuation and syntactic cohesion.
  ParenthesisValidationReport validateStructure({
    required String fullSentence,
    required PunctuationStyle style,
    required bool isSentenceEndAttachment,
  }) {
    final errors = <String>[];
    final recommendations = <String>[];

    bool symmetrical = true;

    if (style == PunctuationStyle.pairedDashes) {
      final dashCount = RegExp(r'–').allMatches(fullSentence).length;
      if (!isSentenceEndAttachment) {
        if (dashCount < 2) {
          symmetrical = false;
          errors.add('Asymmetrische Gedankenstriche: Ein eingeschobener Gedankenstrich muss vor dem Satzende wieder geschlossen werden.');
          recommendations.add('Fügen Sie den schließenden Gedankenstrich (–) vor dem Hauptsatz-Suffix ein.');
        }
      } else {
        if (dashCount < 1) {
          symmetrical = false;
          errors.add('Fehlender Gedankenstrich vor Nachfeld-Parenthese.');
        }
      }
    } else if (style == PunctuationStyle.parenthesesBrackets) {
      final openCount = RegExp(r'\(').allMatches(fullSentence).length;
      final closeCount = RegExp(r'\)').allMatches(fullSentence).length;
      if (openCount != closeCount) {
        symmetrical = false;
        errors.add('Asymmetrische Klammern: Jede öffnende Klammer muss geschlossen werden.');
      }
    } else if (style == PunctuationStyle.pairedCommas) {
      if (!isSentenceEndAttachment) {
        final commaCount = RegExp(r',').allMatches(fullSentence).length;
        if (commaCount < 2) {
          symmetrical = false;
          errors.add('Unvollständige Kommasetzung: Ein Schaltsatz im Satzinneren verlangt zwingend zwei Kommas (vorne und hinten).');
        }
      }
    }

    final isValid = errors.isEmpty;
    final arabicSummary = isValid
        ? 'التركيب النحوي للجملة الاعتراضية وعلامات ترقيمها متطابقة مع أعلى معايير الصياغة الألمانية (C1-C2).'
        : 'تم رصد خلل في تناظر علامات الترقيم أو إغلاق القوس الاعتراضي.';

    return ParenthesisValidationReport(
      isValid: isValid,
      hasSymmetricalPunctuation: symmetrical,
      hostSentenceSyntacticallySound: true,
      errorList: errors,
      stylisticRecommendations: recommendations,
      arabicSummary: arabicSummary,
    );
  }

  List<ParenthesisModel> filterByType(IntercalationType type) {
    return _catalog.where((item) => item.intercalationType == type).toList();
  }

  List<ParenthesisModel> filterByStyle(PunctuationStyle style) {
    return _catalog.where((item) => item.punctuationStyle == style).toList();
  }

  List<ParenthesisModel> filterByDomain(CommunicativeDomain domain) {
    return _catalog.where((item) => item.domain == domain).toList();
  }
}
