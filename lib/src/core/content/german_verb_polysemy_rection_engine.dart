import 'dart:collection';

/// Base verb root groups that exhibit drastic semantic shifts based on prepositional rection.
enum BaseVerbGroup {
  bestehen('bestehen', 'ثبت / قام / تشكل'),
  ankommen('ankommen', 'وصل / اعتمد / لاقى قبولاً'),
  ausgehen('ausgehen', 'افترض / انطلق / استهدف / انطفأ'),
  absehen('absehen', 'تغاضى / استهدف / توقع'),
  halten('halten', 'اعتبر / رأى / التزم / اعتنى'),
  passen('passen', 'طابق / ناسب / واءم'),
  fuehren('führen', 'أدى إلى / قاد نحو'),
  anknuepfen('anknüpfen', 'ربط بـ / استند إلى');

  final String de;
  final String ar;
  const BaseVerbGroup(this.de, this.ar);
}

/// Preposition and governed case combination.
enum RectionPreposition {
  aufAkk('auf + Akkusativ', 'على + النصب'),
  aufDat('auf + Dativ', 'على + الجر'),
  ausDat('aus + Dativ', 'من + الجر'),
  inDat('in + Dativ', 'في + الجر'),
  inAkk('in + Akkusativ', 'إلى / داخل + النصب'),
  zuDat('zu + Dativ', 'إلى / نحو + الجر'),
  vonDat('von + Dativ', 'عن / من + الجر'),
  beiDat('bei + Dativ', 'لدى / عند + الجر'),
  fuerAkk('für + Akkusativ', 'لأجل / لـ + النصب'),
  nachDat('nach + Dativ', 'نحو / بحسب + الجر'),
  anAkk('an + Akkusativ', 'بـ / عند + النصب'),
  anDat('an + Dativ', 'بـ / في + الجر');

  final String formula;
  final String arabicFormula;
  const RectionPreposition(this.formula, this.arabicFormula);
}

/// Semantic category of the resulting shift.
enum SemanticShiftCategory {
  materialComposition(
    'Materielle Zusammensetzung',
    'التركيب المادي والعناصري',
  ),
  dogmaticInsistence(
    'Beharren & Unnachgiebigkeit',
    'الإصرار والتمسك الصارم',
  ),
  existentialEssence(
    'Wesenhafter Kern & Definition',
    'الجوهر الوجودي والتعريف الماهوي',
  ),
  probabilisticAssumption(
    'Hypothetische Ausgangsannahme',
    'الفرضية المبدئية والاستناد النظري',
  ),
  spatialArrival(
    'Lokale Ankunft am Zielort',
    'الوصول المكاني إلى الوجهة',
  ),
  systemicDependency(
    'Konditionale Abhängigkeit & Kriterium',
    'الاعتماد والتعليق على شرط محدد',
  ),
  adherenceToNorm(
    'Normtreue & Regeltreue',
    'الامتثال والالتزام بالمعايير',
  ),
  judgmentalOpinion(
    'Subjektive Wertung & Ansicht',
    'التقدير التقييمي وإبداء الرأي',
  ),
  targetPursuit(
    'Zielverfolgung & Absicht',
    'استهداف غاية أو مطمع محدد',
  ),
  consequenceInduction(
    'Kausale Folgewirkung',
    'التسبيب والإفضاء إلى نتيجة',
  );

  final String de;
  final String ar;
  const SemanticShiftCategory(this.de, this.ar);
}

/// Professional and engineering domains free of legal/medical liability.
enum CommunicativeDomain {
  renewableEnergyGrid('Erneuerbare Energien & Netztechnik', 'الطاقة المتجددة وهندسة الشبكات'),
  aerospaceAndAviation('Luft- & Raumfahrttechnik', 'هندسة الطيران واستكشاف الفضاء'),
  industrialRobotics('Industrierobotik & Automatisierung', 'الروبوتات الصناعية والأتمتة'),
  civilInfrastructure('Bauingenieurwesen & Materialprüfung', 'الهندسة المدنية وفحص المواد'),
  materialScience('Werkstoffkunde & Nanostrukturen', 'علم المواد والتراكيب النانوية'),
  maritimeLogistics('Maritime Schifffahrt & Hafenumschlag', 'الملاحة البحرية والشحن الدولي');

  final String de;
  final String ar;
  const CommunicativeDomain(this.de, this.ar);
}

/// Model of a specific verb-preposition rection variant.
class VerbRectionVariantModel {
  final String id;
  final BaseVerbGroup baseVerb;
  final RectionPreposition rectionPreposition;
  final SemanticShiftCategory semanticCategory;
  final String formulaGerman;
  final String primaryMeaningArabic;
  final String primaryMeaningGerman;
  final CommunicativeDomain domain;
  final String sampleSentence;
  final String arabicTranslation;
  final String grammaticalAnalysisArabic;
  final String grammaticalAnalysisGerman;
  final String falsePrepositionPitfall;
  final String diagnosticCorrectionRule;

  const VerbRectionVariantModel({
    required this.id,
    required this.baseVerb,
    required this.rectionPreposition,
    required this.semanticCategory,
    required this.formulaGerman,
    required this.primaryMeaningArabic,
    required this.primaryMeaningGerman,
    required this.domain,
    required this.sampleSentence,
    required this.arabicTranslation,
    required this.grammaticalAnalysisArabic,
    required this.grammaticalAnalysisGerman,
    required this.falsePrepositionPitfall,
    required this.diagnosticCorrectionRule,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'baseVerb': baseVerb.name,
    'rectionPreposition': rectionPreposition.name,
    'semanticCategory': semanticCategory.name,
    'formulaGerman': formulaGerman,
    'primaryMeaningArabic': primaryMeaningArabic,
    'primaryMeaningGerman': primaryMeaningGerman,
    'domain': domain.name,
    'sampleSentence': sampleSentence,
    'arabicTranslation': arabicTranslation,
    'grammaticalAnalysisArabic': grammaticalAnalysisArabic,
    'grammaticalAnalysisGerman': grammaticalAnalysisGerman,
    'falsePrepositionPitfall': falsePrepositionPitfall,
    'diagnosticCorrectionRule': diagnosticCorrectionRule,
  };
}

/// Validation report container for verb rection shift analysis.
class VerbRectionValidationReport {
  final bool isValid;
  final bool matchesIntendedMeaning;
  final bool isCasePrepositionCorrect;
  final List<String> issues;
  final List<String> recommendations;
  final String arabicDiagnosticVerdict;

  const VerbRectionValidationReport({
    required this.isValid,
    required this.matchesIntendedMeaning,
    required this.isCasePrepositionCorrect,
    required this.issues,
    required this.recommendations,
    required this.arabicDiagnosticVerdict,
  });
}

/// Sovereign engine governing German Verb Polysemy Rection Shifts & Semantic Divergence.
class GermanVerbPolysemyRectionEngine {
  final List<VerbRectionVariantModel> _catalog = [];

  GermanVerbPolysemyRectionEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<VerbRectionVariantModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    // 1. bestehen auf + Dativ (Insistence) - Civil Infrastructure
    _catalog.add(
      const VerbRectionVariantModel(
        id: 'REC-BESTEHEN-AUF-01',
        baseVerb: BaseVerbGroup.bestehen,
        rectionPreposition: RectionPreposition.aufDat,
        semanticCategory: SemanticShiftCategory.dogmaticInsistence,
        formulaGerman: 'bestehen auf + Dativ',
        primaryMeaningArabic: 'الإصرار والتمسك الصارم بتنفيذ المعيار',
        primaryMeaningGerman: 'Auf der strikten Einhaltung einer Vorgabe beharren',
        domain: CommunicativeDomain.civilInfrastructure,
        sampleSentence:
            'Der leitende Prüfstatiker besteht unnachgiebig auf der Einhaltung der DIN-Sicherheitsnorm.',
        arabicTranslation:
            'يُصر كبير مهندسي التدقيق الإنشائي بصرامة مطلقة على الالتزام بمعيار الأمان وفق المواصفات القياسية الألمانية DIN.',
        grammaticalAnalysisArabic:
            'تعدي الفعل بـ "auf + Dativ": يفيد الإصرار والعزم الحاسم على الأمر (auf der Einhaltung). يختلف كلياً عن bestehen aus.',
        grammaticalAnalysisGerman:
            'Verb mit fester Präposition "auf" + Dativ. Drückt eine unumstößliche Forderung oder Willenshaltung aus.',
        falsePrepositionPitfall:
            'Verwechslung mit Akkusativ (*besteht auf die Einhaltung) oder falsche Präposition (*besteht in der Einhaltung).',
        diagnosticCorrectionRule:
            'Zur Formulierung eines rechtlichen oder normativen Beharrens zwingend "auf + Dativ" verwenden.',
      ),
    );

    // 2. bestehen aus + Dativ (Material Composition) - Material Science
    _catalog.add(
      const VerbRectionVariantModel(
        id: 'REC-BESTEHEN-AUS-02',
        baseVerb: BaseVerbGroup.bestehen,
        rectionPreposition: RectionPreposition.ausDat,
        semanticCategory: SemanticShiftCategory.materialComposition,
        formulaGerman: 'bestehen aus + Dativ',
        primaryMeaningArabic: 'التألف والتكون المادي من عناصر محددة',
        primaryMeaningGerman: 'Aus bestimmten stofflichen Komponenten zusammengesetzt sein',
        domain: CommunicativeDomain.materialScience,
        sampleSentence:
            'Die neuentwickelte Hitzeschutzkeramik besteht aus nanoskaligen Siliziumkarbid-Fasern.',
        arabicTranslation:
            'يتألف خزف الحماية الحرارية المطور حديثاً من ألياف كربيد السيليكون النانوية الدقيقة.',
        grammaticalAnalysisArabic:
            'تعدي الفعل بـ "aus + Dativ": يدل على المكونات الفيزيائية والكيميائية الملموسة للمادة المصنوعة.',
        grammaticalAnalysisGerman:
            'Präpositionalrektion "aus" + Dativ zur Angabe des Werkstoffs oder der physischen Bestandteile.',
        falsePrepositionPitfall:
            'Fehlerhafter Gebrauch von "von" (*besteht von Fasern) oder "in" (*besteht in Fasern).',
        diagnosticCorrectionRule:
            'Bei substanziellen und werkstofflichen Bestandteilen ausnahmslos "aus + Dativ" verwenden.',
      ),
    );

    // 3. bestehen in + Dativ (Essence/Definition) - Software Architecture
    _catalog.add(
      const VerbRectionVariantModel(
        id: 'REC-BESTEHEN-IN-03',
        baseVerb: BaseVerbGroup.bestehen,
        rectionPreposition: RectionPreposition.inDat,
        semanticCategory: SemanticShiftCategory.existentialEssence,
        formulaGerman: 'bestehen in + Dativ',
        primaryMeaningArabic: 'التمثل والكمون في جوهر الشيء وماهيته',
        primaryMeaningGerman: 'Den wesentlichen Inhalt oder Zweck einer Sache ausmachen',
        domain: CommunicativeDomain.softwareEngineering,
        sampleSentence:
            'Die wesentliche Herausforderung dieses verteilten Systems besteht in der fehlerfreien Synchronisation der Replikate.',
        arabicTranslation:
            'يتمثل التحدي الجوهري في هذه المنظومة الموزعة في مزامنة النسخ المتطابقة وتناسقها التام دون أي خطأ.',
        grammaticalAnalysisArabic:
            'تعدي الفعل بـ "in + Dativ": يعبر عن حقيقة المشكلة أو كنه الميزة (تكمن المشكلة في / يتمثل السر في).',
        grammaticalAnalysisGerman:
            'Abstrakte Wesensbestimmung mittels "in" + Dativ. Beschreibt, worin der eigentliche Kern einer Sache liegt.',
        falsePrepositionPitfall:
            'Verwechslung mit "bestehen aus": Man kann nicht sagen "*Die Herausforderung besteht aus der Synchronisation".',
        diagnosticCorrectionRule:
            'Für abstrakte Definitionen, Hauptaufgaben und Kernfragen stets "bestehen in + Dativ" wählen.',
      ),
    );

    // 4. ankommen auf + Akkusativ (Systemic Dependency) - Aerospace Engineering
    _catalog.add(
      const VerbRectionVariantModel(
        id: 'REC-ANKOMMEN-AUF-04',
        baseVerb: BaseVerbGroup.ankommen,
        rectionPreposition: RectionPreposition.aufAkk,
        semanticCategory: SemanticShiftCategory.systemicDependency,
        formulaGerman: 'ankommen auf + Akkusativ (unpersönlich)',
        primaryMeaningArabic: 'التوقف والاعتماد الحاسم على عامل محدد (المرد والفيصل في الأمر)',
        primaryMeaningGerman: 'Von einem entscheidenden Faktor maßgeblich abhängen',
        domain: CommunicativeDomain.aerospaceAndAviation,
        sampleSentence:
            'Beim atmosphärischen Wiedereintritt der Kapsel kommt es auf den exakten Neigungswinkel an.',
        arabicTranslation:
            'عند دخول الكبسولة إلى الغلاف الجوي مجدداً، يتوقف النجاح الحاسم على زاوية الميل الدقيقة للغاية.',
        grammaticalAnalysisArabic:
            'التركيب غير الشخصي "es kommt an auf + Akkusativ": يفيد أن العامل المذكور هو مربط الفرس وأساس النجاح.',
        grammaticalAnalysisGerman:
            'Unpersönliche Konstruktion mit Valenz-es und fester Präposition "auf" + Akkusativ (Konditionalsinn).',
        falsePrepositionPitfall:
            'Falscher Dativ (*kommt auf dem Winkel an) oder unvollständiger Ausdruck ohne "es" (*Der Erfolg kommt auf den Winkel an).',
        diagnosticCorrectionRule:
            'Zur Ausdrückung von ausschlaggebender Relevanz zwingend "es kommt an auf + Akkusativ" nutzen.',
      ),
    );

    // 5. ankommen in + Dativ (Spatial Arrival) - Maritime Logistics
    _catalog.add(
      const VerbRectionVariantModel(
        id: 'REC-ANKOMMEN-IN-05',
        baseVerb: BaseVerbGroup.ankommen,
        rectionPreposition: RectionPreposition.inDat,
        semanticCategory: SemanticShiftCategory.spatialArrival,
        formulaGerman: 'ankommen in + Dativ',
        primaryMeaningArabic: 'الوصول المكاني المادي إلى الميناء أو المدينة',
        primaryMeaningGerman: 'Einen geografischen Zielort physisch erreichen',
        domain: CommunicativeDomain.maritimeLogistics,
        sampleSentence:
            'Das vollbeladene Containerschiff wird morgen früh im Hamburger Hafen ankommen.',
        arabicTranslation:
            'ستصل سفينة الحاويات المحملة بالكامل صباح الغد إلى ميناء هامبورغ.',
        grammaticalAnalysisArabic:
            'تعدي الفعل بـ "in + Dativ" للوصول المكاني بعد قطع الرحلة: im Hamburger Hafen (Dativ).',
        grammaticalAnalysisGerman:
            'Lokale Direktiv- und Zielfunktion mit "in" + Dativ zur Bezeichnung des erreichten Orts.',
        falsePrepositionPitfall:
            'Verwechslung mit Akkusativ (*in den Hafen ankommen) oder Präposition nach (*nach Hamburg ankommen).',
        diagnosticCorrectionRule:
            'Bei Erreichen von Städten, Ländern und Häfen folgt nach "ankommen" die Präposition "in + Dativ".',
      ),
    );

    // 6. ankommen bei + Dativ (Social/Team Resonance) - Industrial Robotics
    _catalog.add(
      const VerbRectionVariantModel(
        id: 'REC-ANKOMMEN-BEI-06',
        baseVerb: BaseVerbGroup.ankommen,
        rectionPreposition: RectionPreposition.beiDat,
        semanticCategory: SemanticShiftCategory.judgmentalOpinion,
        formulaGerman: 'ankommen bei + Dativ',
        primaryMeaningArabic: 'الملاقاة للاستحسان والقبول لدى الفريق أو المستفيدين',
        primaryMeaningGerman: 'Auf positive oder negative Resonanz bei einer Personengruppe stoßen',
        domain: CommunicativeDomain.industrialRobotics,
        sampleSentence:
            'Die neuartige intuitive Touch-Bedienung des Roboterarms kommt bei den Fabrikarbeitern hervorragend an.',
        arabicTranslation:
            'لاقت واجهة التحكم اللمسية البديهية والمبتكرة لذراع الروبوت استحساناً وترحيباً رائعاً لدى عمال المصنع.',
        grammaticalAnalysisArabic:
            'تعدي الفعل بـ "bei + Dativ": يعبر عن الصدى الإيجابي أو التقييم المشترك لدى جمهور المستخدمين.',
        grammaticalAnalysisGerman:
            'Präposition "bei" + Dativ indiziert das soziale Bezugsfeld und die emotionale Akzeptanz.',
        falsePrepositionPitfall:
            'Falsche Präposition "mit" (*kommt mit den Arbeitern an) oder "zu" (*kommt zu den Arbeitern an).',
        diagnosticCorrectionRule:
            'Für Resonanz und Akzeptanz bei Zielgruppen stets "ankommen bei + Dativ" wählen.',
      ),
    );

    // 7. ausgehen von + Dativ (Probabilistic Assumption) - Renewable Energy
    _catalog.add(
      const VerbRectionVariantModel(
        id: 'REC-AUSGEHEN-VON-07',
        baseVerb: BaseVerbGroup.ausgehen,
        rectionPreposition: RectionPreposition.vonDat,
        semanticCategory: SemanticShiftCategory.probabilisticAssumption,
        formulaGerman: 'ausgehen von + Dativ',
        primaryMeaningArabic: 'الانطلاق من فرضية أو تقدير أولي والاعتماد عليه كأساس',
        primaryMeaningGerman: 'Eine begründete Annahme oder Prämisse zugrunde legen',
        domain: CommunicativeDomain.renewableEnergyGrid,
        sampleSentence:
            'Die Netzplaner gehen bei der Kapazitätsberechnung von einem stetigen Anstieg der Einspeiseleistung aus.',
        arabicTranslation:
            'ينطلق مخططو الشبكة الكهربائية في حسابات السعة من افتراض حدوث زيادة مطردة في قدرة الطاقة المضخومة.',
        grammaticalAnalysisArabic:
            'الفعل المنفصل "ausgehen von + Dativ": يفيد البناء على معطيات وفرضيات حسابية محددة.',
        grammaticalAnalysisGerman:
            'Pronominalverbale Rektion mit "von" + Dativ zur Kennzeichnung der epistemischen Ausgangsbasis.',
        falsePrepositionPitfall:
            'Verwechslung mit "ausgehen aus" (*gehen aus einem Anstieg aus ist falsch).',
        diagnosticCorrectionRule:
            'Im wissenschaftlichen Diskurs für Annahmen und Thesen zwingend "ausgehen von + Dativ" anwenden.',
      ),
    );

    // 8. absehen von + Dativ (Disregard/Refrain) - Civil Infrastructure
    _catalog.add(
      const VerbRectionVariantModel(
        id: 'REC-ABSEHEN-VON-08',
        baseVerb: BaseVerbGroup.absehen,
        rectionPreposition: RectionPreposition.vonDat,
        semanticCategory: SemanticShiftCategory.dogmaticInsistence,
        formulaGerman: 'absehen von + Dativ',
        primaryMeaningArabic: 'صرف النظر والتغاضي عن إجراء معين تيسيراً أو استغناءً',
        primaryMeaningGerman: 'Auf eine Maßnahme oder Geltendmachung bewusst verzichten',
        domain: CommunicativeDomain.civilInfrastructure,
        sampleSentence:
            'Wegen der hervorragenden Materialprüfwerte sah die Bauaufsicht von einer zusätzlichen Kernbohrung ab.',
        arabicTranslation:
            'نظراً لنتائج فحص المواد الممتازة، صرفت هيئة الرقابة على البناء النظر عن إجراء حفر أسطواني إضافي.',
        grammaticalAnalysisArabic:
            'تعدي الفعل بـ "von + Dativ": يفيد العدول عن الشيء وترك تنفيذه طواعية.',
        grammaticalAnalysisGerman:
            'Verbale Fügung "absehen von" + Dativ drückt den freiwilligen Verzicht auf eine Handlung aus.',
        falsePrepositionPitfall:
            'Verwechslung mit "es absehen auf" (*sah auf eine Bohrung ab bedeutet böswilliges Anvisieren!).',
        diagnosticCorrectionRule:
            'Für "verzichten auf / ignorieren" ist ausschließlich "absehen von + Dativ" korrekt.',
      ),
    );

    // 9. es absehen auf + Akkusativ (Malicious/Target Pursuit) - Industrial Automation
    _catalog.add(
      const VerbRectionVariantModel(
        id: 'REC-ABSEHEN-AUF-09',
        baseVerb: BaseVerbGroup.absehen,
        rectionPreposition: RectionPreposition.aufAkk,
        semanticCategory: SemanticShiftCategory.targetPursuit,
        formulaGerman: 'es abgesehen haben auf + Akkusativ',
        primaryMeaningArabic: 'الاستهداف المتعمد لشيء معين بنيّة السيطرة أو الاستيلاء',
        primaryMeaningGerman: 'Zielgerichtet und meist mit unlauterer Absicht eine Sache anvisieren',
        domain: CommunicativeDomain.industrialRobotics,
        sampleSentence:
            'Industriespione hatten es vor allem auf die patentierten Schweißparameter der Steuerungssoftware abgesehen.',
        arabicTranslation:
            'كان جواسيس الصناعة يضعون نصب أعينهم تحديداً ويستهدفون إعدادات اللحام الحاصلة على براءة اختراع.',
        grammaticalAnalysisArabic:
            'التركيب التعبيري "es abgesehen haben auf + Akkusativ": يفيد التربص بالشيء واستهدافه مطمعاً.',
        grammaticalAnalysisGerman:
            'Idiomatisches Gefüge mit obligatorischem Scheinsubjekt/-objekt "es" und Präposition "auf" + Akkusativ.',
        falsePrepositionPitfall:
            'Gefährliche Bedeutungsverwechslung mit "absehen von" (Verzicht vs. gezielter Angriff!).',
        diagnosticCorrectionRule:
            'Das Streben nach einem unlauteren Ziel erfordert "es abgesehen haben auf + Akkusativ".',
      ),
    );

    // 10. halten von + Dativ (Opinion/Estimation) - Maritime Logistics
    _catalog.add(
      const VerbRectionVariantModel(
        id: 'REC-HALTEN-VON-10',
        baseVerb: BaseVerbGroup.halten,
        rectionPreposition: RectionPreposition.vonDat,
        semanticCategory: SemanticShiftCategory.judgmentalOpinion,
        formulaGerman: 'halten von + Dativ',
        primaryMeaningArabic: 'الرأي والتقييم الشخصي حول فكرة أو خطة مقترحة',
        primaryMeaningGerman: 'Eine qualitative Meinung oder ein Werturteil über etwas haben',
        domain: CommunicativeDomain.maritimeLogistics,
        sampleSentence:
            'Was hält der Hafenkapitän von der Verlegung der Fahrrinne nach Westen?',
        arabicTranslation:
            'ما هو رأي قبطان الميناء وتقييمه لمقترح نقل وتعديل مسار المجرى الملاحي غرباً؟',
        grammaticalAnalysisArabic:
            'تعدي الفعل بـ "von + Dativ": يسأل عن الرأي والتقدير الموضوعي (ما رأيك في كذا؟).',
        grammaticalAnalysisGerman:
            'Frage nach der Urteilsbildung: "halten von" + Dativ erfragt die Haltung zu einem Sachverhalt.',
        falsePrepositionPitfall:
            'Verwechslung mit "halten für" (*Was hält er für die Verlegung ist falsch; "halten für" erfordert ein Adjektiv/Prädikativ).',
        diagnosticCorrectionRule:
            'Für "eine Meinung haben über" stets "halten von + Dativ" anwenden.',
      ),
    );

    // 11. halten für + Akkusativ (Categorization/Deeming) - Aerospace Engineering
    _catalog.add(
      const VerbRectionVariantModel(
        id: 'REC-HALTEN-FUER-11',
        baseVerb: BaseVerbGroup.halten,
        rectionPreposition: RectionPreposition.fuerAkk,
        semanticCategory: SemanticShiftCategory.judgmentalOpinion,
        formulaGerman: 'halten für + Akkusativ',
        primaryMeaningArabic: 'الاعتبار والعدّ والتصنيف كصفة مؤكدة (يعتبر الشيء كذا)',
        primaryMeaningGerman: 'Etwas als wahr, plausibel oder erwiesen erachten (mit Prädikativ)',
        domain: CommunicativeDomain.aerospaceAndAviation,
        sampleSentence:
            'Die Missionsleitung hält den neuen Wärmeschild für uneingeschränkt flugtauglich.',
        arabicTranslation:
            'تعتبر إدارة المهمة الفضائية الدرع الواقي من الحرارة الجديد صالحاً تماماً للطيران دون أي قيد.',
        grammaticalAnalysisArabic:
            'تعدي الفعل بـ "für + Akkusativ": يربط المفعول به بوصف واعتبار خبري (يعده صالحاً / يعتبره آمناً).',
        grammaticalAnalysisGerman:
            'Kopulatives Urteilsgefüge: "halten" + Akkusativobjekt + "für" + prädikatives Adjektiv/Substantiv.',
        falsePrepositionPitfall:
            'Falsches Weglassen von "für" (*hält den Schild flugtauglich) oder falsche Präposition (*hält als flugtauglich).',
        diagnosticCorrectionRule:
            'Beim Zuschreiben einer Eigenschaft an ein Objekt immer "halten für + Akkusativ" konstruieren.',
      ),
    );

    // 12. sich halten an + Akkusativ (Adherence to Rules) - Industrial Robotics
    _catalog.add(
      const VerbRectionVariantModel(
        id: 'REC-HALTEN-AN-12',
        baseVerb: BaseVerbGroup.halten,
        rectionPreposition: RectionPreposition.anAkk,
        semanticCategory: SemanticShiftCategory.adherenceToNorm,
        formulaGerman: 'sich halten an + Akkusativ',
        primaryMeaningArabic: 'التقيد والالتزام التام بالتعليمات والضوابط المبرمجة',
        primaryMeaningGerman: 'Vorgegebene Regeln, Vorschriften oder Vereinbarungen strikt befolgen',
        domain: CommunicativeDomain.industrialRobotics,
        sampleSentence:
            'Die adaptive Sicherheitssteuerung hält sich exakt an die vorgeschriebenen Abstandsradien.',
        arabicTranslation:
            'تلتزم منظومة الأمان التكيفية بدقة متناهية بنطاقات وأنصاف أقطار الأمان المقررة.',
        grammaticalAnalysisArabic:
            'التركيب الانعكاسي "sich halten an + Akkusativ": يفيد التقيد الصارم بالنصوص والقواعد.',
        grammaticalAnalysisGerman:
            'Reflexives Verbgefüge mit "an" + Akkusativ als Direktive zur Regeltreue.',
        falsePrepositionPitfall:
            'Vergessen des Reflexivpronomens (*Die Steuerung hält an die Radien) oder falscher Dativ (*an den Radien).',
        diagnosticCorrectionRule:
            'Zur Regeltreue ist das Reflexivpronomen und "an + Akkusativ" unverzichtbar.',
      ),
    );

    // 13. passen zu + Dativ (Aesthetic/Systemic Compatibility) - Material Science
    _catalog.add(
      const VerbRectionVariantModel(
        id: 'REC-PASSEN-ZU-13',
        baseVerb: BaseVerbGroup.passen,
        rectionPreposition: RectionPreposition.zuDat,
        semanticCategory: SemanticShiftCategory.materialComposition,
        formulaGerman: 'passen zu + Dativ',
        primaryMeaningArabic: 'التوافق والانسجام التام مع خصائص المواد الأخرى',
        primaryMeaningGerman: 'Mit einer anderen Komponente harmonieren oder kompatibel sein',
        domain: CommunicativeDomain.materialScience,
        sampleSentence:
            'Der thermische Ausdehnungskoeffizient des Trägerharzes passt perfekt zu den Kohlenstofffasern.',
        arabicTranslation:
            'يتوافق ويتناغم معامل التمدد الحراري للراتنج الحامل توافقاً تاماً مع ألياف الكربون.',
        grammaticalAnalysisArabic:
            'تعدي الفعل بـ "zu + Dativ": يفيد التلاؤم الوظيفي والتجانس الهندسي المتبادل.',
        grammaticalAnalysisGerman:
            'Präposition "zu" + Dativ zur Angabe wechselseitiger Kompatibilität und Systemharmonie.',
        falsePrepositionPitfall:
            'Falsche Präposition "mit" (*passt perfekt mit den Fasern) oder "für" (*passt für die Fasern).',
        diagnosticCorrectionRule:
            'Bei harmonischer Zusammengehörigkeit und technischer Kompatibilität stets "passen zu + Dativ" wählen.',
      ),
    );

    // 14. führen zu + Dativ (Causal Induction) - Renewable Energy
    _catalog.add(
      const VerbRectionVariantModel(
        id: 'REC-FUEHREN-ZU-14',
        baseVerb: BaseVerbGroup.fuehren,
        rectionPreposition: RectionPreposition.zuDat,
        semanticCategory: SemanticShiftCategory.consequenceInduction,
        formulaGerman: 'führen zu + Dativ',
        primaryMeaningArabic: 'التسبيب والإفضاء الحتمي إلى نتيجة أو واقعة تقنية',
        primaryMeaningGerman: 'Einen kausalen Zustand oder ein Endergebnis unausweichlich bewirken',
        domain: CommunicativeDomain.renewableEnergyGrid,
        sampleSentence:
            'Jede unkontrollierte Frequenzabweichung führt im Verbundnetz unverzüglich zur Schutzabschaltung.',
        arabicTranslation:
            'أي انحراف غير منضبط في التردد يفضي فوراً وبشكل حتمي في الشبكة الموحدة إلى الإغلاق الوقائي التلقائي.',
        grammaticalAnalysisArabic:
            'تعدي الفعل بـ "zu + Dativ": يفيد السببية المباشرة والنتيجة الحتمية المترتبة على السبب.',
        grammaticalAnalysisGerman:
            'Kausale Folgerelation mit Richtungspräposition "zu" + Dativ.',
        falsePrepositionPitfall:
            'Weglassen von "zu" (*führt die Schutzabschaltung) oder falsche Präposition (*führt in die Abschaltung).',
        diagnosticCorrectionRule:
            'Zum Ausdrücken von Ursache-Wirkungs-Ketten ausnahmslos "führen zu + Dativ" formulieren.',
      ),
    );

    // 15. anknüpfen an + Akkusativ (Thematic Continuity) - Civil Infrastructure
    _catalog.add(
      const VerbRectionVariantModel(
        id: 'REC-ANKNUEPFEN-AN-15',
        baseVerb: BaseVerbGroup.anknuepfen,
        rectionPreposition: RectionPreposition.anAkk,
        semanticCategory: SemanticShiftCategory.systemicDependency,
        formulaGerman: 'anknüpfen an + Akkusativ',
        primaryMeaningArabic: 'البناء والاستناد إلى دراسات وتجارب سابقة ومواصلتها',
        primaryMeaningGerman: 'Auf vorangegangene Erkenntnisse, Daten oder Beschlüsse nahtlos aufbauen',
        domain: CommunicativeDomain.civilInfrastructure,
        sampleSentence:
            'Die neuen Baugrundgutachten knüpfen direkt an die geologischen Sondierungsbohrungen des Vorjahres an.',
        arabicTranslation:
            'تبني تقارير التربة الإنشائية الجديدة مباشرة وتستند إلى عمليات الحفر السبرية الجيولوجية للعام السابق.',
        grammaticalAnalysisArabic:
            'تعدي الفعل المنفصل بـ "an + Akkusativ": يفيد الوصل والاتصال الموضوعي ومتابعة العمل السابق.',
        grammaticalAnalysisGerman:
            'Metaphorische Fortführungstradition mittels "an" + Akkusativ (Orientierung auf die Vorlage hin).',
        falsePrepositionPitfall:
            'Falscher Dativ (*knüpfen an den Bohrungen an) oder falsche Präposition (*knüpfen auf die Bohrungen an).',
        diagnosticCorrectionRule:
            'Zur Formulierung von inhaltlicher Kontinuität stets "anknüpfen an + Akkusativ" verwenden.',
      ),
    );

    // 16. passen in + Akkusativ (Dimensional Enclosure) - Aerospace Engineering
    _catalog.add(
      const VerbRectionVariantModel(
        id: 'REC-PASSEN-IN-16',
        baseVerb: BaseVerbGroup.passen,
        rectionPreposition: RectionPreposition.inAkk,
        semanticCategory: SemanticShiftCategory.spatialArrival,
        formulaGerman: 'passen in + Akkusativ',
        primaryMeaningArabic: 'الملاءمة المكانية والبعدية للدخول والتثبيت في تجويف مخصص',
        primaryMeaningGerman: 'Physisch und dimensional exakt in einen Hohlraum oder Rahmen hineinpassen',
        domain: CommunicativeDomain.aerospaceAndAviation,
        sampleSentence:
            'Das miniaturisierte Spektrometer passt millimetergenau in das vorgesehene Gehäuse der Nutzlastbucht.',
        arabicTranslation:
            'يدخل مقياس الطيف المصغر بمقاس مليميتري بالغ الدقة داخل الهيكل المخصص له في حجرة الحمولة النافعة.',
        grammaticalAnalysisArabic:
            'تعدي الفعل بـ "in + Akkusativ": يفيد الدخول الحركي والاحتواء البعدي الدقيق (Dimensionale Einpassung).',
        grammaticalAnalysisGerman:
            'Räumlich-dimensionale Einpassung mittels Direktivpräposition "in" + Akkusativ.',
        falsePrepositionPitfall:
            'Verwechslung mit Dativ (*passt in dem Gehäuse) bei der Beschreibung des Hineinpassens.',
        diagnosticCorrectionRule:
            'Beim Hineinpassen in Begrenzungen und Halterungen "in + Akkusativ" wählen.',
      ),
    );
  }

  /// Validates a verb-preposition pair against its intended semantic category and case rection.
  VerbRectionValidationReport validateRection({
    required BaseVerbGroup verb,
    required RectionPreposition selectedPreposition,
    required SemanticShiftCategory intendedMeaning,
  }) {
    final issues = <String>[];
    final recommendations = <String>[];

    final matches = _catalog.where(
      (m) =>
          m.baseVerb == verb &&
          m.rectionPreposition == selectedPreposition &&
          m.semanticCategory == intendedMeaning,
    );

    bool isValid = matches.isNotEmpty;

    if (!isValid) {
      final possibleVariants = _catalog.where((m) => m.baseVerb == verb);
      issues.add(
        'Rektions- und Bedeutungsdivergenz: Das Verb "${verb.de}" mit "${selectedPreposition.formula}" drückt nicht "${intendedMeaning.de}" aus.',
      );
      if (possibleVariants.isNotEmpty) {
        recommendations.add(
          'Gültige Rektionsvarianten für "${verb.de}": ' +
              possibleVariants.map((v) => '${v.formulaGerman} (${v.semanticCategory.de})').join(' | '),
        );
      }
    }

    final verdict = isValid
        ? 'التركيب النحوي لتعدي الفعل بالحرف وحالته الإعرابية متطابق تماماً مع المعنى المقصود فصاحةً ودقة.'
        : 'تم رصد تناقض دلالي أو إعرابي بين حرف الجر المختار ومعنى الفعل المستهدف؛ يلزم ضبط حرف الجر وحالته.';

    return VerbRectionValidationReport(
      isValid: isValid,
      matchesIntendedMeaning: isValid,
      isCasePrepositionCorrect: isValid,
      issues: issues,
      recommendations: recommendations,
      arabicDiagnosticVerdict: verdict,
    );
  }

  List<VerbRectionVariantModel> filterByVerb(BaseVerbGroup verb) {
    return _catalog.where((item) => item.baseVerb == verb).toList();
  }

  List<VerbRectionVariantModel> filterByDomain(CommunicativeDomain domain) {
    return _catalog.where((item) => item.domain == domain).toList();
  }
}
