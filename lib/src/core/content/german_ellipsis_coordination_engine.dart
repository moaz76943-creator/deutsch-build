import 'dart:collection';

/// Classification of elliptical structures and coordination reductions in German syntax.
enum EllipsisType {
  prädikatsellipseGapping(
    'Prädikatsellipse (Gapping)',
    'حذف الفعل المشترك في الجمل المعطوفة (Gapping)',
    'Auslassung des identischen finiten Verbs im zweiten Teilsatz: Die erste Turbine erzeugt 300 MW, die zweite 400 MW.',
  ),
  subjektellipse(
    'Subjektellipse bei koordinierter Beiordnung',
    'حذف الفاعل المتطابق عند العطف',
    'Wegfall des identischen Subjekts nach Konjunktion: Der Ingenieur prüfte das Modul und kalibrierte den Sensor.',
  ),
  objektellipse(
    'Objektellipse bei identischer Rektion',
    'حذف المفعول به المشترك المتطابق إعرابياً',
    'Einsparung des identischen Objekts bei kongruenter Kasusrektion beider Verben.',
  ),
  hilfsverbellipse(
    'Hilfsverbellipse im gehobenen Stil',
    'حذف الفعل المساعد في التراكيب الأكاديمية والوثائقية',
    'Auslassung von "haben/sein" im Nebensatz: Nachdem die Daten gesammelt und ausgewertet worden waren.',
  ),
  vergleichsellipse(
    'Vergleichsellipse nach als / wie',
    'حذف جملة المقارنة بعد كاف التشبيه أو أداة التفضيل',
    'Reduzierter Komparativsatz: Das neue Modell arbeitet energieeffizienter als das alte.',
  ),
  prosiopese(
    'Prosiopese (Kopf-Ellipse im Berufsalltag)',
    'حذف صدر الجملة في التخاطب المهني السريع',
    'Auslassung unbetonter Satzeröffnungen: [Das ist] Schon erledigt! / [Ich habe] Keinen Einwand.',
  );

  final String germanTitle;
  final String arabicTitle;
  final String grammaticalDescription;
  const EllipsisType(
    this.germanTitle,
    this.arabicTitle,
    this.grammaticalDescription,
  );
}

/// Syntactic status and validity of the elliptical operation.
enum SyntacticFeasibility {
  grammaticallySound(
    'Syntaktisch einwandfrei',
    'سليم نحوياً وبلاغياً دون أي تنازع إعرابي',
  ),
  blockedByValenceConflict(
    'Blockiert: Zeugma / Rektionskonflikt',
    'ممتنع لاختلاف التعدي والإعراب (خطر التعاقب المعيب)',
  ),
  blockedByNumberMismatch(
    'Blockiert: Numerus-Diskrepanz',
    'ممتنع لاختلاف الإفراد والجمع بين المعطوفين',
  );

  final String de;
  final String ar;
  const SyntacticFeasibility(this.de, this.ar);
}

/// Communicative domains strictly free of legal and medical liability.
enum CommunicativeDomain {
  renewableEnergy('Erneuerbare Energien & Netztechnik', 'الطاقة المتجددة وشبكات الكهرباء'),
  aviationLogistics('Luftfahrt & Frachtlogistik', 'الملاحة الجوية واللوجستيات'),
  roboticsAutomation('Industrielle Robotik & Automatisierung', 'الروبوتات والأتمتة الصناعية'),
  civilEngineering('Bauingenieurwesen & Statik', 'الهندسة المدنية والإنشائية'),
  maritimeTrade('Seefracht & Hafentechnologie', 'الشحن البحري وإدارة الموانئ'),
  workplaceTeamwork('Berufliche Teamkoordination & Handwerk', 'التنسيق المهني والعمل الجماعي');

  final String de;
  final String ar;
  const CommunicativeDomain(this.de, this.ar);
}

/// Data model representing an elliptical or reduced construction.
class EllipsisModel {
  final String id;
  final String fullOvertSentence;
  final String reducedEllipticSentence;
  final String omittedElement;
  final EllipsisType ellipsisType;
  final SyntacticFeasibility feasibility;
  final CommunicativeDomain domain;
  final String arabicTranslation;
  final String grammaticalAnalysisArabic;
  final String grammaticalAnalysisGerman;
  final String valenceIntegrityRule;
  final String stylisticNote;

  const EllipsisModel({
    required this.id,
    required this.fullOvertSentence,
    required this.reducedEllipticSentence,
    required this.omittedElement,
    required this.ellipsisType,
    required this.feasibility,
    required this.domain,
    required this.arabicTranslation,
    required this.grammaticalAnalysisArabic,
    required this.grammaticalAnalysisGerman,
    required this.valenceIntegrityRule,
    required this.stylisticNote,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullOvertSentence': fullOvertSentence,
    'reducedEllipticSentence': reducedEllipticSentence,
    'omittedElement': omittedElement,
    'ellipsisType': ellipsisType.name,
    'feasibility': feasibility.name,
    'domain': domain.name,
    'arabicTranslation': arabicTranslation,
    'grammaticalAnalysisArabic': grammaticalAnalysisArabic,
    'grammaticalAnalysisGerman': grammaticalAnalysisGerman,
    'valenceIntegrityRule': valenceIntegrityRule,
    'stylisticNote': stylisticNote,
  };
}

/// Verification report container for coordinate ellipsis and gapping checks.
class EllipsisValidationReport {
  final bool isValid;
  final bool avoidsValenceZeugma;
  final bool hasParallelMorphology;
  final List<String> issues;
  final List<String> recommendations;
  final String arabicSummary;

  const EllipsisValidationReport({
    required this.isValid,
    required this.avoidsValenceZeugma,
    required this.hasParallelMorphology,
    required this.issues,
    required this.recommendations,
    required this.arabicSummary,
  });
}

/// Comprehensive linguistic engine governing German Sentence Ellipsis, Coordinate Reduction & Gapping.
class GermanEllipsisCoordinationEngine {
  final List<EllipsisModel> _catalog = [];

  GermanEllipsisCoordinationEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<EllipsisModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    // 1. Renewable Energy: Gapping of identical transitive verb
    _catalog.add(
      const EllipsisModel(
        id: 'ELL-GAP-ENERGY-01',
        fullOvertSentence:
            'Der Offshore-Windpark speist achthundert Megawatt in das Höchstspannungsnetz ein und die Solaranlage speist zweihundert Megawatt in das Höchstspannungsnetz ein.',
        reducedEllipticSentence:
            'Der Offshore-Windpark speist achthundert Megawatt in das Höchstspannungsnetz ein und die Solaranlage zweihundert Megawatt.',
        omittedElement: 'speist ... in das Höchstspannungsnetz ein',
        ellipsisType: EllipsisType.prädikatsellipseGapping,
        feasibility: SyntacticFeasibility.grammaticallySound,
        domain: CommunicativeDomain.renewableEnergy,
        arabicTranslation:
            'تضخ محطة الرياح البحرية ثمانمائة ميغاوات في شبكة الجهد الفائق، ومحطة الطاقة الشمسية مائتي ميغاوات.',
        grammaticalAnalysisArabic:
            'حذف الفعل المشترك وحرف الجر المنفصل (Gapping) في الشطر المعطوف لدلالة المتقدم عليه، مما يمنح الجملة إيجازاً بلاغياً ورشاقة دون أي غموض.',
        grammaticalAnalysisGerman:
            'Klassisches Gapping des trennbaren Prädikats "speist ... ein" samt Richtungsangabe. Perfekte Parallelität der Nominalphrasen.',
        valenceIntegrityRule:
            'Beide Teilsätze verlangen dieselbe Valenz (Akkusativobjekt + Direktiv-Ergänzung); kein Valenzkonflikt.',
        stylisticNote:
            'Erhöht die Lesbarkeit in technischen Berichten und vermeidet ermüdende Wiederholungen.',
      ),
    );

    // 2. Robotics & Automation: Subject deletion under coordination
    _catalog.add(
      const EllipsisModel(
        id: 'ELL-SUBJ-ROBOT-02',
        fullOvertSentence:
            'Der sechsachsige Knickarmroboter erfasste das Aluminiumprofil präzise und er verschweißte die Verbindungsnaht fehlerfrei.',
        reducedEllipticSentence:
            'Der sechsachsige Knickarmroboter erfasste das Aluminiumprofil präzise und verschweißte die Verbindungsnaht fehlerfrei.',
        omittedElement: 'er (wiederholtes Subjekt)',
        ellipsisType: EllipsisType.subjektellipse,
        feasibility: SyntacticFeasibility.grammaticallySound,
        domain: CommunicativeDomain.roboticsAutomation,
        arabicTranslation:
            'التقط الروبوت سداسي المحاور القطاع المصنوع من الألومنيوم بدقة متناهية، ولحم وصلة التثبيت دون أي عيب.',
        grammaticalAnalysisArabic:
            'حذف الفاعل المتطابق بعد واو العطف (und): يتشارك الفعلان في الفاعل النحوي نفسه مع تقدم الفعلين وتتابعهما زمنياً.',
        grammaticalAnalysisGerman:
            'Subjektellipse bei koordinierter Hauptsatzreihung mit "und". Beide Prädikate regieren dasselbe logische Agens.',
        valenceIntegrityRule:
            'Identisches Subjekt im Nominativ Singular Maskulinum gestattet nahtlose Ellipse.',
        stylisticNote:
            'Im Deutschen ist die Subjektwiederholung bei koordinierter Verbkette stilistisch unerwünscht.',
      ),
    );

    // 3. Civil Engineering: Blocked Ellipsis due to Valence Clash (Zeugma Prevention)
    _catalog.add(
      const EllipsisModel(
        id: 'ELL-BLOCKED-ZEUGMA-03',
        fullOvertSentence:
            'Der leitende Prüfstatiker vertraute den computergestützten Berechnungen [Dativ] und überprüfte die manuellen Messwerte [Akkusativ].',
        reducedEllipticSentence:
            '*Der leitende Prüfstatiker vertraute und überprüfte die Berechnungen.',
        omittedElement: 'Unzulässige Objektverschmelzung bei ungleichem Kasus',
        ellipsisType: EllipsisType.objektellipse,
        feasibility: SyntacticFeasibility.blockedByValenceConflict,
        domain: CommunicativeDomain.civilEngineering,
        arabicTranslation:
            'وضع مهندس التدقيق الإنشائي ثقته في الحسابات المعتمدة على الحاسوب ودقق قيم القياس اليدوية. (يُمنع حذف المفعول هنا لاختلاف الإعراب بين الجر والنصب).',
        grammaticalAnalysisArabic:
            'امتناع الحذف والتنازع النحوي (Zeugma-Konflikt): الفعل "vertrauen" يتعدى بالداتيف (Dativ)، بينما الفعل "überprüfen" يتعدى بالأكوزاتيف (Akkusativ)، فلا يجوز جمع مفعول واحد لهما.',
        grammaticalAnalysisGerman:
            'Strikter Rektionskonflikt: "vertrauen" (+ Dativ) vs. "überprüfen" (+ Akkusativ). Zusammenziehung zu einem gemeinsamen Objekt ist ungrammatisch.',
        valenceIntegrityRule:
            'Objektellipsen erfordern zwingend identische Kasusrektion beider Verben.',
        stylisticNote:
            'Wichtiges Qualitätsmerkmal: Polyglot blockiert solche Rektionsfehler präventiv.',
      ),
    );

    // 4. Aviation Logistics: Auxiliary Ellipsis in High-Register Documentation
    _catalog.add(
      const EllipsisModel(
        id: 'ELL-AUX-AVIA-04',
        fullOvertSentence:
            'Nachdem die Frachtpapiere vollständig digital signiert worden waren und die Sicherheitsfreigaben erteilt worden waren, rollte das Frachtflugzeug zur Startbahn.',
        reducedEllipticSentence:
            'Nachdem die Frachtpapiere vollständig digital signiert und die Sicherheitsfreigaben erteilt worden waren, rollte das Frachtflugzeug zur Startbahn.',
        omittedElement: 'worden waren (erstes Hilfsverbgefüge)',
        ellipsisType: EllipsisType.hilfsverbellipse,
        feasibility: SyntacticFeasibility.grammaticallySound,
        domain: CommunicativeDomain.aviationLogistics,
        arabicTranslation:
            'بعد أن جرى توقيع وثائق الشحن رقمياً بالكامل وصدرت تصاريح السلامة، تحركت طائرة الشحن نحو مدرج الإقلاع.',
        grammaticalAnalysisArabic:
            'حذف الفعل المساعد وفعل الكينونة (worden waren) في الشق الأول من جملة بعد (Nachdem) والاكتفاء بذكره في نهاية المعطوف الثاني.',
        grammaticalAnalysisGerman:
            'Hilfsverbellipse im Passiv-Plusquamperfekt bei koordinierten Nebensätzen mit gemeinsamer Konjunktion "nachdem".',
        valenceIntegrityRule:
            'Beide Passivkonstruktionen stehen im Plural ("Frachtpapiere" / "Sicherheitsfreigaben"), daher numeruskongruent.',
        stylisticNote:
            'Gilt in der gehobenen Wissenschafts- und Dokumentationssprache als besonders elegant.',
      ),
    );

    // 5. Maritime Trade: Comparative Ellipsis
    _catalog.add(
      const EllipsisModel(
        id: 'ELL-COMP-MARITIME-05',
        fullOvertSentence:
            'Das neu in Dienst gestellte Containerschiff bewältigt die Atlantikroute mit deutlich geringerem Treibstoffverbrauch, als die älteren Einheiten der Flotte die Atlantikroute bewältigen.',
        reducedEllipticSentence:
            'Das neu in Dienst gestellte Containerschiff bewältigt die Atlantikroute mit deutlich geringerem Treibstoffverbrauch als die älteren Einheiten der Flotte.',
        omittedElement: 'die Atlantikroute bewältigen',
        ellipsisType: EllipsisType.vergleichsellipse,
        feasibility: SyntacticFeasibility.grammaticallySound,
        domain: CommunicativeDomain.maritimeTrade,
        arabicTranslation:
            'تقطع سفينة الحاويات التي دخلت الخدمة حديثاً مسار المحيط الأطلسي باستهلاك أقل بكثير للوقود مقارنة بالسفن الأقدم في الأسطول.',
        grammaticalAnalysisArabic:
            'حذف جملة المقارنة بعد "als" والاكتفاء بذكر طرف المقارنة الفاعل فقط (Vergleichsellipse).',
        grammaticalAnalysisGerman:
            'Vergleichsellipse nach komparativem "als". Das Prädikat samt Objekt wird im Vergleichssatz vollständig eingespart.',
        valenceIntegrityRule:
            'Der Vergleichsträger "die älteren Einheiten" übernimmt die syntaktische Rolle des Subjekts im Nominativ.',
        stylisticNote:
            'Vollständige Ausformulierung nach "als" wirkt unnatürlich und schleppend.',
      ),
    );

    // 6. Workplace Teamwork: Prosiopese in Agile Operations
    _catalog.add(
      const EllipsisModel(
        id: 'ELL-PROSIO-WORK-06',
        fullOvertSentence:
            'Ich habe die technischen Zeichnungen für das Gehäuse bereits an die Fertigung weitergeleitet.',
        reducedEllipticSentence:
            'Schon an die Fertigung weitergeleitet! Alles termingerecht im Plan.',
        omittedElement: 'Ich habe die Zeichnungen (Satzkopf)',
        ellipsisType: EllipsisType.prosiopese,
        feasibility: SyntacticFeasibility.grammaticallySound,
        domain: CommunicativeDomain.workplaceTeamwork,
        arabicTranslation:
            'أُحيلت بالفعل إلى قسم التصنيع! كل شيء يسير بدقة وفق الجدول المخطط.',
        grammaticalAnalysisArabic:
            'حذف صدر الجملة (Prosiopese) في بيئة العمل السريعة: حذف الفاعل والفعل المساعد المفهومين سياقاً والاكتفاء بجوهر الخبر.',
        grammaticalAnalysisGerman:
            'Prosiopese (Kopffellipsen-Struktur): Wegfall des unbetonten Vorfelds und finiten Hilfsverbs im professionellen Zuruf.',
        valenceIntegrityRule:
            'Partizip II "weitergeleitet" trägt den gesamten propositionalen Gehalt.',
        stylisticNote:
            'Funktional, dynamisch und absolut gebräuchlich in agilen Ingenieur- und Handwerksteams.',
      ),
    );

    // 7. Renewable Energy: Auxiliary Gapping with Modal Verbs
    _catalog.add(
      const EllipsisModel(
        id: 'ELL-MODAL-ENERGY-07',
        fullOvertSentence:
            'Die Wechselrichter müssen monatlich gewartet werden und die Transformatoren müssen halbjährlich gewartet werden.',
        reducedEllipticSentence:
            'Die Wechselrichter müssen monatlich und die Transformatoren halbjährlich gewartet werden.',
        omittedElement: 'müssen ... gewartet werden (im ersten Konjunkt)',
        ellipsisType: EllipsisType.prädikatsellipseGapping,
        feasibility: SyntacticFeasibility.grammaticallySound,
        domain: CommunicativeDomain.renewableEnergy,
        arabicTranslation:
            'يجب صيانة العواكس الكهربائية شهرياً والمحولات نصف سنوياً.',
        grammaticalAnalysisArabic:
            'حذف القوس الفعلي المركب (Modalverb + Passivinfinitiv) في الشق الأول وتأجيله للختام ليعمل على كلا المعطوفين.',
        grammaticalAnalysisGerman:
            'Gemeinsame Klammerbildung: Die verbale Endgruppe "gewartet werden" regiert beide Subjekt-Adverbial-Paare.',
        valenceIntegrityRule:
            'Beide Subjekte stehen im Plural ("Wechselrichter" / "Transformatoren"), wodurch keine Numerus-Friktion entsteht.',
        stylisticNote:
            'Kompakt, rhythmisch ausgewogen und optimal für Betriebs- und Wartungshandbücher.',
      ),
    );

    // 8. Civil Engineering: Coordinate Subject Ellipsis with Adverbial Fronting
    _catalog.add(
      const EllipsisModel(
        id: 'ELL-ADV-CIVIL-08',
        fullOvertSentence:
            'Gestern vermessen die Ingenieure das Fundament und heute betonieren die Ingenieure die Bodenplatte.',
        reducedEllipticSentence:
            'Gestern vermessen die Ingenieure das Fundament und heute betonieren sie die Bodenplatte.',
        omittedElement: 'Keine Ellipse zulässig wegen Inversion nach Vorfeld-Adverb',
        ellipsisType: EllipsisType.subjektellipse,
        feasibility: SyntacticFeasibility.grammaticallySound,
        domain: CommunicativeDomain.civilEngineering,
        arabicTranslation:
            'أمس قام المهندسون بقياس الأساسات، واليوم يصبون الخرسانة للقاعدة الأرضية.',
        grammaticalAnalysisArabic:
            'عند تصدير ظرف جديد (heute) في المعطوف الثاني، يتعذر حذف الفاعل كلياً بسبب تقديم الفعل (Inversion)، بل يستعاض عنه بضمير (sie).',
        grammaticalAnalysisGerman:
            'Vorfeldbesetzung durch Adverbial "heute" erzwingt V2-Inversion; eine Null-Subjektellipse ist hier syntaktisch gesperrt.',
        valenceIntegrityRule:
            'Ersatz durch anaphorisches Pronomen "sie" stellt die syntaktische Vollständigkeit her.',
        stylisticNote:
            'Schützt vor der häufigen Fehlerquelle des unzulässigen Subjektausfalls bei Inversion.',
      ),
    );

    // 9. Robotics Automation: Chiasmus with Symmetric Ellipsis
    _catalog.add(
      const EllipsisModel(
        id: 'ELL-CHIASM-ROBOT-09',
        fullOvertSentence:
            'Präzision zeichnet die Hardwaresysteme aus und unübertroffene Zuverlässigkeit zeichnet die Steuerungssoftware aus.',
        reducedEllipticSentence:
            'Präzision zeichnet die Hardwaresysteme aus und die Steuerungssoftware unübertroffene Zuverlässigkeit.',
        omittedElement: 'zeichnet ... aus',
        ellipsisType: EllipsisType.prädikatsellipseGapping,
        feasibility: SyntacticFeasibility.grammaticallySound,
        domain: CommunicativeDomain.roboticsAutomation,
        arabicTranslation:
            'الدقة تميز منظومة العتاد، وبرمجيات التحكم تميزها الموثوقية التي لا تضاهى.',
        grammaticalAnalysisArabic:
            'حذف الفعل في تركيب متناظر بلاغياً (Chiasmus) يعطي التعبير قوة إقناعية وأناقة أدبية راقية.',
        grammaticalAnalysisGerman:
            'Rhetorisch pointiertes Prädikatsgapping in chiastischer Anordnung der Satzglieder.',
        valenceIntegrityRule:
            'Beide Satzhälften weisen transitives "auszeichnen" mit identischen Kasusrelationen auf.',
        stylisticNote:
            'Hervorragend geeignet für repräsentative Produktvorstellungen und High-End-Architekturberichte.',
      ),
    );

    // 10. Maritime Logistics: Port Operation Gapping
    _catalog.add(
      const EllipsisModel(
        id: 'ELL-PORT-MARITIME-10',
        fullOvertSentence:
            'Kran 1 entlädt das Trockenfrachtschiff an Kai 4 und Kran 2 entlädt das Tankschiff an Kai 7.',
        reducedEllipticSentence:
            'Kran 1 entlädt das Trockenfrachtschiff an Kai 4 und Kran 2 das Tankschiff an Kai 7.',
        omittedElement: 'entlädt',
        ellipsisType: EllipsisType.prädikatsellipseGapping,
        feasibility: SyntacticFeasibility.grammaticallySound,
        domain: CommunicativeDomain.maritimeTrade,
        arabicTranslation:
            'الرافعة 1 تفرغ سفينة البضائع الجافة على الرصيف 4، والرافعة 2 سفينة الصهاريج على الرصيف 7.',
        grammaticalAnalysisArabic:
            'حذف الفعل "تفرغ" في المعطوف الثاني لدلالة الأول عليه (Gapping)، مع بقاء الفاعل والمفعول وشبه الجملة.',
        grammaticalAnalysisGerman:
            'Paralleles Prädikatsgapping in betrieblicher Logistiksitzung zur prägnanten Situationsdarstellung.',
        valenceIntegrityRule:
            'Strikte semantische und syntaktische Symmetrie beider Disjunkte.',
        stylisticNote:
            'Standardmuster im maritimen Umschlags- und Dispositionswesen.',
      ),
    );

    // 11. Renewable Energy: Blocked Ellipsis on Number Conflict
    _catalog.add(
      const EllipsisModel(
        id: 'ELL-NUM-CONFLICT-11',
        fullOvertSentence:
            'Der Solarpark liefert [Singular] sauberen Strom und die Biomassekraftwerke liefern [Plural] kontinuierliche Grundlast.',
        reducedEllipticSentence:
            '*Der Solarpark liefert sauberen Strom und die Biomassekraftwerke kontinuierliche Grundlast.',
        omittedElement: 'Unzulässiges Gapping bei Verbnumerus-Diskrepanz (liefert vs. liefern)',
        ellipsisType: EllipsisType.prädikatsellipseGapping,
        feasibility: SyntacticFeasibility.blockedByNumberMismatch,
        domain: CommunicativeDomain.renewableEnergy,
        arabicTranslation:
            'محطة الطاقة الشمسية توفر طاقة نظيفة، ومحطات الكتلة الحيوية توفر حمولة أساسية مستمرة. (امتناع الحذف لاختلاف إفراد الفعل وجمعه).',
        grammaticalAnalysisArabic:
            'امتناع الحذف لاختلاف صيغة الفعل بين المفرد (liefert) والجمع (liefern)؛ فالحذف هنا يسبب اضطراباً نحوياً في التطابق.',
        grammaticalAnalysisGerman:
            'Numerus-Konflikt: Das finite Verb im ersten Konjunkt steht im Singular, das Subjekt des zweiten im Plural.',
        valenceIntegrityRule:
            'Gapping erfordert identische morphosyntaktische Merkmale oder standardsprachliche Duldung.',
        stylisticNote:
            'Polyglot markiert diesen Fall als strukturell heikel und empfiehlt die Wiederholung des Verbs im Plural.',
      ),
    );

    // 12. Aviation Technology: Prepositional Ellipsis in Flight Planning
    _catalog.add(
      const EllipsisModel(
        id: 'ELL-PREP-AVIA-12',
        fullOvertSentence:
            'Die Flugroute verläuft über die Alpen und über das Mittelmeer bis nach Nordafrika.',
        reducedEllipticSentence:
            'Die Flugroute verläuft über die Alpen und das Mittelmeer bis nach Nordafrika.',
        omittedElement: 'über (wiederholte Präposition)',
        ellipsisType: EllipsisType.objektellipse,
        feasibility: SyntacticFeasibility.grammaticallySound,
        domain: CommunicativeDomain.aviationLogistics,
        arabicTranslation:
            'يمر مسار الرحلة الجوية فوق جبال الألب والبحر الأبيض المتوسط وصولاً إلى شمال إفريقيا.',
        grammaticalAnalysisArabic:
            'حذف حرف الجر المشترك (über) في المعطوف الثاني مع اتحاد المعنى والجر بالأكوزاتيف للاتجاه الحركي.',
        grammaticalAnalysisGerman:
            'Präpositionalellipse bei koordinierter Richtungsangabe mit geteilter Präposition "über".',
        valenceIntegrityRule:
            'Beide Nomina ("Alpen" und "Mittelmeer") fordern hier den Akkusativ der Bewegung.',
        stylisticNote:
            'Standard in der Flugwegsbeschreibung und Navigationsdokumentation.',
      ),
    );
  }

  /// Evaluates an elliptical coordination candidate against valence and agreement constraints.
  EllipsisValidationReport validateCoordination({
    required String firstVerb,
    required String secondVerb,
    required bool sameValenceCase,
    required bool sameSubjectNumber,
  }) {
    final issues = <String>[];
    final recommendations = <String>[];

    if (!sameValenceCase) {
      issues.add('Rektionskonflikt (Zeugma-Fehler): Die beiden Verben fordern unterschiedliche Kasus (z. B. Dativ vs. Akkusativ). Ein gemeinsames Objekt ist unzulässig.');
      recommendations.add('Nennen Sie für jedes Verb das passende Objekt mit dem korrekten Kasus oder verwenden Sie ein anaphorisches Pronomen.');
    }

    if (!sameSubjectNumber) {
      issues.add('Numerus-Diskrepanz: Ein Satzglied steht im Singular, das andere im Plural. Gapping kann zu grammatikalischer Dissonanz führen.');
      recommendations.add('Wiederholen Sie das finite Verb im korrekten Numerus im zweiten Konjunkt.');
    }

    final isValid = issues.isEmpty;
    final arabicSummary = isValid
        ? 'التركيب المعطوف المحذوف سليم لغوياً ومتوافق مع قواعد الإيجاز والبلاغة الألمانية.'
        : 'تم رصد مانع نحوي (تنازع إعرابي أو خلاف في الإفراد والجمع) يحول دون صحة الحذف.';

    return EllipsisValidationReport(
      isValid: isValid,
      avoidsValenceZeugma: sameValenceCase,
      hasParallelMorphology: sameSubjectNumber,
      issues: issues,
      recommendations: recommendations,
      arabicSummary: arabicSummary,
    );
  }

  List<EllipsisModel> filterByType(EllipsisType type) {
    return _catalog.where((item) => item.ellipsisType == type).toList();
  }

  List<EllipsisModel> filterByFeasibility(SyntacticFeasibility feasibility) {
    return _catalog.where((item) => item.feasibility == feasibility).toList();
  }

  List<EllipsisModel> filterByDomain(CommunicativeDomain domain) {
    return _catalog.where((item) => item.domain == domain).toList();
  }
}
