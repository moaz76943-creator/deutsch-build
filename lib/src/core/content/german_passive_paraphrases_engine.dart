import 'dart:collection';

/// Classification of German passive paraphrases and decausative alternations.
enum PassiveParaphraseType {
  sichLassenPlusInfinitive(
    'sich lassen + Infinitiv (kann getan werden)',
    'صيغة الانعكاس الممكن (sich lassen + المصدر: يمكن إنجازه تقنياً)',
    'Paraphrasiert das Passiv mit Modalverb "können": Das Subjekt ist patientiv; nur bei transitiven Verben zulässig: "Die Kennlinie lässt sich kalibrieren" = kann kalibriert werden.',
  ),
  seinPlusZuPlusInfinitive(
    'sein + zu + Infinitiv (muss / kann getan werden)',
    'صيغة الكينونة المصدرية (sein + zu + المصدر: يجب حتماً أو يمكن إنجازه)',
    'Drückt je nach Kontext zwingende Notwendigkeit (muss) oder Machbarkeit (kann) aus: "Die Schrauben sind nachzuziehen" = müssen nachgezogen werden.',
  ),
  suffixalAdjectivePotential(
    'Suffix-Adjektive (-bar, -lich, -abel: passive Eignung)',
    'الصفات المشتقة الدالة على القابلية (-bar / -lich: قابل للإنجاز والقياس)',
    'Leitet aus transitiven Verbstämmen adjektivische Attribute ab: "messbar" (kann gemessen werden), "vermeidbar" (kann vermieden werden).',
  ),
  passiveFunktionsverbgefuege(
    'Funktionsverbgefüge mit Passivbedeutung (zur Anwendung kommen, etc.)',
    'تراكيب الأفعال الوظيفية ذات الدلالة المبنية للمجهول (قيد التطبيق / تحت المراقبة)',
    'Ersetzt passivische Verben durch präpositionale Nomen-Verb-Verbindungen: "zur Anwendung kommen" = angewendet werden, "unter Beobachtung stehen" = beobachtet werden.',
  ),
  decausativeMediopassive(
    'Dekausatives Mediopassiv (sich-Verben: automatische Selbstwirkung)',
    'الصيغة شبه المبنية للمجهول الدالة على الحركة الذاتية التلقائية للمنظومة',
    'Stellt das System oder Bauteil so dar, als vollziehe es den Vorgang von selbst: "Das Überdruckventil öffnet sich bei 6 bar" = wird selbsttätig geöffnet.',
  );

  final String deTitle;
  final String arTitle;
  final String grammaticalDefinition;
  const PassiveParaphraseType(this.deTitle, this.arTitle, this.grammaticalDefinition);
}

/// Modal nuance conveyed by the passive paraphrase.
enum ParaphraseModalNuance {
  purePossibility('Reine Machbarkeit / Potenzialität (können)', 'إمكانية تقنية وقابلية للتنفيذ'),
  categoricalNecessity('Kategorische Pflicht / Vorschrift (müssen / sollen)', 'وجوب قطعي وإلزام معياري حتمي'),
  conditionalFeasibility('Konditionale Realisierbarkeit (nur unter Auflagen machbar)', 'إمكانية مشروطة بتحقق معايير محددة'),
  processualStateTransition('Prozessualer Zustandseintritt (Passivische Dynamik)', 'دخول في حالة تشغيلية خاضعة للمراقبة');

  final String de;
  final String ar;
  const ParaphraseModalNuance(this.de, this.ar);
}

/// Technical and engineering communicative domains free of legal/medical liability.
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

/// Structural model of a German passive paraphrase occurrence.
class PassiveParaphraseModel {
  final String id;
  final PassiveParaphraseType paraphraseType;
  final ParaphraseModalNuance modalNuance;
  final CommunicativeDomain domain;
  final String paraphraseExpression;
  final String canonicalPassiveEquivalent;
  final String fullGermanSentence;
  final String subjectAgentSuppressionExplanationGerman;
  final String subjectAgentSuppressionExplanationArabic;
  final String modalShiftNuance;
  final bool isTransitiveOrigin;

  const PassiveParaphraseModel({
    required this.id,
    required this.paraphraseType,
    required this.modalNuance,
    required this.domain,
    required this.paraphraseExpression,
    required this.canonicalPassiveEquivalent,
    required this.fullGermanSentence,
    required this.subjectAgentSuppressionExplanationGerman,
    required this.subjectAgentSuppressionExplanationArabic,
    required this.modalShiftNuance,
    this.isTransitiveOrigin = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'paraphraseType': paraphraseType.name,
    'modalNuance': modalNuance.name,
    'domain': domain.name,
    'paraphraseExpression': paraphraseExpression,
    'canonicalPassiveEquivalent': canonicalPassiveEquivalent,
    'fullGermanSentence': fullGermanSentence,
    'subjectAgentSuppressionExplanationGerman': subjectAgentSuppressionExplanationGerman,
    'subjectAgentSuppressionExplanationArabic': subjectAgentSuppressionExplanationArabic,
    'modalShiftNuance': modalShiftNuance,
    'isTransitiveOrigin': isTransitiveOrigin,
  };
}

/// Validation result for passive paraphrase syntax and transitivity.
class ParaphraseValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<String> stylisticNotes;

  const ParaphraseValidationResult({
    required this.isValid,
    required this.issues,
    required this.stylisticNotes,
  });
}

/// Core Engine managing German Passive Paraphrases & Decausative Alternations.
class GermanPassiveParaphrasesEngine {
  final List<PassiveParaphraseModel> _catalog = [];

  GermanPassiveParaphrasesEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<PassiveParaphraseModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    _catalog.addAll([
      // 1. sich lassen + Infinitiv (Possibility)
      const PassiveParaphraseModel(
        id: 'PASS-4963-01',
        paraphraseType: PassiveParaphraseType.sichLassenPlusInfinitive,
        modalNuance: ParaphraseModalNuance.purePossibility,
        domain: CommunicativeDomain.renewableEnergyGrid,
        paraphraseExpression: 'lässt sich präzise regeln',
        canonicalPassiveEquivalent: 'kann präzise geregelt werden',
        fullGermanSentence:
            'Die Wirkleistungseinspeisung der Photovoltaik-Freiflächenanlage lässt sich über den zentralen Wechselrichter stufenlos regeln.',
        subjectAgentSuppressionExplanationGerman:
            'Der handelnde Operator tritt vollständig in den Hintergrund; die technische Machbarkeit der Regelung wird hervorgehoben.',
        subjectAgentSuppressionExplanationArabic:
            'تجريد الفاعل البشري تماماً والتركيز على قابلية القدرة الفعالة للضبط السلس عبر المحول المركزي.',
        modalShiftNuance: 'Ausdruck technischer Regelbarkeit (Möglichkeit: "kann geregelt werden").',
        isTransitiveOrigin: true,
      ),
      // 2. sein + zu + Infinitiv (Categorical Necessity)
      const PassiveParaphraseModel(
        id: 'PASS-4963-02',
        paraphraseType: PassiveParaphraseType.seinPlusZuPlusInfinitive,
        modalNuance: ParaphraseModalNuance.categoricalNecessity,
        domain: CommunicativeDomain.aerospaceAndAviation,
        paraphraseExpression: 'sind zwingend zu protokollieren',
        canonicalPassiveEquivalent: 'müssen zwingend protokolliert werden',
        fullGermanSentence:
            'Sämtliche Drehmomente der Triebwerksaufhängung sind nach der Montage zwingend im Prüfbuch zu protokollieren.',
        subjectAgentSuppressionExplanationGerman:
            'Formale Dienstvorschrift: "sein + zu" drückt hier eine unverhandelbare normative Pflicht (müssen) aus.',
        subjectAgentSuppressionExplanationArabic:
            'صيغة إلزام معيارية: عزم دوران تعليق المحرك يجب توثيقه حتماً في سجل الفحص عقب التركيب.',
        modalShiftNuance: 'Kategorische Notwendigkeit gestützt durch Signaladverb "zwingend" (muss protokolliert werden).',
        isTransitiveOrigin: true,
      ),
      // 3. Adjektiv auf -bar (Potentiality)
      const PassiveParaphraseModel(
        id: 'PASS-4963-03',
        paraphraseType: PassiveParaphraseType.suffixalAdjectivePotential,
        modalNuance: ParaphraseModalNuance.purePossibility,
        domain: CommunicativeDomain.industrialRobotics,
        paraphraseExpression: 'ist modular erweiterbar',
        canonicalPassiveEquivalent: 'kann modular erweitert werden',
        fullGermanSentence:
            'Die flexible Fertigungszelle ist durch zusätzliche optische Prüfstationen modular erweiterbar.',
        subjectAgentSuppressionExplanationGerman:
            'Adjektivisches Passiv-Äquivalent auf "-bar": Beschreibt die inhärente Systemeigenschaft zur Aufrüstung.',
        subjectAgentSuppressionExplanationArabic:
            'صفة قابلية مشتقة (-bar): خلية التصنيع المرنة قابلة للتوسيع معيارياً بإضافة محطات فحص بصرية.',
        modalShiftNuance: 'Eigenschaftspotenzial: Das System besitzt die Fähigkeit zur Erweiterung.',
        isTransitiveOrigin: true,
      ),
      // 4. Funktionsverbgefüge (zur Anwendung kommen)
      const PassiveParaphraseModel(
        id: 'PASS-4963-04',
        paraphraseType: PassiveParaphraseType.passiveFunktionsverbgefuege,
        modalNuance: ParaphraseModalNuance.processualStateTransition,
        domain: CommunicativeDomain.materialScience,
        paraphraseExpression: 'kommt ein neuartiges PVD-Verfahren zur Anwendung',
        canonicalPassiveEquivalent: 'wird ein neuartiges PVD-Verfahren angewendet',
        fullGermanSentence:
            'Zur Veredelung der Titan-Aluminium-Beschichtung kommt ein neuartiges PVD-Verfahren zur Anwendung.',
        subjectAgentSuppressionExplanationGerman:
            'Gehobener Fachstil: "zur Anwendung kommen" ersetzt das schlichte Vorgangspassiv "wird angewendet".',
        subjectAgentSuppressionExplanationArabic:
            'تركيب فعل وظيفي راقٍ: تطبيق تقنية الترسيب الفيزيائي للبخار (PVD) لمعالجة طلاء التيتانيوم.',
        modalShiftNuance: 'Prozessualer Übergang in den aktiven Einsatz ohne Nennung des Labormitarbeiters.',
        isTransitiveOrigin: true,
      ),
      // 5. Dekausatives Mediopassiv (sich schließen)
      const PassiveParaphraseModel(
        id: 'PASS-4963-05',
        paraphraseType: PassiveParaphraseType.decausativeMediopassive,
        modalNuance: ParaphraseModalNuance.processualStateTransition,
        domain: CommunicativeDomain.civilInfrastructure,
        paraphraseExpression: 'schließt sich federvorgespannt automatisch',
        canonicalPassiveEquivalent: 'wird federvorgespannt automatisch geschlossen',
        fullGermanSentence:
            'Die Brandschutzklappe im Lüftungskanal schließt sich bei einer Auslösetemperatur von 72 Grad federvorgespannt automatisch.',
        subjectAgentSuppressionExplanationGerman:
            'Mediopassiv: Das mechanische Bauteil agiert syntaktisch als Subjekt und schließt die Einwirkung eines Bedieners aus.',
        subjectAgentSuppressionExplanationArabic:
            'صيغة ذاتية شبه مبنية للمجهول: مصراع الحريق يغلق تلقائياً بفعل الزنبرك المشدود عند بلوغ 72 درجة.',
        modalShiftNuance: 'Autonomer physikalischer Ablauf des Auslösemechanismus.',
        isTransitiveOrigin: true,
      ),
      // 6. sein + zu + Infinitiv (Feasibility / Possibility with kaum)
      const PassiveParaphraseModel(
        id: 'PASS-4963-06',
        paraphraseType: PassiveParaphraseType.seinPlusZuPlusInfinitive,
        modalNuance: ParaphraseModalNuance.conditionalFeasibility,
        domain: CommunicativeDomain.maritimeLogistics,
        paraphraseExpression: 'ist im dichten Seenebel kaum auszumachen',
        canonicalPassiveEquivalent: 'kann im dichten Seenebel kaum ausgemacht werden',
        fullGermanSentence:
            'Die unbeleuchtete Fahrwassertonne ist im dichten Seenebel mit bloßem Auge kaum auszumachen.',
        subjectAgentSuppressionExplanationGerman:
            'Möglichkeitsbedeutung von "sein + zu": Das einschränkende Adverb "kaum" schaltet die Semantik von Pflicht auf Unmöglichkeit um.',
        subjectAgentSuppressionExplanationArabic:
            'صيغة إمكانية مقيدة بظرف النفي النسبي: عوامة الممر الملاحي تكاد لا ترى بالعين المجردة في الضباب الكثيف.',
        modalShiftNuance: 'Eingeschränkte optische Wahrnehmbarkeit (kann kaum erkannt werden).',
        isTransitiveOrigin: true,
      ),
      // 7. sich lassen + Infinitiv (Optimization Potential)
      const PassiveParaphraseModel(
        id: 'PASS-4963-07',
        paraphraseType: PassiveParaphraseType.sichLassenPlusInfinitive,
        modalNuance: ParaphraseModalNuance.purePossibility,
        domain: CommunicativeDomain.aerospaceAndAviation,
        paraphraseExpression: 'lässt sich um 12% reduzieren',
        canonicalPassiveEquivalent: 'kann um 12% reduziert werden',
        fullGermanSentence:
            'Der aerodynamische induzierte Widerstand lässt sich durch neuartige Winglet-Geometrien um 12% reduzieren.',
        subjectAgentSuppressionExplanationGerman:
            'Ingenieurtechnische Potenzialaussage: Schiebt den aerodynamischen Effekt in den syntaktischen Mittelpunkt.',
        subjectAgentSuppressionExplanationArabic:
            'إمكانية تحسين هندسي: تقليص مقاومة الهواء المستحثة بنسبة 12% بفضل جنيحات الأجنحة المبتكرة.',
        modalShiftNuance: 'Rechnerisch nachgewiesene Optimierungsmöglichkeit.',
        isTransitiveOrigin: true,
      ),
      // 8. Funktionsverbgefüge (unter Beobachtung stehen)
      const PassiveParaphraseModel(
        id: 'PASS-4963-08',
        paraphraseType: PassiveParaphraseType.passiveFunktionsverbgefuege,
        modalNuance: ParaphraseModalNuance.processualStateTransition,
        domain: CommunicativeDomain.civilInfrastructure,
        paraphraseExpression: 'steht unter kontinuierlicher geodätischer Beobachtung',
        canonicalPassiveEquivalent: 'wird kontinuierlich geodätisch beobachtet',
        fullGermanSentence:
            'Der geologisch instabile Hang über der Eisenbahntrasse steht unter kontinuierlicher geodätischer Beobachtung.',
        subjectAgentSuppressionExplanationGerman:
            'Funktionsverbgefüge mit "stehen": Drückt einen dauerhaften passiven Zustand der Überwachung aus.',
        subjectAgentSuppressionExplanationArabic:
            'تركيب فعلي وظيفي دال على حالة مستقرة: المنحدر الجيولوجي غير المستقر يقع تحت المراقبة المساحية المستمرة.',
        modalShiftNuance: 'Dauerzustand der messtechnischen Erfassung.',
        isTransitiveOrigin: true,
      ),
      // 9. Adjektiv auf -lich (Requirement / Inherent Quality)
      const PassiveParaphraseModel(
        id: 'PASS-4963-09',
        paraphraseType: PassiveParaphraseType.suffixalAdjectivePotential,
        modalNuance: ParaphraseModalNuance.purePossibility,
        domain: CommunicativeDomain.materialScience,
        paraphraseExpression: 'ist in wässriger Lösung leicht löslich',
        canonicalPassiveEquivalent: 'kann in wässriger Lösung leicht gelöst werden',
        fullGermanSentence:
            'Das als Bindemittel eingesetzte Polymer ist in wässriger Lösung bei Raumtemperatur leicht löslich.',
        subjectAgentSuppressionExplanationGerman:
            'Chemische Eigenschaft: Das Suffix "-lich" drückt die passive Löslichkeit ohne Reagenzienzusatz aus.',
        subjectAgentSuppressionExplanationArabic:
            'صفة قابلية مشتقة (-lich): البوليمر المستخدم كرابط قابل للذوبان بسهولة في المحاليل المائية.',
        modalShiftNuance: 'Inhärente chemische Reaktionsfähigkeit.',
        isTransitiveOrigin: true,
      ),
      // 10. sein + zu + Infinitiv (DIN Norm Necessity)
      const PassiveParaphraseModel(
        id: 'PASS-4963-10',
        paraphraseType: PassiveParaphraseType.seinPlusZuPlusInfinitive,
        modalNuance: ParaphraseModalNuance.categoricalNecessity,
        domain: CommunicativeDomain.renewableEnergyGrid,
        paraphraseExpression: 'ist nach DIN EN 62305 auszuführen',
        canonicalPassiveEquivalent: 'muss nach DIN EN 62305 ausgeführt werden',
        fullGermanSentence:
            'Der äußere Blitzschutz der Windenergieanlage ist strikt nach DIN EN 62305 auszuführen.',
        subjectAgentSuppressionExplanationGerman:
            'Normative Bauvorschrift: "ist auszuführen" = "muss ausgeführt werden".',
        subjectAgentSuppressionArabic:
            'صيغة وجوب معيارية: مانعة الصواعق الخارجية لتوربين الرياح يجب تنفيذها حصراً وفق معايير DIN EN 62305.',
        modalShiftNuance: 'Verbindliche Ausführungsnorm.',
        isTransitiveOrigin: true,
      ),
      // 11. Dekausatives Mediopassiv (sich entladen)
      const PassiveParaphraseModel(
        id: 'PASS-4963-11',
        paraphraseType: PassiveParaphraseType.decausativeMediopassive,
        modalNuance: ParaphraseModalNuance.processualStateTransition,
        domain: CommunicativeDomain.industrialRobotics,
        paraphraseExpression: 'entlädt sich über interne Schutzwiderstände',
        canonicalPassiveEquivalent: 'wird über interne Schutzwiderstände entladen',
        fullGermanSentence:
            'Der Zwischenkreiskondensator des Servoantriebs entlädt sich nach Abschaltung über interne Schutzwiderstände.',
        subjectAgentSuppressionExplanationGerman:
            'Mediopassive Entladung: Automatischer Sicherheitsmechanismus schützt Wartungstechniker.',
        subjectAgentSuppressionExplanationArabic:
            'تفريغ ذاتي آمن: مكثف الدائرة الوسيطة يفرغ شحنته تلقائياً عبر مقاومات الحماية الداخلية فور الفصل.',
        modalShiftNuance: 'Schutzfunktionale Eigendynamik der elektrischen Schaltung.',
        isTransitiveOrigin: true,
      ),
      // 12. Funktionsverbgefüge (zur Durchführung gelangen)
      const PassiveParaphraseModel(
        id: 'PASS-4963-12',
        paraphraseType: PassiveParaphraseType.passiveFunktionsverbgefuege,
        modalNuance: ParaphraseModalNuance.processualStateTransition,
        domain: CommunicativeDomain.maritimeLogistics,
        paraphraseExpression: 'gelangt im Trockendock zur Durchführung',
        canonicalPassiveEquivalent: 'wird im Trockendock durchgeführt',
        fullGermanSentence:
            'Die Rumpfkonservierung des Großcontainerschiffs gelangt turnusgemäß im Trockendock zur Durchführung.',
        subjectAgentSuppressionExplanationGerman:
            'Amts- und Werftdeutsch: "zur Durchführung gelangen" betont den formalen Prozesscharakter.',
        subjectAgentSuppressionExplanationArabic:
            'أسلوب إداري ملاحي رفيع: صيانة طلاء هيكل سفينة الحاويات تدخل حيز التنفيذ دورياً بالحوض الجاف.',
        modalShiftNuance: 'Planmäßige Realisierung eines Instandhaltungsintervalls.',
        isTransitiveOrigin: true,
      ),
      // 13. sich lassen + Infinitiv (Verification Feasibility)
      const PassiveParaphraseModel(
        id: 'PASS-4963-13',
        paraphraseType: PassiveParaphraseType.sichLassenPlusInfinitive,
        modalNuance: ParaphraseModalNuance.purePossibility,
        domain: CommunicativeDomain.materialScience,
        paraphraseExpression: 'lässt sich zerstörungsfrei nachweisen',
        canonicalPassiveEquivalent: 'kann zerstörungsfrei nachgewiesen werden',
        fullGermanSentence:
            'Die Delamination innerhalb des Kohlenstofffaserlaminats lässt sich mittels Ultraschall-Phased-Array zerstörungsfrei nachweisen.',
        subjectAgentSuppressionExplanationGerman:
            'Prüftechnisches Statement: Betont die Zerstörungsfreiheit der Prüfmethode.',
        subjectAgentSuppressionExplanationArabic:
            'إمكانية إثبات غير إتلافي: انفصال طبقات ألياف الكربون يمكن إثباته مخبرياً عبر مصفوفة الموجات فوق الصوتية.',
        modalShiftNuance: 'Analytische Machbarkeit (kann nachgewiesen werden).',
        isTransitiveOrigin: true,
      ),
      // 14. Adjektiv auf -abel / -ibel (Technical Standard)
      const PassiveParaphraseModel(
        id: 'PASS-4963-14',
        paraphraseType: PassiveParaphraseType.suffixalAdjectivePotential,
        modalNuance: ParaphraseModalNuance.purePossibility,
        domain: CommunicativeDomain.industrialRobotics,
        paraphraseExpression: 'ist uneingeschränkt kompatibel',
        canonicalPassiveEquivalent: 'kann uneingeschränkt kombiniert / integriert werden',
        fullGermanSentence:
            'Die Feldbusschnittstelle des Greifarms ist mit allen gängigen Profinet-Controllern uneingeschränkt kompatibel.',
        subjectAgentSuppressionExplanationGerman:
            'Lateinisches Lehnadjektiv auf "-ibel": Technischer Interoperabilitätsstandard.',
        subjectAgentSuppressionExplanationArabic:
            'صفة توافقية قياسية (-ibel): منفذ ناقل المجال لمقبض الروبوت متوافق كلياً مع وحدات تحكم Profinet.',
        modalShiftNuance: 'Inhärente Protokollkompatibilität.',
        isTransitiveOrigin: true,
      ),
      // 15. sein + zu + Infinitiv (Possibility with Adverb)
      const PassiveParaphraseModel(
        id: 'PASS-4963-15',
        paraphraseType: PassiveParaphraseType.seinPlusZuPlusInfinitive,
        modalNuance: ParaphraseModalNuance.purePossibility,
        domain: CommunicativeDomain.civilInfrastructure,
        paraphraseExpression: 'sind mit herkömmlichen Werkzeugen leicht zu lösen',
        canonicalPassiveEquivalent: 'können mit herkömmlichen Werkzeugen leicht gelöst werden',
        fullGermanSentence:
            'Die Montagebolzen der provisorischen Brückenstütze sind nach Entlastung mit herkömmlichen Werkzeugen leicht zu lösen.',
        subjectAgentSuppressionExplanationGerman:
            'Möglichkeitsbedeutung durch "leicht": Keine Spezialwerkzeuge erforderlich.',
        subjectAgentSuppressionExplanationArabic:
            'صيغة إمكانية ميسرة: مسامير تثبيت دعامة الجسر المؤقتة يمكن فكها بسهولة باستخدام عدد يدوية تقليدية.',
        modalShiftNuance: 'Einfache Lösbarkeit nach hydraulischer Entlastung.',
        isTransitiveOrigin: true,
      ),
      // 16. Funktionsverbgefüge (eine Lösung finden)
      const PassiveParaphraseModel(
        id: 'PASS-4963-16',
        paraphraseType: PassiveParaphraseType.passiveFunktionsverbgefuege,
        modalNuance: ParaphraseModalNuance.processualStateTransition,
        domain: CommunicativeDomain.aerospaceAndAviation,
        paraphraseExpression: 'fand eine konstruktive Lösung',
        canonicalPassiveEquivalent: 'wurde konstruktiv gelöst',
        fullGermanSentence:
            'Das Problem der Grenzschichtablösung am Tragflächenübergang fand durch Wirbelgeneratoren eine konstruktive Lösung.',
        subjectAgentSuppressionExplanationGerman:
            'Funktionsverbgefüge mit passivischer Konnotation: "eine Lösung finden" = erfolgreich gelöst werden.',
        subjectAgentSuppressionExplanationArabic:
            'تركيب وظيفي ذو دلالة إنجازية مبنية للمجهول: معضلة انفصال الطبقة الجدارية حُلّت بتثبيت مولدات الدوامات.',
        modalShiftNuance: 'Vollendete Problemlösung im Flugzeugentwurf.',
        isTransitiveOrigin: true,
      ),
    ]);
  }

  List<PassiveParaphraseModel> getByType(PassiveParaphraseType type) =>
      _catalog.where((p) => p.paraphraseType == type).toList();

  List<PassiveParaphraseModel> getByModalNuance(ParaphraseModalNuance nuance) =>
      _catalog.where((p) => p.modalNuance == nuance).toList();

  List<PassiveParaphraseModel> getByDomain(CommunicativeDomain domain) =>
      _catalog.where((p) => p.domain == domain).toList();

  /// Validates transitivity constraints and modal disambiguation for passive paraphrases.
  ParaphraseValidationResult validatePassiveParaphrase({
    required PassiveParaphraseType type,
    required bool isVerbTransitive,
    required bool containsZuParticle,
    required ParaphraseModalNuance assertedNuance,
  }) {
    final List<String> issues = [];
    final List<String> notes = [];

    // Rule 1: "sich lassen" REQUIRES transitive verbs with accusative object
    if (type == PassiveParaphraseType.sichLassenPlusInfinitive) {
      if (!isVerbTransitive) {
        issues.add(
            'Valenzfehler: Die Passiversatzform "sich lassen + Infinitiv" ist ausschließlich mit transitiven Verben bildbar (Akkusativobjekt wird zum Subjekt).');
      } else {
        notes.add('Valenz konform: Transitives Basisverb erlaubt reguläre sich-lassen-Bildung.');
      }
    }

    // Rule 2: "sein + zu" MUST contain the particle "zu"
    if (type == PassiveParaphraseType.seinPlusZuPlusInfinitive) {
      if (!containsZuParticle) {
        issues.add(
            'Morphosyntax-Fehler: Die Konstruktion "sein + zu + Infinitiv" erfordert zwingend das Partikel "zu" vor dem Infinitiv (bzw. eingeschoben bei trennbaren Verben).');
      } else {
        notes.add('Syntax normgerecht: "zu"-Partikel vorschriftsmäßig eingebunden.');
      }
    }

    // Rule 3: Modal disambiguation for "sein + zu"
    if (type == PassiveParaphraseType.seinPlusZuPlusInfinitive) {
      if (assertedNuance == ParaphraseModalNuance.categoricalNecessity) {
        notes.add('Modale Lesart: Notwendigkeit ("muss getan werden") normativ verankert.');
      } else if (assertedNuance == ParaphraseModalNuance.purePossibility ||
                 assertedNuance == ParaphraseModalNuance.conditionalFeasibility) {
        notes.add('Modale Lesart: Machbarkeit ("kann getan werden") durch Adverbialmodifikation aktiviert.');
      }
    }

    return ParaphraseValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      stylisticNotes: notes,
    );
  }

  Map<String, dynamic> generateTelemetrySnapshot() {
    return {
      'totalExemplars': _catalog.length,
      'typeDistribution': {
        for (var t in PassiveParaphraseType.values)
          t.name: _catalog.where((p) => p.paraphraseType == t).length,
      },
      'nuanceDistribution': {
        for (var n in ParaphraseModalNuance.values)
          n.name: _catalog.where((p) => p.modalNuance == n).length,
      },
      'domainDistribution': {
        for (var d in CommunicativeDomain.values)
          d.name: _catalog.where((p) => p.domain == d).length,
      },
      'cefrLevel': 'CEFR C1-C2 Masterclass Passive Paraphrases',
      'engineVersion': '1.0.0+subsystem1797',
    };
  }
}
