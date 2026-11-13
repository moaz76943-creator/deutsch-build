import 'dart:collection';

/// Specific types of German modal particles (Abtönungspartikeln).
enum ModalParticleType {
  ja('ja (Gemeinsames Vorwissen)', 'يا (التذكير بالمعلوم المشترك المسلم به)'),
  doch('doch (Erinnerung / Dissens-Abbau)', 'دوخ (التذكير الحازم / تفنيد التردد والشك)'),
  denn('denn (Kollegiales W-Interesse)', 'دِن (تلطيف الاستفهام الاستكشافي)'),
  halt('halt (Pragmatische Resignation)', 'هالت (التسليم العملي بالحتمية الواقعية)'),
  eben('eben (Objektive Unausweichlichkeit)', 'إيبن (التسليم الموضوعي الصارم بالثوابت)'),
  wohl('wohl (Epistemische Vermutung)', 'فول (الرجحان والترجيح المدروس)'),
  mal('mal (Pragmatische Milderung)', 'مال (تخفيف وطأة الطلب وجعله عفوياً)'),
  schon('schon (Konzessive Zuversicht)', 'شون (الطمأنة والاستدراك التمهيدي)'),
  bloss('bloß (Dringliche Warnung/Exhortation)', 'بلوس (شحذ التحذير والنهي القطعي)'),
  etwa('etwa (Skeptische Kontraerwartung)', 'إتوا (الاستنكار التشكيكي في الأسئلة القطبية)');

  final String de;
  final String ar;
  const ModalParticleType(this.de, this.ar);
}

/// The pragmatic intersubjective function modified by the particle.
enum IntersubjectiveFunction {
  sharedCommonGround(
    'Gemeinsames Vorwissen & Konsens',
    'استدعاء الأرضية المعرفية المشتركة وبداهة الحقيقة المتفق عليها',
    'Signalisiert dem Hörer: "Das weißt du genauso gut wie ich; darüber müssen wir nicht debattieren."',
  ),
  adversativeCorrectionOrReminder(
    'Nachdrückliche Erinnerung & Dissens-Korrektur',
    'التذكير التوكيدي الحازم وتصحيح التشكيك أو النسيان',
    'Appelliert an den Hörer gegen eine falsche Annahme: "Vergiss nicht, dass dieser Schritt bereits erfolgt ist!"',
  ),
  benevolentInterest(
    'Kollegiales Interesse & Entschärfung',
    'الاهتمام الودي وتخفيف الصبغة التحقيقية الاستجوابية',
    'Nimmt einer Frage die bürokratische Härte und bettet sie in ein partnerschaftliches Arbeitsverhältnis ein.',
  ),
  unalterableResignation(
    'Pragmatische Akzeptanz objektiver Restriktionen',
    'القبول الواقعي الهادئ بالقيود الجيولوجية والفيزيائية القاطعة',
    'Bringt zum Ausdruck, dass eine Gegebenheit unveränderlich ist und pragmatisch hingenommen werden muss.',
  ),
  epistemicProbability(
    'Epistemische Hypothese & fundierte Wahrscheinlichkeit',
    'الترجيح المعرفي المدروس غير القطعي',
    'Stellt eine wissenschaftlich begründete Vermutung dar, ohne absolute Gewähr zu fingieren.',
  ),
  politeAttenuation(
    'Situative Milderung von Arbeitsanweisungen',
    'تلطيف الأوامر التشغيلية لتسهيل التعاون الميداني',
    'Transformiert eine formelle Anweisung in eine unaufdringliche, situative Aufforderung.',
  ),
  concessiveAnticipation(
    'Konzessive Absicherung & vorsichtige Zuversicht',
    'الإقرار الاستدراكي والطمأنة المشروطة',
    'Räumt die Richtigkeit eines Aspekts ein, um die Aufmerksamkeit sofort auf flankierende Risiken zu lenken.',
  ),
  urgentExhortation(
    'Dringliche Exhortation & Gefahrenprävention',
    'النهي المشدد للوقاية من المخاطر التشغيلية القاتلة',
    'Verstärkt Handlungsverbote an Hochspannungs- oder Triebwerksanlagen zur Abwendung fataler Unfälle.',
  ),
  skepticalCounterExpectation(
    'Skeptische Kontraerwartung bei Polarfragen',
    'التشكيك الاستنكاري المعرب عن أمل نفي الفعل الخاطئ',
    'Drückt das besorgte Erstaunen aus, dass ein unverantwortlicher Schritt vollzogen worden sein könnte.',
  );

  final String deTitle;
  final String arTitle;
  final String pragmaticDescription;
  const IntersubjectiveFunction(this.deTitle, this.arTitle, this.pragmaticDescription);
}

/// Technical and engineering communicative domains.
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

/// Structural model for a German modal particle occurrence.
class ModalParticleModel {
  final String id;
  final ModalParticleType particle;
  final IntersubjectiveFunction function;
  final CommunicativeDomain domain;
  final String baseSentenceWithoutParticle;
  final String modulatedSentence;
  final String targetParticleChain;
  final String pragmaticEffectGerman;
  final String pragmaticEffectArabic;
  final String commonGroundPresupposition;
  final bool isUnaccentedMittelfeld;
  final bool allowsVorfeldPlacement;

  const ModalParticleModel({
    required this.id,
    required this.particle,
    required this.function,
    required this.domain,
    required this.baseSentenceWithoutParticle,
    required this.modulatedSentence,
    required this.targetParticleChain,
    required this.pragmaticEffectGerman,
    required this.pragmaticEffectArabic,
    required this.commonGroundPresupposition,
    this.isUnaccentedMittelfeld = true,
    this.allowsVorfeldPlacement = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'particle': particle.name,
    'function': function.name,
    'domain': domain.name,
    'baseSentenceWithoutParticle': baseSentenceWithoutParticle,
    'modulatedSentence': modulatedSentence,
    'targetParticleChain': targetParticleChain,
    'pragmaticEffectGerman': pragmaticEffectGerman,
    'pragmaticEffectArabic': pragmaticEffectArabic,
    'commonGroundPresupposition': commonGroundPresupposition,
    'isUnaccentedMittelfeld': isUnaccentedMittelfeld,
    'allowsVorfeldPlacement': allowsVorfeldPlacement,
  };
}

/// Validation result for modal particle syntax & discourse topology.
class ModalParticleValidationResult {
  final bool isValid;
  final List<String> errorMessages;
  final List<String> pragmaticNotes;

  const ModalParticleValidationResult({
    required this.isValid,
    required this.errorMessages,
    required this.pragmaticNotes,
  });
}

/// Core Engine managing German Modal Particles & Communicative Intersubjectivity.
class GermanModalParticlesIntersubjectivityEngine {
  final List<ModalParticleModel> _catalog = [];

  GermanModalParticlesIntersubjectivityEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<ModalParticleModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    _catalog.addAll([
      const ModalParticleModel(
        id: 'PART-4955-01',
        particle: ModalParticleType.ja,
        function: IntersubjectiveFunction.sharedCommonGround,
        domain: CommunicativeDomain.renewableEnergyGrid,
        baseSentenceWithoutParticle:
            'Die Nennleistung der Offshore-Windkraftanlage sinkt bei Flaute.',
        modulatedSentence:
            'Die Nennleistung der Offshore-Windkraftanlage sinkt ja bei Flaute.',
        targetParticleChain: 'ja',
        pragmaticEffectGerman:
            'Signalisiert, dass dieser physikalische Zusammenhang den Ingenieuren bereits bekannt und unstrittig ist.',
        pragmaticEffectArabic:
            'تؤكد المعلومة كأمر بدهي مشترك ومعلوم مسبقاً لدى الفريق الهندسي دون استعلاء.',
        commonGroundPresupposition:
            'Beide Kommunikationspartner verfügen über das thermodynamische/meteorologische Vorwissen.',
      ),
      const ModalParticleModel(
        id: 'PART-4955-02',
        particle: ModalParticleType.doch,
        function: IntersubjectiveFunction.adversativeCorrectionOrReminder,
        domain: CommunicativeDomain.aerospaceAndAviation,
        baseSentenceWithoutParticle:
            'Die Telemetriedaten wurden vor dem Triebwerkstest kalibriert.',
        modulatedSentence:
            'Die Telemetriedaten wurden doch vor dem Triebwerkstest kalibriert!',
        targetParticleChain: 'doch',
        pragmaticEffectGerman:
            'Erinnert nachdrücklich an eine bereits erfolgte Handlung gegen den impliziten Zweifel des Gegenübers.',
        pragmaticEffectArabic:
            'تُذكّر الطرف الآخر بحزم بحدوث المعايرة مسبقاً رداً على تشكيكه أو نسيانه.',
        commonGroundPresupposition:
            'Der Sprecher appelliert an das Gedächtnis des Prüfleiters, die Protokolle zu konsultieren.',
      ),
      const ModalParticleModel(
        id: 'PART-4955-03',
        particle: ModalParticleType.denn,
        function: IntersubjectiveFunction.benevolentInterest,
        domain: CommunicativeDomain.industrialRobotics,
        baseSentenceWithoutParticle:
            'Wann wird die servomotorische Kalibrierung abgeschlossen?',
        modulatedSentence:
            'Wann wird denn die servomotorische Kalibrierung abgeschlossen?',
        targetParticleChain: 'denn',
        pragmaticEffectGerman:
            'Nimmt der W-Frage die bürokratische Schärfe und bekundet kollegiales, situatives Interesse.',
        pragmaticEffectArabic:
            'تنزع الجفاف والحدة الاستجوابية من السؤال الهندسي وتضفي نبرة اهتمام ودية.',
        commonGroundPresupposition:
            'Die Frage knüpft an eine vorangegangene Arbeitssequenz im Montageraum an.',
      ),
      const ModalParticleModel(
        id: 'PART-4955-04',
        particle: ModalParticleType.halt,
        function: IntersubjectiveFunction.unalterableResignation,
        domain: CommunicativeDomain.civilInfrastructure,
        baseSentenceWithoutParticle:
            'Aufgrund des feuchten Baugrunds müssen wir zusätzliche Pfeiler gründen.',
        modulatedSentence:
            'Aufgrund des feuchten Baugrunds müssen wir halt zusätzliche Pfeiler gründen.',
        targetParticleChain: 'halt',
        pragmaticEffectGerman:
            'Drückt pragmatische Akzeptanz einer unveränderlichen geologischen Tatsache aus.',
        pragmaticEffectArabic:
            'تُعبر عن التسليم الواقعي بضرورة التكيّف مع عائق جيولوجي قاهر لا مفر منه.',
        commonGroundPresupposition:
            'Die Bodenanalyse lässt objektiv keine wirtschaftlichere Alternative zu.',
      ),
      const ModalParticleModel(
        id: 'PART-4955-05',
        particle: ModalParticleType.eben,
        function: IntersubjectiveFunction.unalterableResignation,
        domain: CommunicativeDomain.materialScience,
        baseSentenceWithoutParticle:
            'Titanlegierungen weisen eine geringere Duktilität bei extremen Minustemperaturen auf.',
        modulatedSentence:
            'Titanlegierungen weisen eben eine geringere Duktilität bei extremen Minustemperaturen auf.',
        targetParticleChain: 'eben',
        pragmaticEffectGerman:
            'Bestätigt eine physikalische Naturkonstante als unumstößliche Tatsache (noch sachlicher als halt).',
        pragmaticEffectArabic:
            'تُثبت حقيقة فيزيائية موضوعية قطعية لا تقبل النقاش ولا تحتمل اللوم.',
        commonGroundPresupposition:
            'Kristallographische Eigenschaften des Materials sind nicht manipulierbar.',
      ),
      const ModalParticleModel(
        id: 'PART-4955-06',
        particle: ModalParticleType.wohl,
        function: IntersubjectiveFunction.epistemicProbability,
        domain: CommunicativeDomain.maritimeLogistics,
        baseSentenceWithoutParticle:
            'Das Containerschiff erreicht den Tiefwasserhafen vor Einbruch der Dämmerung.',
        modulatedSentence:
            'Das Containerschiff erreicht wohl den Tiefwasserhafen vor Einbruch der Dämmerung.',
        targetParticleChain: 'wohl',
        pragmaticEffectGerman:
            'Kennzeichnet eine fundierte Vermutung des Navigators ohne absolute Gewähr.',
        pragmaticEffectArabic:
            'تُفيد الرجحان والترجيح المدروس بناءً على مؤشرات ملاحية دون الجزم المطلق.',
        commonGroundPresupposition:
            'Aktuelle Strömungs- und Wetterdaten deuten stark darauf hin.',
      ),
      const ModalParticleModel(
        id: 'PART-4955-07',
        particle: ModalParticleType.mal,
        function: IntersubjectiveFunction.politeAttenuation,
        domain: CommunicativeDomain.aerospaceAndAviation,
        baseSentenceWithoutParticle:
            'Überprüfen Sie den Drucksensor im Hydraulikkreislauf.',
        modulatedSentence:
            'Überprüfen Sie mal den Drucksensor im Hydraulikkreislauf.',
        targetParticleChain: 'mal',
        pragmaticEffectGerman:
            'Wandelt eine dienstliche Anweisung in eine beiläufige, unaufdringliche Bitte um.',
        pragmaticEffectArabic:
            'تُلطف الأمر الهندسي لتبدو المراجعة خطوة سريعة وعفوية غير معقدة.',
        commonGroundPresupposition:
            'Der Vorgang erfordert keinen übermäßigen bürokratischen Zeitaufwand.',
      ),
      const ModalParticleModel(
        id: 'PART-4955-08',
        particle: ModalParticleType.schon,
        function: IntersubjectiveFunction.concessiveAnticipation,
        domain: CommunicativeDomain.industrialRobotics,
        baseSentenceWithoutParticle:
            'Der Algorithmus optimiert die Trajektorie, aber der Rechenaufwand bleibt hoch.',
        modulatedSentence:
            'Der Algorithmus optimiert schon die Trajektorie, aber der Rechenaufwand bleibt hoch.',
        targetParticleChain: 'schon',
        pragmaticEffectGerman:
            'Räumt den Nutzen ein (Konzession), bereitet aber sofort die Einschränkung vor.',
        pragmaticEffectArabic:
            'تُقر بفاعلية الخوارزمية كتمهيد استدراكي لطرح عائق استهلاك الموارد الحسابية.',
        commonGroundPresupposition:
            'Die Optimierung ist unbestritten, genügt allein jedoch nicht zur Gesamtbewertung.',
      ),
      const ModalParticleModel(
        id: 'PART-4955-09',
        particle: ModalParticleType.bloss,
        function: IntersubjectiveFunction.urgentExhortation,
        domain: CommunicativeDomain.renewableEnergyGrid,
        baseSentenceWithoutParticle:
            'Berühren Sie nicht die ungesicherten Hochspannungsklemmen des Transformators!',
        modulatedSentence:
            'Berühren Sie bloß nicht die ungesicherten Hochspannungsklemmen des Transformators!',
        targetParticleChain: 'bloß',
        pragmaticEffectGerman:
            'Verstärkt die Warnung vor Lebensgefahr mit maximaler Dringlichkeit.',
        pragmaticEffectArabic:
            'تشحذ النهي بأعلى درجات التحذير القطعي لتفادي صدمة كهربائية مميتة.',
        commonGroundPresupposition:
            'Lebensbedrohliches Potenzial bei Missachtung des Schutzabstands.',
      ),
      const ModalParticleModel(
        id: 'PART-4955-10',
        particle: ModalParticleType.etwa,
        function: IntersubjectiveFunction.skepticalCounterExpectation,
        domain: CommunicativeDomain.civilInfrastructure,
        baseSentenceWithoutParticle:
            'Haben Sie den Spannbetonträger ohne statische Freigabe belastet?',
        modulatedSentence:
            'Haben Sie etwa den Spannbetonträger ohne statische Freigabe belastet?',
        targetParticleChain: 'etwa',
        pragmaticEffectGerman:
            'Drückt ungläubiges Erstaunen und Besorgnis über eine mögliche grobe Fahrlässigkeit aus.',
        pragmaticEffectArabic:
            'تُعبر عن استنكار تشكيكي وقلق بالغ مفاده: "أيعقل أنك فعلت هذا دون إذن؟".',
        commonGroundPresupposition:
            'Der Sprecher hofft inständig auf ein Dementi des Angesprochenen.',
      ),
      const ModalParticleModel(
        id: 'PART-4955-11',
        particle: ModalParticleType.ja,
        function: IntersubjectiveFunction.sharedCommonGround,
        domain: CommunicativeDomain.materialScience,
        baseSentenceWithoutParticle:
            'Die Kriechdehnung von Polymeren ist bei Dauerlast ja doch unvermeidlich.',
        modulatedSentence:
            'Die Kriechdehnung von Polymeren ist bei Dauerlast ja doch unvermeidlich.',
        targetParticleChain: 'ja doch',
        pragmaticEffectGerman:
            'Kombinierte Partikelkette: Bestätigt das gemeinsame Wissen (ja) gegen vorübergehende Skepsis (doch).',
        pragmaticEffectArabic:
            'سلسلة جسيمية مدمجة (ja doch): تؤكد البداهة العلمية مع تذكير الطرف المتردد بها.',
        commonGroundPresupposition:
            'Laborversuche belegen das Kriechverhalten zweifelsfrei.',
      ),
      const ModalParticleModel(
        id: 'PART-4955-12',
        particle: ModalParticleType.halt,
        function: IntersubjectiveFunction.unalterableResignation,
        domain: CommunicativeDomain.maritimeLogistics,
        baseSentenceWithoutParticle:
            'Wenn der Seegang zunimmt, müssen wir halt eben beidrehen.',
        modulatedSentence:
            'Wenn der Seegang zunimmt, müssen wir halt eben beidrehen.',
        targetParticleChain: 'halt eben',
        pragmaticEffectGerman:
            'Verdoppelte Resignationskette (halt eben): Unterstreicht die absolute Unausweichlichkeit des Manövers.',
        pragmaticEffectArabic:
            'سلسلة توكيدية مزدوجة (halt eben): تجسد الحتمية البحرية المطلقة لحماية السفينة.',
        commonGroundPresupposition:
            'Sicherheit auf See bricht jeden Fahrplan.',
      ),
      const ModalParticleModel(
        id: 'PART-4955-13',
        particle: ModalParticleType.denn,
        function: IntersubjectiveFunction.benevolentInterest,
        domain: CommunicativeDomain.aerospaceAndAviation,
        baseSentenceWithoutParticle:
            'Ist das neue Triebwerksmodell denn eigentlich flugtauglich zertifiziert?',
        modulatedSentence:
            'Ist das neue Triebwerksmodell denn eigentlich flugtauglich zertifiziert?',
        targetParticleChain: 'denn eigentlich',
        pragmaticEffectGerman:
            'Verknüpft kollegiales Interesse (denn) mit sachlicher Grundsatzreflexion (eigentlich).',
        pragmaticEffectArabic:
            'دمج (denn eigentlich): تساؤل استكشافي ودود يستوثق من الوضع التنظيمي الجوهري.',
        commonGroundPresupposition:
            'Vor dem Erstflug muss die EASA/FAA-Zulassung geklärt sein.',
      ),
      const ModalParticleModel(
        id: 'PART-4955-14',
        particle: ModalParticleType.ja,
        function: IntersubjectiveFunction.sharedCommonGround,
        domain: CommunicativeDomain.industrialRobotics,
        baseSentenceWithoutParticle:
            'Der Not-Aus-Schalter unterbricht ja wohl die Stromzufuhr redundant.',
        modulatedSentence:
            'Der Not-Aus-Schalter unterbricht ja wohl die Stromzufuhr redundant.',
        targetParticleChain: 'ja wohl',
        pragmaticEffectGerman:
            'Kombination aus Vorwissensappell (ja) und nachdrücklicher Erwartung von Konformität (wohl).',
        pragmaticEffectArabic:
            'دمج (ja wohl): نبرة تجمع بين البداهة والتوقع الصارم للامتثال لمعايير الأمان.',
        commonGroundPresupposition:
            'ISO 13849 Sicherheitsnormen sind für alle Schaltschränke verbindlich.',
      ),
      const ModalParticleModel(
        id: 'PART-4955-15',
        particle: ModalParticleType.doch,
        function: IntersubjectiveFunction.urgentExhortation,
        domain: CommunicativeDomain.renewableEnergyGrid,
        baseSentenceWithoutParticle:
            'Schalten Sie doch mal den Wechselrichter zur Diagnose ab.',
        modulatedSentence:
            'Schalten Sie doch mal den Wechselrichter zur Diagnose ab.',
        targetParticleChain: 'doch mal',
        pragmaticEffectGerman:
            'Kombiniert appellativen Nachdruck (doch) mit situativer Milderung (mal) zu einem ermutigenden Vorschlag.',
        pragmaticEffectArabic:
            'دمج (doch mal): مقترح هندسي مشجع يجمع بين الحث العملي وتخفيف وطأة الإجراء.',
        commonGroundPresupposition:
            'Eine kurze Abschaltung gefährdet das Netz nicht.',
      ),
      const ModalParticleModel(
        id: 'PART-4955-16',
        particle: ModalParticleType.schon,
        function: IntersubjectiveFunction.concessiveAnticipation,
        domain: CommunicativeDomain.civilInfrastructure,
        baseSentenceWithoutParticle:
            'Das Fundament wird schon halten, aber die Rissbreite muss überwacht werden.',
        modulatedSentence:
            'Das Fundament wird schon halten, aber die Rissbreite muss überwacht werden.',
        targetParticleChain: 'schon',
        pragmaticEffectGerman:
            'Drückt beruhigende Zuversicht aus, verlangt jedoch gleichzeitig präventive Messtechnik.',
        pragmaticEffectArabic:
            'تمنح طمأنة أولية للمشرف الميداني مع إلزامية رصد اتساع الشروخ مستقبلاً.',
        commonGroundPresupposition:
            'Die rechnerische Tragfähigkeit ist vorhanden, Langzeitverformung möglich.',
      ),
    ]);
  }

  List<ModalParticleModel> getByParticle(ModalParticleType particle) =>
      _catalog.where((m) => m.particle == particle).toList();

  List<ModalParticleModel> getByDomain(CommunicativeDomain domain) =>
      _catalog.where((m) => m.domain == domain).toList();

  List<ModalParticleModel> getByFunction(IntersubjectiveFunction function) =>
      _catalog.where((m) => m.function == function).toList();

  /// Validates topological and discourse constraints for German modal particles.
  ModalParticleValidationResult validateParticleUsage({
    required String sentence,
    required ModalParticleType particle,
    required bool isQuestion,
    required bool isVorfeld,
  }) {
    final List<String> errors = [];
    final List<String> notes = [];

    // Rule 1: Modal particles cannot occur in Vorfeld (Position 1 before finite verb).
    if (isVorfeld) {
      errors.add(
          'Topologischer Verstoß: Abtönungspartikeln (${particle.name}) sind unbetonbar und dürfen niemals im Vorfeld stehen.');
    }

    // Rule 2: Question restrictions for "denn" vs "etwa"
    if (particle == ModalParticleType.denn && !isQuestion) {
      notes.add(
          'Hinweis: "denn" als reine Abtönungspartikel tritt fast ausschließlich in Fragesätzen auf (in Aussagesätzen fungiert es als kausale Konjunktion).');
    }

    if (particle == ModalParticleType.etwa && !isQuestion) {
      errors.add(
          'Pragmatische Restriktion: "etwa" als modale Skepsispartikel erfordert eine Entscheidungsfrage (Polarfrage).');
    }

    // Rule 3: Mittelfeld requirement
    notes.add(
        'Topologische Konformität: Unbetonte Positionierung im Mittelfeld hinter Personalpronomen/Finitum gesichert.');

    return ModalParticleValidationResult(
      isValid: errors.isEmpty,
      errorMessages: errors,
      pragmaticNotes: notes,
    );
  }

  Map<String, dynamic> generateTelemetrySnapshot() {
    return {
      'totalExemplars': _catalog.length,
      'particleDistribution': {
        for (var p in ModalParticleType.values)
          p.name: _catalog.where((e) => e.particle == p).length,
      },
      'domainDistribution': {
        for (var d in CommunicativeDomain.values)
          d.name: _catalog.where((e) => e.domain == d).length,
      },
      'chainsCount':
          _catalog.where((e) => e.targetParticleChain.contains(' ')).length,
      'cefrLevel': 'CEFR C1-C2 Masterclass Intersubjectivity',
      'engineVersion': '1.0.0+subsystem1789',
    };
  }
}
