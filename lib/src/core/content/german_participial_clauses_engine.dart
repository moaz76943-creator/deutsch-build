import 'dart:collection';

/// Classification of participial constructions and non-finite clauses.
enum ParticipialType {
  participleOneSimultaneous(
    'Partizip I (Präsenspartizip - Gleichzeitigkeit)',
    'اسم الفاعل المعبر عن الآنية والمزامنة الزمنية',
    'Drückt aktive, unabgeschlossene Gleichzeitigkeit aus: Unablässig rotierend, erzeugt die Turbine...',
  ),
  participleTwoPrior(
    'Partizip II (Perfektpartizip - Vorzeitigkeit & Passiv)',
    'اسم المفعول المعبر عن الأسبقية الزمنية أو البناء للمجهول',
    'Drückt Vorzeitigkeit oder passivischen Zustand aus: Fachgerecht montiert, hält der Träger...',
  ),
  absoluteParticipialConstruction(
    'Absolute Partizipialkonstruktion (mit eigenem Subjekt)',
    'التركيب الوصفي المطلق ذو الفاعل الداخلي المستقل',
    'Besitzt ein eigenes internes Bezugswort: Den Blick auf die Telemetriedaten gerichtet, leitete der Fluglotse...',
  ),
  infinitiveClauseSubjectSharing(
    'Infinitivgruppe mit zu (strikte Subjektsidentität)',
    'المصدر المؤول المقترن بـ zu والمشترط لاتحاد الفاعل',
    'um zu, ohne zu, anstatt zu verlangen zwingende Identität mit dem Subjekt des Hauptsatzes.',
  );

  final String germanTitle;
  final String arabicTitle;
  final String grammaticalPattern;
  const ParticipialType(
    this.germanTitle,
    this.arabicTitle,
    this.grammaticalPattern,
  );
}

/// Status of logical and grammatical subject equivalence (Vermeidung des falschen Bezugs).
enum SubjectEquivalenceStatus {
  congruentSubject(
    'Syntaktisch kongruent (identisches Subjekt)',
    'تطابق تام بين فاعل شبه الجملة وفاعل الجملة الرئيسية',
  ),
  danglingSubjectViolation(
    'Falscher Bezug / Partizip-Anakoluth (Dangling Modifier)',
    'خلل التعليق النحوي (عدم تطابق الفاعل النحوي مع الفاعل الدلالي للشبه جملة)',
  ),
  validAbsoluteDetached(
    'Zulässige absolute Fügung mit eigenem Bezugswort',
    'تركيب مطلق سليم استقل بفاعله الخاص',
  );

  final String de;
  final String ar;
  const SubjectEquivalenceStatus(this.de, this.ar);
}

/// Temporal aspect relation between the non-finite clause and the main matrix clause.
enum TemporalRelation {
  simultaneous('Gleichzeitig (Präsens/Imperfektiv)', 'متزامن آنياً'),
  anterior('Vorzeitig (Perfektiv/Abgeschlossen)', 'سابق زمنياً');

  final String de;
  final String ar;
  const TemporalRelation(this.de, this.ar);
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

/// Model of a participial clause construction with subject-equivalence diagnostics.
class ParticipialClauseModel {
  final String id;
  final ParticipialType participialType;
  final TemporalRelation temporalRelation;
  final SubjectEquivalenceStatus equivalenceStatus;
  final String participialPhrase;
  final String governingMainClause;
  final String fullCombinedSentence;
  final String logicalSubject;
  final String explicitMainSubject;
  final CommunicativeDomain domain;
  final String arabicTranslation;
  final String grammaticalAnalysisArabic;
  final String grammaticalAnalysisGerman;
  final String clausalParaphraseSubordinate;
  final String stylisticDiagnosticRule;

  const ParticipialClauseModel({
    required this.id,
    required this.participialType,
    required this.temporalRelation,
    required this.equivalenceStatus,
    required this.participialPhrase,
    required this.governingMainClause,
    required this.fullCombinedSentence,
    required this.logicalSubject,
    required this.explicitMainSubject,
    required this.domain,
    required this.arabicTranslation,
    required this.grammaticalAnalysisArabic,
    required this.grammaticalAnalysisGerman,
    required this.clausalParaphraseSubordinate,
    required this.stylisticDiagnosticRule,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'participialType': participialType.name,
    'temporalRelation': temporalRelation.name,
    'equivalenceStatus': equivalenceStatus.name,
    'participialPhrase': participialPhrase,
    'governingMainClause': governingMainClause,
    'fullCombinedSentence': fullCombinedSentence,
    'logicalSubject': logicalSubject,
    'explicitMainSubject': explicitMainSubject,
    'domain': domain.name,
    'arabicTranslation': arabicTranslation,
    'grammaticalAnalysisArabic': grammaticalAnalysisArabic,
    'grammaticalAnalysisGerman': grammaticalAnalysisGerman,
    'clausalParaphraseSubordinate': clausalParaphraseSubordinate,
    'stylisticDiagnosticRule': stylisticDiagnosticRule,
  };
}

/// Verification report container for participial clause validation.
class ParticipialValidationReport {
  final bool isValid;
  final bool isSubjectCongruent;
  final bool avoidsDanglingModifier;
  final List<String> issues;
  final List<String> recommendations;
  final String arabicDiagnosticVerdict;

  const ParticipialValidationReport({
    required this.isValid,
    required this.isSubjectCongruent,
    required this.avoidsDanglingModifier,
    required this.issues,
    required this.recommendations,
    required this.arabicDiagnosticVerdict,
  });
}

/// Sovereign engine governing German Participial Clauses, Dangling Modifiers & Subject Equivalence.
class GermanParticipialClausesEngine {
  final List<ParticipialClauseModel> _catalog = [];

  GermanParticipialClausesEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<ParticipialClauseModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    // 1. Partizip II Congruent (Vorzeitigkeit) - Renewable Energy
    _catalog.add(
      const ParticipialClauseModel(
        id: 'PART-CONG-ENERGY-01',
        participialType: ParticipialType.participleTwoPrior,
        temporalRelation: TemporalRelation.anterior,
        equivalenceStatus: SubjectEquivalenceStatus.congruentSubject,
        participialPhrase: 'Vollständig mit grünem Wasserstoff befüllt',
        governingMainClause: 'kann die Brennstoffzelle Spitzenlasten bis zu zwanzig Stunden überbrücken',
        fullCombinedSentence:
            'Vollständig mit grünem Wasserstoff befüllt, kann die Brennstoffzelle Spitzenlasten bis zu zwanzig Stunden überbrücken.',
        logicalSubject: 'die Brennstoffzelle (wird befüllt)',
        explicitMainSubject: 'die Brennstoffzelle',
        domain: CommunicativeDomain.renewableEnergyGrid,
        arabicTranslation:
            'بعد أن مُلئت بالكامل بالهيدروجين الأخضر، تستطيع خلية الوقود تغطية أحمال الذروة لمدة تصل إلى عشرين ساعة.',
        grammaticalAnalysisArabic:
            'شبه جملة وصفية بـ Partizip II تفيد الأسبقية الزمنية والصفة المكتملة: الفاعل الدلالي لشبه الجملة هو نفسه فاعل الجملة الرئيسية (خلية الوقود)، مما يحقق التطابق النحوي الكامل.',
        grammaticalAnalysisGerman:
            'Partizip-II-Gruppe mit Vorzeitigkeit. Das logische Bezugswort entspricht exakt dem grammatischen Subjekt des Hauptsatzes ("die Brennstoffzelle").',
        clausalParaphraseSubordinate:
            'Paraphrase mit Nebensatz: "Nachdem sie vollständig mit grünem Wasserstoff befüllt worden ist, kann die Brennstoffzelle..."',
        stylisticDiagnosticRule:
            'Perfekte Subjektskongruenz: Das grammatische Subjekt des Hauptsatzes ist Träger des im Partizip ausgedrückten Zustands.',
      ),
    );

    // 2. Partizip I Congruent (Gleichzeitigkeit) - Aerospace Aviation
    _catalog.add(
      const ParticipialClauseModel(
        id: 'PART-CONG-AERO-02',
        participialType: ParticipialType.participleOneSimultaneous,
        temporalRelation: TemporalRelation.simultaneous,
        equivalenceStatus: SubjectEquivalenceStatus.congruentSubject,
        participialPhrase: 'Kontinuierlich Daten an das Kontrollzentrum sendend',
        governingMainClause: 'umkreist die Forschungssonde den Zielplaneten in stabiler Bahn',
        fullCombinedSentence:
            'Kontinuierlich Daten an das Kontrollzentrum sendend, umkreist die Forschungssonde den Zielplaneten in stabiler Bahn.',
        logicalSubject: 'die Forschungssonde (sendet aktiv)',
        explicitMainSubject: 'die Forschungssonde',
        domain: CommunicativeDomain.aerospaceAndAviation,
        arabicTranslation:
            'مرسلةً البيانات باستمرار إلى مركز التحكم، تدور كبسولة الأبحاث حول الكوكب المستهدف في مسار مداري مستقر.',
        grammaticalAnalysisArabic:
            'اسم فاعل (Partizip I) يفيد الآنية والاستمرارية المتزامنة مع فعل الدوران: الفاعل متطابق تماماً بين شطري الجملة.',
        grammaticalAnalysisGerman:
            'Partizip-I-Konstruktion zur Wiedergabe von Gleichzeitigkeit. Das Agens des Sendens ist identisch mit dem Subjekt des Umkreisens ("die Forschungssonde").',
        clausalParaphraseSubordinate:
            'Paraphrase: "Während sie kontinuierlich Daten an das Kontrollzentrum sendet, umkreist die Forschungssonde..."',
        stylisticDiagnosticRule:
            'Partizip I verlangt stets aktive Gleichzeitigkeit zum Hauptsatzprädikat.',
      ),
    );

    // 3. Dangling Modifier Pitfall (Falscher Bezug / Anakoluth) - Civil Infrastructure
    _catalog.add(
      const ParticipialClauseModel(
        id: 'PART-DANGLING-CIVIL-03',
        participialType: ParticipialType.participleTwoPrior,
        temporalRelation: TemporalRelation.anterior,
        equivalenceStatus: SubjectEquivalenceStatus.danglingSubjectViolation,
        participialPhrase: '*Fachgerecht im Fundament verankert',
        governingMainClause: 'bemerkten die Bauingenieure eine gefährliche Haarrissbildung am Pfeiler',
        fullCombinedSentence:
            '*Fachgerecht im Fundament verankert, bemerkten die Bauingenieure eine gefährliche Haarrissbildung am Pfeiler.',
        logicalSubject: 'der Pfeiler (wurde verankert)',
        explicitMainSubject: 'die Bauingenieure (Grammatisches Subjekt!)',
        domain: CommunicativeDomain.civilInfrastructure,
        arabicTranslation:
            '*بعد أن رُسِّخ في الأساسات وفق الأصول الهندسية، لاحظ مهندسو البناء تشكلاً خطيراً لشروخ شعرية في الدعامة. (خطأ نحوي ألماني: يوهم أن المهندسين هم من تم ترسيخهم في الأساسات!).',
        grammaticalAnalysisArabic:
            'خلل التعليق النحوي والفاعل الوهمي (Partizip-Anakoluth / Dangling Modifier): فاعل الجملة الرئيسية هو "المهندسون"، مما يجعل شبه الجملة تعود عليهم لغوياً بدلاً من الدعامة! هذا خطأ أسلوبي فادح في الألمانية.',
        grammaticalAnalysisGerman:
            'Schwerer stilistischer Fehler des falschen Bezugs (Partizip-Anakoluth): Das Partizip "verankert" bezieht sich syntaktisch auf das Hauptsatzsubjekt "die Bauingenieure", gemeint ist aber der Pfeiler.',
        clausalParaphraseSubordinate:
            'Korrekte Fassung: "Als der Pfeiler fachgerecht im Fundament verankert war, bemerkten die Bauingenieure..." oder "Fachgerecht verankert, zeigte der Pfeiler dennoch..."',
        stylisticDiagnosticRule:
            'Kardinalfehler: Ein Partizip darf niemals bezugslos im Satz stehen, wenn sein logischer Träger nicht das Hauptsatzsubjekt ist.',
      ),
    );

    // 4. Absolute Participial Construction (Zulässig mit eigenem Nomen) - Maritime Logistics
    _catalog.add(
      const ParticipialClauseModel(
        id: 'PART-ABSOLUTE-MARITIME-04',
        participialType: ParticipialType.absoluteParticipialConstruction,
        temporalRelation: TemporalRelation.anterior,
        equivalenceStatus: SubjectEquivalenceStatus.validAbsoluteDetached,
        participialPhrase: 'Alle Frachtluken dicht verschlossen und gesichert',
        governingMainClause: 'lief das Containerschiff bei aufkommendem Sturm aus dem Hafen aus',
        fullCombinedSentence:
            'Alle Frachtluken dicht verschlossen und gesichert, lief das Containerschiff bei aufkommendem Sturm aus dem Hafen aus.',
        logicalSubject: 'alle Frachtluken (internes Bezugsnomen)',
        explicitMainSubject: 'das Containerschiff',
        domain: CommunicativeDomain.maritimeLogistics,
        arabicTranslation:
            'وقد أُحكم إغلاق كافة فتحات الشحن وتأمينها، أبحرت سفينة الحاويات خارجة من الميناء مع هبوب العاصفة.',
        grammaticalAnalysisArabic:
            'تركيب وصفي مطلق مشروع (Absolute Partizipialkonstruktion): يحمل الاسم الخاص به في داخله (Alle Frachtluken)، لذا لا يشترط تطابقه مع فاعل السفينة الرئيسي.',
        grammaticalAnalysisGerman:
            'Absolute Partizipialkonstruktion (Nominativus Absolutus). Da das Partizip ein eigenes Nomen ("alle Frachtluken") mitführt, liegt kein falscher Bezug vor.',
        clausalParaphraseSubordinate:
            'Paraphrase: "Nachdem alle Frachtluken dicht verschlossen und gesichert worden waren, lief das Containerschiff aus..."',
        stylisticDiagnosticRule:
            'Zulässig, wenn die Partizipialphrase ihr Bezugswort selbst explizit enthält.',
      ),
    );

    // 5. Infinitive with 'um zu' Dangling Pitfall - Industrial Automation
    _catalog.add(
      const ParticipialClauseModel(
        id: 'PART-DANGLING-INF-ROBOT-05',
        participialType: ParticipialType.infinitiveClauseSubjectSharing,
        temporalRelation: TemporalRelation.simultaneous,
        equivalenceStatus: SubjectEquivalenceStatus.danglingSubjectViolation,
        participialPhrase: '*Um den Energieverbrauch des Schweißroboters zu minimieren',
        governingMainClause: 'müssen die Bewegungstrajektorien neu berechnet werden',
        fullCombinedSentence:
            '*Um den Energieverbrauch des Schweißroboters zu minimieren, müssen die Bewegungstrajektorien neu berechnet werden.',
        logicalSubject: 'der Programmierer / Ingenieur (handelt mit Absicht)',
        explicitMainSubject: 'die Bewegungstrajektorien (Passiv-Subjekt!)',
        domain: CommunicativeDomain.industrialRobotics,
        arabicTranslation:
            '*بغية تقليل استهلاك الروبوت للطاقة، يجب إعادة حساب مسارات الحركة. (ضعف أسلوبي شائع في الألمانية الأكاديمية: مسارات الحركة لا تهدف بنفسها إلى تقليل الاستهلاك).',
        grammaticalAnalysisArabic:
            'خلل اتحاد الفاعل في المصدر المؤول (um zu): الجملة المبنية للمجهول تجعل فاعل الجملة الرئيسية هو "مسارات الحركة"، بينما فاعل القصد والهدف هو المهندس المبرمج.',
        grammaticalAnalysisGerman:
            'Verletzung der Subjektsidentität bei Infinitivsatz mit "um zu". Das Ziel "minimieren" kann logisch nicht von den passiven "Bewegungstrajektorien" verfolgt werden.',
        clausalParaphraseSubordinate:
            'Korrekte Fassung: "Um den Energieverbrauch zu minimieren, muss der Ingenieur die Trajektorien neu berechnen" oder "Zur Minimierung des Energieverbrauchs müssen..."',
        stylisticDiagnosticRule:
            'Bei "um zu" muss das Subjekt des Hauptsatzes das willentliche Agens der Zielhandlung sein.',
      ),
    );

    // 6. Infinitive with 'um zu' Congruent - Software Architecture
    _catalog.add(
      const ParticipialClauseModel(
        id: 'PART-CONG-INF-SOFT-06',
        participialType: ParticipialType.infinitiveClauseSubjectSharing,
        temporalRelation: TemporalRelation.simultaneous,
        equivalenceStatus: SubjectEquivalenceStatus.congruentSubject,
        participialPhrase: 'Um die Ausfallsicherheit der Cloud-Plattform zu garantieren',
        governingMainClause: 'implementierte die Chefarchitektin ein georedundantes Speichercluster',
        fullCombinedSentence:
            'Um die Ausfallsicherheit der Cloud-Plattform zu garantieren, implementierte die Chefarchitektin ein georedundantes Speichercluster.',
        logicalSubject: 'die Chefarchitektin',
        explicitMainSubject: 'die Chefarchitektin',
        domain: CommunicativeDomain.softwareEngineering,
        arabicTranslation:
            'ضماناً لمقاومة المنصة السحابية للأعطال، قامت كبيرة مهندسي المعمارية بتطبيق عنقود تخزين مكرر جغرافياً.',
        grammaticalAnalysisArabic:
            'تطابق تام في المصدر المؤول (um zu): مهندسة المعمارية هي التي تهدف للضمان وهي فاعل التطبيق والتنفيذ في الجملة الرئيسية.',
        grammaticalAnalysisGerman:
            'Einwandfreie Subjektskongruenz: Das grammatische Hauptsatzsubjekt ("die Chefarchitektin") ist identisch mit dem impliziten logischen Subjekt des Infinitivsatzes.',
        clausalParaphraseSubordinate:
            'Paraphrase: "Damit sie die Ausfallsicherheit garantieren kann, implementierte die Chefarchitektin..."',
        stylisticDiagnosticRule:
            'Goldstandard für finale Nebensätze im anspruchsvollen Fachdeutsch.',
      ),
    );

    // 7. Partizip II Congruent (Causal/Condition) - Material Science
    _catalog.add(
      const ParticipialClauseModel(
        id: 'PART-CONG-MAT-07',
        participialType: ParticipialType.participleTwoPrior,
        temporalRelation: TemporalRelation.anterior,
        equivalenceStatus: SubjectEquivalenceStatus.congruentSubject,
        participialPhrase: 'Unter extremem Druck und bei 1200 Grad gesintert',
        governingMainClause: 'weist die Siliziumnitrid-Keramik eine diamantgleiche Oberflächenhärte auf',
        fullCombinedSentence:
            'Unter extremem Druck und bei 1200 Grad gesintert, weist die Siliziumnitrid-Keramik eine diamantgleiche Oberflächenhärte auf.',
        logicalSubject: 'die Siliziumnitrid-Keramik',
        explicitMainSubject: 'die Siliziumnitrid-Keramik',
        domain: CommunicativeDomain.materialScience,
        arabicTranslation:
            'بعد تلبيدها تحت ضغط فائق وعند درجة حرارة 1200 مئوية، تُظهر خزفيات نتريد السيليكون صلادة سطحية تضاهي الماس.',
        grammaticalAnalysisArabic:
            'شبه جملة Partizip II تسبق الجملة الرئيسية وتفيد التعليل والشرط المتحقق: خزفيات السيليكون هي الملبدة وهي التي تظهر الصلادة.',
        grammaticalAnalysisGerman:
            'Kausales Partizip II im Vorfeld. Das logische Subjekt der Vorbehandlung stimmt mit dem Träger der Härte überein.',
        clausalParaphraseSubordinate:
            'Paraphrase: "Da sie unter extremem Druck gesintert wurde, weist die Keramik..."',
        stylisticDiagnosticRule:
            'Elegante Verdichtung wissenschaftlicher Kausalitätsketten.',
      ),
    );

    // 8. Partizip I Congruent (Modal/Concomitant) - Industrial Robotics
    _catalog.add(
      const ParticipialClauseModel(
        id: 'PART-CONG-ROBOT-08',
        participialType: ParticipialType.participleOneSimultaneous,
        temporalRelation: TemporalRelation.simultaneous,
        equivalenceStatus: SubjectEquivalenceStatus.congruentSubject,
        participialPhrase: 'Mittels Laserinterferometrie mikrometergenau messend',
        governingMainClause: 'justiert der Mehrachsroboter die optischen Spiegel millimetergenau nach',
        fullCombinedSentence:
            'Mittels Laserinterferometrie mikrometergenau messend, justiert der Mehrachsroboter die optischen Spiegel millimetergenau nach.',
        logicalSubject: 'der Mehrachsroboter',
        explicitMainSubject: 'der Mehrachsroboter',
        domain: CommunicativeDomain.industrialRobotics,
        arabicTranslation:
            'قائماً بالقياس بدقة الميكرومتر عبر قياس التداخل الليزري، يضبط الروبوت متعدد المحاور موضع المرايا البصرية بدقة متناهية.',
        grammaticalAnalysisArabic:
            'اسم فاعل في موضع الحال والوسيلة المصاحبة (messend): الروبوت هو القائم بالقياس وهو الفاعل لعملية الضبط والتعديل.',
        grammaticalAnalysisGerman:
            'Modale Partizip-I-Gruppe zur Beschreibung des Begleitumstands bei lückenloser Subjektsidentität.',
        clausalParaphraseSubordinate:
            'Paraphrase: "Indem er mittels Laserinterferometrie misst, justiert der Mehrachsroboter..."',
        stylisticDiagnosticRule:
            'Ersetzt sperrige indem-Sätze in technischen Betriebsbeschreibungen.',
      ),
    );

    // 9. Absolute Accusative Construction (Accusativus Absolutus) - Aerospace Aviation
    _catalog.add(
      const ParticipialClauseModel(
        id: 'PART-ACC-ABSOLUTE-09',
        participialType: ParticipialType.absoluteParticipialConstruction,
        temporalRelation: TemporalRelation.simultaneous,
        equivalenceStatus: SubjectEquivalenceStatus.validAbsoluteDetached,
        participialPhrase: 'Den Blick unverwandt auf die Triebwerksdruckanzeige gerichtet',
        governingMainClause: 'überwachte der Flugkapitän den kritischen Steigflug nach dem Start',
        fullCombinedSentence:
            'Den Blick unverwandt auf die Triebwerksdruckanzeige gerichtet, überwachte der Flugkapitän den kritischen Steigflug nach dem Start.',
        logicalSubject: 'den Blick (Akkusativus Absolutus)',
        explicitMainSubject: 'der Flugkapitän',
        domain: CommunicativeDomain.aerospaceAndAviation,
        arabicTranslation:
            'شاخصاً ببصره دون انقطاع نحو مؤشر ضغط المحركات، راقب كابتن الطائرة مرحلة الصعود الحرجة بعد الإقلاع.',
        grammaticalAnalysisArabic:
            'تركيب مطلق منصوب مأثور في الفصحى الراقية (Accusativus Absolutus): "Den Blick gerichtet" يصف هيئة الفاعل بملكية داخلية مباشرة.',
        grammaticalAnalysisGerman:
            'Accusativus Absolutus als traditionell anerkannte absolute Fügung zur Kennzeichnung von Haltung oder Begleitumstand.',
        clausalParaphraseSubordinate:
            'Paraphrase: "Während er den Blick auf die Anzeige gerichtet hielt, überwachte der Flugkapitän..."',
        stylisticDiagnosticRule:
            'Gilt in der gehobenen Literatursprache und Fachprosa als rhetorisches Glanzstück.',
      ),
    );

    // 10. Infinitive with 'ohne zu' Congruent - Civil Infrastructure
    _catalog.add(
      const ParticipialClauseModel(
        id: 'PART-CONG-OHNE-ZU-10',
        participialType: ParticipialType.infinitiveClauseSubjectSharing,
        temporalRelation: TemporalRelation.simultaneous,
        equivalenceStatus: SubjectEquivalenceStatus.congruentSubject,
        participialPhrase: 'Ohne den regulären Bahnverkehr auch nur für eine Stunde zu unterbrechen',
        governingMainClause: 'schoben die Brückenbauer die neue Stahlkonstruktion über die Gleise',
        fullCombinedSentence:
            'Ohne den regulären Bahnverkehr auch nur für eine Stunde zu unterbrechen, schoben die Brückenbauer die neue Stahlkonstruktion über die Gleise.',
        logicalSubject: 'die Brückenbauer',
        explicitMainSubject: 'die Brückenbauer',
        domain: CommunicativeDomain.civilInfrastructure,
        arabicTranslation:
            'دون قطع حركة القطارات المنتظمة ولو لساعة واحدة، دفع بناة الجسور الهيكل الفولاذي الجديد فوق مسارات السكك الحديدية.',
        grammaticalAnalysisArabic:
            'مصدر مؤول منفي بـ ohne zu: بناة الجسور هم الذين امتنعوا عن قطع الحركة وهم الذين قاموا بدفع الهيكل، مما يحقق تطابق الفاعل.',
        grammaticalAnalysisGerman:
            'Infinitivkonstruktion mit "ohne zu". Das handelnde Subjekt des Einschubs ist deckungsgleich mit dem Subjekt des Hauptsatzes.',
        clausalParaphraseSubordinate:
            'Paraphrase: "Ohne dass sie den Bahnverkehr unterbrachen, schoben die Brückenbauer..."',
        stylisticDiagnosticRule:
            'Infinitiv mit "ohne zu" ist stilistisch weitaus eleganter als "ohne dass".',
      ),
    );

    // 11. Dangling Modifier Pitfall (Partizip I) - Maritime Logistics
    _catalog.add(
      const ParticipialClauseModel(
        id: 'PART-DANGLING-MARITIME-11',
        participialType: ParticipialType.participleOneSimultaneous,
        temporalRelation: TemporalRelation.simultaneous,
        equivalenceStatus: SubjectEquivalenceStatus.danglingSubjectViolation,
        participialPhrase: '*Mit hoher Geschwindigkeit in den Hafenbecken einfahrend',
        governingMainClause: 'zerbrach die Steuerbordleine des Frachters unter starkem Zug',
        fullCombinedSentence:
            '*Mit hoher Geschwindigkeit in das Hafenbecken einfahrend, zerbrach die Steuerbordleine des Frachters unter starkem Zug.',
        logicalSubject: 'der Frachter (fährt ein)',
        explicitMainSubject: 'die Steuerbordleine (Grammatisches Subjekt!)',
        domain: CommunicativeDomain.maritimeLogistics,
        arabicTranslation:
            '*أثناء الدخول بسرعة عالية إلى حوض الميناء، انقطع حبل الميمنة الخاص بسفينة الشحن تحت وطأة الشد الشديد. (خطأ تركيبي: يوهم أن حبل السفينة هو من كان يقود ويدخل الميناء بسرعة!).',
        grammaticalAnalysisArabic:
            'خطأ في تطابق الفاعل: فاعل الجملة الرئيسية هو "حبل السفينة" (die Leine)، في حين أن الذي كان يبحر ويدخل الميناء هو "السفينة" نفسها! الحل إعادة صياغة الجملة بجعل السفينة هي الفاعل.',
        grammaticalAnalysisGerman:
            'Partizip-Anakoluth: "einfahrend" knüpft syntaktisch an "die Steuerbordleine" an. Seile fahren jedoch nicht in Hafenbecken ein.',
        clausalParaphraseSubordinate:
            'Korrekte Fassung: "Als der Frachter mit hoher Geschwindigkeit einfuhr, zerbrach die Leine..." oder "In das Becken einfahrend, verlor der Frachter seine Steuerbordleine."',
        stylisticDiagnosticRule:
            'Zur Fehlervermeidung: Vor dem Hauptsatz-Subjekt stets prüfen, ob es die Partiziphandlung aktiv ausführen kann.',
      ),
    );

    // 12. Partizip II Congruent (Post-Positioned) - Renewable Energy
    _catalog.add(
      const ParticipialClauseModel(
        id: 'PART-CONG-POST-ENERGY-12',
        participialType: ParticipialType.participleTwoPrior,
        temporalRelation: TemporalRelation.anterior,
        equivalenceStatus: SubjectEquivalenceStatus.congruentSubject,
        participialPhrase: 'von führenden Prüfinstituten mehrfach zertifiziert',
        governingMainClause: 'Das neue Hochspannungs-Gleichstrom-Kabel gewährleistet verlustarme Übertragungen',
        fullCombinedSentence:
            'Das neue Hochspannungs-Gleichstrom-Kabel, von führenden Prüfinstituten mehrfach zertifiziert, gewährleistet verlustarme Übertragungen über tausend Kilometer.',
        logicalSubject: 'das Kabel (wurde zertifiziert)',
        explicitMainSubject: 'das neue Hochspannungs-Gleichstrom-Kabel',
        domain: CommunicativeDomain.renewableEnergyGrid,
        arabicTranslation:
            'يضمن كابل التيار المباشر عالي الجهد الجديد، بعد أن نال شهادات اعتماد متكررة من كبريات معاهد الفحص، نقلاً قليل الفواقد عبر أكثر من ألف كيلومتر.',
        grammaticalAnalysisArabic:
            'شبه جملة وصفية اعتراضية محصورة بين فاصلتين بعد المبتدأ مباشرة: الفاعل الاسمي متطابق بدقة مع موضوع الشهادة.',
        grammaticalAnalysisGerman:
            'Nachgestellte attributive Partizip-II-Apposition im Vorfeldkomplex. Vollständige grammatische und semantische Kongruenz.',
        clausalParaphraseSubordinate:
            'Paraphrase: "Das Kabel, das von Prüfinstituten zertifiziert wurde, gewährleistet..."',
        stylisticDiagnosticRule:
            'Paarige Kommasetzung grenzt die nachgestellte Partizipialgruppe präzise ab.',
      ),
    );

    // 13. Infinitive with 'anstatt zu' Congruent - Aerospace Aviation
    _catalog.add(
      const ParticipialClauseModel(
        id: 'PART-CONG-ANSTATT-13',
        participialType: ParticipialType.infinitiveClauseSubjectSharing,
        temporalRelation: TemporalRelation.simultaneous,
        equivalenceStatus: SubjectEquivalenceStatus.congruentSubject,
        participialPhrase: 'Anstatt die fehlerhaften Treibstoffventile im Eilverfahren auszutauschen',
        governingMainClause: 'unterzog das Wartungsteam die gesamte Zuleitung einer gründlichen Röntgenprüfung',
        fullCombinedSentence:
            'Anstatt die fehlerhaften Treibstoffventile im Eilverfahren auszutauschen, unterzog das Wartungsteam die gesamte Zuleitung einer gründlichen Röntgenprüfung.',
        logicalSubject: 'das Wartungsteam',
        explicitMainSubject: 'das Wartungsteam',
        domain: CommunicativeDomain.aerospaceAndAviation,
        arabicTranslation:
            'بدلاً من استبدال صمامات الوقود المعيبة على عجل وبصورة متسرعة، أخضع فريق الصيانة خط الإمداد بأكمله لفحص دقيق بالأشعة السينية.',
        grammaticalAnalysisArabic:
            'مصدر مؤول بديل بـ anstatt zu: فريق الصيانة هو الذي عدل عن الاستبدال السريع وهو الذي نفذ الفحص الإشعاعي، محققاً التطابق التام.',
        grammaticalAnalysisGerman:
            'Adversative Infinitivgruppe mit "anstatt zu". Volle Kongruenz zwischen Agens der Ausweichhandlung und Subjekt der realisierten Maßnahme.',
        clausalParaphraseSubordinate:
            'Paraphrase: "Anstatt dass das Wartungsteam die Ventile austauschte, unterzog es..."',
        stylisticDiagnosticRule:
            'Subjektsidentität sichert logische Konsistenz der Handlungsentscheidung.',
      ),
    );

    // 14. Dangling Modifier Pitfall (Infinitive 'ohne zu') - Material Science
    _catalog.add(
      const ParticipialClauseModel(
        id: 'PART-DANGLING-OHNE-MAT-14',
        participialType: ParticipialType.infinitiveClauseSubjectSharing,
        temporalRelation: TemporalRelation.simultaneous,
        equivalenceStatus: SubjectEquivalenceStatus.danglingSubjectViolation,
        participialPhrase: '*Ohne die Kristallstruktur im Elektronenmikroskop zu analysieren',
        governingMainClause: 'zeigte sich eine überraschende Festigkeitszunahme der Titanlegierung',
        fullCombinedSentence:
            '*Ohne die Kristallstruktur im Elektronenmikroskop zu analysieren, zeigte sich eine überraschende Festigkeitszunahme der Titanlegierung.',
        logicalSubject: 'die Forscher (analysieren nicht)',
        explicitMainSubject: 'eine überraschende Festigkeitszunahme (Grammatisches Subjekt!)',
        domain: CommunicativeDomain.materialScience,
        arabicTranslation:
            '*دون تحليل البنية البلورية تحت المجهر الإلكتروني، ظهرت زيادة مفاجئة في متانة سبيكة التيتانيوم. (خلل تركيبي: يوهم أن زيادة المتانة هي التي امتنعت عن التحليل المجهري!).',
        grammaticalAnalysisArabic:
            'خلل فادح في فاعل المصدر المؤول: فاعل الجملة هو "زيادة المتانة"، في حين أن الذي كان يجب أن يقوم بالتحليل هم "الباحثون". الحل إعادة الصياغة بجعل الباحثين هم الفاعل أو استخدام شبه جملة اسمية (Ohne Analyse der Kristallstruktur).',
        grammaticalAnalysisGerman:
            'Falscher Bezug bei "ohne zu": "Festigkeitszunahme" kann keine mikroskopischen Analysen durchführen. Verstoß gegen die Subjektsidentitätsregel.',
        clausalParaphraseSubordinate:
            'Korrekte Fassung: "Ohne dass die Forscher die Struktur analysierten, zeigte sich..." oder "Ohne Analyse der Struktur stellten die Forscher fest..."',
        stylisticDiagnosticRule:
            'Ersatz durch Präpositionalphrasen ("ohne Analyse...") löst den Konflikt elegant.',
      ),
    );

    // 15. Partizip I Congruent (Coordination of Two Participles) - Renewable Energy
    _catalog.add(
      const ParticipialClauseModel(
        id: 'PART-CONG-DOUBLE-P1-15',
        participialType: ParticipialType.participleOneSimultaneous,
        temporalRelation: TemporalRelation.simultaneous,
        equivalenceStatus: SubjectEquivalenceStatus.congruentSubject,
        participialPhrase: 'Leise vibrierend und beträchtliche Wärmemengen abgebend',
        governingMainClause: 'transformiert der Großtransformator den Strom für die Überlandleitung',
        fullCombinedSentence:
            'Leise vibrierend und beträchtliche Wärmemengen abgebend, transformiert der Großtransformator den Strom für die Überlandleitung.',
        logicalSubject: 'der Großtransformator',
        explicitMainSubject: 'der Großtransformator',
        domain: CommunicativeDomain.renewableEnergyGrid,
        arabicTranslation:
            'مصدراً اهتزازاً خافتاً وباعثاً كميات معتبرة من الحرارة، يقوم المحول الضخم بتحويل الكهرباء لخطوط النقل الكهربائي البعيدة.',
        grammaticalAnalysisArabic:
            'عطف اسمي فاعل متزامنين (vibrierend und abgebend): المحول الكهربائي هو فاعل الاهتزاز والانبعاث وهو فاعل التحويل الكهربائي.',
        grammaticalAnalysisGerman:
            'Koordinierte Partizip-I-Gruppe als modales Begleitadverbial. Völlige Identität mit dem Subjekt "der Großtransformator".',
        clausalParaphraseSubordinate:
            'Paraphrase: "Während er leise vibriert und Wärme abgibt, transformiert der Großtransformator..."',
        stylisticDiagnosticRule:
            'Rhythmisch exzellente Verdichtung technischer Begleitprozesse.',
      ),
    );

    // 16. Partizip II Congruent (Passivische Zustandsschilderung) - Civil Infrastructure
    _catalog.add(
      const ParticipialClauseModel(
        id: 'PART-CONG-P2-PASS-16',
        participialType: ParticipialType.participleTwoPrior,
        temporalRelation: TemporalRelation.anterior,
        equivalenceStatus: SubjectEquivalenceStatus.congruentSubject,
        participialPhrase: 'Streng nach den Vorgaben der europäischen Erdbeben-Bauwerksnorm errichtet',
        governingMainClause: 'überstand der Spannbetonturm die simulierten Erschütterungen auf dem Rütteltisch schadlos',
        fullCombinedSentence:
            'Streng nach den Vorgaben der europäischen Erdbeben-Bauwerksnorm errichtet, überstand der Spannbetonturm die simulierten Erschütterungen auf dem Rütteltisch schadlos.',
        logicalSubject: 'der Spannbetonturm (wurde errichtet)',
        explicitMainSubject: 'der Spannbetonturm',
        domain: CommunicativeDomain.civilInfrastructure,
        arabicTranslation:
            'بعد أن شُيِّد بدقة متناهية وفق معايير الكود الأوروبي لمقاومة الزلازل، اجتاز برج الخرسانة مسبقة الإجهاد الاهتزازات المحاكاة على طاولة الاختبار دون أي ضرر.',
        grammaticalAnalysisArabic:
            'شبه جملة Partizip II تفيد البناء للمجهول المكتمل والأسبقية: برج الخرسانة هو الذي شُيِّد وهو الذي اجتاز الاختبار بسلام، محققاً أرقى درجات التماسك اللغوي.',
        grammaticalAnalysisGerman:
            'Vorangestellte Partizip-II-Fügung mit Kausalsinn. Subjekt des Hauptsatzes ("der Spannbetonturm") ist zugleich logisches Patiens der Errichtung.',
        clausalParaphraseSubordinate:
            'Paraphrase: "Da er streng nach den Vorgaben errichtet worden war, überstand der Spannbetonturm..."',
        stylisticDiagnosticRule:
            'Höchstes syntaktisches Niveau im Bauingenieurwesen und in der Zulassungsdokumentation.',
      ),
    );
  }

  /// Evaluates an input participial or infinitive construction for logical subject congruence and dangling modifiers.
  ParticipialValidationReport validateConstruction({
    required ParticipialType type,
    required String explicitMainSubject,
    required String logicalAgentOfPhrase,
    required bool hasOwnSubjectNoun,
  }) {
    final issues = <String>[];
    final recommendations = <String>[];

    final isSameSubject = explicitMainSubject.trim().toLowerCase() == logicalAgentOfPhrase.trim().toLowerCase();

    if (!isSameSubject) {
      if (type == ParticipialType.absoluteParticipialConstruction && hasOwnSubjectNoun) {
        // Valid absolute construction
      } else {
        issues.add(
          'Schwerer stilistischer Verstoß: Falscher Bezug / Dangling Modifier (Partizip-Anakoluth). Das implizite Subjekt der Partizipial-/Infinitivgruppe ("$logicalAgentOfPhrase") stimmt nicht mit dem grammatischen Subjekt des Hauptsatzes ("$explicitMainSubject") überein.',
        );
        recommendations.add(
          'Formen Sie den Satz in einen vollständigen Nebensatz um (z. B. mit "nachdem", "als", "da" oder "damit").',
        );
        recommendations.add(
          'Alternativ: Ändern Sie das Subjekt des Hauptsatzes so, dass es identisch mit dem Handelnden der Phrase ist.',
        );
      }
    }

    final isValid = issues.isEmpty;
    final verdict = isValid
        ? 'التركيب النحوي لشبه الجملة الوصفية/المصدرية متطابق تماماً في الفاعل والزمن مع المعايير الفصيحة العليا (C1-C2).'
        : 'تم رصد خلل في تطابق الفاعل النحوي (Dangling Modifier / Anakoluth)؛ الفاعل الدلالي لشبه الجملة منفصل عن فاعل الجملة الرئيسية.';

    return ParticipialValidationReport(
      isValid: isValid,
      isSubjectCongruent: isSameSubject || (type == ParticipialType.absoluteParticipialConstruction && hasOwnSubjectNoun),
      avoidsDanglingModifier: isValid,
      issues: issues,
      recommendations: recommendations,
      arabicDiagnosticVerdict: verdict,
    );
  }

  List<ParticipialClauseModel> filterByType(ParticipialType type) {
    return _catalog.where((item) => item.participialType == type).toList();
  }

  List<ParticipialClauseModel> filterByStatus(SubjectEquivalenceStatus status) {
    return _catalog.where((item) => item.equivalenceStatus == status).toList();
  }

  List<ParticipialClauseModel> filterByDomain(CommunicativeDomain domain) {
    return _catalog.where((item) => item.domain == domain).toList();
  }
}
