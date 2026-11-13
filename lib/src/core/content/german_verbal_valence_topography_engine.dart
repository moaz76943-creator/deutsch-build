import 'dart:collection';

/// Classification of verbal valence complements and secondary predications in German syntax.
enum ValenceComplementType {
  prepositionalObject(
    'Präpositionalobjekt (lexikalisch gebundene Valenzergänzung)',
    'المفعول به غير المباشر المقيد بمعجمية الفعل (Präpositionalobjekt)',
    'Die Präposition ist semantisch verblasst und vom Verb diktiert: warten auf, hinweisen auf, bestehen aus. Fragetest: Worauf? Nicht Wo?',
  ),
  directionalComplement(
    'Obligatorische Direktivergänzung (Zielangabe - Wohin?)',
    'المكمل الاتجاهي الإلزامي غير القابل للحذف (Direktivergänzung)',
    'Ohne Zielangabe ungrammatisch: legen, stellen, leiten, führen. Fragetest: Wohin? Das Modul auf den Prüfstand stellen.',
  ),
  situationalComplement(
    'Obligatorische Situativergänzung (Ortsangabe - Wo?)',
    'المكمل المكاني الموقعي الإلزامي (Situativergänzung)',
    'Gibt den festen Ort an: sich befinden, liegen, haften. Fragetest: Wo? Der Sensor befindet sich im Druckbehälter.',
  ),
  freeAdverbialModifier(
    'Freie Adverbialangabe (fakultative Modifikation)',
    'شبه الجملة الظرفية الحرة القابلة للحذف دون الإخلال بالنحو',
    'Liefert Zusatzinformationen (Zeit, Grund, Art) und ist weglassbar: gestern, wegen des Sturms, mit höchster Präzision.',
  ),
  secondaryPredicateDepictive(
    'Depiktives sekundäres Prädikat (Zustand während Handlung)',
    'المسند الثانوي الوصفي لحال الفاعل/المفعول أثناء الحدث (غير معرب)',
    'Beschreibt den Zustand des Subjekts/Objekts während des Prädikatsgeschehens; bleibt undekliniert: Der Roboter montierte die Düse unbeschädigt.',
  ),
  secondaryPredicateResultative(
    'Resultatives sekundäres Prädikat (Handlungsergebnis)',
    'المسند الثانوي الناتج عن الحدث والمبين للأثر المستقر (غير معرب)',
    'Beschreibt das unmittelbare Resultat der Handlung am Objekt; bleibt undekliniert: Die Walze presste das Blech hauchdünn.',
  );

  final String germanTitle;
  final String arabicTitle;
  final String structuralCriteria;
  const ValenceComplementType(
    this.germanTitle,
    this.arabicTitle,
    this.structuralCriteria,
  );
}

/// Diagnostic interrogative test category.
enum InterrogativeTestCategory {
  prepositionalPronoun('Pronominaladverb (Woran? Worauf? Womit?)', 'اسم استفهام موصولي مركب'),
  locativeSpatial('Lokaladverb (Wo? Wohin? Woher?)', 'اسم استفهام مكاني/اتجاهي'),
  mannerDegree('Modaladverb (Wie? In welchem Zustand?)', 'اسم استفهام للحال والصفة');

  final String de;
  final String ar;
  const InterrogativeTestCategory(this.de, this.ar);
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

/// Structural model of a verbal valence construction.
class ValenceTopographyModel {
  final String id;
  final String governingVerb;
  final ValenceComplementType complementType;
  final InterrogativeTestCategory testCategory;
  final String complementPhrase;
  final String fullSentence;
  final bool isObligatory;
  final CommunicativeDomain domain;
  final String arabicTranslation;
  final String grammaticalAnalysisArabic;
  final String grammaticalAnalysisGerman;
  final String substitutionTestFormula;
  final String diagnosticPitfallWarning;

  const ValenceTopographyModel({
    required this.id,
    required this.governingVerb,
    required this.complementType,
    required this.testCategory,
    required this.complementPhrase,
    required this.fullSentence,
    required this.isObligatory,
    required this.domain,
    required this.arabicTranslation,
    required this.grammaticalAnalysisArabic,
    required this.grammaticalAnalysisGerman,
    required this.substitutionTestFormula,
    required this.diagnosticPitfallWarning,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'governingVerb': governingVerb,
    'complementType': complementType.name,
    'testCategory': testCategory.name,
    'complementPhrase': complementPhrase,
    'fullSentence': fullSentence,
    'isObligatory': isObligatory,
    'domain': domain.name,
    'arabicTranslation': arabicTranslation,
    'grammaticalAnalysisArabic': grammaticalAnalysisArabic,
    'grammaticalAnalysisGerman': grammaticalAnalysisGerman,
    'substitutionTestFormula': substitutionTestFormula,
    'diagnosticPitfallWarning': diagnosticPitfallWarning,
  };
}

/// Verification report container for valence topography validation.
class ValenceValidationReport {
  final bool isValid;
  final bool isComplementCorrectlyTyped;
  final bool avoidsWrongAdjectiveInflection;
  final bool respectsObligatoryValence;
  final List<String> issues;
  final List<String> recommendations;
  final String arabicDiagnosticVerdict;

  const ValenceValidationReport({
    required this.isValid,
    required this.isComplementCorrectlyTyped,
    required this.avoidsWrongAdjectiveInflection,
    required this.respectsObligatoryValence,
    required this.issues,
    required this.recommendations,
    required this.arabicDiagnosticVerdict,
  });
}

/// Sovereign engine governing German Verbal Valence Topography, Complements & Secondary Predicates.
class GermanVerbalValenceTopographyEngine {
  final List<ValenceTopographyModel> _catalog = [];

  GermanVerbalValenceTopographyEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<ValenceTopographyModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    // 1. Präpositionalobjekt: hinweisen auf + Akkusativ - Renewable Energy
    _catalog.add(
      const ValenceTopographyModel(
        id: 'VAL-PREP-OBJ-ENERGY-01',
        governingVerb: 'hinweisen auf',
        complementType: ValenceComplementType.prepositionalObject,
        testCategory: InterrogativeTestCategory.prepositionalPronoun,
        complementPhrase: 'auf die thermische Überlastung des Wechselrichters',
        fullSentence:
            'Die Diagnosesoftware weist den Wartungsingenieur frühzeitig auf die thermische Überlastung des Wechselrichters hin.',
        isObligatory: true,
        domain: CommunicativeDomain.renewableEnergyGrid,
        arabicTranslation:
            'تنبه برمجية التشخيص مهندس الصيانة في وقت مبكر إلى فرط التحميل الحراري للمحول الكهربائي.',
        grammaticalAnalysisArabic:
            'مفعول به غير مباشر مقيد بمعجمية الفعل (Präpositionalobjekt): حرف الجر "auf" مجرد دلالياً وملزم بالفعل hinweisen، ولا يمكن الاستفسار عنه بـ Wo أو Wohin، بل بـ "Worauf?".',
        grammaticalAnalysisGerman:
            'Lexikalisch determiniertes Präpositionalobjekt: Die Präposition "auf" hat keine räumliche Bedeutung. Pronominaladverbialer Fragetest: "Worauf weist die Software hin?".',
        substitutionTestFormula:
            'Fragetest: Worauf weist sie hin?  -->  Antwort: Auf die Überlastung. (NICHT: *Wo weist sie hin?)',
        diagnosticPitfallWarning:
            'Klassische Verwechslung mit Ortsadverbialen; Präpositionalobjekte dürfen nicht mit Lokaladverbien abgefragt werden.',
      ),
    );

    // 2. Direktivergänzung: stellen auf + Akkusativ - Industrial Robotics
    _catalog.add(
      const ValenceTopographyModel(
        id: 'VAL-DIREKTIV-ROBOT-02',
        governingVerb: 'stellen',
        complementType: ValenceComplementType.directionalComplement,
        testCategory: InterrogativeTestCategory.locativeSpatial,
        complementPhrase: 'auf den mobilen Werkstückträger',
        fullSentence:
            'Der Sechsachsroboter stellt das fertig geschweißte Getriebegehäuse präzise auf den mobilen Werkstückträger.',
        isObligatory: true,
        domain: CommunicativeDomain.industrialRobotics,
        arabicTranslation:
            'يضع الروبوت سداسي المحاور غلاف صندوق التروس الملحوم بالكامل بدقة على حامل القطع المتحرك.',
        grammaticalAnalysisArabic:
            'مكمل اتجاهي إلزامي (Direktivergänzung): الفعل "stellen" يتطلب مفعولين حتماً: المفعول المنصوب (das Gehäuse) وشبه الجملة الحركية الاتجاهية (auf den Träger). حذف شبه الجملة يجعل التركيب غير مكتمل نحوياً.',
        grammaticalAnalysisGerman:
            'Obligatorische Direktivergänzung (Akkusativ nach "auf"). Ohne Angabe des Zielorts ist der Satz ungrammatisch (*Der Roboter stellt das Gehäuse).',
        substitutionTestFormula:
            'Fragetest: Wohin stellt der Roboter das Gehäuse?  -->  Auf den Träger. (Richtungsfrage mit Akkusativ).',
        diagnosticPitfallWarning:
            'Verwechslung von Direktivergänzung (stellen + Wohin + Akk) mit Situativergänzung (stehen + Wo + Dat).',
      ),
    );

    // 3. Situativergänzung: sich befinden in + Dativ - Aerospace Aviation
    _catalog.add(
      const ValenceTopographyModel(
        id: 'VAL-SITUATIV-AERO-03',
        governingVerb: 'sich befinden',
        complementType: ValenceComplementType.situationalComplement,
        testCategory: InterrogativeTestCategory.locativeSpatial,
        complementPhrase: 'in einer stabilen geosynchronen Umlaufbahn',
        fullSentence:
            'Der Kommunikationssatellit befindet sich seit heute früh in einer stabilen geosynchronen Umlaufbahn.',
        isObligatory: true,
        domain: CommunicativeDomain.aerospaceAndAviation,
        arabicTranslation:
            'يستقر قمر الاتصالات الاصطناعي ويوجد منذ صباح اليوم في مدار متزامن مع الأرض مستقر وثابت.',
        grammaticalAnalysisArabic:
            'مكمل مكاني إلزامي دال على الموقع (Situativergänzung): الفعل "sich befinden" ناقص الدلالة بدون بيان المكان (Wo? - in der Umlaufbahn مع الداتيف).',
        grammaticalAnalysisGerman:
            'Obligatorische Situativergänzung mit Dativ nach "in". Gibt den statischen Ort an. Fragetest: "Wo befindet sich der Satellit?".',
        substitutionTestFormula:
            'Fragetest: Wo befindet sich der Satellit?  -->  In der Umlaufbahn. (Statischer Dativ).',
        diagnosticPitfallWarning:
            'Weglassen der Ortsangabe macht den Satz unvollständig (*Der Satellit befindet sich seit heute früh).',
      ),
    );

    // 4. Sekundäres Prädikat (Resultativ): flach - Material Science
    _catalog.add(
      const ValenceTopographyModel(
        id: 'VAL-RESULTATIV-MAT-04',
        governingVerb: 'schmieden',
        complementType: ValenceComplementType.secondaryPredicateResultative,
        testCategory: InterrogativeTestCategory.mannerDegree,
        complementPhrase: 'flach (unflektiertes Adjektiv als Resultat)',
        fullSentence:
            'Die hydraulische Gesenkschmiede presste den rotglühenden Titanbarren mit zweitausend Tonnen Druck flach.',
        isObligatory: false,
        domain: CommunicativeDomain.materialScience,
        arabicTranslation:
            'ضغطت مطرقة القولبة الهيدروليكية سبيكة التيتانيوم المتوهجة حمرةً بضغط ألفي طن حتى سوتها مسطحة.',
        grammaticalAnalysisArabic:
            'مسند ثانوي ناتج عن الحدث (Resultatives Prädikat): الصفة "flach" تصف النتيجة المستقرة التي آلت إليها السبيكة بعد الطرق. وتبقى الصفة غير معربة تماماً دون أي لواحق تصريف.',
        grammaticalAnalysisGerman:
            'Resultatives sekundäres Prädikat: Beschreibt den durch den Vorgang bewirkten Endzustand des Objekts ("den Titanbarren"). Bleibt strikt unflektiert.',
        substitutionTestFormula:
            'Paraphrase: Die Schmiede presste den Barren so, dass er flach wurde.',
        diagnosticTrapWarning:
            'Häufiger Fehler: Fälschliches Deklinieren des Adjektivs (*presste den Barren flachen) durch Verwechslung mit Attributen.',
      ),
    );

    // 5. Sekundäres Prädikat (Depiktiv): unbeschädigt - Civil Infrastructure
    _catalog.add(
      const ValenceTopographyModel(
        id: 'VAL-DEPIKTIV-CIVIL-05',
        governingVerb: 'überstehen',
        complementType: ValenceComplementType.secondaryPredicateDepictive,
        testCategory: InterrogativeTestCategory.mannerDegree,
        complementPhrase: 'völlig unbeschädigt (Zustand des Subjekts)',
        fullSentence:
            'Der Spannbetonpfeiler überstand das schwere Erdbebensimulationsexperiment auf dem Rütteltisch völlig unbeschädigt.',
        isObligatory: false,
        domain: CommunicativeDomain.civilInfrastructure,
        arabicTranslation:
            'اجتاز عمود الخرسانة مسبقة الإجهاد تجربة محاكاة الزلزال العنيفة على طاولة الاهتزاز سليماً تماماً دون أي ضرر.',
        grammaticalAnalysisArabic:
            'مسند ثانوي وصفي للحال أثناء الواقعة (Depiktives Prädikat): الصفة "unbeschädigt" تصف حالة العمود وقت اجتياز الاختبار، وتبقى مجردة من علامات الإعراب.',
        grammaticalAnalysisGerman:
            'Depiktives sekundäres Prädikat bezogen auf das Subjekt ("der Pfeiler"). Drückt den Begleitzustand während des Geschehens aus; bleibt unflektiert.',
        substitutionTestFormula:
            'Paraphrase: Der Pfeiler überstand das Experiment und er war dabei völlig unbeschädigt.',
        diagnosticTrapWarning:
            'Nicht als Adverb der Handlungsweise missverstehen (nicht die Art des Überstehens, sondern der Zustand des Pfeilers ist gemeint).',
      ),
    );

    // 6. Freie Adverbialangabe: gestern / wegen des Sturms - Maritime Logistics
    _catalog.add(
      const ValenceTopographyModel(
        id: 'VAL-ADVERBIAL-MARITIME-06',
        governingVerb: 'ankommen',
        complementType: ValenceComplementType.freeAdverbialModifier,
        testCategory: InterrogativeTestCategory.locativeSpatial,
        complementPhrase: 'wegen des dichten Nebels (Kausalangabe)',
        fullSentence:
            'Das Containerschiff erreichte das Terminal wegen des dichten Nebels mit zweistündiger Verspätung.',
        isObligatory: false,
        domain: CommunicativeDomain.maritimeLogistics,
        arabicTranslation:
            'وصلت سفينة الحاويات إلى المحطة البحرية بتأخير ساعتين بسبب الضباب الكثيف.',
        grammaticalAnalysisArabic:
            'شبه جملة ظرفية حرة غير لازمة (Freie Adverbialangabe): تبين سبب التأخير، ويمكن حذفها من الجملة دون الإخلال بسلامة البنية النحوية الأساسية.',
        grammaticalAnalysisGerman:
            'Fakultative Kausalangabe: Kann syntaktisch weggelassen werden, ohne dass die Satzvalenz verletzt wird ("Das Schiff erreichte das Terminal").',
        substitutionTestFormula:
            'Fragetest: Warum erreichte es das Terminal später?  -->  Wegen des Nebels.',
        diagnosticTrapWarning:
            'Freie Angaben unterliegen im Mittelfeld der TeKaMoLo-Topologie, sind aber valenzmäßig ungebunden.',
      ),
    );

    // 7. Präpositionalobjekt: warten auf + Akkusativ - Renewable Energy
    _catalog.add(
      const ValenceTopographyModel(
        id: 'VAL-PREP-OBJ-WARTEN-07',
        governingVerb: 'warten auf',
        complementType: ValenceComplementType.prepositionalObject,
        testCategory: InterrogativeTestCategory.prepositionalPronoun,
        complementPhrase: 'auf die automatische Freigabe des Netzleitsystems',
        fullSentence:
            'Die Einspeisestation wartet nach dem Kaltstart auf die automatische Freigabe des Netzleitsystems.',
        isObligatory: true,
        domain: CommunicativeDomain.renewableEnergyGrid,
        arabicTranslation:
            'تنتظر محطة التغذية والضخ بعد الإقلاع البارد صدور الموافقة والاعتماد التلقائي من منظومة إدارة الشبكة.',
        grammaticalAnalysisArabic:
            'مفعول مقيد بـ auf + Akkusativ: الاستفسار عنه يكون بـ "Worauf wartet die Station?" وليس بأي ظرف مكاني.',
        grammaticalAnalysisGerman:
            'Klassisches Präpositionalobjekt zu "warten". Das Nomen nach "auf" steht obligatorisch im Akkusativ ("die Freigabe").',
        substitutionTestFormula:
            'Fragetest: Worauf wartet die Station?  -->  Auf die Freigabe.',
        diagnosticPitfallWarning:
            'Niemals Dativ nach "warten auf": "*wartet auf der Freigabe" ist falsch.',
      ),
    );

    // 8. Direktivergänzung: leiten in + Akkusativ - Renewable Energy
    _catalog.add(
      const ValenceTopographyModel(
        id: 'VAL-DIREKTIV-LEITEN-08',
        governingVerb: 'leiten',
        complementType: ValenceComplementType.directionalComplement,
        testCategory: InterrogativeTestCategory.locativeSpatial,
        complementPhrase: 'in das unterirdische Hochspannungskabelnetz',
        fullSentence:
            'Die Transformatorenstation leitet den erzeugten Drehstrom direkt in das unterirdische Hochspannungskabelnetz.',
        isObligatory: true,
        domain: CommunicativeDomain.renewableEnergyGrid,
        arabicTranslation:
            'توجه محطة المحولات الكهربائية التيار ثلاثي الأطوار المولد مباشرة إلى شبكة الكابلات الأرضية فائقة الجهد.',
        grammaticalAnalysisArabic:
            'مكمل اتجاهي مساري إلزامي (Direktivergänzung): الفعل "leiten" يتطلب توجيه المفعول الصريح نحو مسار محدد (Wohin? - in das Netz).',
        grammaticalAnalysisGerman:
            'Direktiv-Komplement zu "leiten": Fordert zwingend die Akkusativ-Richtung ("in das Kabelnetz"). Ohne Direktivangabe semantisch unvollständig.',
        substitutionTestFormula:
            'Fragetest: Wohin leitet die Station den Strom?  -->  In das Netz.',
        diagnosticPitfallWarning:
            'Verwechslung von statischem Dativ ("im Netz") mit dynamischem Akkusativ ("in das Netz").',
      ),
    );

    // 9. Sekundäres Prädikat (Depiktiv des Objekts): betriebsbereit - Industrial Robotics
    _catalog.add(
      const ValenceTopographyModel(
        id: 'VAL-DEPIKTIV-OBJ-09',
        governingVerb: 'übergeben',
        complementType: ValenceComplementType.secondaryPredicateDepictive,
        testCategory: InterrogativeTestCategory.mannerDegree,
        complementPhrase: 'vollständig betriebsbereit (Zustand des Objekts)',
        fullSentence:
            'Der Systemintegrator übergab dem Werksleiter die automatisierte Verpackungsstraße vollständig betriebsbereit.',
        isObligatory: false,
        domain: CommunicativeDomain.industrialRobotics,
        arabicTranslation:
            'سلم مكامل الأنظمة إلى مدير المصنع خط التغليف المؤتمت جاهزاً للتشغيل بالكامل.',
        grammaticalAnalysisArabic:
            'مسند ثانوي وصفي لحال المفعول به وقت التسليم (Depiktives Prädikat): "betriebsbereit" تصف خط التغليف عند تسليمه، وتبقى مجردة من علامات الإعراب.',
        grammaticalAnalysisGerman:
            'Objektbezogenes depiktives Prädikat: Bezieht sich auf "die Verpackungsstraße". Drückt die Verfassung des Objekts bei der Übergabe aus.',
        substitutionTestFormula:
            'Paraphrase: Er übergab die Straße, und diese war zu diesem Zeitpunkt betriebsbereit.',
        diagnosticTrapWarning:
            'Nicht flektieren (*betriebsbereite übergeben), da es kein pränominales Attribut ist.',
      ),
    );

    // 10. Sekundäres Prädikat (Resultativ): blank - Aerospace Aviation
    _catalog.add(
      const ValenceTopographyModel(
        id: 'VAL-RESULTATIV-BLANK-10',
        governingVerb: 'schleifen',
        complementType: ValenceComplementType.secondaryPredicateResultative,
        testCategory: InterrogativeTestCategory.mannerDegree,
        complementPhrase: 'spiegelblank (Resultat am Objekt)',
        fullSentence:
            'Die Präzisionsschleifmaschine schliff die Oberfläche der Turbinenschaufel spiegelblank.',
        isObligatory: false,
        domain: CommunicativeDomain.aerospaceAndAviation,
        arabicTranslation:
            'صقلت آلة التجليخ الدقيقة سطح شفرة التوربين حتى غدا لامعاً كالمرآة.',
        grammaticalAnalysisArabic:
            'مسند ثانوي ناتج (Resultativ): اللمعان الصقيل كالمرآة (spiegelblank) هو النتيجة المستقرة الحاصلة على السطح بفعل التجليخ، وتلزم عدم التصريف.',
        grammaticalAnalysisGerman:
            'Resultatsprädikat am Akkusativobjekt ("die Oberfläche"). Das Schleifen führt unmittelbar zum Zustand "spiegelblank".',
        substitutionTestFormula:
            'Paraphrase: Die Maschine schliff die Schaufel so, dass sie spiegelblank wurde.',
        diagnosticTrapWarning:
            'Keine adverbiale Modifikation der Maschine, sondern stofflicher Endzustand des Werkstücks.',
      ),
    );

    // 11. Präpositionalobjekt: zweifeln an + Dativ - Civil Infrastructure
    _catalog.add(
      const ValenceTopographyModel(
        id: 'VAL-PREP-OBJ-ZWEIFELN-11',
        governingVerb: 'zweifeln an',
        complementType: ValenceComplementType.prepositionalObject,
        testCategory: InterrogativeTestCategory.prepositionalPronoun,
        complementPhrase: 'an der Belastbarkeit des recycelten Zuschlagstoffs',
        fullSentence:
            'Die Prüfstatiker zweifeln nach den ersten Laborergebnissen an der Belastbarkeit des recycelten Zuschlagstoffs.',
        isObligatory: true,
        domain: CommunicativeDomain.civilInfrastructure,
        arabicTranslation:
            'يشكك مهندسو التدقيق الإنشائي بعد ظهور النتائج المخبرية الأولية في قدرة المادة الحصوية المعاد تدويرها على تحمل الإجهاد.',
        grammaticalAnalysisArabic:
            'مفعول مقيد بحرف الجر an + Dativ: السؤال عنه بـ "Woran zweifeln die Statiker?"، ولا يمكن تعويضه بأي ظرف مكاني.',
        grammaticalAnalysisGerman:
            'Idiomatisches Präpositionalobjekt zu "zweifeln". Pronominaladverbialer Fragetest: "Woran zweifeln sie?".',
        substitutionTestFormula:
            'Fragetest: Woran zweifeln sie?  -->  An der Belastbarkeit.',
        diagnosticPitfallWarning:
            'Verwechslung von "zweifeln an + Dativ" mit "verzweifeln an + Dativ" (unterschiedliche Verbstämme).',
      ),
    );

    // 12. Situativergänzung: haften an + Dativ - Material Science
    _catalog.add(
      const ValenceTopographyModel(
        id: 'VAL-SITUATIV-HAFTEN-12',
        governingVerb: 'haften',
        complementType: ValenceComplementType.situationalComplement,
        testCategory: InterrogativeTestCategory.locativeSpatial,
        complementPhrase: 'an der modifizierten Siliziumoberfläche',
        fullSentence:
            'Die monomolekulare Schutzschicht haftet dank kovalenter Bindungen extrem fest an der modifizierten Siliziumoberfläche.',
        isObligatory: true,
        domain: CommunicativeDomain.materialScience,
        arabicTranslation:
            'تلتصق الطبقة الواقية أحادية الجزيء بفضل الروابط التساهمية بقوة فائقة بسطح السيليكون المعدل.',
        grammaticalAnalysisArabic:
            'مكمل موضعي استقراري (Situativergänzung): الفعل "haften" يتطلب تحديد السطح الملتصق به (Wo haftet die Schicht? - an der Oberfläche مع الداتيف).',
        grammaticalAnalysisGerman:
            'Lokale Situativergänzung mit "an" + Dativ. Bestimmt den physischen Kontaktbereich der Adhäsion.',
        substitutionTestFormula:
            'Fragetest: Wo haftet die Schicht?  -->  An der Oberfläche. (Lokale Bindung).',
        diagnosticPitfallWarning:
            'Akkusativ wäre falsch (*an die Oberfläche haften), da kein dynamischer Richtungswechsel vorliegt.',
      ),
    );

    // 13. Direktivergänzung: umleiten nach/über - Maritime Logistics
    _catalog.add(
      const ValenceTopographyModel(
        id: 'VAL-DIREKTIV-UMLEITEN-13',
        governingVerb: 'umleiten',
        complementType: ValenceComplementType.directionalComplement,
        testCategory: InterrogativeTestCategory.locativeSpatial,
        complementPhrase: 'in das südliche Ausweichbecken',
        fullSentence:
            'Die Hafenlotsen leiten den ankommenden Tanker wegen Wartungsarbeiten in das südliche Ausweichbecken um.',
        isObligatory: true,
        domain: CommunicativeDomain.maritimeLogistics,
        arabicTranslation:
            'يوجه مرشدو الميناء ناقلة النفط القادمة نحو حوض المناورة والانتظار الجنوبي بسبب أعمال الصيانة.',
        grammaticalAnalysisArabic:
            'مكمل اتجاهي مساري إلزامي (Direktivergänzung): فعل التحويل "umleiten" يتطلب تحديد الوجهة الجديدة (Wohin? - in das Becken مع الأكوزاتيف).',
        grammaticalAnalysisGerman:
            'Zwingende Richtungsangabe bei trennbarem Direktionalverb "umleiten" (Wohin? + Akkusativ).',
        substitutionTestFormula:
            'Fragetest: Wohin leiten sie den Tanker um?  -->  In das Ausweichbecken.',
        diagnosticPitfallWarning:
            'Ohne Richtungsangabe ist der Satz semantisch amputiert (*Die Lotsen leiten den Tanker um).',
      ),
    );

    // 14. Sekundäres Prädikat (Depiktiv des Subjekts): unbemerkt - Software Engineering
    _catalog.add(
      const ValenceTopographyModel(
        id: 'VAL-DEPIKTIV-UNBEMERKT-14',
        governingVerb: 'einschleusen',
        complementType: ValenceComplementType.secondaryPredicateDepictive,
        testCategory: InterrogativeTestCategory.mannerDegree,
        complementPhrase: 'völlig unbemerkt (Zustand des Vorgangs/Subjekts)',
        fullSentence:
            'Ein fehlerhafter Microservice schleuste unbemerkt korrupte Datenpakete in die Replikationswarteschlange ein.',
        isObligatory: false,
        domain: CommunicativeDomain.softwareEngineering,
        arabicTranslation:
            'دسّت خدمة مصغرة معيبة دون أن يلاحظها أحد حزم بيانات تالفة داخل طابور المزامنة والتكرار.',
        grammaticalAnalysisArabic:
            'مسند ثانوي وصفي للحال (unbemerkt): يصف غياب الرصد والانتباه أثناء وقوع الحدث، ويبقى مجرداً من أي تصريف إعرابي.',
        grammaticalAnalysisGerman:
            'Depiktives Prädikat zur Schilderung des Begleitumstands ("unbemerkt"). Modifiziert nicht die Art des Einschleusens, sondern den Wahrnehmungszustand.',
        substitutionTestFormula:
            'Paraphrase: Der Service schleuste Daten ein, und dies geschah, ohne dass es jemand bemerkte.',
        diagnosticTrapWarning:
            'Häufige Verwechslung mit rein modalen Adverbien.',
      ),
    );

    // 15. Präpositionalobjekt: absehen von + Dativ - Civil Infrastructure
    _catalog.add(
      const ValenceTopographyModel(
        id: 'VAL-PREP-OBJ-ABSEHEN-15',
        governingVerb: 'absehen von',
        complementType: ValenceComplementType.prepositionalObject,
        testCategory: InterrogativeTestCategory.prepositionalPronoun,
        complementPhrase: 'von einer vollständigen Neuverlegung der Rohrtrasse',
        fullSentence:
            'Aufgrund der erfolgreichen Rohrsanierung sah die Bauleitung von einer vollständigen Neuverlegung der Trasse ab.',
        isObligatory: true,
        domain: CommunicativeDomain.civilInfrastructure,
        arabicTranslation:
            'نظراً لنجاح أعمال ترميم الأنابيب، صرفت إدارة المشروع النظر عن إعادة مد المسار بالكامل.',
        grammaticalAnalysisArabic:
            'مفعول مقيد بـ von + Dativ (absehen von): الاستفسار عنه بـ "Wovon sah die Leitung ab?"، ولا علاقة له بالجهات المكانية.',
        grammaticalAnalysisGerman:
            'Fester Valenzrahmen: "absehen von" + Dativ. Das Pronominaladverb "wovon" testet das Präpositionalobjekt.',
        substitutionTestFormula:
            'Fragetest: Wovon sah die Leitung ab?  -->  Von einer Neuverlegung.',
        diagnosticPitfallWarning:
            'Nicht als räumliche Blickabwendung (*Wohin sah sie ab?) missdeuten.',
      ),
    );

    // 16. Sekundäres Prädikat (Resultativ): gasdicht - Aerospace Aviation
    _catalog.add(
      const ValenceTopographyModel(
        id: 'VAL-RESULTATIV-GASDICHT-16',
        governingVerb: 'verschließen',
        complementType: ValenceComplementType.secondaryPredicateResultative,
        testCategory: InterrogativeTestCategory.mannerDegree,
        complementPhrase: 'vollständig gasdicht (Endzustand der Schleuse)',
        fullSentence:
            'Die automatische Schließmechanik verschloss das Schott der Notausstiegskammer vollständig gasdicht.',
        isObligatory: false,
        domain: CommunicativeDomain.aerospaceAndAviation,
        arabicTranslation:
            'أغلقت آلية الإغلاق التلقائية حاجز حجرة الخروج الطارئ إغلاقاً محكماً عازلاً للغازات تماماً.',
        grammaticalAnalysisArabic:
            'مسند ثانوي ناتج (Resultativ): الإحكام العازل للغازات (gasdicht) هو الأثر النهائي المستقر الواقع على الحاجز نتيجة القفل، ويلزم عدم التصريف.',
        grammaticalAnalysisGerman:
            'Resultatives Prädikat zum Akkusativobjekt ("das Schott"). Bezeichnet die neu geschaffene physikalische Eigenschaft nach Vollendung der Schließung.',
        substitutionTestFormula:
            'Paraphrase: Die Mechanik verschloss das Schott so, dass es gasdicht war.',
        diagnosticTrapWarning:
            'Unflektierte Form ist Pflicht (*verschloss das Schott gasdichtes ist schwerer Fehler).',
      ),
    );
  }

  /// Evaluates an input sentence for correct complement classification and uninflected secondary predicates.
  ValenceValidationReport validateComplementStructure({
    required String governingVerb,
    required ValenceComplementType complementType,
    required bool isObligatorySupplied,
    required bool isSecondaryPredicateUninflected,
  }) {
    final issues = <String>[];
    final recommendations = <String>[];

    final isSecondaryPredicate =
        complementType == ValenceComplementType.secondaryPredicateDepictive ||
        complementType == ValenceComplementType.secondaryPredicateResultative;

    if (isSecondaryPredicate && !isSecondaryPredicateUninflected) {
      issues.add(
        'Morphologischer Fehler beim sekundären Prädikat: Depiktive und resultative Prädikate (z. B. unbeschädigt, flach, spiegelblank) dürfen NIEMALS wie attributive Adjektive flektiert werden. Sie bleiben stets endungslos.',
      );
      recommendations.add(
        'Verwenden Sie die reine unflektierte Grundform des Adjektivs (z. B. "presste das Blech flach", nicht "*flaches").',
      );
    }

    final isObligatoryType =
        complementType == ValenceComplementType.directionalComplement ||
        complementType == ValenceComplementType.situationalComplement ||
        complementType == ValenceComplementType.prepositionalObject;

    if (isObligatoryType && !isObligatorySupplied) {
      issues.add(
        'Valenzlücke: Das Verb "$governingVerb" fordert eine obligatorische Valenzergänzung ($complementType). Ohne diese Angabe ist der Satz syntaktisch unvollständig.',
      );
      recommendations.add(
        'Ergänzen Sie die geforderte Direktive, Situative oder das Präpositionalobjekt.',
      );
    }

    final isValid = issues.isEmpty;
    final verdict = isValid
        ? 'التركيب النحوي للمكمل الفعلي وتجريد المسند الثانوي من التصريف سليم تماماً ومطابق لمعايير C1-C2.'
        : 'تم رصد خلل في استيفاء مكملات الفعل الإلزامية أو تصريف خاطئ لمسند ثانوي مجرد.';

    return ValenceValidationReport(
      isValid: isValid,
      isComplementCorrectlyTyped: isValid,
      avoidsWrongAdjectiveInflection: !isSecondaryPredicate || isSecondaryPredicateUninflected,
      respectsObligatoryValence: !isObligatoryType || isObligatorySupplied,
      issues: issues,
      recommendations: recommendations,
      arabicDiagnosticVerdict: verdict,
    );
  }

  List<ValenceTopographyModel> filterByType(ValenceComplementType type) {
    return _catalog.where((item) => item.complementType == type).toList();
  }

  List<ValenceTopographyModel> filterByDomain(CommunicativeDomain domain) {
    return _catalog.where((item) => item.domain == domain).toList();
  }
}
