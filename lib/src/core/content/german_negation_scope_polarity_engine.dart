import 'dart:collection';

/// Classification of German negation scope and polarity architectures.
enum NegationScopeType {
  sententialNegationSatznegation(
    'Satznegation (Rechts-Positionierung vor rechter Klammer / Prädikatsergänzung)',
    'نفي الجملة الكلي (موضع أداة النفي قبل القوس الفعلي الأيمن أو المكملات الوثيقة)',
    'Negiert die gesamte Proposition. "nicht" steht HINTER definiten Objekten/Pronomen, aber VOR Prädikativa, Direktivergänzungen, Präpositionalobjekten und Funktionsverbgefügen.',
  ),
  constituentFocusNegationSondernegation(
    'Sondernegation / Kontrastive Teilnegation (nicht X, sondern Y)',
    'النفي الجزئي التبايني (نفي عنصر محدد وحصر الإثبات في بديله)',
    '"nicht" steht unmittelbar VOR dem negierten Satzglied und verlangt meist eine explizite Korrektur mit "sondern": "Nicht der Sensor, sondern das Kabel ist defekt."',
  ),
  indefiniteArticleNegationKein(
    'Indefinitartikel-Negation (kein- statt nicht + ein- / Nullartikel)',
    'نفي النكرة والأسماء المجردة عبر (kein-) بدلاً من (nicht ein)',
    'Obligatorischer Ersatz von "nicht + ein/e" oder Nullartikel durch das Negationspronomen "kein-": "Wir haben keinen Spannungsabfall gemessen."',
  ),
  negativePolarityItemLicensing(
    'Negative Polaritätselemente / NPIs (im Geringsten, auch nur ansatzweise, jemals)',
    'عناصر القطبية السالبة المقيدة بالنفي (لا تصح إلا في سياق نفي صريح أو تساؤل)',
    'Ausdrücke wie "auch nur im Geringsten", "sonderlich" oder "jemals" sind nur in negativen oder abwärts-monotonen Kontexten grammatisch lizenziert.',
  ),
  diplomaticLitotesDoubleNegation(
    'Diplomatische Litotes (Doppelte Negation: nicht unbedeutend, keineswegs ausgeschlossen)',
    'أسلوب التخفيف الدبلوماسي بالنفي المزدوج (ليس غير ذي شأن / لا يستبعد البتة)',
    'Zwei Negationen heben sich semantisch nicht schlicht auf, sondern erzeugen eine vorsichtig-diplomatische Bejahung im Gutachtenstil (C1-C2).',
  ),
  lexicalNegativeConcordProhibition(
    'Verbot doppelter Satznegation (kein + nicht -> ungrammatisch im Standarddeutschen)',
    'حظر تعدد أدوات النفي غير المقصود في الألمانية الفصحى (منع التطابق السلبي)',
    'Im Gegensatz zu manchen Sprachen führt doppeltes "kein + nicht" im Standarddeutschen zu einer unfreiwilligen Bejahung oder Ungrammatikalität.',
  );

  final String deTitle;
  final String arTitle;
  final String syntacticCriteria;
  const NegationScopeType(this.deTitle, this.arTitle, this.syntacticCriteria);
}

/// Topological boundary that determines where "nicht" sits in the Mittelfeld.
enum MittelfeldNegationAnchor {
  afterDefiniteObjects('Hinter definiten Akkusativ-/Dativobjekten', 'بعد المفاعيل المعرفة والضمائر'),
  beforePrepositionalObject('Unmittelbar vor dem Präpositionalobjekt', 'مباشرة قبل المفعول به المجرور بحرف جر'),
  beforeDirectionalOrSituative('Vor obligatorischer Direktiv-/Situativergänzung', 'قبل المكمل الاتجاهي أو المكاني الإلزامي'),
  beforeFvgNominalPart('Vor dem Nomen eines Funktionsverbgefüges', 'قبل الاسم في تراكيب الأفعال الوظيفية'),
  immediatelyBeforeFocusedConstituent('Direkt vor dem kontrastierten Fokusglied', 'مباشرة قبل العنصر المقصود بالنفي التبايني');

  final String de;
  final String ar;
  const MittelfeldNegationAnchor(this.de, this.ar);
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

/// Structural model of a German negation scope or polarity occurrence.
class NegationScopePolarityModel {
  final String id;
  final NegationScopeType scopeType;
  final MittelfeldNegationAnchor anchorPosition;
  final CommunicativeDomain domain;
  final String negationOperator;
  final String fullGermanSentence;
  final String ungrammaticalPlacementExample;
  final String semanticEffectGerman;
  final String semanticEffectArabic;
  final bool containsLicensedNpi;
  final bool isDiplomaticLitotes;

  const NegationScopePolarityModel({
    required this.id,
    required this.scopeType,
    required this.anchorPosition,
    required this.domain,
    required this.negationOperator,
    required this.fullGermanSentence,
    required this.ungrammaticalPlacementExample,
    required this.semanticEffectGerman,
    required this.semanticEffectArabic,
    this.containsLicensedNpi = false,
    this.isDiplomaticLitotes = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'scopeType': scopeType.name,
    'anchorPosition': anchorPosition.name,
    'domain': domain.name,
    'negationOperator': negationOperator,
    'fullGermanSentence': fullGermanSentence,
    'ungrammaticalPlacementExample': ungrammaticalPlacementExample,
    'semanticEffectGerman': semanticEffectGerman,
    'semanticEffectArabic': semanticEffectArabic,
    'containsLicensedNpi': containsLicensedNpi,
    'isDiplomaticLitotes': isDiplomaticLitotes,
  };
}

/// Validation result for negation placement and polarity licensing.
class NegationValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<String> syntacticNotes;

  const NegationValidationResult({
    required this.isValid,
    required this.issues,
    required this.syntacticNotes,
  });
}

/// Core Engine managing German Negation Scope, Polarity Licensing & Litotes.
class GermanNegationScopePolarityEngine {
  final List<NegationScopePolarityModel> _catalog = [];

  GermanNegationScopePolarityEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<NegationScopePolarityModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    _catalog.addAll([
      // 1. Satznegation hinter definitem Objekt
      const NegationScopePolarityModel(
        id: 'NEG-4968-01',
        scopeType: NegationScopeType.sententialNegationSatznegation,
        anchorPosition: MittelfeldNegationAnchor.afterDefiniteObjects,
        domain: CommunicativeDomain.renewableEnergyGrid,
        negationOperator: 'nicht',
        fullGermanSentence:
            'Der Wechselrichter hat den kritischen Frequenzabfall im Inselnetz rechtzeitig nicht kompensiert? Korrekt: ... hat den kritischen Frequenzabfall nicht rechtzeitig kompensiert.',
        ungrammaticalPlacementExample:
            '*Der Wechselrichter hat nicht den kritischen Frequenzabfall kompensiert (ohne Kontrastfortsetzung mit "sondern").',
        semanticEffectGerman:
            'Satznegation: "nicht" steht zwingend hinter dem definiten Akkusativobjekt ("den kritischen Frequenzabfall").',
        semanticEffectArabic:
            'نفي الجملة الكلي: يجب تأخير (nicht) لما بعد المفعول به المعرف (انخفاض التردد الحرج) عند عدم وجود استدراك.',
      ),
      // 2. Sondernegation (Kontrastfokus: nicht X, sondern Y)
      const NegationScopePolarityModel(
        id: 'NEG-4968-02',
        scopeType: NegationScopeType.constituentFocusNegationSondernegation,
        anchorPosition: MittelfeldNegationAnchor.immediatelyBeforeFocusedConstituent,
        domain: CommunicativeDomain.aerospaceAndAviation,
        negationOperator: 'nicht ... sondern',
        fullGermanSentence:
            'Nicht die äußere Titanverkleidung, sondern die interne Treibstoffdichtung hat bei dem Drucktest nachgegeben.',
        ungrammaticalPlacementExample:
            '*Die äußere Titanverkleidung hat nicht nachgegeben, sondern die interne Dichtung (verlagert Fokus unklar).',
        semanticEffectGerman:
            'Sondernegation im Vorfeld: "nicht" steht direkt vor dem negierten Subjekt und kontrastiert es scharf mit dem wahren Verursacher.',
        semanticEffectArabic:
            'نفي جزئي تبايني بالصدارة: ليست الكسوة الخارجية من تيتانيوم هي التي فشلت، بل مانع التسرب الداخلي للوقود.',
      ),
      // 3. Satznegation vor Präpositionalobjekt
      const NegationScopePolarityModel(
        id: 'NEG-4968-03',
        scopeType: NegationScopeType.sententialNegationSatznegation,
        anchorPosition: MittelfeldNegationAnchor.beforePrepositionalObject,
        domain: CommunicativeDomain.industrialRobotics,
        negationOperator: 'nicht',
        fullGermanSentence:
            'Die SPS-Steuerung hat auf das optische Not-Halt-Signal des Laserscanners nicht rechtzeitig reagiert — bzw. ... hat nicht auf das Signal reagiert.',
        ungrammaticalPlacementExample:
            '*Die SPS-Steuerung hat auf das optische Not-Halt-Signal nicht reagiert (bei engem Verbkontakt unnatürlich).',
        semanticEffectGerman:
            'Bei lexikalisch gebundenen Präpositionalobjekten ("reagieren auf") steht "nicht" regulär unmittelbar VOR der Präpositionalphrase.',
        semanticEffectArabic:
            'مع المفعول به المقيد بحرف جر (reagieren auf)، يتمركز النفي (nicht) مباشرة قبل شبه الجملة المجرورة.',
      ),
      // 4. Satznegation vor Funktionsverbgefüge (FVG)
      const NegationScopePolarityModel(
        id: 'NEG-4968-04',
        scopeType: NegationScopeType.sententialNegationSatznegation,
        anchorPosition: MittelfeldNegationAnchor.beforeFvgNominalPart,
        domain: CommunicativeDomain.civilInfrastructure,
        negationOperator: 'nicht',
        fullGermanSentence:
            'Die geplante Behelfsbrücke konnte wegen des Hochwassers nicht in Betrieb genommen werden.',
        ungrammaticalPlacementExample:
            '*Die Behelfsbrücke konnte in Betrieb nicht genommen werden.',
        semanticEffectGerman:
            'Funktionsverbgefüge ("in Betrieb nehmen") bilden eine unzertrennliche Prädikatseinheit; "nicht" steht immer VOR der gesamten FVG-Phrase.',
        semanticEffectArabic:
            'تراكيب الأفعال الوظيفية (in Betrieb nehmen) لا تتجزأ: يسبقها حرف النفي (nicht) بالكامل دائماً.',
      ),
      // 5. Indefinitartikel-Negation (kein-)
      const NegationScopePolarityModel(
        id: 'NEG-4968-05',
        scopeType: NegationScopeType.indefiniteArticleNegationKein,
        anchorPosition: MittelfeldNegationAnchor.afterDefiniteObjects,
        domain: CommunicativeDomain.materialScience,
        negationOperator: 'keine',
        fullGermanSentence:
            'Das Rasterelektronenmikroskop wies nach 10.000 Lastzyklen keine Delamination in der Kohlefaser-Matrix nach.',
        ungrammaticalPlacementExample:
            '*Das Mikroskop wies nicht eine Delamination nach (ohne kontrastives "sondern zwei").',
        semanticEffectGerman:
            'Indefinite Nomen oder Nullartikel-Nomen im Akkusativ werden im Standarddeutschen zwingend mit "kein-" negiert.',
        semanticEffectArabic:
            'الأسماء النكرة والمجردة من أداة التعريف تُنفى وجوباً بـ (kein-) وليس بـ (nicht ein).',
      ),
      // 6. Negative Polaritätselemente (NPI): im Geringsten
      const NegationScopePolarityModel(
        id: 'NEG-4968-06',
        scopeType: NegationScopeType.negativePolarityItemLicensing,
        anchorPosition: MittelfeldNegationAnchor.afterDefiniteObjects,
        domain: CommunicativeDomain.maritimeLogistics,
        negationOperator: 'keineswegs / nicht im Geringsten',
        fullGermanSentence:
            'Die leichte Oberflächenkorrosion am Deckshaus beeinträchtigt die strukturelle Seetüchtigkeit des Rumpfes nicht im Geringsten.',
        ungrammaticalPlacementExample:
            '*Die leichte Korrosion beeinträchtigt die Seetüchtigkeit im Geringsten (unlizenzierter NPI ohne Negation!).',
        semanticEffectGerman:
            'Das NPI "im Geringsten" ist nur durch die vorangehende Negation "nicht" grammatisch lizenziert und verstärkt die Entwarnung.',
        semanticEffectArabic:
            'عنصر القطبية السالبة (im Geringsten) لا يصح إلا في كنف النفي، ويفيد نفي التأثير السلبي على صلاحية السفينة بأدنى درجة.',
        containsLicensedNpi: true,
      ),
      // 7. Negative Polaritätselemente (NPI): auch nur ansatzweise
      const NegationScopePolarityModel(
        id: 'NEG-4968-07',
        scopeType: NegationScopeType.negativePolarityItemLicensing,
        anchorPosition: MittelfeldNegationAnchor.afterDefiniteObjects,
        domain: CommunicativeDomain.aerospaceAndAviation,
        negationOperator: 'nicht ... auch nur ansatzweise',
        fullGermanSentence:
            'Die veraltete Simulationssoftware konnte die turbulenten Wirbelschleppen hinter den Tragflächen nicht auch nur ansatzweise abbilden.',
        ungrammaticalPlacementExample:
            '*Die Software konnte die Wirbelschleppen auch nur ansatzweise abbilden (ohne Negation ungrammatisch).',
        semanticEffectGerman:
            'Skalares NPI "auch nur ansatzweise" betont das völlige Ausbleiben einer Minimalleistung.',
        semanticEffectArabic:
            'عنصر قطبية سالب (auch nur ansatzweise): عجزت البرمجية القديمة عن محاكاة الدوامات الهوائية ولو بشكل تقريبي أولي.',
        containsLicensedNpi: true,
      ),
      // 8. Diplomatische Litotes: nicht unbedeutend
      const NegationScopePolarityModel(
        id: 'NEG-4968-08',
        scopeType: NegationScopeType.diplomaticLitotesDoubleNegation,
        anchorPosition: MittelfeldNegationAnchor.immediatelyBeforeFocusedConstituent,
        domain: CommunicativeDomain.renewableEnergyGrid,
        negationOperator: 'nicht unbedeutend',
        fullGermanSentence:
            'Die durch den Ausfall der Seekabelverbindung verursachten Netzverluste sind für die regionale Versorgungssicherheit nicht unbedeutend.',
        ungrammaticalPlacementExample:
            'Vergleich ohne Litotes: "... sind sehr hoch" (klingt im formellen Gutachten oft zu undifferenziert).',
        semanticEffectGerman:
            'Litotes ("nicht + un-"): Durch doppelte Verneinung wird ein erhebliches Risiko diplomatisch-sachlich hervorgehoben.',
        semanticEffectArabic:
            'أسلوب التخفيف البلاغي (Litotes): نفي النفي (ليست عديمة الأهمية) يبرز جسامة خسائر الشبكة برصانة وتوازن دبلوماسي.',
        isDiplomaticLitotes: true,
      ),
      // 9. Diplomatische Litotes: keineswegs auszuschließen
      const NegationScopePolarityModel(
        id: 'NEG-4968-09',
        scopeType: NegationScopeType.diplomaticLitotesDoubleNegation,
        anchorPosition: MittelfeldNegationAnchor.beforeFvgNominalPart,
        domain: CommunicativeDomain.civilInfrastructure,
        negationOperator: 'nicht auszuschließen / keineswegs unmöglich',
        fullGermanSentence:
            'Bei anhaltender Unterspülung der Ufermauer ist ein progressives Versagen der Böschung keineswegs auszuschließen.',
        ungrammaticalPlacementExample:
            'Ohne Litotes: "... wird wahrscheinlich einstürzen" (überschreitet gutachterliche Evidenz).',
        semanticEffectGerman:
            'Vorsichtige Risiko-Einschätzung: "keineswegs auszuschließen" (= durchaus möglich) wahrt die wissenschaftliche Redlichkeit.',
        semanticEffectArabic:
            'تقدير احتمالي حذر بالنفي المزدوج (لا يمكن استبعاده البتة): إقرار باحتمالية الانهيار دون جزم متسرع.',
        isDiplomaticLitotes: true,
      ),
      // 10. Satznegation vor Direktivergänzung
      const NegationScopePolarityModel(
        id: 'NEG-4968-10',
        scopeType: NegationScopeType.sententialNegationSatznegation,
        anchorPosition: MittelfeldNegationAnchor.beforeDirectionalOrSituative,
        domain: CommunicativeDomain.maritimeLogistics,
        negationOperator: 'nicht',
        fullGermanSentence:
            'Der Gefahrgutcontainer darf aufgrund der Leckagewarnung nicht in den geschlossenen Lagerbereich verbracht werden.',
        ungrammaticalPlacementExample:
            '*Der Gefahrgutcontainer darf in den geschlossenen Lagerbereich nicht verbracht werden.',
        semanticEffectGerman:
            'Direktivergänzungen ("in den Lagerbereich") gehören eng zum Verbkomplex; "nicht" steht zwingend davor.',
        semanticEffectArabic:
            'المكملات الاتجاهية (إلى منطقة التخزين) تلتصق بالفعل في النهاية، لذا يتقدمها حرف النفي (nicht) وجوباً.',
      ),
      // 11. Verbot doppelter Satznegation (Negative Concord)
      const NegationScopePolarityModel(
        id: 'NEG-4968-11',
        scopeType: NegationScopeType.lexicalNegativeConcordProhibition,
        anchorPosition: MittelfeldNegationAnchor.afterDefiniteObjects,
        domain: CommunicativeDomain.industrialRobotics,
        negationOperator: 'niemals ... (kein nicht!)',
        fullGermanSentence:
            'Der automatisierte Schweißroboter hat während des gesamten Schichtbetriebs keinerlei Fehlschweißungen verursacht.',
        ungrammaticalPlacementExample:
            '*Der Roboter hat keine Fehlschweißungen nicht verursacht (ungrammatische doppelte Verneinung / Negative Concord).',
        semanticEffectGerman:
            'Standarddeutsches Verbot von Negative Concord: "keinerlei" negiert allein; ein zweites "nicht" ist streng fehlerhaft.',
        semanticEffectArabic:
            'حظر التطابق السلبي: يكفي استخدام (keinerlei) منفرداً للنفي المطلق، وإضافة (nicht) معها يعد خطأ نحوياً فادحاً.',
      ),
      // 12. Sondernegation von Adverbien (nicht nur..., sondern auch / nicht immer)
      const NegationScopePolarityModel(
        id: 'NEG-4968-12',
        scopeType: NegationScopeType.constituentFocusNegationSondernegation,
        anchorPosition: MittelfeldNegationAnchor.immediatelyBeforeFocusedConstituent,
        domain: CommunicativeDomain.materialScience,
        negationOperator: 'nicht zwingend',
        fullGermanSentence:
            'Eine erhöhte Oberflächenhärte bedingt nicht zwingend eine höhere Risszähigkeit der Keramikbeschichtung.',
        ungrammaticalPlacementExample:
            '*Eine erhöhte Oberflächenhärte bedingt eine höhere Risszähigkeit zwingend nicht.',
        semanticEffectGerman:
            'Skopuseinengung auf das Modaladverb ("nicht zwingend"): Die Korrelation kann existieren, ist aber kein Naturgesetz.',
        semanticEffectArabic:
            'قصر النفي على الظرف المقيد (ليس بالضرورة): ارتفاع الصلابة السطحية لا يستلزم حتماً زيادة مقاومة الكسر.',
      ),
      // 13. NPI: jemals (lizenziert durch "nie" / "ohne dass")
      const NegationScopePolarityModel(
        id: 'NEG-4968-13',
        scopeType: NegationScopeType.negativePolarityItemLicensing,
        anchorPosition: MittelfeldNegationAnchor.afterDefiniteObjects,
        domain: CommunicativeDomain.aerospaceAndAviation,
        negationOperator: 'ohne ... jemals',
        fullGermanSentence:
            'Das redundante Triebwerkssteuergerät arbeitete 15.000 Stunden lang fehlerfrei, ohne jemals in den Notbetrieb zu wechseln.',
        ungrammaticalPlacementExample:
            '*Das Steuergerät arbeitete fehlerfrei und wechselte jemals in den Notbetrieb.',
        semanticEffectGerman:
            'Implizite Negation durch die Konjunktion "ohne" lizenziert das NPI "jemals" vollständig.',
        semanticEffectArabic:
            'الربط السالب بـ (ohne) يُجيز نحوياً استخدام عنصر القطبية (jemals) ليؤكد خلو السجل من أي تشغيل طارئ إطلاقاً.',
        containsLicensedNpi: true,
      ),
      // 14. Diplomatische Litotes: nicht unerheblich
      const NegationScopePolarityModel(
        id: 'NEG-4968-14',
        scopeType: NegationScopeType.diplomaticLitotesDoubleNegation,
        anchorPosition: MittelfeldNegationAnchor.immediatelyBeforeFocusedConstituent,
        domain: CommunicativeDomain.renewableEnergyGrid,
        negationOperator: 'nicht unerheblich',
        fullGermanSentence:
            'Die Blindleistungskompensation reduziert die thermische Belastung der Erdkabel in nicht unerheblichem Maße.',
        ungrammaticalPlacementExample:
            'Ohne Litotes: "... in sehr großem Maße" (weniger präzise im technischen Fachaufsatz).',
        semanticEffectGerman:
            'Gehobene wissenschaftliche Litotes ("in nicht unerheblichem Maße") für eine signifikante Entlastung.',
        semanticEffectArabic:
            'نفي مزدوج رفيع (بقدر غير ضئيل): تعويض القدرة غير الفعالة يقلص الإجهاد الحراري للكابلات بقدر ملموس جداً.',
        isDiplomaticLitotes: true,
      ),
      // 15. Indefinitartikel-Negation (kein + Komparativ/Plural)
      const NegationScopePolarityModel(
        id: 'NEG-4968-15',
        scopeType: NegationScopeType.indefiniteArticleNegationKein,
        anchorPosition: MittelfeldNegationAnchor.afterDefiniteObjects,
        domain: CommunicativeDomain.civilInfrastructure,
        negationOperator: 'keine nennenswerten',
        fullGermanSentence:
            'Die Laservermessung des Tunnelgewölbes ergab nach dem Durchbruch keine nennenswerten Konvergenzen.',
        ungrammaticalPlacementExample:
            '*Die Laservermessung ergab nicht nennenswerte Konvergenzen.',
        semanticEffectGerman:
            'Bei artikellosen Pluralnomen ("Konvergenzen") ist "keine" die einzig grammatische Negationsform.',
        semanticEffectArabic:
            'الأسماء الجمعية المجردة من أداة التعريف تُنفى حصرياً بـ (keine) في التقارير الهندسية.',
      ),
      // 16. Sondernegation (nicht etwa..., sondern)
      const NegationScopePolarityModel(
        id: 'NEG-4968-16',
        scopeType: NegationScopeType.constituentFocusNegationSondernegation,
        anchorPosition: MittelfeldNegationAnchor.immediatelyBeforeFocusedConstituent,
        domain: CommunicativeDomain.industrialRobotics,
        negationOperator: 'nicht etwa ... sondern',
        fullGermanSentence:
            'Die Taktzeitverzögerung entstand nicht etwa durch ein mechanisches Klemmen, sondern durch einen Konflikt im Feldbus-Protokoll.',
        ungrammaticalPlacementExample:
            '*Die Taktzeitverzögerung entstand durch ein Klemmen nicht etwa, sondern durch einen Protokollkonflikt.',
        semanticEffectGerman:
            'Fokussierendes "nicht etwa" weist eine naheliegende Vermutung (mechanisches Klemmen) vornehm aber bestimmt zurück.',
        semanticEffectArabic:
            'نفي استدراكي دقيق (ليس كما قد يُظن): تأخر دورة الروبوت لم ينجم عن تعثر ميكانيكي بل عن تعارض في بروتوكول الاتصال.',
      ),
    ]);
  }

  List<NegationScopePolarityModel> getByScopeType(NegationScopeType type) =>
      _catalog.where((n) => n.scopeType == type).toList();

  List<NegationScopePolarityModel> getByAnchor(MittelfeldNegationAnchor anchor) =>
      _catalog.where((n) => n.anchorPosition == anchor).toList();

  List<NegationScopePolarityModel> getByDomain(CommunicativeDomain domain) =>
      _catalog.where((n) => n.domain == domain).toList();

  /// Validates negation placement, NPI licensing, and negative concord prohibition.
  NegationValidationResult validateNegationStructure({
    required NegationScopeType scopeType,
    required bool isPlacedBeforeFvgOrPpOrDirectional,
    required bool usesKeinForIndefiniteOrBareNoun,
    required bool hasNegativeLicensorForNpi,
    required bool hasAccidentalDoubleNegation,
  }) {
    final List<String> issues = [];
    final List<String> notes = [];

    // Rule 1: Negative Concord Prohibition (except intentional Litotes)
    if (hasAccidentalDoubleNegation && scopeType != NegationScopeType.diplomaticLitotesDoubleNegation) {
      issues.add(
          'Negative-Concord-Verstoß: Das Standarddeutsche verbietet doppelte Satznegation (z. B. *"keine... nicht"). Nutzen Sie ausschließlich einen Negationsträger.');
    } else if (scopeType == NegationScopeType.diplomaticLitotesDoubleNegation) {
      notes.add('Stilistisch lizenziert: Bewusste Litotes ("nicht un-") erzeugt diplomatische Bejahung.');
    }

    // Rule 2: Mittelfeld placement before close verb complements
    if (scopeType == NegationScopeType.sententialNegationSatznegation &&
        !isPlacedBeforeFvgOrPpOrDirectional) {
      issues.add(
          'Topologie-Fehler: Bei Satznegation muss "nicht" zwingend VOR Funktionsverbgefügen, Präpositionalobjekten und Direktivergänzungen stehen.');
    } else if (scopeType == NegationScopeType.sententialNegationSatznegation) {
      notes.add('Topologisch normgerecht: "nicht" ankert exakt vor der rechten Klammer / engen Verbergänzung.');
    }

    // Rule 3: Indefinite noun negation
    if (scopeType == NegationScopeType.indefiniteArticleNegationKein &&
        !usesKeinForIndefiniteOrBareNoun) {
      issues.add(
          'Morphosyntax-Fehler: Indefinite Nomen (ein-) oder artikellose Nomen müssen mit "kein-" negiert werden (nicht *"nicht ein-").');
    }

    // Rule 4: NPI Licensing
    if (scopeType == NegationScopeType.negativePolarityItemLicensing &&
        !hasNegativeLicensorForNpi) {
      issues.add(
          'Lizenzierungsfehler: Negative Polaritätselemente (jemals, im Geringsten, auch nur ansatzweise) sind ohne negativen Lizenzierer ("nicht", "kein", "ohne") ungrammatisch.');
    } else if (scopeType == NegationScopeType.negativePolarityItemLicensing) {
      notes.add('Polarität normgerecht: NPI ist durch abwärts-monotone Negation sauber lizenziert.');
    }

    return NegationValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      syntacticNotes: notes,
    );
  }

  Map<String, dynamic> generateTelemetrySnapshot() {
    return {
      'totalExemplars': _catalog.length,
      'scopeTypeDistribution': {
        for (var s in NegationScopeType.values)
          s.name: _catalog.where((n) => n.scopeType == s).length,
      },
      'anchorDistribution': {
        for (var a in MittelfeldNegationAnchor.values)
          a.name: _catalog.where((n) => n.anchorPosition == a).length,
      },
      'domainDistribution': {
        for (var d in CommunicativeDomain.values)
          d.name: _catalog.where((n) => n.domain == d).length,
      },
      'npiCount': _catalog.where((n) => n.containsLicensedNpi).length,
      'litotesCount': _catalog.where((n) => n.isDiplomaticLitotes).length,
      'cefrLevel': 'CEFR C1-C2 Masterclass Negation Scope & Polarity Licensing',
      'engineVersion': '1.0.0+subsystem1802',
    };
  }
}
