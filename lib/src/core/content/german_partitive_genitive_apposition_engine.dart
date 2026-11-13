import 'dart:collection';

/// Classification of partitive genitive, apposition, and measure attribution.
enum PartitiveAppositionCategory {
  measureNounAdjectiveAttribution(
    'Maß-/Mengenangaben mit Adjektiv (Apposition im gleichen Kasus vs. partitiver Genitiv)',
    'أسماء المقادير والأوزان المقترنة بصفة (المطابقة البدلية الإعرابية مقابل المضاف إليه التبعيضي)',
    'Nach Maß- und Mengennamen ohne Artikel schwankt die Beugung des Adjektivs: Kongruierende Apposition (mit einem Liter reinem Wasser [Dativ]) oder partitiver Genitiv (mit einem Liter reinen Wassers [Genitiv]).',
  ),
  closeAppositionTitleName(
    'Enge Apposition (Titel/Gattung + Eigenname: das Element Titan, Ingenieur Weber)',
    'البدل المطابق الملاصق الخالي من الفواصل (اللقب/النوع + الاسم العلم: عنصر التيتانيوم)',
    'Steht ohne Komma; bei Genitivierung flektiert im Standarddeutschen nur der nachgestellte Eigenname bzw. das Grundwort: "die Dichte des Elements Titan" / "die Unterschrift des Ingenieurs Weber".',
  ),
  looseAppositionCaseAttraction(
    'Lockere Apposition (eingeschoben mit Kommas: Herrn Dr. Weber, dem Prüfleiter)',
    'البدل المنفصل المفسر المحاط بفواصل والمطابق إعرابياً للمبدل منه',
    'Wird durch Kommas abgetrennt und kongruiert strikt im Kasus mit dem Bezugswort (Kasusattraktion): "dem Prüfleiter, einem erfahrenen Fachingenieur, ..."',
  ),
  genitivusExplicativusDefinitivus(
    'Genitivus explicativus / definitivus (das Problem der Kaltversprödung)',
    'المضاف إليه البياني التفسيري المحدد لماهية المصطلح (مفهوم الكسر الهش)',
    'Das Genitivattribut benennt den Inhalt oder die Definition des vorangestellten Oberbegriffs: "der Begriff der Enthalpie", "das Phänomen der Resonanz".',
  ),
  fractionalPartitiveVerbAgreement(
    'Bruch- und Prozentpartitive mit Verb-Kongruenz (zwei Drittel des / der ...)',
    'الكسور والنسب المئوية التبعيضية وتطابق الفعل (إفراد الفعل مع المفرد وجمعه مع الجمع)',
    'Die Verbkongruenz richtet sich nach dem Genitivkomplement: Singuläres Nomen erfordert Singularverb ("drei Viertel des Speichers ist gefüllt"), pluralisches Nomen erfordert Pluralverb ("drei Viertel der Sensoren sind defekt").',
  );

  final String deTitle;
  final String arTitle;
  final String grammaticalDefinition;
  const PartitiveAppositionCategory(this.deTitle, this.arTitle, this.grammaticalDefinition);
}

/// Case governance mode for measure noun attributes.
enum AdjectiveMeasureCaseGovernance {
  congruentAppositionCase('Kongruierende Kasusübernahme (Apposition im Dativ/Akkusativ)', 'مطابقة بدلية تامة في الإعراب'),
  partitiveGenitiveCase('Partitiver Genitiv (strikte Genitivendung)', 'إعراب بالإضافة التبعيضية في المجرور بالكسرة/السكون'),
  indeclinableMeasureNoun('Unflektiertes maskulines/neutrales Maßnomen (Liter, Kilo, Bar, Gramm)', 'اسم المقدار المذكر/المحايد المجرد من علامة الجمع'),
  feminineMeasureInflectionException('Feminines Maßnomen mit regulärer Pluralendung (Tonnen, Tassen)', 'اسم المقدار المؤنث المجموع بالنون جمعاً قياسياً');

  final String de;
  final String ar;
  const AdjectiveMeasureCaseGovernance(this.de, this.ar);
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

/// Structural model of a German partitive genitive or apposition construction.
class PartitiveAppositionModel {
  final String id;
  final PartitiveAppositionCategory category;
  final AdjectiveMeasureCaseGovernance caseGovernance;
  final CommunicativeDomain domain;
  final String carrierNounPhrase;
  final String headNoun;
  final String fullGermanSentence;
  final String ungrammaticalMismatchExample;
  final String grammaticalRuleGerman;
  final String grammaticalRuleArabic;
  final String verbAgreementNumber;

  const PartitiveAppositionModel({
    required this.id,
    required this.category,
    required this.caseGovernance,
    required this.domain,
    required this.carrierNounPhrase,
    required this.headNoun,
    required this.fullGermanSentence,
    required this.ungrammaticalMismatchExample,
    required this.grammaticalRuleGerman,
    required this.grammaticalRuleArabic,
    required this.verbAgreementNumber,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.name,
    'caseGovernance': caseGovernance.name,
    'domain': domain.name,
    'carrierNounPhrase': carrierNounPhrase,
    'headNoun': headNoun,
    'fullGermanSentence': fullGermanSentence,
    'ungrammaticalMismatchExample': ungrammaticalMismatchExample,
    'grammaticalRuleGerman': grammaticalRuleGerman,
    'grammaticalRuleArabic': grammaticalRuleArabic,
    'verbAgreementNumber': verbAgreementNumber,
  };
}

/// Validation result for partitive and appositive syntax.
class PartitiveValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<String> syntacticNotes;

  const PartitiveValidationResult({
    required this.isValid,
    required this.issues,
    required this.syntacticNotes,
  });
}

/// Core Engine managing German Partitive Genitive, Appositions & Measure Attribution.
class GermanPartitiveGenitiveAppositionEngine {
  final List<PartitiveAppositionModel> _catalog = [];

  GermanPartitiveGenitiveAppositionEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<PartitiveAppositionModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    _catalog.addAll([
      // 1. Maßangabe mit kongruierendem Dativ (mit einem Liter reinem Wasser)
      const PartitiveAppositionModel(
        id: 'PART-4969-01',
        category: PartitiveAppositionCategory.measureNounAdjectiveAttribution,
        caseGovernance: AdjectiveMeasureCaseGovernance.congruentAppositionCase,
        domain: CommunicativeDomain.materialScience,
        carrierNounPhrase: 'mit einem Liter reinem Elektrolyt',
        headNoun: 'Elektrolyt',
        fullGermanSentence:
            'Die Brennstoffzelle wurde für den Prüflauf mit einem Liter reinem Elektrolyt bei konstantem Druck befüllt.',
        ungrammaticalMismatchExample:
            '*mit einem Liter reiner Elektrolyt (Nominativ nach Dativ-Präposition "mit" ist fehlerhaft).',
        grammaticalRuleGerman:
            'Kongruierende Apposition: Das Adjektiv "reinem" übernimmt den Dativ des vorangestellten Maßausdrucks "einem Liter".',
        grammaticalRuleArabic:
            'مطابقة بدلية إعرابية في الجر: الصفة (reinem) تتبع اسم المقدار (einem Liter) في حالة الجر بحرف الجر mit.',
        verbAgreementNumber: 'Singular',
      ),
      // 2. Maßangabe mit partitivem Genitiv (mit einem Liter reinen Elektrolyts)
      const PartitiveAppositionModel(
        id: 'PART-4969-02',
        category: PartitiveAppositionCategory.measureNounAdjectiveAttribution,
        caseGovernance: AdjectiveMeasureCaseGovernance.partitiveGenitiveCase,
        domain: CommunicativeDomain.materialScience,
        carrierNounPhrase: 'mit einem Liter reinen Elektrolyts',
        headNoun: 'Elektrolyt',
        fullGermanSentence:
            'Zur Viskositätsbestimmung titrieren die Chemiker die Probe mit einem Liter reinen Elektrolyts.',
        ungrammaticalMismatchExample:
            '*mit einem Liter reines Elektrolyt (unvollständige/widersprüchliche Beugung).',
        grammaticalRuleGerman:
            'Partitiver Genitiv: Gehobener Standard; Adjektiv und Nomen stehen beide strikt im Genitiv ("reinen Elektrolyts").',
        grammaticalRuleArabic:
            'المضاف إليه التبعيضي: أسلوب فصيح راقٍ تتبع فيه الصفة والموصوف صيغة الإضافة التبعيضية في حالة الجر بالإس.',
        verbAgreementNumber: 'Singular',
      ),
      // 3. Enge Apposition (das Element Titan)
      const PartitiveAppositionModel(
        id: 'PART-4969-03',
        category: PartitiveAppositionCategory.closeAppositionTitleName,
        caseGovernance: AdjectiveMeasureCaseGovernance.indeclinableMeasureNoun,
        domain: CommunicativeDomain.aerospaceAndAviation,
        carrierNounPhrase: 'des Elements Titan',
        headNoun: 'Titan',
        fullGermanSentence:
            'Wegen der hervorragenden spezifischen Festigkeit des Elements Titan setzen Triebwerksbauer auf neuartige Blisk-Rotoren.',
        ungrammaticalMismatchExample:
            '*des Elements Titans (falsche Doppel-Genitivierung des Eigennamens in enger Apposition).',
        grammaticalRuleGerman:
            'Enge Apposition bei Gattungsname + Stoffname: Im Genitiv flektiert nur das Grundwort ("des Elements"); der Stoffname "Titan" bleibt endungslos.',
        grammaticalRuleArabic:
            'البدل الملاصق غير المفصول: يكتفى بجر الاسم العام الممهد (des Elements) ويبقى اسم المادة المعدنية (Titan) مجرداً بلا إس.',
        verbAgreementNumber: 'Singular',
      ),
      // 4. Lockere Apposition mit Dativ-Attraktion
      const PartitiveAppositionModel(
        id: 'PART-4969-04',
        category: PartitiveAppositionCategory.looseAppositionCaseAttraction,
        caseGovernance: AdjectiveMeasureCaseGovernance.congruentAppositionCase,
        domain: CommunicativeDomain.civilInfrastructure,
        carrierNounPhrase: 'Herrn Dr. Weber, dem leitenden Prüfstatiker,',
        headNoun: 'Prüfstatiker',
        fullGermanSentence:
            'Die Bauaufsichtsbehörde übertrug Herrn Dr. Weber, dem leitenden Prüfstatiker, die Endabnahme der Schrägseilbrücke.',
        ungrammaticalMismatchExample:
            '*übertrug Herrn Dr. Weber, der leitende Prüfstatiker (Nominativ-Bruch in der Apposition).',
        grammaticalRuleGerman:
            'Kasusattraktion in lockerer Apposition: Das durch Kommas abgetrennte Appositionsgefüge kongruiert strikt im Dativ ("dem leitenden Prüfstatiker").',
        grammaticalRuleArabic:
            'تطابق البدل المنفصل المحاط بفواصل: يجب تطابق البدل في حالة الجر بالداتيف مع المبدل منه (Herrn Dr. Weber).',
        verbAgreementNumber: 'Singular',
      ),
      // 5. Genitivus explicativus (das Phänomen der Resonanzkatastrophe)
      const PartitiveAppositionModel(
        id: 'PART-4969-05',
        category: PartitiveAppositionCategory.genitivusExplicativusDefinitivus,
        caseGovernance: AdjectiveMeasureCaseGovernance.partitiveGenitiveCase,
        domain: CommunicativeDomain.civilInfrastructure,
        carrierNounPhrase: 'das Phänomen der Resonanzkatastrophe',
        headNoun: 'Resonanzkatastrophe',
        fullGermanSentence:
            'Zur Vermeidung der Einsturzgefahr untersuchte das Ingenieurbüro das Phänomen der selbsterregten Resonanzkatastrophe im Windkanal.',
        ungrammaticalMismatchExample:
            '*das Phänomen von die Resonanzkatastrophe (unzulässige umgangssprachliche Dativ-Periphrase).',
        grammaticalRuleGerman:
            'Genitivus definitivus: Definiert den Oberbegriff "Phänomen" durch die präzise ingenieurwissenschaftliche Fachbezeichnung im Genitiv.',
        grammaticalRuleArabic:
            'المضاف إليه البياني المفسر: تحديد ماهية الظاهرة الفيزيائية بإضافتها إلى المصطلح التخصصي (كارثة الرنين الذاتي).',
        verbAgreementNumber: 'Singular',
      ),
      // 6. Bruchpartitiv mit Plural-Kongruenz (drei Viertel der Sensoren sind...)
      const PartitiveAppositionModel(
        id: 'PART-4969-06',
        category: PartitiveAppositionCategory.fractionalPartitiveVerbAgreement,
        caseGovernance: AdjectiveMeasureCaseGovernance.partitiveGenitiveCase,
        domain: CommunicativeDomain.industrialRobotics,
        carrierNounPhrase: 'Drei Viertel der piezoelektrischen Sensoren',
        headNoun: 'Sensoren',
        fullGermanSentence:
            'Drei Viertel der piezoelektrischen Sensoren erfassen die Körperschallsignale der Roboterachse mit Mikrosekundenpräzision.',
        ungrammaticalMismatchExample:
            '*Drei Viertel der Sensoren erfasst (Singularverb bei zählbarem pluralischem Genitivkomplement ist ungrammatisch).',
        grammaticalRuleGerman:
            'Numeruskongruenz bei Bruchzahlen: Bei zählbarem Plural-Genitiv ("der Sensoren") MUSS das finite Verb im Plural stehen ("erfassen").',
        grammaticalRuleArabic:
            'تطابق الفعل مع الكسر العددي التبعيضي: إذا كان المضاف إليه التبعيضي جمعاً معدوداً (المستشعرات) يلزم جمع الفعل (erfassen).',
        verbAgreementNumber: 'Plural',
      ),
      // 7. Bruchpartitiv mit Singular-Kongruenz (ein Viertel des Gesamtvolumens ist...)
      const PartitiveAppositionModel(
        id: 'PART-4969-07',
        category: PartitiveAppositionCategory.fractionalPartitiveVerbAgreement,
        caseGovernance: AdjectiveMeasureCaseGovernance.partitiveGenitiveCase,
        domain: CommunicativeDomain.renewableEnergyGrid,
        carrierNounPhrase: 'Ein Viertel des verfügbaren Speichervolumens',
        headNoun: 'Speichervolumen',
        fullGermanSentence:
            'Ein Viertel des verfügbaren Speichervolumens dient als redundante Schwarzstart-Reserve für das Inselnetz.',
        ungrammaticalMismatchExample:
            '*Ein Viertel des Speichervolumens dienen (Pluralverb bei singulärem Kontinuum ist unzulässig).',
        grammaticalRuleGerman:
            'Numeruskongruenz bei Kontinuums-Genitiv: Singuläres Nomen ("des Speichervolumens") erzwingt das Verb im Singular ("dient").',
        grammaticalRuleArabic:
            'تطابق الفعل مع الكسر للكميات المتصلة: الاسم المفرد غير المعدود يوجب إفراد الفعل (dient) كاحتياطي للبدء الذاتي.',
        verbAgreementNumber: 'Singular',
      ),
      // 8. Maßnomen im Plural (zwei Tonnen hochfester Stahl)
      const PartitiveAppositionModel(
        id: 'PART-4969-08',
        category: PartitiveAppositionCategory.measureNounAdjectiveAttribution,
        caseGovernance: AdjectiveMeasureCaseGovernance.feminineMeasureInflectionException,
        domain: CommunicativeDomain.maritimeLogistics,
        carrierNounPhrase: 'zwei Tonnen hochfester Stahl',
        headNoun: 'Stahl',
        fullGermanSentence:
            'Für die Reparatur der Bordwand wurden zwei Tonnen hochfester Stahl per Spezialkran an Bord gehoben.',
        ungrammaticalMismatchExample:
            '*zwei Tonnen hochfesten Stahl (falscher Akkusativ/Genitiv im Subjektsnominativ).',
        grammaticalRuleGerman:
            'Feminines Maßnomen "Tonne" bildet regulären Plural "Tonnen"; im Nominativ steht das partitive Adjektiv stark gebeugt: "hochfester Stahl".',
        grammaticalRuleArabic:
            'اسم المقدار المؤنث (Tonne): يجمع قياسياً بالنون (Tonnen)، وتتبعه الصفة المرفوعة بعلامة الرفع القوية (hochfester Stahl).',
        verbAgreementNumber: 'Plural',
      ),
      // 9. Enge Apposition im Dativ (mit dem Element Silizium)
      const PartitiveAppositionModel(
        id: 'PART-4969-09',
        category: PartitiveAppositionCategory.closeAppositionTitleName,
        caseGovernance: AdjectiveMeasureCaseGovernance.indeclinableMeasureNoun,
        domain: CommunicativeDomain.renewableEnergyGrid,
        carrierNounPhrase: 'mit dem Halbleiterelement Silizium',
        headNoun: 'Silizium',
        fullGermanSentence:
            'Der Wirkungsgrad der Tandem-Solarzelle korreliert eng mit dem dotierten Halbleiterelement Silizium.',
        ungrammaticalMismatchExample:
            '*mit dem Halbleiterelement Siliziums (falsche Beugung in enger Dativ-Apposition).',
        grammaticalRuleGerman:
            'Enge Apposition im Dativ: Der Eigenname "Silizium" bleibt im Dativ unflektiert neben dem deklinierten Grundwort "dem Halbleiterelement".',
        grammaticalRuleArabic:
            'البدل الملاصق في المجرور: يبقى اسم العنصر (Silizium) مجرداً بينما تُعرب اللفظة العامة السابقة (dem Halbleiterelement).',
        verbAgreementNumber: 'Singular',
      ),
      // 10. Lockere Apposition im Akkusativ
      const PartitiveAppositionModel(
        id: 'PART-4969-10',
        category: PartitiveAppositionCategory.looseAppositionCaseAttraction,
        caseGovernance: AdjectiveMeasureCaseGovernance.congruentAppositionCase,
        domain: CommunicativeDomain.aerospaceAndAviation,
        carrierNounPhrase: 'den Höhenkammertest, einen entscheidenden Meilenstein der Zulassung,',
        headNoun: 'Meilenstein',
        fullGermanSentence:
            'Die Triebwerksentwickler absolvierten den anspruchsvollen Höhenkammertest, einen entscheidenden Meilenstein der Zulassung, ohne thermische Beanstandungen.',
        ungrammaticalMismatchExample:
            '*absolvierten den Höhenkammertest, ein entscheidender Meilenstein (Nominativ statt Akkusativattraktion).',
        grammaticalRuleGerman:
            'Akkusativkongruenz in lockerer Apposition: "einen entscheidenden Meilenstein" gleicht sich an das Akkusativobjekt "den Höhenkammertest" an.',
        grammaticalRuleArabic:
            'تطابق البدل المنصوب: يتبع البدل التفسيري المفعول به في حالة النصب (einen entscheidenden Meilenstein).',
        verbAgreementNumber: 'Singular',
      ),
      // 11. Maßnomen im Dativ mit partitivem Genitiv (mit 500 Gramm reinen Kupfers)
      const PartitiveAppositionModel(
        id: 'PART-4969-11',
        category: PartitiveAppositionCategory.measureNounAdjectiveAttribution,
        caseGovernance: AdjectiveMeasureCaseGovernance.partitiveGenitiveCase,
        domain: CommunicativeDomain.materialScience,
        carrierNounPhrase: 'mit 500 Gramm reinen Kupfers',
        headNoun: 'Kupfer',
        fullGermanSentence:
            'Die Induktionsspule wurde zur Minimierung der ohmschen Verluste mit 500 Gramm reinen Kupfers galvanisch ummantelt.',
        ungrammaticalMismatchExample:
            '*mit 500 Gramm reines Kupfer (Umgangssprachlich ohne Beugungsharmonie).',
        grammaticalRuleGerman:
            'Partitiver Genitiv nach neutralem Maßnomen "Gramm": Genitivflexion "-s" am Stoffnomen "Kupfers".',
        grammaticalRuleArabic:
            'المضاف إليه التبعيضي بعد اسم المقدار المحايد (Gramm): إلحاق علامة الجر (reinen Kupfers) لبيان نوع المادة ونقائها.',
        verbAgreementNumber: 'Singular',
      ),
      // 12. Genitivus explicativus (die Anforderung der elektromagnetischen Verträglichkeit)
      const PartitiveAppositionModel(
        id: 'PART-4969-12',
        category: PartitiveAppositionCategory.genitivusExplicativusDefinitivus,
        caseGovernance: AdjectiveMeasureCaseGovernance.partitiveGenitiveCase,
        domain: CommunicativeDomain.industrialRobotics,
        carrierNounPhrase: 'die Anforderung der elektromagnetischen Verträglichkeit (EMV)',
        headNoun: 'Verträglichkeit',
        fullGermanSentence:
            'Der Servoverstärker erfüllt die normative Anforderung der elektromagnetischen Verträglichkeit gemäß EN 61800-3.',
        ungrammaticalMismatchExample:
            '*die Anforderung für die elektromagnetische Verträglichkeit (präpositionale Abschwächung statt präzisem Genitiv).',
        grammaticalRuleGerman:
            'Explikativer Genitiv spezifiziert die Art der normativen Anforderung ohne umschreibende Präposition.',
        grammaticalRuleArabic:
            'المضاف إليه التفسيري يحدد معيار التوافق الكهرومغناطيسي كبند ملزم وفق اللائحة القياسية EN 61800-3.',
        verbAgreementNumber: 'Singular',
      ),
      // 13. Bruchpartitiv mit zählbaren Dativergänzungen
      const PartitiveAppositionModel(
        id: 'PART-4969-13',
        category: PartitiveAppositionCategory.fractionalPartitiveVerbAgreement,
        caseGovernance: AdjectiveMeasureCaseGovernance.partitiveGenitiveCase,
        domain: CommunicativeDomain.civilInfrastructure,
        carrierNounPhrase: 'Zwei Drittel der tragenden Betonstützen',
        headNoun: 'Betonstützen',
        fullGermanSentence:
            'Zwei Drittel der tragenden Betonstützen weisen nach dem Erdbeben keine sicherheitsrelevanten Verformungen auf.',
        ungrammaticalMismatchExample:
            '*Zwei Drittel der Betonstützen weist auf (falscher Singular bei Pluralnomen).',
        grammaticalRuleGerman:
            'Pluralische Verbkongruenz ("weisen auf") wegen des pluralischen Bezugsworts "Betonstützen".',
        grammaticalRuleArabic:
            'تطابق الجمع الفعلي (weisen auf) مع الكسر العددي (ثلثا الأعمدة الخرسانية الحاملة).',
        verbAgreementNumber: 'Plural',
      ),
      // 14. Maßnomen im Akkusativ (fünf Bar statischen Überdruck)
      const PartitiveAppositionModel(
        id: 'PART-4969-14',
        category: PartitiveAppositionCategory.measureNounAdjectiveAttribution,
        caseGovernance: AdjectiveMeasureCaseGovernance.congruentAppositionCase,
        domain: CommunicativeDomain.maritimeLogistics,
        carrierNounPhrase: 'fünf Bar statischen Überdruck',
        headNoun: 'Überdruck',
        fullGermanSentence:
            'Das Sicherheitsventil der Ballasttanks hält fünf Bar statischen Überdruck ohne Druckabfall stand.',
        ungrammaticalMismatchExample:
            '*fünf Bar statischer Überdruck (falscher Nominativ im Akkusativobjekt).',
        grammaticalRuleGerman:
            'Kongruierender Akkusativ nach maskulinem Maßnomen "fünf Bar": stark gebeugtes Adjektiv "statischen Überdruck".',
        grammaticalRuleArabic:
            'المطابقة البدلية في النصب: إعراب الصفة (statischen) والموصوف بالنصب التام تبعاً لمحل المفعول به.',
        verbAgreementNumber: 'Singular',
      ),
      // 15. Enge Apposition im Genitiv bei Eigennamen (des Projekts Alpha)
      const PartitiveAppositionModel(
        id: 'PART-4969-15',
        category: PartitiveAppositionCategory.closeAppositionTitleName,
        caseGovernance: AdjectiveMeasureCaseGovernance.indeclinableMeasureNoun,
        domain: CommunicativeDomain.aerospaceAndAviation,
        carrierNounPhrase: 'des Forschungsprojekts Hyperschall',
        headNoun: 'Hyperschall',
        fullGermanSentence:
            'Die Zwischenergebnisse des Forschungsprojekts Hyperschall belegen die Machbarkeit luftatmender Scramjet-Antriebe.',
        ungrammaticalMismatchExample:
            '*des Forschungsprojekts Hyperschalls (fehlerhafte S-Endung am Projekt-Eigennamen).',
        grammaticalRuleGerman:
            'Enge Apposition bei neutralem Gattungsnomen + Eigenname: Nur "des Forschungsprojekts" trägt das Genitiv-s.',
        grammaticalRuleArabic:
            'البدل الملاصق لأسماء المشاريع: تقتصر علامة الجر على اللفظ العام (des Forschungsprojekts) ويبقى اسم المشروع مجرداً.',
        verbAgreementNumber: 'Singular',
      ),
      // 16. Lockere Apposition im Genitiv
      const PartitiveAppositionModel(
        id: 'PART-4969-16',
        category: PartitiveAppositionCategory.looseAppositionCaseAttraction,
        caseGovernance: AdjectiveMeasureCaseGovernance.congruentAppositionCase,
        domain: CommunicativeDomain.materialScience,
        carrierNounPhrase: 'der Nickelbasislegierung Inconel 718, eines extrem kriechbeständigen Werkstoffs,',
        headNoun: 'Werkstoff',
        fullGermanSentence:
            'Die Dauerfestigkeit der Nickelbasislegierung Inconel 718, eines extrem kriechbeständigen Werkstoffs, garantiert die Betriebssicherheit der Gasturbine.',
        ungrammaticalMismatchExample:
            '*der Legierung Inconel 718, ein extrem kriechbeständiger Werkstoff (Bruch der Genitivkongruenz).',
        grammaticalRuleGerman:
            'Genitivkongruenz in lockerer Apposition: "eines extrem kriechbeständigen Werkstoffs" steht im Genitiv kongruent zum Bezugsnomen.',
        grammaticalRuleArabic:
            'تطابق البدل المجرور بالإضافة: مطابقة تامة في الجر بالكسرة/الإس (eines extrem kriechbeständigen Werkstoffs).',
        verbAgreementNumber: 'Singular',
      ),
    ]);
  }

  List<PartitiveAppositionModel> getByCategory(PartitiveAppositionCategory category) =>
      _catalog.where((p) => p.category == category).toList();

  List<PartitiveAppositionModel> getByGovernance(AdjectiveMeasureCaseGovernance gov) =>
      _catalog.where((p) => p.caseGovernance == gov).toList();

  List<PartitiveAppositionModel> getByDomain(CommunicativeDomain domain) =>
      _catalog.where((p) => p.domain == domain).toList();

  /// Validates case congruency, close/loose apposition rules, and fractional verb agreement.
  PartitiveValidationResult validatePartitiveStructure({
    required PartitiveAppositionCategory category,
    required bool hasCaseAttractionAgreement,
    required bool doesOnlyHeadNounInflectInCloseApposition,
    required bool isFractionalVerbAgreementCorrect,
  }) {
    final List<String> issues = [];
    final List<String> notes = [];

    if (category == PartitiveAppositionCategory.looseAppositionCaseAttraction &&
        !hasCaseAttractionAgreement) {
      issues.add(
          'Kongruenzfehler in lockerer Apposition: Die eingeschobene Apposition muss exakt im Kasus des Bezugsworts stehen (Kasusattraktion).');
    } else if (category == PartitiveAppositionCategory.looseAppositionCaseAttraction) {
      notes.add('Kasusattraktion normgerecht: Vollständige Übereinstimmung zwischen Bezugswort und Apposition.');
    }

    if (category == PartitiveAppositionCategory.closeAppositionTitleName &&
        !doesOnlyHeadNounInflectInCloseApposition) {
      issues.add(
          'Flexionsfehler in enger Apposition: Bei Gattungsname + Eigenname/Stoffname flektiert im Genitiv nur das Gattungswort (z. B. "des Elements Titan", nicht *"des Elements Titans").');
    } else if (category == PartitiveAppositionCategory.closeAppositionTitleName) {
      notes.add('Enge Apposition normgerecht: Keine unzulässige Doppelflexion am Eigennamen.');
    }

    if (category == PartitiveAppositionCategory.fractionalPartitiveVerbAgreement &&
        !isFractionalVerbAgreementCorrect) {
      issues.add(
          'Numeruskongruenz-Fehler bei Bruchpartitiv: Das Verb muss im Plural stehen, wenn das partitive Genitivkomplement im Plural steht (drei Viertel der Sensoren SIND), und im Singular bei unzählbaren Massen (drei Viertel des Speichers IST).');
    } else if (category == PartitiveAppositionCategory.fractionalPartitiveVerbAgreement) {
      notes.add('Numeruskongruenz normgerecht: Verb richtet sich semantisch nach dem partitiven Genitivkomplement.');
    }

    return PartitiveValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      syntacticNotes: notes,
    );
  }

  Map<String, dynamic> generateTelemetrySnapshot() {
    return {
      'totalExemplars': _catalog.length,
      'categoryDistribution': {
        for (var c in PartitiveAppositionCategory.values)
          c.name: _catalog.where((p) => p.category == c).length,
      },
      'governanceDistribution': {
        for (var g in AdjectiveMeasureCaseGovernance.values)
          g.name: _catalog.where((p) => p.caseGovernance == g).length,
      },
      'domainDistribution': {
        for (var d in CommunicativeDomain.values)
          d.name: _catalog.where((p) => p.domain == d).length,
      },
      'cefrLevel': 'CEFR C1-C2 Masterclass Partitive Genitive & Apposition',
      'engineVersion': '1.0.0+subsystem1803',
    };
  }
}
