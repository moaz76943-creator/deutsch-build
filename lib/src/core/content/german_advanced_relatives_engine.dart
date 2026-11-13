import 'dart:collection';

/// Classification of advanced relative clause constructions in C1-C2 German.
enum RelativeClauseType {
  genitiveRelativeDessen(
    'Genitiv-Relativpronomen "dessen" (Maskulinum & Neutrum Singular)',
    'ضمير الوصل في حالة الإضافة للمذكر والمحايد المفرد (dessen)',
    'Referiert auf maskuline oder neutrale Singularköpfe: der Reaktor, dessen Brennelemente; das Labor, dessen Messwerte...',
  ),
  genitiveRelativeDeren(
    'Genitiv-Relativpronomen "deren" (Femininum Singular & Plural)',
    'ضمير الوصل في حالة الإضافة للمؤنث المفرد والجمع بجميع أنواعه (deren)',
    'Referiert auf feminine Köpfe oder alle Pluralformen: die Turbine, deren Wirkungsgrad; die Ingenieure, deren Entwürfe...',
  ),
  prepositionalGenitiveRelative(
    'Präpositionale Genitiv-Relativgefüge (anhand dessen, infolge deren, mit Hilfe derer)',
    'تراكيب صلة الموصول المجرورة بحرف جر متبوع بضمير الإضافة',
    'Eingebettete Präpositionalphrase im Vorfeld des Nebensatzes: Kriterien, anhand deren die Prüfung erfolgte...',
  ),
  partitiveRelativeClause(
    'Partitive Relativgefüge (von denen, unter denen, worunter)',
    'صلة الموصول التبعيضية المقترنة بالمقادير والأعداد',
    'Drückt eine Teilmenge aus: fünfzig Sensoren, von denen zehn kalibriert wurden...',
  ),
  generalizingLocativeRelative(
    'Generalisierende Relativadverbien (wo, wohin, woher)',
    'ظروف الوصل المكانية والوظيفية المحيلة على اسم عام',
    'Ersetzt Präpositionalgefüge bei Raum- und Systembezug: die Anlage, wo die Synthese stattfindet...',
  );

  final String germanTitle;
  final String arabicTitle;
  final String grammaticalDefinition;
  const RelativeClauseType(
    this.germanTitle,
    this.arabicTitle,
    this.grammaticalDefinition,
  );
}

/// Gender and number classification of the antecedent noun (Bezugswort).
enum AntecedentGenderNumber {
  masculineSingular('Maskulinum Singular (der)', 'مذكر مفرد'),
  neuterSingular('Neutrum Singular (das)', 'محايد مفرد'),
  feminineSingular('Femininum Singular (die)', 'مؤنث مفرد'),
  pluralAll('Plural alle Genera (die)', 'جمع لجميع الأجناس');

  final String de;
  final String ar;
  const AntecedentGenderNumber(this.de, this.ar);
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

/// Model of an advanced relative clause construction with its agreement dynamics.
class AdvancedRelativeModel {
  final String id;
  final RelativeClauseType relativeType;
  final String antecedentNoun;
  final AntecedentGenderNumber antecedentGenderNumber;
  final String relativePronounPhrase;
  final String possessedNounInRelativeClause;
  final String fullSentence;
  final CommunicativeDomain domain;
  final String arabicTranslation;
  final String grammaticalAnalysisArabic;
  final String grammaticalAnalysisGerman;
  final String commonAgreementTrap;
  final String topologicalRuleSummary;

  const AdvancedRelativeModel({
    required this.id,
    required this.relativeType,
    required this.antecedentNoun,
    required this.antecedentGenderNumber,
    required this.relativePronounPhrase,
    required this.possessedNounInRelativeClause,
    required this.fullSentence,
    required this.domain,
    required this.arabicTranslation,
    required this.grammaticalAnalysisArabic,
    required this.grammaticalAnalysisGerman,
    required this.commonAgreementTrap,
    required this.topologicalRuleSummary,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'relativeType': relativeType.name,
    'antecedentNoun': antecedentNoun,
    'antecedentGenderNumber': antecedentGenderNumber.name,
    'relativePronounPhrase': relativePronounPhrase,
    'possessedNounInRelativeClause': possessedNounInRelativeClause,
    'fullSentence': fullSentence,
    'domain': domain.name,
    'arabicTranslation': arabicTranslation,
    'grammaticalAnalysisArabic': grammaticalAnalysisArabic,
    'grammaticalAnalysisGerman': grammaticalAnalysisGerman,
    'commonAgreementTrap': commonAgreementTrap,
    'topologicalRuleSummary': topologicalRuleSummary,
  };
}

/// Verification report container for relative pronoun agreement and topology.
class RelativeValidationReport {
  final bool isValid;
  final bool isPronounGenderNumberCorrect;
  final bool avoidsPossessedNounInterference;
  final List<String> issues;
  final List<String> recommendations;
  final String arabicDiagnosticVerdict;

  const RelativeValidationReport({
    required this.isValid,
    required this.isPronounGenderNumberCorrect,
    required this.avoidsPossessedNounInterference,
    required this.issues,
    required this.recommendations,
    required this.arabicDiagnosticVerdict,
  });
}

/// Sovereign engine governing German Advanced Relative Clauses & Genitive/Partitive Anaphora.
class GermanAdvancedRelativesEngine {
  final List<AdvancedRelativeModel> _catalog = [];

  GermanAdvancedRelativesEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<AdvancedRelativeModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    // 1. dessen (Maskulinum Singular) - Renewable Energy
    _catalog.add(
      const AdvancedRelativeModel(
        id: 'REL-DESSEN-MASK-01',
        relativeType: RelativeClauseType.genitiveRelativeDessen,
        antecedentNoun: 'der Hochspannungs-Transformator',
        antecedentGenderNumber: AntecedentGenderNumber.masculineSingular,
        relativePronounPhrase: 'dessen',
        possessedNounInRelativeClause: 'sekundäre Kühlkreisläufe (Plural!)',
        fullSentence:
            'Der Hochspannungs-Transformator, dessen sekundäre Kühlkreisläufe gestern gewartet wurden, arbeitet nun wieder mit voller Nennleistung.',
        domain: CommunicativeDomain.renewableEnergyGrid,
        arabicTranslation:
            'محول الجهد الفائق، الذي خضعت دارات تبريده الثانوية للصيانة بالأمس، يعمل الآن مجدداً بكامل قدرته الاسمية.',
        grammaticalAnalysisArabic:
            'ضمير الوصل في حالة الإضافة "dessen": يطابق المبدل منه المذكر المفرد (der Transformator) دون التأثر بجمع الاسم المملوك اللاحق (Kühlkreisläufe). الاسم المملوك يأتي مجرداً بدون أداة تعريف.',
        grammaticalAnalysisGerman:
            'Genitiv-Relativpronomen "dessen" richtet sich in Genus und Numerus strikt nach dem Bezugswort ("der Transformator"). Das bezogene Nomen ("Kühlkreisläufe") steht artikellos.',
        commonAgreementTrap:
            'Häufigster Fehler: Verwendung von "*deren" wegen des pluralischen Folgeworts ("Kühlkreisläufe"). Das Relativpronomen kongruiert ausschließlich mit dem Bezugsnomen!',
        topologicalRuleSummary:
            'Regel: Maskulinum/Neutrum Singular -> immer "dessen", völlig unabhängig von Genus/Numerus des nachfolgenden Nomens.',
      ),
    );

    // 2. deren (Femininum Singular) - Aerospace Aviation
    _catalog.add(
      const AdvancedRelativeModel(
        id: 'REL-DEREN-FEM-02',
        relativeType: RelativeClauseType.genitiveRelativeDeren,
        antecedentNoun: 'die Trägerrakete',
        antecedentGenderNumber: AntecedentGenderNumber.feminineSingular,
        relativePronounPhrase: 'deren',
        possessedNounInRelativeClause: 'autonomes Lenksystem (Neutrum Singular)',
        fullSentence:
            'Die Trägerrakete, deren autonomes Lenksystem auf Quanten-Kreiselkompassen basiert, hob pünktlich zur Mission ab.',
        domain: CommunicativeDomain.aerospaceAndAviation,
        arabicTranslation:
            'صاروخ الإطلاق، الذي تعتمد منظومة توجيهه الذاتية على بوصلات جيروسكوبية كمومية، انطلق في موعده المحدد للمهمة.',
        grammaticalAnalysisArabic:
            'ضمير الوصل في حالة الإضافة "deren": يعود على المؤنث المفرد (die Trägerrakete). لا يتأثر بكون المنظومة التابعة محايدة (autonomes Lenksystem).',
        grammaticalAnalysisGerman:
            'Genitiv-Relativpronomen "deren" für feminin Singular. Das Possessum ("Lenksystem") steht im Akkusativ/Nominativ ohne Begleiterartikel.',
        commonAgreementTrap:
            'Falsches Einsetzen von "*dessen" durch Beeinflussung des neutralen "Lenksystem".',
        topologicalRuleSummary:
            'Regel: Femininum Singular -> immer "deren" + artikelloses Nomen.',
      ),
    );

    // 3. dessen (Neutrum Singular) - Industrial Robotics
    _catalog.add(
      const AdvancedRelativeModel(
        id: 'REL-DESSEN-NEUT-03',
        relativeType: RelativeClauseType.genitiveRelativeDessen,
        antecedentNoun: 'das mechatronische Greifersystem',
        antecedentGenderNumber: AntecedentGenderNumber.neuterSingular,
        relativePronounPhrase: 'dessen',
        possessedNounInRelativeClause: 'pneumatische Druckventile (Plural)',
        fullSentence:
            'Das mechatronische Greifersystem, dessen pneumatische Druckventile neu kalibriert wurden, greift empfindliche Wafer absolut erschütterungsfrei.',
        domain: CommunicativeDomain.industrialRobotics,
        arabicTranslation:
            'نظام القابض الميكاترونيكي، الذي جرت إعادة معايرة صمامات ضغطه الهوائية حديثاً، يلتقط رقاقات السيليكون الحساسة دون أي اهتزاز.',
        grammaticalAnalysisArabic:
            'ضمير الإضافة للمحايد "dessen": يطابق المحايد المفرد (das Greifersystem)، وتبقى صمامات الضغط جمعاً تحدد تصريف الفعل في نهاية الجملة (wurden).',
        grammaticalAnalysisGerman:
            'Neutrum Singular verlangt "dessen". Das Pluralsubjekt des Relativsatzes ("Druckventile") steuert das finite Hilfsverb am Satzende ("wurden").',
        commonAgreementTrap:
            'Falsches Verwenden von "*deren" wegen Plural des Folgeworts.',
        topologicalRuleSummary:
            'Regel: Neutrum Singular erfordert ausnahmslos "dessen".',
      ),
    );

    // 4. deren (Plural aller Genera) - Civil Infrastructure
    _catalog.add(
      const AdvancedRelativeModel(
        id: 'REL-DEREN-PLUR-04',
        relativeType: RelativeClauseType.genitiveRelativeDeren,
        antecedentNoun: 'die Bauprüfer (Plural)',
        antecedentGenderNumber: AntecedentGenderNumber.pluralAll,
        relativePronounPhrase: 'deren',
        possessedNounInRelativeClause: 'detaillierter Abschlussbericht (Maskulinum Singular)',
        fullSentence:
            'Die Bauprüfer, deren detaillierter Abschlussbericht die Freigabe des Spannbetontunnels empfahl, lobten die hohe Materialgüte.',
        domain: CommunicativeDomain.civilInfrastructure,
        arabicTranslation:
            'مدققو البناء، الذين أوصى تقريرهم الختامي المفصل باعتماد نفق الخرسانة مسبقة الإجهاد، أشادوا بالجودة العالية للمواد.',
        grammaticalAnalysisArabic:
            'ضمير الإضافة للجمع "deren": يعود على المدققين (die Bauprüfer - Plural). التقرير المفرد المذكر (Bericht) لا يغير صيغة ضمير الوصل الجمعية.',
        grammaticalAnalysisGerman:
            'Plural-Antezedens verlangt strikt "deren". Der maskuline Singular des Folgeausdrucks ("Bericht") beeinflusst das Relativpronomen nicht.',
        commonAgreementTrap:
            'Verwechslung mit "*dessen" durch gedankliche Ausrichtung auf den Einzahl-Bericht.',
        topologicalRuleSummary:
            'Regel: Plural aller Genera -> ausnahmslos "deren".',
      ),
    );

    // 5. anhand dessen (Prepositional Genitive Relative - Neutrum) - Material Science
    _catalog.add(
      const AdvancedRelativeModel(
        id: 'REL-PREP-ANHAND-05',
        relativeType: RelativeClauseType.prepositionalGenitiveRelative,
        antecedentNoun: 'das spektroskopische Messverfahren',
        antecedentGenderNumber: AntecedentGenderNumber.neuterSingular,
        relativePronounPhrase: 'anhand dessen',
        possessedNounInRelativeClause: 'die chemische Reinheit',
        fullSentence:
            'Das spektroskopische Messverfahren, anhand dessen die Forscher die chemische Reinheit der Nanofasern ermittelten, erwies sich als äußerst zuverlässig.',
        arabicTranslation:
            'طريقة القياس الطيفي، التي استند إليها الباحثون في تحديد النقاء الكيميائي لألياف النانو، أثبتت أنها موثوقة للغاية.',
        grammaticalAnalysisArabic:
            'تركيب حرف جر إضافة متداخل (anhand dessen): يدمج حرف الجر anhand مع ضمير الوصل المحايد dessen، ويشغل صدر جملة الصلة مع تأخر الفعل (ermittelten) إلى الختام.',
        grammaticalAnalysisGerman:
            'Präpositional-Relativkomplex: Genitivpräposition "anhand" verschmilzt syntaktisch mit dem neutralen Pronomen "dessen". Verb-Endstellung im Relativsatz.',
        commonAgreementTrap:
            'Falsches Einfügen von "*anhand dem" oder "*anhand welches" (stilistisch minderwertig).',
        topologicalRuleSummary:
            'Regel: Präposition + dessen/deren steht geschlossen am Kopf des Relativsatzes.',
      ),
    );

    // 6. infolge deren / derer (Prepositional Genitive Relative - Plural) - Renewable Energy
    _catalog.add(
      const AdvancedRelativeModel(
        id: 'REL-PREP-INFOLGE-06',
        relativeType: RelativeClauseType.prepositionalGenitiveRelative,
        antecedentNoun: 'die schweren Sturmböen (Plural)',
        antecedentGenderNumber: AntecedentGenderNumber.pluralAll,
        relativePronounPhrase: 'infolge deren (oder: derer)',
        possessedNounInRelativeClause: 'mehrere Windturbinen',
        fullSentence:
            'Die schweren Sturmböen, infolge deren mehrere Windturbinen automatisch abgeschaltet wurden, klangen am späten Abend ab.',
        arabicTranslation:
            'عواصف الرياح العاتية، التي تم على إثرها إيقاف عدة توربينات رياح تلقائياً، هدأت حدتها في ساعة متأخرة من المساء.',
        grammaticalAnalysisArabic:
            'تركيب الإضافة السببي (infolge deren / derer): يعود على جمع مؤنث/مذكر (Sturmböen)، متبوعاً بجملة صلة موصول ينتهي فعلها المساعد بـ wurden.',
        grammaticalAnalysisGerman:
            'Kausale Präposition "infolge" mit Plural-Relativpronomen "deren" (variativ auch "derer").',
        commonAgreementTrap:
            'Verwechslung mit dem Adverb "*infolgedessen" (Adverb vs. Relativpronomengefüge).',
        topologicalRuleSummary:
            'Duden: Nach Präpositionen mit Genitiv ist bei Plural "deren" und "derer" zulässig.',
      ),
    );

    // 7. von denen (Partitive Relative Clause) - Maritime Logistics
    _catalog.add(
      const AdvancedRelativeModel(
        id: 'REL-PART-VON-DENEN-07',
        relativeType: RelativeClauseType.partitiveRelativeClause,
        antecedentNoun: 'achtzig Frachtschiffe (Plural)',
        antecedentGenderNumber: AntecedentGenderNumber.pluralAll,
        relativePronounPhrase: 'von denen',
        possessedNounInRelativeClause: 'zwölf Einheiten (Teilmenge)',
        fullSentence:
            'Der Reederverband disponiert achtzig Frachtschiffe, von denen zwölf Einheiten bereits mit modernen LNG-Antrieben ausgerüstet sind.',
        arabicTranslation:
            'تدير رابطة شركات الملاحة ثمانين سفينة شحن، من بينها اثنتا عشرة وحدة مجهزة بالفعل بمحركات حديثة تعمل بالغاز الطبيعي المسال.',
        grammaticalAnalysisArabic:
            'صلة موصول تبعيضية (Partitiv): استخدام "von denen" لتحديد فئة جزئية من المجموع الكلي، مع استقرار الفعل المصرف (sind) في الختام.',
        grammaticalAnalysisGerman:
            'Partitive Präpositionalgruppe "von denen" zur Selektion einer quantitativen Untermenge aus dem pluralischen Gesamtkollektiv.',
        commonAgreementTrap:
            'Fälschliches Verwenden von "*von welche" oder "*worunter" bei zählbaren Personen/Schiffen.',
        topologicalRuleSummary:
            'Regel: Zählbare diskrete Einheiten im Plural erfordern partitiv "von denen" + Zahlwort.',
      ),
    );

    // 8. unter denen (Partitive Relative with Locative Metaphor) - Industrial Robotics
    _catalog.add(
      const AdvancedRelativeModel(
        id: 'REL-PART-UNTER-DENEN-08',
        relativeType: RelativeClauseType.partitiveRelativeClause,
        antecedentNoun: 'die eingereichten Fertigungskonzepte (Plural)',
        antecedentGenderNumber: AntecedentGenderNumber.pluralAll,
        relativePronounPhrase: 'unter denen',
        possessedNounInRelativeClause: 'das modulare Roboterzellen-Design',
        fullSentence:
            'Die Fachjury evaluierte zwanzig Fertigungskonzepte, unter denen sich das modulare Roboterzellen-Design als Siegerentwurf durchsetzte.',
        arabicTranslation:
            'قيّمت لجنة التحكيم المتخصصة عشرين مفهوماً تصنيعياً، برز من بينها تصميم خلايا الروبوتات المعيارية كالتصميم الفائز الأول.',
        grammaticalAnalysisArabic:
            'شبه جملة صلة موصول تبعيضية بـ "unter denen": تفيد الاختيار والانتقاء من بين خيارات متعددة مع تصريف الفعل المنعكس في النهاية (durchsetzte).',
        grammaticalAnalysisGerman:
            'Partitiv-selektive Einbettung mit Präposition "unter" + Dativ Plural ("denen").',
        commonAgreementTrap:
            'Verwechslung von "unter denen" mit "*unter denen sich durchsetzten" (Numerus des Satzsubjekts beachten: Design = Singular -> durchsetzte!).',
        topologicalRuleSummary:
            'Das finite Verb kongruiert mit dem Subjekt des Relativsatzes, nicht mit dem Plural-Bezugsnomen.',
      ),
    );

    // 9. dessen (Maskulinum mit Präposition vor Pronomen) - Aerospace Aviation
    _catalog.add(
      const AdvancedRelativeModel(
        id: 'REL-MIT-DESSEN-AERO-09',
        relativeType: RelativeClauseType.prepositionalGenitiveRelative,
        antecedentNoun: 'der Flugsimulator',
        antecedentGenderNumber: AntecedentGenderNumber.masculineSingular,
        relativePronounPhrase: 'mit dessen Hilfe',
        possessedNounInRelativeClause: 'die Piloten',
        fullSentence:
            'Die Fluggesellschaft investierte in einen neuen Flugsimulator, mit dessen Hilfe die Piloten komplexe Triebwerksausfälle trainieren können.',
        arabicTranslation:
            'استثمرت شركة الطيران في جهاز محاكاة طيران جديد، يستطيع الطيارون بمساعدته والاعتماد عليه التدرب على أعطال المحركات المعقدة.',
        grammaticalAnalysisArabic:
            'التركيب الإضافي الوسيط: "mit dessen Hilfe" (بمساعدته / بفضله) يربط أداة الجر مع ضمير الوصل المذكر، يليه الفاعل والخبر والفعل الناقص بالختام (trainieren können).',
        grammaticalAnalysisGerman:
            'Instrumentale Phrasenfügung: Präposition "mit" + Genitivattribut "dessen" + Nomen "Hilfe" im Dativ.',
        commonAgreementTrap:
            'Falsches Einfügen von "*mit der Hilfe von dem" (schlechter Stil).',
        topologicalRuleSummary:
            'Formel: mit dessen Hilfe (Mask/Neutr) / mit deren Hilfe (Fem/Plur).',
      ),
    );

    // 10. mit deren Hilfe (Femininum Singular) - Software Engineering
    _catalog.add(
      const AdvancedRelativeModel(
        id: 'REL-MIT-DEREN-SOFT-10',
        relativeType: RelativeClauseType.prepositionalGenitiveRelative,
        antecedentNoun: 'die kryptografische Signaturbibliothek',
        antecedentGenderNumber: AntecedentGenderNumber.feminineSingular,
        relativePronounPhrase: 'mit deren Hilfe',
        possessedNounInRelativeClause: 'das Sicherheitsmodul',
        fullSentence:
            'Das Entwicklerteam integrierte eine kryptografische Signaturbibliothek, mit deren Hilfe das Sicherheitsmodul alle Transaktionen manipulationssicher signiert.',
        arabicTranslation:
            'دمج فريق المطورين مكتبة توقيع تشفيرية، تقوم وحدة الأمان بمساعدتها بتوقيع كافة المعاملات البرمجية ضد أي تلاعب.',
        grammaticalAnalysisArabic:
            'مطابقة المؤنث المفرد في التركيب الإضافي: "mit deren Hilfe" تعود على المكتبة المؤنثة (die Signaturbibliothek).',
        grammaticalAnalysisGerman:
            'Feminines Bezugswort ("die Bibliothek") steuert das Genitivpronomen "deren" innerhalb des Gefüges "mit deren Hilfe".',
        commonAgreementTrap:
            'Verwechslung mit "*mit dessen Hilfe" bei Unklarheit über das Femininum von "Bibliothek".',
        topologicalRuleSummary:
            'Bei femininen Substantiven gilt ausnahmslos "mit deren Hilfe".',
      ),
    );

    // 11. wo (Locative Generalizing Relative) - Civil Infrastructure
    _catalog.add(
      const AdvancedRelativeModel(
        id: 'REL-LOC-WO-CIVIL-11',
        relativeType: RelativeClauseType.generalizingLocativeRelative,
        antecedentNoun: 'die Tiefbaustelle',
        antecedentGenderNumber: AntecedentGenderNumber.feminineSingular,
        relativePronounPhrase: 'wo',
        possessedNounInRelativeClause: 'die Dichtwand',
        fullSentence:
            'Die Bauleiter inspizierten die tiefe Baugrube, wo gegenwärtig die unterirdische Dichtwand errichtet wird.',
        arabicTranslation:
            'تفقد مديرو الموقع حفرة البناء العميقة، حيث يجري تشييد الجدار الحاجز العازل تحت الأرض في الوقت الراهن.',
        grammaticalAnalysisArabic:
            'ظرف الوصل المكاني "wo": يحل محل شبه الجملة المجرورة (in der / an der) في الاستعمال الفصيح للربط بمكان جغرافي أو ورشة عمل.',
        grammaticalAnalysisGerman:
            'Lokales Relativadverb "wo" substituiert eine Präpositionalphrase ("in der Baugrube") und wahrt die Verb-Endstellung ("errichtet wird").',
        commonAgreementTrap:
            'Verwendung von "*in welcher" ist formeller, "wo" ist jedoch standardsprachlich bei räumlichen Örtlichkeiten absolut legitim.',
        topologicalRuleSummary:
            'Relativadverb "wo" fungiert syntaktisch als Konnektor mit zwingender Verb-Endstellung.',
      ),
    );

    // 12. wohin (Directional Relative) - Maritime Logistics
    _catalog.add(
      const AdvancedRelativeModel(
        id: 'REL-LOC-WOHIN-MARITIME-12',
        relativeType: RelativeClauseType.generalizingLocativeRelative,
        antecedentNoun: 'das neue Tiefwasserterminal',
        antecedentGenderNumber: AntecedentGenderNumber.neuterSingular,
        relativePronounPhrase: 'wohin',
        possessedNounInRelativeClause: 'die Großschiffe',
        fullSentence:
            'Die Hafenbehörde erweiterte das neue Tiefwasserterminal, wohin die vollbeladenen Großcontainerschiffe künftig umgeleitet werden.',
        arabicTranslation:
            'وسّعت سلطة الموانئ محطة المياه العميقة الجديدة، التي سيتم توجيه سفن الحاويات العملاقة المحملة بالكامل إليها مستقبلاً.',
        grammaticalAnalysisArabic:
            'ظرف الوصل الحركي الاتجاهي "wohin": يعبر عن الحركة صوب الهدف (an das / in das)، ويغني عن التراكيب المجرورة الثقيلة.',
        grammaticalAnalysisGerman:
            'Direktionales Relativadverb "wohin" drückt eine zielgerichtete Bewegung zum Bezugsort aus.',
        commonAgreementTrap:
            'Verwechslung von statischem "wo" mit direktionalem "wohin".',
        topologicalRuleSummary:
            'Zielortsbewegung verlangt zwingend "wohin", nicht "wo".',
      ),
    );

    // 13. bezüglich dessen (Prepositional Genitive - Maskulinum) - Renewable Energy
    _catalog.add(
      const AdvancedRelativeModel(
        id: 'REL-PREP-BEZUEGLICH-13',
        relativeType: RelativeClauseType.prepositionalGenitiveRelative,
        antecedentNoun: 'der Netzentwicklungsplan',
        antecedentGenderNumber: AntecedentGenderNumber.masculineSingular,
        relativePronounPhrase: 'bezüglich dessen',
        possessedNounInRelativeClause: 'die Bundesnetzagentur',
        fullSentence:
            'Die Ingenieure überarbeiteten den Netzentwicklungsplan, bezüglich dessen die Regulierungsbehörde weitere Trassenprüfungen angefordert hatte.',
        arabicTranslation:
            'نقح المهندسون خطة تطوير الشبكة، التي طلبت الهيئة التنظيمية بشأنها إجراء تدقيقات إضافية لمسارات خطوط النقل.',
        grammaticalAnalysisArabic:
            'حرف الجر الإضافي "bezüglich dessen": يفيد الاختصاص والإحالة الموضوعية (بشأن / بخصوص كذا)، متبوعاً بجملة صلة تامة.',
        grammaticalAnalysisGerman:
            'Thematische Präpositional-Relativphrase mit "bezüglich" + maskulinem Genitiv "dessen".',
        commonAgreementTrap:
            'Grammatikalischer Fehler: "*bezüglich dem" (bezüglich verlangt strikt den Genitiv!).',
        topologicalRuleSummary:
            'Formel: bezüglich dessen (Mask/Neutr) / bezüglich deren (Fem/Plur).',
      ),
    );

    // 14. worunter (Pronominal Adverbial Partitive) - Material Science
    _catalog.add(
      const AdvancedRelativeModel(
        id: 'REL-WORUNTER-MAT-14',
        relativeType: RelativeClauseType.partitiveRelativeClause,
        antecedentNoun: 'zahlreiche experimentelle Proben (Plural)',
        antecedentGenderNumber: AntecedentGenderNumber.pluralAll,
        relativePronounPhrase: 'worunter',
        possessedNounInRelativeClause: 'drei supraleitende Legierungen',
        fullSentence:
            'Das Forschungslabor analysierte zahlreiche experimentelle Proben, worunter sich drei supraleitende Legierungen mit hoher Übergangstemperatur befanden.',
        arabicTranslation:
            'حلل المختبر البحثي عينات تجريبية متعددة، كان من بينها ثلاث سبائك فائقة التوصيل ذات درجة حرارة تحول حرجة عالية.',
        grammaticalAnalysisArabic:
            'ظرف الوصل التبعيضي "worunter": يعبر عن الاندراج الضمني لسبائك ضمن مجموعة العينات المفحوصة.',
        grammaticalAnalysisGerman:
            'Pronominaladverbiales Relativum "worunter" fungiert partitiv bei stofflichen oder unpersönlichen Sachverhalten.',
        commonAgreementTrap:
            'Bei Personen muss zwingend "unter denen" stehen, "worunter" ist nur für Sachen und Phänomene zulässig.',
        topologicalRuleSummary:
            'Regel: Personen -> unter denen; Sachen/Materialien -> worunter (oder: unter denen).',
      ),
    );

    // 15. dessen (Neutrum - Doppel-Inversion im Hauptsatz vermieden) - Software Engineering
    _catalog.add(
      const AdvancedRelativeModel(
        id: 'REL-DESSEN-CORE-15',
        relativeType: RelativeClauseType.genitiveRelativeDessen,
        antecedentNoun: 'das kryptografische Schlüsselpaar',
        antecedentGenderNumber: AntecedentGenderNumber.neuterSingular,
        relativePronounPhrase: 'dessen',
        possessedNounInRelativeClause: 'öffentlicher Schlüssel (Maskulinum Singular)',
        fullSentence:
            'Das kryptografische Schlüsselpaar, dessen öffentlicher Schlüssel im zentralen Zertifikatsserver hinterlegt ist, schützt die Kommunikation vor Abhörmaßnahmen.',
        domain: CommunicativeDomain.softwareEngineering,
        arabicTranslation:
            'زوج المفاتيح التشفيرية، الذي أُودع مفتاحه العام في خادم الشهادات المركزي، يحمي الاتصالات من محاولات التنصت.',
        grammaticalAnalysisArabic:
            'مطابقة المحايد بـ dessen: "das Schlüsselpaar" محايد، ومفتاحه العام المذكر (Schlüssel) لا يغير صيغة dessen، ويأتي مجرداً من أداة التعريف.',
        grammaticalAnalysisGerman:
            'Neutrum Singular Antezedens steuert "dessen". Das maskuline Prädikatsnomen "öffentlicher Schlüssel" behält seine starke Endung ohne Artikel.',
        commonAgreementTrap:
            'Falsches Einfügen eines Artikels: "*dessen der öffentliche Schlüssel" ist ungrammatisch.',
        topologicalRuleSummary:
            'Das Nomen nach dessen/deren steht IMMER ohne Artikel!',
      ),
    );

    // 16. deren (Plural - Abstraktum als Possessum) - Civil Infrastructure
    _catalog.add(
      const AdvancedRelativeModel(
        id: 'REL-DEREN-ABSTRAKT-16',
        relativeType: RelativeClauseType.genitiveRelativeDeren,
        antecedentNoun: 'die beteiligten Ingenieurbüros (Plural)',
        antecedentGenderNumber: AntecedentGenderNumber.pluralAll,
        relativePronounPhrase: 'deren',
        possessedNounInRelativeClause: 'fachliche Kompetenz (Femininum Singular)',
        fullSentence:
            'Die beteiligten Ingenieurbüros, deren fachliche Kompetenz im Brückenbau weltweit anerkannt ist, erhielten den Planungsauftrag für das Megaprojekt.',
        arabicTranslation:
            'المكاتب الهندسية المشاركة، التي تحظى كفاءتها التخصصية في بناء الجسور باعتراف وتقدير عالمي، فازت بعقد التخطيط للمشروع العملاق.',
        grammaticalAnalysisArabic:
            'ضمير الإضافة للجمع "deren": يعود على المكاتب الهندسية في صيغة الجمع، وتتبعه الكفاءة المفردة المؤنثة (Kompetenz) بدون أداة.',
        grammaticalAnalysisGerman:
            'Pluralische Genitiv-Anapher "deren" gefolgt von abstraktem Femininum "Kompetenz".',
        commonAgreementTrap:
            'Falsches Verwenden von "*dessen" durch unbewusste Anlehnung an das Singular-Subjekt "Kompetenz".',
        topologicalRuleSummary:
            'Plural bleibt Plural: stets "deren", niemals dessen.',
      ),
    );
  }

  /// Validates a genitive relative pronoun against its antecedent noun's gender and number.
  RelativeValidationReport validateGenitiveRelative({
    required AntecedentGenderNumber genderNumber,
    required String relativePronounUsed,
    required bool containsIllegalArticleAfterPronoun,
  }) {
    final issues = <String>[];
    final recommendations = <String>[];

    final isMaskOrNeutr =
        genderNumber == AntecedentGenderNumber.masculineSingular ||
        genderNumber == AntecedentGenderNumber.neuterSingular;

    final expectedPronoun = isMaskOrNeutr ? 'dessen' : 'deren';
    final actual = relativePronounUsed.trim().toLowerCase();

    if (actual != expectedPronoun && !actual.contains(expectedPronoun)) {
      issues.add(
        'Kongruenzfehler beim Relativpronomen: Für $genderNumber ist "$actual" fehlerhaft. Das korrekte Genitiv-Relativpronomen lautet "$expectedPronoun".',
      );
      recommendations.add(
        'Richten Sie das Pronomen ausschließlich nach Genus und Numerus des Bezugsworts (Mask/Neutr -> dessen; Fem/Plur -> deren). Lassen Sie sich nicht vom nachfolgenden Nomen beirren!',
      );
    }

    if (containsIllegalArticleAfterPronoun) {
      issues.add(
        'Syntaktischer Fehler: Nach "dessen" oder "deren" darf NIEMALS ein Artikel (der, die, das, ein) stehen.',
      );
      recommendations.add(
        'Löschen Sie den Artikel nach dem Pronomen (z. B. "dessen Motor", nicht "*dessen der Motor").',
      );
    }

    final isValid = issues.isEmpty;
    final verdict = isValid
        ? 'التركيب النحوي لضمير الوصل في حالة الإضافة متطابق تماماً مع جنس وعدة الاسم الموصوف وفق أعلى معايير C1-C2.'
        : 'تم رصد خطأ في تطابق ضمير الوصل الإضافي (استخدام dessen بدلاً من deren أو العكس، أو إدراج أداة تعريف غير جائزة).';

    return RelativeValidationReport(
      isValid: isValid,
      isPronounGenderNumberCorrect: actual == expectedPronoun || actual.contains(expectedPronoun),
      avoidsPossessedNounInterference: !containsIllegalArticleAfterPronoun,
      issues: issues,
      recommendations: recommendations,
      arabicDiagnosticVerdict: verdict,
    );
  }

  List<AdvancedRelativeModel> filterByType(RelativeClauseType type) {
    return _catalog.where((item) => item.relativeType == type).toList();
  }

  List<AdvancedRelativeModel> filterByDomain(CommunicativeDomain domain) {
    return _catalog.where((item) => item.domain == domain).toList();
  }
}
