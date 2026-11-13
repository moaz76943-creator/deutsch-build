import 'dart:collection';

/// Classification of extended participial attributes and gerundives.
enum ParticipialConstructionType {
  gerundiveNecessity(
    'Gerundiv der Notwendigkeit (zu + Partizip I: muss/soll getan werden)',
    'صيغة الإلزام المصدرية الوصفية (zu + اسم الفاعل: يجب وينبغي إنجازه حتماً)',
    'Drückt eine zwingende technische Vorschrift im Passiv aus: "die vor dem Test zu kalibrierenden Sensoren" = die Sensoren, die kalibriert werden müssen.',
  ),
  gerundivePossibility(
    'Gerundiv der Möglichkeit (zu + Partizip I + Adverb: kann getan werden)',
    'صيغة الإمكانية والقدرة الوصفية (zu + اسم الفاعل مع ظرف إمكانية: يمكن إنجازه)',
    'Signalisiert machbare technische Prozesse (oft mit kaum, schwer, leicht): "das schwer zu detektierende Leck" = das Leck, das schwer detektiert werden kann.',
  ),
  extendedPartizipIActiveSimultaneous(
    'Erweitertes Partizip I (Aktiv & Gleichzeitigkeit: ablaufender Vorgang)',
    'اسم الفاعل الممتد (المبني للمعلوم والتزامن: حدث تقني متزامن قيد الحدوث)',
    'Beschreibt eine gleichzeitig aktive Bewegung oder einen Systemzustand: "die kontinuierlich rotierende Welle" = die Welle, die kontinuierlich rotiert.',
  ),
  extendedPartizipIIPassivePerfective(
    'Erweitertes Partizip II (Passiv & Vollendung / Zustand)',
    'اسم المفعول الممتد (المبني للمجهول والتمام: حالة مكتملة ومستقرة ناتجة عن معالجة سابقة)',
    'Beschreibt ein vollendetes Ergebnis einer Einwirkung: "die im Vakuumofen gehärteten Titanbauteile" = die Bauteile, die gehärtet worden sind.',
  );

  final String deTitle;
  final String arTitle;
  final String grammaticalDefinition;
  const ParticipialConstructionType(this.deTitle, this.arTitle, this.grammaticalDefinition);
}

/// Case and gender alignment of the attributive participle.
enum ParticipialCaseAndGender {
  nominativeMasculine('Nominativ Maskulin (-er / -e)', 'مرفوع مذكر'),
  nominativeFeminine('Nominativ Feminin (-e)', 'مرفوع مؤنث'),
  nominativeNeuter('Nominativ Neutrum (-es / -e)', 'مرفوع محايد'),
  nominativePlural('Nominativ Plural (-en / -e)', 'مرفوع جمع'),
  accusativeMasculine('Akkusativ Maskulin (-en)', 'منصوب مذكر'),
  accusativeFeminine('Akkusativ Feminin (-e)', 'منصوب مؤنث'),
  accusativeNeuter('Akkusativ Neutrum (-es / -e)', 'منصوب محايد'),
  accusativePlural('Akkusativ Plural (-en / -e)', 'منصوب جمع'),
  dativeMasculine('Dativ Maskulin (-en)', 'مجرور مذكر'),
  dativeFeminine('Dativ Feminin (-en)', 'مجرور مؤنث'),
  dativeNeuter('Dativ Neutrum (-en)', 'مجرور محايد'),
  dativePlural('Dativ Plural (-en)', 'مجرور جمع'),
  genitiveMasculine('Genitiv Maskulin (-en)', 'مضاف إليه مذكر'),
  genitiveFeminine('Genitiv Feminin (-en)', 'مضاف إليه مؤنث'),
  genitiveNeuter('Genitiv Neutrum (-en)', 'مضاف إليه محايد'),
  genitivePlural('Genitiv Plural (-en)', 'مضاف إليه جمع');

  final String de;
  final String ar;
  const ParticipialCaseAndGender(this.de, this.ar);
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

/// Structural model of an extended participial attribute or gerundive phrase.
class ParticipialAttributeModel {
  final String id;
  final ParticipialConstructionType constructionType;
  final ParticipialCaseAndGender caseAndGender;
  final CommunicativeDomain domain;
  final String extendedAttributePhrase;
  final String headNoun;
  final String fullGermanSentence;
  final String relativeClauseTransformation;
  final String modalParaphrase;
  final String embeddedComplements;
  final String pragmaticTechnicalContextGerman;
  final String pragmaticTechnicalContextArabic;
  final bool isTransitiveVerb;

  const ParticipialAttributeModel({
    required this.id,
    required this.constructionType,
    required this.caseAndGender,
    required this.domain,
    required this.extendedAttributePhrase,
    required this.headNoun,
    required this.fullGermanSentence,
    required this.relativeClauseTransformation,
    required this.modalParaphrase,
    required this.embeddedComplements,
    required this.pragmaticTechnicalContextGerman,
    required this.pragmaticTechnicalContextArabic,
    this.isTransitiveVerb = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'constructionType': constructionType.name,
    'caseAndGender': caseAndGender.name,
    'domain': domain.name,
    'extendedAttributePhrase': extendedAttributePhrase,
    'headNoun': headNoun,
    'fullGermanSentence': fullGermanSentence,
    'relativeClauseTransformation': relativeClauseTransformation,
    'modalParaphrase': modalParaphrase,
    'embeddedComplements': embeddedComplements,
    'pragmaticTechnicalContextGerman': pragmaticTechnicalContextGerman,
    'pragmaticTechnicalContextArabic': pragmaticTechnicalContextArabic,
    'isTransitiveVerb': isTransitiveVerb,
  };
}

/// Validation report for participial attributes and gerundives.
class ParticipialValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<String> syntacticNotes;

  const ParticipialValidationResult({
    required this.isValid,
    required this.issues,
    required this.syntacticNotes,
  });
}

/// Core Engine managing German Extended Participial Attributes & Gerundive.
class GermanParticipialAttributesGerundiveEngine {
  final List<ParticipialAttributeModel> _catalog = [];

  GermanParticipialAttributesGerundiveEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<ParticipialAttributeModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    _catalog.addAll([
      // 1. Gerundiv (Notwendigkeit, Plural Akkusativ)
      const ParticipialAttributeModel(
        id: 'PART-4961-01',
        constructionType: ParticipialConstructionType.gerundiveNecessity,
        caseAndGender: ParticipialCaseAndGender.accusativePlural,
        domain: CommunicativeDomain.renewableEnergyGrid,
        extendedAttributePhrase:
            'die vor der Netzsynchronisation zwingend zu überprüfenden',
        headNoun: 'Schutzrelais',
        fullGermanSentence:
            'Der Inbetriebsetzungsingenieur dokumentiert die vor der Netzsynchronisation zwingend zu überprüfenden Schutzrelais im Abnahmeprotokoll.',
        relativeClauseTransformation:
            'die Schutzrelais, die vor der Netzsynchronisation zwingend überprüft werden müssen',
        modalParaphrase: 'müssen überprüft werden (strikte Notwendigkeit)',
        embeddedComplements: 'vor der Netzsynchronisation (temporales PP), zwingend (modales Adverb)',
        pragmaticTechnicalContextGerman:
            'Verbindliche Prüfvorschrift: Gerundiv komprimiert eine normative Vorschrift in ein attributives Adjektiv.',
        pragmaticTechnicalContextArabic:
            'قاعدة فحص ملزمة: تكثيف صيغة الوجوب المبنية للمجهول (مرحلات الحماية التي يجب فحصها حتماً قبل ربط الشبكة).',
        isTransitiveVerb: true,
      ),
      // 2. Gerundiv (Möglichkeit, Maskulin Nominativ)
      const ParticipialAttributeModel(
        id: 'PART-4961-02',
        constructionType: ParticipialConstructionType.gerundivePossibility,
        caseAndGender: ParticipialCaseAndGender.nominativeMasculine,
        domain: CommunicativeDomain.materialScience,
        extendedAttributePhrase:
            'Der nur unter dem Rasterelektronenmikroskop zu identifizierende',
        headNoun: 'Mikroriss',
        fullGermanSentence:
            'Der nur unter dem Rasterelektronenmikroskop zu identifizierende Mikroriss beeinträchtigt die Schwingfestigkeit der Schaufelwurzel erheblich.',
        relativeClauseTransformation:
            'Der Mikroriss, der nur unter dem Rasterelektronenmikroskop identifiziert werden kann',
        modalParaphrase: 'kann identifiziert werden (technische Möglichkeit / Nachweisgrenze)',
        embeddedComplements: 'nur unter dem Rasterelektronenmikroskop (instrumentales PP)',
        pragmaticTechnicalContextGerman:
            'Gerundiv der Möglichkeit: Durch die Einschränkung "nur ... unter" wird die messtechnische Nachweisbarkeit ausgedrückt.',
        pragmaticTechnicalContextArabic:
            'صيغة إمكانية تقنية: الشق المجهري الذي لا يمكن رصده إلا بواسطة المجهر الإلكتروني الماسح.',
        isTransitiveVerb: true,
      ),
      // 3. Erweitertes Partizip I (Aktiv, Feminin Nominativ)
      const ParticipialAttributeModel(
        id: 'PART-4961-03',
        constructionType: ParticipialConstructionType.extendedPartizipIActiveSimultaneous,
        caseAndGender: ParticipialCaseAndGender.nominativeFeminine,
        domain: CommunicativeDomain.aerospaceAndAviation,
        extendedAttributePhrase:
            'Die mit über 14.000 Umdrehungen pro Minute rotierende',
        headNoun: 'Hochdruckturbinenwelle',
        fullGermanSentence:
            'Die mit über 14.000 Umdrehungen pro Minute rotierende Hochdruckturbinenwelle erfordert eine hochpräzise hydrodynamische Lagerung.',
        relativeClauseTransformation:
            'Die Hochdruckturbinenwelle, die mit über 14.000 Umdrehungen pro Minute rotiert',
        modalParaphrase: 'rotiert aktiv (gleichzeitiges Prozessgeschehen)',
        embeddedComplements: 'mit über 14.000 Umdrehungen pro Minute (modales Modaladverbial)',
        pragmaticTechnicalContextGerman:
            'Partizip I Aktiv: Schließt eine Umfangsgeschwindigkeit als kontinuierliches physikalisches Geschehen ein.',
        pragmaticTechnicalContextArabic:
            'اسم فاعل ممتد مبني للمعلوم: عمود توربين الضغط العالي الذي يدور بسرعة تفوق 14 ألف دورة بالدقيقة.',
        isTransitiveVerb: false, // rotieren ist intransitiv, aber bildet Partizip I aktiv
      ),
      // 4. Erweitertes Partizip II (Passiv, Plural Dativ)
      const ParticipialAttributeModel(
        id: 'PART-4961-04',
        constructionType: ParticipialConstructionType.extendedPartizipIIPassivePerfective,
        caseAndGender: ParticipialCaseAndGender.dativePlural,
        domain: CommunicativeDomain.civilInfrastructure,
        extendedAttributePhrase:
            'den nach europäischen Erdbeben-Normen berechneten',
        headNoun: 'Brückenpfeilern',
        fullGermanSentence:
            'Die Prüfstatiker vertrauen den nach europäischen Erdbeben-Normen berechneten Brückenpfeilern auch bei schweren Erschütterungen.',
        relativeClauseTransformation:
            'den Brückenpfeilern, die nach europäischen Erdbeben-Normen berechnet worden sind',
        modalParaphrase: 'sind berechnet worden (abgeschlossene statische Auslegung)',
        embeddedComplements: 'nach europäischen Erdbeben-Normen (normatives Richtlinien-PP)',
        pragmaticTechnicalContextGerman:
            'Partizip II Passiv: Vergangene, verbindlich vollendete statische Bemessung im Dativ Plural.',
        pragmaticTechnicalContextArabic:
            'اسم مفعول ممتد مبني للمجهول في حالة الجر: دعامات الجسور التي حُسبت وفق معايير الزلازل الأوروبية.',
        isTransitiveVerb: true,
      ),
      // 5. Gerundiv (Notwendigkeit, Neutrum Nominativ)
      const ParticipialAttributeModel(
        id: 'PART-4961-05',
        constructionType: ParticipialConstructionType.gerundiveNecessity,
        caseAndGender: ParticipialCaseAndGender.nominativeNeuter,
        domain: CommunicativeDomain.industrialRobotics,
        extendedAttributePhrase:
            'Das bei jeder Werkzeugrüstzeit neu zu parametrierende',
        headNoun: 'Kollisionsmodell',
        fullGermanSentence:
            'Das bei jeder Werkzeugrüstzeit neu zu parametrierende Kollisionsmodell verhindert Beschädigungen an der CNC-Spindel.',
        relativeClauseTransformation:
            'Das Kollisionsmodell, das bei jeder Werkzeugrüstzeit neu parametriert werden muss',
        modalParaphrase: 'muss neu parametriert werden (unverzichtbare Rüstvorschrift)',
        embeddedComplements: 'bei jeder Werkzeugrüstzeit (temporales PP), neu (modales Adverb)',
        pragmaticTechnicalContextGerman:
            'Gerundivischer Rüststandard: Das Kollisionsmodell muss zwingend bei jedem Werkzeugwechsel angepasst werden.',
        pragmaticTechnicalContextArabic:
            'صيغة وجوب للمحايد: نموذج تفادي التصادم الذي يجب ضبط بارامتراته مجدداً عند كل تبديل لعدة القطع.',
        isTransitiveVerb: true,
      ),
      // 6. Gerundiv (Möglichkeit, Feminin Akkusativ)
      const ParticipialAttributeModel(
        id: 'PART-4961-06',
        constructionType: ParticipialConstructionType.gerundivePossibility,
        caseAndGender: ParticipialCaseAndGender.accusativeFeminine,
        domain: CommunicativeDomain.maritimeLogistics,
        extendedAttributePhrase:
            'eine durch automatisierte Ballastpumpen leicht auszugleichende',
        headNoun: 'Schlagseite',
        fullGermanSentence:
            'Das Containerschiff wies eine durch automatisierte Ballastpumpen leicht auszugleichende Schlagseite von 1,5 Grad auf.',
        relativeClauseTransformation:
            'eine Schlagseite, die durch automatisierte Ballastpumpen leicht ausgeglichen werden kann',
        modalParaphrase: 'kann leicht ausgeglichen werden (beherrschbare nautische Toleranz)',
        embeddedComplements: 'durch automatisierte Ballastpumpen (kausales PP), leicht (Gradadverb)',
        pragmaticTechnicalContextGerman:
            'Abtrennbares Verb "ausgleichen" im Gerundiv mit Zwischenstellung von "zu": "aus-zu-gleichende".',
        pragmaticTechnicalContextArabic:
            'فعل مركب منفصل في صيغة الإمكانية: ميلان السفينة الذي يمكن موازنته بسهولة بمضخات صابورة المؤازرة.',
        isTransitiveVerb: true,
      ),
      // 7. Erweitertes Partizip II (Passiv, Maskulin Akkusativ)
      const ParticipialAttributeModel(
        id: 'PART-4961-07',
        constructionType: ParticipialConstructionType.extendedPartizipIIPassivePerfective,
        caseAndGender: ParticipialCaseAndGender.accusativeMasculine,
        domain: CommunicativeDomain.renewableEnergyGrid,
        extendedAttributePhrase:
            'den im Reinraum unter Schutzgas gefertigten',
        headNoun: 'Halbleiter-Leistungsschalter',
        fullGermanSentence:
            'Die Monteure installieren den im Reinraum unter Schutzgas gefertigten Halbleiter-Leistungsschalter im Umspannwerk.',
        relativeClauseTransformation:
            'den Halbleiter-Leistungsschalter, der im Reinraum unter Schutzgas gefertigt worden ist',
        modalParaphrase: 'ist gefertigt worden (abgeschlossener Fertigungsprozess)',
        embeddedComplements: 'im Reinraum (Lokalangabe), unter Schutzgas (Modalangabe)',
        pragmaticTechnicalContextGerman:
            'Akkusativ Maskulin mit starker Beugung im Attribut: "-en" bei bestimmtem Artikel.',
        pragmaticTechnicalContextArabic:
            'اسم مفعول ممتد لمنصوب مذكر: قاطع قدرة أشباه الموصلات الذي صُنع داخل الغرفة النقية تحت غاز خامل.',
        isTransitiveVerb: true,
      ),
      // 8. Erweitertes Partizip I (Aktiv, Neutrum Dativ)
      const ParticipialAttributeModel(
        id: 'PART-4961-08',
        constructionType: ParticipialConstructionType.extendedPartizipIActiveSimultaneous,
        caseAndGender: ParticipialCaseAndGender.dativeNeuter,
        domain: CommunicativeDomain.materialScience,
        extendedAttributePhrase:
            'einem sich rasch im Schmelzbad ausbreitenden',
        headNoun: 'Erstarrungsgefüge',
        fullGermanSentence:
            'Die Erstarrungsgeschwindigkeit entspricht einem sich rasch im Schmelzbad ausbreitenden Erstarrungsgefüge.',
        relativeClauseTransformation:
            'einem Erstarrungsgefüge, das sich rasch im Schmelzbad ausbreitet',
        modalParaphrase: 'breitet sich aktiv aus (reflexives Partizip I)',
        embeddedComplements: 'sich (Reflexivpronomen), rasch (Temporaladverb), im Schmelzbad (Lokal-PP)',
        pragmaticTechnicalContextGerman:
            'Reflexives Partizip I: Das Reflexivpronomen "sich" rückt unmittelbar an den Anfang des Attributfelds.',
        pragmaticTechnicalContextArabic:
            'اسم فاعل انعكاسي ممتد: بنية التصلب التي تتمدد وتنتشر بسرعة داخل حوض المصهور المعدني.',
        isTransitiveVerb: false,
      ),
      // 9. Gerundiv (Notwendigkeit, Feminin Genitiv)
      const ParticipialAttributeModel(
        id: 'PART-4961-09',
        constructionType: ParticipialConstructionType.gerundiveNecessity,
        caseAndGender: ParticipialCaseAndGender.genitiveFeminine,
        domain: CommunicativeDomain.aerospaceAndAviation,
        extendedAttributePhrase:
            'der nach 1000 Flugstunden zwingend durchzuführenden',
        headNoun: 'Triebwerksinspektion',
        fullGermanSentence:
            'Die Kosten der nach 1000 Flugstunden zwingend durchzuführenden Triebwerksinspektion sind im Wartungsbudget einkalkuliert.',
        relativeClauseTransformation:
            'der Triebwerksinspektion, die nach 1000 Flugstunden zwingend durchgeführt werden muss',
        modalParaphrase: 'muss durchgeführt werden (gesetzliche EASA-Wartungsvorschrift)',
        embeddedComplements: 'nach 1000 Flugstunden (zeitliche Konditionierung), zwingend (Modaladverb)',
        pragmaticTechnicalContextGerman:
            'Trennbares Verb "durchführen" als Gerundiv im Genitiv Feminin: "durch-zu-führenden".',
        pragmaticTechnicalContextArabic:
            'صيغة وجوب في حالة المضاف إليه المؤنث: فحص المحرك النفاث الإلزامي بعد 1000 ساعة طيران.',
        isTransitiveVerb: true,
      ),
      // 10. Gerundiv (Möglichkeit, Plural Dativ)
      const ParticipialAttributeModel(
        id: 'PART-4961-10',
        constructionType: ParticipialConstructionType.gerundivePossibility,
        caseAndGender: ParticipialCaseAndGender.dativePlural,
        domain: CommunicativeDomain.civilInfrastructure,
        extendedAttributePhrase:
            'den ohne Kranhilfe kaum zu montierenden',
        headNoun: 'Stahlträgern',
        fullGermanSentence:
            'Bei den ohne Kranhilfe kaum zu montierenden Stahlträgern griffen die Bauleiter auf Mobilkräne zurück.',
        relativeClauseTransformation:
            'den Stahlträgern, die ohne Kranhilfe kaum montiert werden können',
        modalParaphrase: 'können kaum montiert werden (bauliche Machbarkeitsgrenze)',
        embeddedComplements: 'ohne Kranhilfe (modale PP), kaum (negierendes Einschränkungsadverb)',
        pragmaticTechnicalContextGerman:
            'Negierte Möglichkeit ("kaum zu montieren"): Drückt logistische Notwendigkeit von Spezialgeräten aus.',
        pragmaticTechnicalContextArabic:
            'صيغة إمكانية شبه معدومة: العوارض الفولاذية الثقيلة التي يكاد يستحيل تركيبها دون الاستعانة بالرافعة.',
        isTransitiveVerb: true,
      ),
      // 11. Erweitertes Partizip II (Passiv, Neutrum Nominativ)
      const ParticipialAttributeModel(
        id: 'PART-4961-11',
        constructionType: ParticipialConstructionType.extendedPartizipIIPassivePerfective,
        caseAndGender: ParticipialCaseAndGender.nominativeNeuter,
        domain: CommunicativeDomain.industrialRobotics,
        extendedAttributePhrase:
            'Das über Ethernet-IP an die zentrale Leitwarte angebundene',
        headNoun: 'Fahrerlose Transportsystem',
        fullGermanSentence:
            'Das über Ethernet-IP an die zentrale Leitwarte angebundene Fahrerlose Transportsystem navigiert autonom durch die Fertigungshalle.',
        relativeClauseTransformation:
            'Das Fahrerlose Transportsystem, das über Ethernet-IP an die zentrale Leitwarte angebunden worden ist',
        modalParaphrase: 'ist angebunden worden (abgeschlossene netzwerktechnische Integration)',
        embeddedComplements: 'über Ethernet-IP (instrumentale PP), an die zentrale Leitwarte (Direktional-PP)',
        pragmaticTechnicalContextGerman:
            'Zweifach erweiterte Präpositionalphrasen im Mittelfeld des Partizipialattributs.',
        pragmaticTechnicalContextArabic:
            'اسم مفعول ممتد ذو وسائط متعددة: نظام النقل الذاتي المرتبط شبكياً بغرفة التحكم المركزية.',
        isTransitiveVerb: true,
      ),
      // 12. Erweitertes Partizip I (Aktiv, Maskulin Genitiv)
      const ParticipialAttributeModel(
        id: 'PART-4961-12',
        constructionType: ParticipialConstructionType.extendedPartizipIActiveSimultaneous,
        caseAndGender: ParticipialCaseAndGender.genitiveMasculine,
        domain: CommunicativeDomain.maritimeLogistics,
        extendedAttributePhrase:
            'eines mit voller Maschinenkraft gegen die Strömung ankämpfenden',
        headNoun: 'Schleppverbandes',
        fullGermanSentence:
            'Die Manövrierfähigkeit eines mit voller Maschinenkraft gegen die Strömung ankämpfenden Schleppverbandes ist stark eingeschränkt.',
        relativeClauseTransformation:
            'eines Schleppverbandes, der mit voller Maschinenkraft gegen die Strömung ankämpft',
        modalParaphrase: 'kämpft aktiv an (dauerhafte Krafteinwirkung)',
        embeddedComplements: 'mit voller Maschinenkraft (Modal-PP), gegen die Strömung (Direktional-PP)',
        pragmaticTechnicalContextGerman:
            'Genitiv Maskulin beim Partizip I ("-en"): "eines ankämpfend-en Schleppverbandes".',
        pragmaticTechnicalContextArabic:
            'اسم فاعل ممتد في صيغة المضاف إليه: أسطول القطر البحري الذي يصارع التيار الجارف بكامل طاقة المحركات.',
        isTransitiveVerb: false,
      ),
      // 13. Gerundiv (Notwendigkeit, Maskulin Nominativ)
      const ParticipialAttributeModel(
        id: 'PART-4961-13',
        constructionType: ParticipialConstructionType.gerundiveNecessity,
        caseAndGender: ParticipialCaseAndGender.nominativeMasculine,
        domain: CommunicativeDomain.renewableEnergyGrid,
        extendedAttributePhrase:
            'Der im Havariefall innerhalb von 15 Millisekunden auszulösende',
        headNoun: 'Thyristorschutzschalter',
        fullGermanSentence:
            'Der im Havariefall innerhalb von 15 Millisekunden auszulösende Thyristorschutzschalter verhindert das Durchbrennen der Umrichterventile.',
        relativeClauseTransformation:
            'Der Thyristorschutzschalter, der im Havariefall innerhalb von 15 Millisekunden ausgelöst werden muss',
        modalParaphrase: 'muss ausgelöst werden (sicherheitskritische Schutzfunktion)',
        embeddedComplements: 'im Havariefall (Konditional-PP), innerhalb von 15 Millisekunden (Temporal-PP)',
        pragmaticTechnicalContextGerman:
            'Präzise Reaktionszeitvorgabe als Gerundiv: "aus-zu-lösende".',
        pragmaticTechnicalContextArabic:
            'صيغة وجوب حتمية: قاطع الثايرستور الذي يجب فصله خلال 15 ميلي ثانية عند وقوع الحوادث الطارئة.',
        isTransitiveVerb: true,
      ),
      // 14. Gerundiv (Möglichkeit, Neutrum Dativ)
      const ParticipialAttributeModel(
        id: 'PART-4961-14',
        constructionType: ParticipialConstructionType.gerundivePossibility,
        caseAndGender: ParticipialCaseAndGender.dativeNeuter,
        domain: CommunicativeDomain.materialScience,
        extendedAttributePhrase:
            'einem mittels Röntgenbeugung präzise zu ermittelnden',
        headNoun: 'Eigenspannungszustand',
        fullGermanSentence:
            'Die Bauteillebensdauer korreliert mit einem mittels Röntgenbeugung präzise zu ermittelnden Eigenspannungszustand.',
        relativeClauseTransformation:
            'einem Eigenspannungszustand, der mittels Röntgenbeugung präzise ermittelt werden kann',
        modalParaphrase: 'kann präzise ermittelt werden (analytische Bestimmbarkeit)',
        embeddedComplements: 'mittels Röntgenbeugung (instrumentales Genitiv-PP), präzise (Modaladverb)',
        pragmaticTechnicalContextGerman:
            'Dativ Neutrum Gerundiv mit instrumentaler Genitiv-Präposition "mittels".',
        pragmaticTechnicalContextArabic:
            'صيغة إمكانية تحليلية: حالة الإجهاد الداخلي التي يمكن قياسها بدقة عبر حيود الأشعة السينية.',
        isTransitiveVerb: true,
      ),
      // 15. Erweitertes Partizip II (Passiv, Feminin Dativ)
      const ParticipialAttributeModel(
        id: 'PART-4961-15',
        constructionType: ParticipialConstructionType.extendedPartizipIIPassivePerfective,
        caseAndGender: ParticipialCaseAndGender.dativeFeminine,
        domain: CommunicativeDomain.aerospaceAndAviation,
        extendedAttributePhrase:
            'einer nach strengen FAA-Kriterien zugelassenen',
        headNoun: 'Avionik-Architektur',
        fullGermanSentence:
            'Das Passagierflugzeug vertraut einer nach strengen FAA-Kriterien zugelassenen Avionik-Architektur.',
        relativeClauseTransformation:
            'einer Avionik-Architektur, die nach strengen FAA-Kriterien zugelassen worden ist',
        modalParaphrase: 'ist zugelassen worden (luftrechtlich zertifizierter Zustand)',
        embeddedComplements: 'nach strengen FAA-Kriterien (normative Richtlinien-PP)',
        pragmaticTechnicalContextGerman:
            'Dativ Feminin mit unbestimmtem Artikel: "einer zugelassen-en Avionik-Architektur".',
        pragmaticTechnicalContextArabic:
            'اسم مفعول ممتد لمعمارية إلكترونيات الطيران التي نالت الاعتماد الرسمي وفق لوائح هيئة الطيران الفيدرالية.',
        isTransitiveVerb: true,
      ),
      // 16. Erweitertes Partizip I (Aktiv, Plural Nominativ)
      const ParticipialAttributeModel(
        id: 'PART-4961-16',
        constructionType: ParticipialConstructionType.extendedPartizipIActiveSimultaneous,
        caseAndGender: ParticipialCaseAndGender.nominativePlural,
        domain: CommunicativeDomain.civilInfrastructure,
        extendedAttributePhrase:
            'Die bei Starkregen unkontrolliert in die Baugrube eindringenden',
        headNoun: 'Wassermassen',
        fullGermanSentence:
            'Die bei Starkregen unkontrolliert in die Baugrube eindringenden Wassermassen erforderten zusätzliche Hochleistungspumpen.',
        relativeClauseTransformation:
            'Die Wassermassen, die bei Starkregen unkontrolliert in die Baugrube eindringen',
        modalParaphrase: 'dringen aktiv ein (akutes Flutungsgeschehen)',
        embeddedComplements: 'bei Starkregen (Konditional-PP), unkontrolliert (Modaladverb), in die Baugrube (Direktional-PP)',
        pragmaticTechnicalContextGerman:
            'Intransitives Partizip I mit dreifacher adverbialer Bestimmung im Attributrahmen.',
        pragmaticTechnicalContextArabic:
            'اسم فاعل ممتد لكتل المياه الجارفة التي تقتحم موقع الحفر عشوائياً عند هطول الأمطار الغزيرة.',
        isTransitiveVerb: false,
      ),
    ]);
  }

  List<ParticipialAttributeModel> getByType(ParticipialConstructionType type) =>
      _catalog.where((p) => p.constructionType == type).toList();

  List<ParticipialAttributeModel> getByCaseAndGender(ParticipialCaseAndGender cg) =>
      _catalog.where((p) => p.caseAndGender == cg).toList();

  List<ParticipialAttributeModel> getByDomain(CommunicativeDomain domain) =>
      _catalog.where((p) => p.domain == domain).toList();

  /// Validates transitivity and grammatical constraints of participial attributes.
  ParticipialValidationResult validateParticipialStructure({
    required ParticipialConstructionType type,
    required bool isVerbTransitive,
    required bool hasInnerZuForSeparable,
    required bool caseAgreementCompliant,
  }) {
    final List<String> issues = [];
    final List<String> notes = [];

    // Rule 1: Gerundive (zu + Partizip I) CAN ONLY be formed from TRANSITIVE verbs!
    if (type == ParticipialConstructionType.gerundiveNecessity ||
        type == ParticipialConstructionType.gerundivePossibility) {
      if (!isVerbTransitive) {
        issues.add(
            'Valenzfehler: Das Gerundiv (zu + Partizip I mit Passivbedeutung) kann NUR von transitiven Verben gebildet werden, die ein Akkusativobjekt regieren.');
      } else {
        notes.add('Valenz konform: Transitives Basisverb erlaubt reguläre Gerundivbildung.');
      }
    }

    // Rule 2: Separable verbs insert "zu" between prefix and stem
    if (!hasInnerZuForSeparable) {
      issues.add(
          'Morphologie-Fehler: Bei trennbaren Verben muss das "zu" im Gerundiv zwischen Vorsilbe und Partizipialstamm eingefügt werden (z. B. aus-zu-gleichende).');
    } else {
      notes.add('Morphologisch korrekt: Korrekte Fugung von "-zu-" bei trennbaren Präfixen.');
    }

    // Rule 3: Case, number, and gender agreement
    if (!caseAgreementCompliant) {
      issues.add(
          'Kongruenzfehler: Das Partizipialattribut muss in Kasus, Numerus und Genus strikt mit dem Bezugsnomen kongruieren.');
    } else {
      notes.add('Syntaktisch normgerecht: Vollständige Kongruenz innerhalb der Attributklammer.');
    }

    return ParticipialValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      syntacticNotes: notes,
    );
  }

  Map<String, dynamic> generateTelemetrySnapshot() {
    return {
      'totalExemplars': _catalog.length,
      'constructionTypeDistribution': {
        for (var t in ParticipialConstructionType.values)
          t.name: _catalog.where((p) => p.constructionType == t).length,
      },
      'domainDistribution': {
        for (var d in CommunicativeDomain.values)
          d.name: _catalog.where((p) => p.domain == d).length,
      },
      'gerundiveCount': _catalog.where((p) =>
          p.constructionType == ParticipialConstructionType.gerundiveNecessity ||
          p.constructionType == ParticipialConstructionType.gerundivePossibility).length,
      'cefrLevel': 'CEFR C1-C2 Masterclass Extended Participial Attributes & Gerundive',
      'engineVersion': '1.0.0+subsystem1795',
    };
  }
}
