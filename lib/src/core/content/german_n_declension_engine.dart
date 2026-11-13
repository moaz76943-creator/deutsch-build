import 'dart:collection';

/// Grammatical cases for German nominal declension.
enum GermanCase {
  nominative('Nominativ', 'الرفع'),
  accusative('Akkusativ', 'النصب'),
  dative('Dativ', 'الجر'),
  genitive('Genitiv', 'الإضافة');

  final String de;
  final String ar;
  const GermanCase(this.de, this.ar);
}

/// Structural sub-classes of German N-Declension (Schwache Maskulina & Ausnahmen).
enum NDeclensionClass {
  pureWeakOnE(
    'Schwache Maskulina auf -e',
    'الأسماء المذكرة الضعيفة المنتهية بـ e',
    'Endung -e im Nominativ, erhält -(e)n in allen anderen Kasus: der Kollege, der Kunde, der Experte, der Zeuge',
  ),
  foreignSuffixWeak(
    'Fremdwörter mit betonten Suffixen',
    'الأسماء الدخيلة ذات اللواحق المنبورة (-ant, -ent, -ist, -at, -oge)',
    'Tragen Hauptakzent auf der Endsilbe: der Praktikant, der Assistent, der Biologe, der Architekt',
  ),
  mixedClassWithNs(
    'Mischklasse (Genitiv auf -ns)',
    'الفئة المختلطة (المعربة بـ -n مع إضافة s في حالة الإضافة)',
    'Endung -(e)n in Akk/Dat und zwingend -(e)ns im Genitiv: der Name, der Gedanke, der Buchstabe, der Wille, der Glaube',
  ),
  irregularNeuterHeart(
    'Sonderfall Neutrum (das Herz)',
    'الاسم المحايد الشاذ الوحيد في هذه الفئة (das Herz)',
    'Nominativ/Akkusativ: das Herz; Dativ: dem Herzen; Genitiv: des Herzens; Plural: die Herzen',
  ),
  monosyllabicHistoricExceptions(
    'Einsilbige & historische schwache Maskulina',
    'الأسماء المفردة التاريخية غير المنتهية بـ e',
    'der Herr (des/dem/den Herrn), der Mensch, der Bär, der Held, der Narr, der Nachbar',
  );

  final String germanTitle;
  final String arabicTitle;
  final String morphologicalRule;
  const NDeclensionClass(
    this.germanTitle,
    this.arabicTitle,
    this.morphologicalRule,
  );
}

/// Professional and technical domains free of legal/medical liability.
enum CommunicativeDomain {
  industrialManufacturing('Industrielle Fertigung & Mechatronik', 'التصنيع الصناعي والميكاترونكس'),
  aerospaceAndAviation('Luftfahrt & Flugbetriebstechnik', 'الطيران وتقنيات الملاحة الجوية'),
  renewableEnergy('Erneuerbare Energien & Netzleitsysteme', 'الطاقة المتجددة وشبكات التوزيع'),
  logisticsAndSupply('Internationale Logistik & Frachtwesen', 'اللوجستيات الدولية والشحن'),
  softwareAndRobotics('Softwarearchitektur & Robotik', 'هندسة البرمجيات والروبوتات'),
  professionalTrade('Handel & Betriebliche Fachkommunikation', 'التجارة والتواصل المهني والتشغيلي');

  final String de;
  final String ar;
  const CommunicativeDomain(this.de, this.ar);
}

/// Structural model of an N-Declension noun entry.
class NDeclensionNounModel {
  final String id;
  final String baseLemma;
  final NDeclensionClass declensionClass;
  final CommunicativeDomain domain;
  final String nominativeForm;
  final String accusativeForm;
  final String dativeForm;
  final String genitiveForm;
  final String pluralForm;
  final bool requiresNsInGenitive;
  final String sampleSentence;
  final String arabicTranslation;
  final String grammaticalAnalysisArabic;
  final String grammaticalAnalysisGerman;
  final String commonLearnerMistake;
  final String diagnosticCorrectionRule;

  const NDeclensionNounModel({
    required this.id,
    required this.baseLemma,
    required this.declensionClass,
    required this.domain,
    required this.nominativeForm,
    required this.accusativeForm,
    required this.dativeForm,
    required this.genitiveForm,
    required this.pluralForm,
    required this.requiresNsInGenitive,
    required this.sampleSentence,
    required this.arabicTranslation,
    required this.grammaticalAnalysisArabic,
    required this.grammaticalAnalysisGerman,
    required this.commonLearnerMistake,
    required this.diagnosticCorrectionRule,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'baseLemma': baseLemma,
    'declensionClass': declensionClass.name,
    'domain': domain.name,
    'nominativeForm': nominativeForm,
    'accusativeForm': accusativeForm,
    'dativeForm': dativeForm,
    'genitiveForm': genitiveForm,
    'pluralForm': pluralForm,
    'requiresNsInGenitive': requiresNsInGenitive,
    'sampleSentence': sampleSentence,
    'arabicTranslation': arabicTranslation,
    'grammaticalAnalysisArabic': grammaticalAnalysisArabic,
    'grammaticalAnalysisGerman': grammaticalAnalysisGerman,
    'commonLearnerMistake': commonLearnerMistake,
    'diagnosticCorrectionRule': diagnosticCorrectionRule,
  };
}

/// Verification report container for N-Declension validation.
class NDeclensionValidationReport {
  final bool isValid;
  final bool isNAppliedCorrectly;
  final bool isMixedGenitiveHandled;
  final List<String> issues;
  final List<String> correctionSteps;
  final String arabicDiagnosticVerdict;

  const NDeclensionValidationReport({
    required this.isValid,
    required this.isNAppliedCorrectly,
    required this.isMixedGenitiveHandled,
    required this.issues,
    required this.correctionSteps,
    required this.arabicDiagnosticVerdict,
  });
}

/// Sovereign engine governing German Weak Masculine Nouns & N-Declension Morphology.
class GermanNDeclensionEngine {
  final List<NDeclensionNounModel> _catalog = [];

  GermanNDeclensionEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<NDeclensionNounModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    // 1. Pure Weak on -e: der Kollege (Professional Workplace)
    _catalog.add(
      const NDeclensionNounModel(
        id: 'NDEC-KOLLEGE-01',
        baseLemma: 'der Kollege',
        declensionClass: NDeclensionClass.pureWeakOnE,
        domain: CommunicativeDomain.professionalTrade,
        nominativeForm: 'der Kollege',
        accusativeForm: 'den Kollegen',
        dativeForm: 'dem Kollegen',
        genitiveForm: 'des Kollegen',
        pluralForm: 'die Kollegen',
        requiresNsInGenitive: false,
        sampleSentence:
            'Der Projektleiter bat den erfahrenen Kollegen um eine statische Nachberechnung der Trägerkonstruktion.',
        arabicTranslation:
            'طلب مدير المشروع من الزميل الخبير إجراء إعادة حساب إنشائي لهيكل العوارض الحاملة.',
        grammaticalAnalysisArabic:
            'اسم مذكر ضعيف (Schwaches Maskulinum): يأخذ اللاحقة -n في حالة النصب (den Kollegen) مع أداة النصب den وصفة ضعيفة بالنصب.',
        grammaticalAnalysisGerman:
            'Akkusativ Singular mit obligatorischer Endung -n ("den Kollegen"). Unflektierte Form (*den Kollege) ist standardsprachlich falsch.',
        commonLearnerMistake:
            'Verwendung der Grundform im Akkusativ: "*Ich frage den Kollege".',
        diagnosticCorrectionRule:
            'Alle Maskulina auf -e (Personenbezeichnungen) müssen im Akk/Dat/Gen zwingend die Endung -n tragen.',
      ),
    );

    // 2. Pure Weak on -e: der Experte (Renewable Energy)
    _catalog.add(
      const NDeclensionNounModel(
        id: 'NDEC-EXPERTE-02',
        baseLemma: 'der Experte',
        declensionClass: NDeclensionClass.pureWeakOnE,
        domain: CommunicativeDomain.renewableEnergy,
        nominativeForm: 'der Experte',
        accusativeForm: 'den Experten',
        dativeForm: 'dem Experten',
        genitiveForm: 'des Experten',
        pluralForm: 'die Experten',
        requiresNsInGenitive: false,
        sampleSentence:
            'Wir übergeben die Abnahme der Hochspannungsanlage dem zertifizierten Experten für Netzstabilität.',
        arabicTranslation:
            'نُسند مهمة اعتماد محطة الجهد الفائق إلى الخبير المعتمد في استقرار الشبكات الكهربائية.',
        grammaticalAnalysisArabic:
            'مجرور بحالة الجر (Dativ): "dem Experten" بإضافة اللاحقة -n وجوباً إلى الاسم بعد أداة التعريف dem.',
        grammaticalAnalysisGerman:
            'Dativ Singular: "dem Experten". Das Nomen dekliniert schwach und nimmt in allen obliquen Kasus -n an.',
        commonLearnerMistake:
            'Weglassen der Endung im Dativ: "*mit dem Experte".',
        diagnosticCorrectionRule:
            'Schwache Maskulina erhalten im Dativ Singular immer die Endung -n.',
      ),
    );

    // 3. Foreign Suffix -ent: der Assistent (Software & Robotics)
    _catalog.add(
      const NDeclensionNounModel(
        id: 'NDEC-ASSISTENT-03',
        baseLemma: 'der Assistent',
        declensionClass: NDeclensionClass.foreignSuffixWeak,
        domain: CommunicativeDomain.softwareAndRobotics,
        nominativeForm: 'der Assistent',
        accusativeForm: 'den Assistenten',
        dativeForm: 'dem Assistenten',
        genitiveForm: 'des Assistenten',
        pluralForm: 'die Assistenten',
        requiresNsInGenitive: false,
        sampleSentence:
            'Die Chefentwicklerin beauftragte den wissenschaftlichen Assistenten mit der Optimierung des Steuerungsalgorithmus.',
        arabicTranslation:
            'كلف رئيس المطورين المساعد العلمي بمهمة تحسين خوارزمية التحكم والتوجيه.',
        grammaticalAnalysisArabic:
            'اسم أجنبي الأصل منتهٍ باللاحقة المنبورة -ent: يعامل معاملة الأسماء الضعيفة ويأخذ -en في النصب (den Assistenten).',
        grammaticalAnalysisGerman:
            'Fremdwort auf -ent gehört zur N-Deklination mit Endung -en im Akkusativ Singular.',
        commonLearnerMistake:
            'Keine Endung: "*Sie beauftragte den Assistent".',
        diagnosticCorrectionRule:
            'Nomina auf -ent, -ant, -ist, -at sind ausnahmslos schwach flektiert.',
      ),
    );

    // 4. Foreign Suffix -ant: der Praktikant (Industrial Manufacturing)
    _catalog.add(
      const NDeclensionNounModel(
        id: 'NDEC-PRAKTIKANT-04',
        baseLemma: 'der Praktikant',
        declensionClass: NDeclensionClass.foreignSuffixWeak,
        domain: CommunicativeDomain.industrialManufacturing,
        nominativeForm: 'der Praktikant',
        accusativeForm: 'den Praktikanten',
        dativeForm: 'dem Praktikanten',
        genitiveForm: 'des Praktikanten',
        pluralForm: 'die Praktikanten',
        requiresNsInGenitive: false,
        sampleSentence:
            'Der Werkstattleiter erklärte dem neuen Praktikanten die Sicherheitsvorkehrungen an der CNC-Fräsmaschine.',
        arabicTranslation:
            'شرح مدير الورشة للمتدرب الجديد تدابير السلامة الوقائية عند تشغيل ماكينة التفريز المبرمجة CNC.',
        grammaticalAnalysisArabic:
            'مجرور بالداتيف باللاحقة -en (dem Praktikanten) لوجود اللاحقة المنبورة -ant الدالة على الفاعل.',
        grammaticalAnalysisGerman:
            'Schwache Dativ-Endung -en bei Personenbezeichnung auf -ant.',
        commonLearnerMistake:
            'Fälschliche Genitivierung mit -s: "*des Praktikants".',
        diagnosticCorrectionRule:
            'Schwache Nomen auf -ant erhalten im Genitiv -en ("des Praktikanten"), niemals "-s".',
      ),
    );

    // 5. Mixed Class: der Name (Professional Trade)
    _catalog.add(
      const NDeclensionNounModel(
        id: 'NDEC-NAME-05',
        baseLemma: 'der Name',
        declensionClass: NDeclensionClass.mixedClassWithNs,
        domain: CommunicativeDomain.professionalTrade,
        nominativeForm: 'der Name',
        accusativeForm: 'den Namen',
        dativeForm: 'dem Namen',
        genitiveForm: 'des Namens',
        pluralForm: 'die Namen',
        requiresNsInGenitive: true,
        sampleSentence:
            'Aufgrund des weltweit geschützten Namens genießt das Handelshaus höchste Glaubwürdigkeit bei internationalen Partnern.',
        arabicTranslation:
            'نظراً لاسمها التجاري المحمي عالمياً، تتمتع المؤسسة التجارية بأعلى درجات المصداقية لدى الشركاء الدوليين.',
        grammaticalAnalysisArabic:
            'الفئة المختلطة (Mischklasse): تأخذ -n في النصب والجر (Namen)، ولكنها تجمع بين -n و -s في حالة الإضافة (des Namens).',
        grammaticalAnalysisGerman:
            'Mischklasse: Endung -n in Akk/Dat, aber doppelter Genitivmarker -ns ("des Namens").',
        commonLearnerMistake:
            'Fehlendes -s im Genitiv (*des Namen) oder fehlendes -n (*des Names).',
        diagnosticCorrectionRule:
            'Substantive der Mischklasse (Name, Gedanke, Buchstabe, Wille, Glaube) verlangen im Genitiv strikt -ns.',
      ),
    );

    // 6. Mixed Class: der Gedanke (Software Architecture)
    _catalog.add(
      const NDeclensionNounModel(
        id: 'NDEC-GEDANKE-06',
        baseLemma: 'der Gedanke',
        declensionClass: NDeclensionClass.mixedClassWithNs,
        domain: CommunicativeDomain.softwareAndRobotics,
        nominativeForm: 'der Gedanke',
        accusativeForm: 'den Gedanken',
        dativeForm: 'dem Gedanken',
        genitiveForm: 'des Gedankens',
        pluralForm: 'die Gedanken',
        requiresNsInGenitive: true,
        sampleSentence:
            'Der leitende Softwarearchitekt folgte dem grundlegenden Gedanken der modularen und ausfallsicheren Koppelung.',
        arabicTranslation:
            'اتبع كبير مهندسي البرمجيات الفكرة الجوهرية القائمة على الربط المعياري المقاوم للأعطال.',
        grammaticalAnalysisArabic:
            'مجرور بالداتيف بعد الفعل المتبع (folgen + Dativ): "dem Gedanken" بإضافة -n إلى الاسم.',
        grammaticalAnalysisGerman:
            'Dativ Singular von "Gedanke" verlangt schwaches -n: "dem Gedanken".',
        commonLearnerMistake:
            'Endungsloser Dativ: "*folgte dem Gedanke".',
        diagnosticCorrectionRule:
            'Objekt zum Dativverb "folgen" muss die N-Deklination vollständig ausprägen.',
      ),
    );

    // 7. Mixed Class: der Wille (Aerospace & Aviation)
    _catalog.add(
      const NDeclensionNounModel(
        id: 'NDEC-WILLE-07',
        baseLemma: 'der Wille',
        declensionClass: NDeclensionClass.mixedClassWithNs,
        domain: CommunicativeDomain.aerospaceAndAviation,
        nominativeForm: 'der Wille',
        accusativeForm: 'den Willen',
        dativeForm: 'dem Willen',
        genitiveForm: 'des Willens',
        pluralForm: 'die Willen',
        requiresNsInGenitive: true,
        sampleSentence:
            'Die Verwirklichung des festen Willens zur emissionsfreien Luftfahrt erfordert immense ingenieurtechnische Anstrengungen.',
        arabicTranslation:
            'إن تحقيق الإرادة الراسخة للوصول إلى طيران خالٍ من الانبعاثات يتطلب جهوداً هندسية جبارة.',
        grammaticalAnalysisArabic:
            'إضافة معربة بـ -ns (des festen Willens) تجمع بين علامة الضعف -n وعلامة الإضافة القياسية -s.',
        grammaticalAnalysisGerman:
            'Genitiv Singular mit charakteristischer -ns Endung der Mischklasse.',
        commonLearnerMistake:
            'Falscher Genitiv "*des Willes" oder "*des Willen".',
        diagnosticCorrectionRule:
            'Zwingende -ns Kombination bei "Wille": des Willens.',
      ),
    );

    // 8. Irregular Neuter: das Herz (Mechatronics Precision Component)
    _catalog.add(
      const NDeclensionNounModel(
        id: 'NDEC-HERZ-08',
        baseLemma: 'das Herz',
        declensionClass: NDeclensionClass.irregularNeuterHeart,
        domain: CommunicativeDomain.industrialManufacturing,
        nominativeForm: 'das Herz',
        accusativeForm: 'das Herz',
        dativeForm: 'dem Herzen',
        genitiveForm: 'des Herzens',
        pluralForm: 'die Herzen',
        requiresNsInGenitive: true,
        sampleSentence:
            'Die mikroelektronische Steuereinheit bildet das Herz der gesamten automatisierten Fertigungsanlage.',
        arabicTranslation:
            'تُشكل وحدة التحكم الإلكترونية الدقيقة قلب منظومة الإنتاج المؤتمتة بأكملها.',
        grammaticalAnalysisArabic:
            'الاسم المحايد الوحيد الشاذ (das Herz): يبقى بلا لاحقة في الرفع والنصب (das Herz)، ويأخذ -en في الجر (dem Herzen)، و -ens في الإضافة (des Herzens).',
        grammaticalAnalysisGerman:
            'Einziges neutrales Substantiv mit N-Deklinationselementen: Nom/Akk endungslos, Dativ mit -en ("dem Herzen"), Genitiv mit -ens ("des Herzens").',
        commonLearnerMistake:
            'Endung im Akkusativ (*das Herzen) oder falscher Genitiv (*des Herzes).',
        diagnosticCorrectionRule:
            'Im Akkusativ bleibt "das Herz" endungslos; im Dativ "dem Herzen", im Genitiv "des Herzens".',
      ),
    );

    // 9. Monosyllabic Historic: der Herr (Formal Addressing)
    _catalog.add(
      const NDeclensionNounModel(
        id: 'NDEC-HERR-09',
        baseLemma: 'der Herr',
        declensionClass: NDeclensionClass.monosyllabicHistoricExceptions,
        domain: CommunicativeDomain.professionalTrade,
        nominativeForm: 'der Herr',
        accusativeForm: 'den Herrn',
        dativeForm: 'dem Herrn',
        genitiveForm: 'des Herrn',
        pluralForm: 'die Herren',
        requiresNsInGenitive: false,
        sampleSentence:
            'Der technische Berater übermittelte Herrn Dr. Schmidt die überarbeiteten Entwurfsunterlagen.',
        arabicTranslation:
            'أرسل المستشار الفني إلى السيد الدكتور شميدت وثائق التصميم المنقحة والمعدلة.',
        grammaticalAnalysisArabic:
            'اسم مذكر أحادي المقطع تاريخي: يأخذ -n في المفرد المنصوب والمجرور (Herrn)، بينما يأخذ -en في الجمع (Herren).',
        grammaticalAnalysisGerman:
            'Singular oblique Formen enden auf -n ("den/dem/des Herrn"), der Plural lautet "die Herren".',
        commonLearnerMistake:
            'Unflektierte Anrede im Dativ/Akkusativ: "*für Herr Schmidt" statt "für Herrn Schmidt".',
        diagnosticCorrectionRule:
            'In allen Kasus außer dem Nominativ heißt es im Singular ausnahmslos "Herrn".',
      ),
    );

    // 10. Monosyllabic Historic: der Mensch (Societal Technology Impact)
    _catalog.add(
      const NDeclensionNounModel(
        id: 'NDEC-MENSCH-10',
        baseLemma: 'der Mensch',
        declensionClass: NDeclensionClass.monosyllabicHistoricExceptions,
        domain: CommunicativeDomain.softwareAndRobotics,
        nominativeForm: 'der Mensch',
        accusativeForm: 'den Menschen',
        dativeForm: 'dem Menschen',
        genitiveForm: 'des Menschen',
        pluralForm: 'die Menschen',
        requiresNsInGenitive: false,
        sampleSentence:
            'Moderne Assistenzroboter sind darauf ausgelegt, dem Menschen schwere körperliche Hebearbeiten abzunehmen.',
        arabicTranslation:
            'صُممت الروبوتات المساعدة الحديثة لتخفف عن الإنسان أعباء الرفع البدني الشاقة وتتحملها عنه.',
        grammaticalAnalysisArabic:
            'مجرور بالداتيف باللاحقة -en (dem Menschen) بعد الفعل المتعدي لشخص (abnehmen + Dativ).',
        grammaticalAnalysisGerman:
            'Einsilbiges historisch schwaches Maskulinum: Erhält in allen obliquen Kasus -en ("des/dem/den Menschen").',
        commonLearnerMistake:
            'Starker Genitiv mit -s: "*des Mensches".',
        diagnosticCorrectionRule:
            '"Mensch" dekliniert strikt schwach: Genitiv lautet immer "des Menschen".',
      ),
    );

    // 11. Foreign Suffix -ist: der Spezialist (Aviation Maintenance)
    _catalog.add(
      const NDeclensionNounModel(
        id: 'NDEC-SPEZIALIST-11',
        baseLemma: 'der Spezialist',
        declensionClass: NDeclensionClass.foreignSuffixWeak,
        domain: CommunicativeDomain.aerospaceAndAviation,
        nominativeForm: 'der Spezialist',
        accusativeForm: 'den Spezialisten',
        dativeForm: 'dem Spezialisten',
        genitiveForm: 'des Spezialisten',
        pluralForm: 'die Spezialisten',
        requiresNsInGenitive: false,
        sampleSentence:
            'Die Airline zog einen anerkannten Spezialisten für Turbinenakustik zur Schwingungsanalyse heran.',
        arabicTranslation:
            'استعانت شركة الطيران بأخصائي معتمد في صوتيات التوربينات لتحليل الاهتزازات.',
        grammaticalAnalysisArabic:
            'اسم فاعل دخيل باللاحقة المنبورة -ist، منصوب بالأكوزاتيف النكرة باللاحقة -en (einen Spezialisten).',
        grammaticalAnalysisGerman:
            'Akkusativ Singular bei Substantiven auf -ist erfordert regulär die Endung -en.',
        commonLearnerMistake:
            'Endungsloser Akkusativ: "*einen Spezialist".',
        diagnosticCorrectionRule:
            'Alle Berufs- und Personenbezeichnungen auf -ist folgen lückenlos der N-Deklination.',
      ),
    );

    // 12. Pure Weak on -e: der Kunde (Logistics & Delivery)
    _catalog.add(
      const NDeclensionNounModel(
        id: 'NDEC-KUNDE-12',
        baseLemma: 'der Kunde',
        declensionClass: NDeclensionClass.pureWeakOnE,
        domain: CommunicativeDomain.logisticsAndSupply,
        nominativeForm: 'der Kunde',
        accusativeForm: 'den Kunden',
        dativeForm: 'dem Kunden',
        genitiveForm: 'des Kunden',
        pluralForm: 'die Kunden',
        requiresNsInGenitive: false,
        sampleSentence:
            'Das Frachtunternehmen garantiert dem gewerblichen Kunden eine termingenaue Zustellung binnen vierundzwanzig Stunden.',
        arabicTranslation:
            'تضمن شركة الشحن للعميل التجاري تسليماً دقيقاً في الموعد المحدد في غضون أربع وعشرين ساعة.',
        grammaticalAnalysisArabic:
            'مجرور بالداتيف بعد فعل الضمان (garantieren + Dativ): "dem Kunden" بإضافة -n وجوباً.',
        grammaticalAnalysisGerman:
            'Dativ Singular von "der Kunde": obligatorisches schwaches -n ("dem Kunden").',
        commonLearnerMistake:
            'Auslassung des -n: "*dem Kunde".',
        diagnosticCorrectionRule:
            '"Kunde" verlangt in Akk/Dat/Gen Singular ausnahmslos die Endung -n.',
      ),
    );

    // 13. Foreign Suffix -oge: der Geologe (Renewable Geothermal Energy)
    _catalog.add(
      const NDeclensionNounModel(
        id: 'NDEC-GEOLOGE-13',
        baseLemma: 'der Geologe',
        declensionClass: NDeclensionClass.foreignSuffixWeak,
        domain: CommunicativeDomain.renewableEnergy,
        nominativeForm: 'der Geologe',
        accusativeForm: 'den Geologen',
        dativeForm: 'dem Geologen',
        genitiveForm: 'des Geologen',
        pluralForm: 'die Geologen',
        requiresNsInGenitive: false,
        sampleSentence:
            'Die Tiefenbohrung für das Geothermiekraftwerk wurde von einem erfahrenen Geologen überwacht.',
        arabicTranslation:
            'تمت مراقبة أعمال الحفر العميق لمحطة الطاقة الحرارية الأرضية من قِبل جيولوجي متمرس.',
        grammaticalAnalysisArabic:
            'مجرور بالداتيف بعد حرف الجر von باللاحقة -en (einem Geologen) لمطابقة اللاحقة العلمية -oge.',
        grammaticalAnalysisGerman:
            'Dativ nach Präposition "von": Nomen auf -oge dekliniert obligatorisch schwach.',
        commonLearnerMistake:
            'Vergessen der Endung im Dativ: "*von einem Geologe".',
        diagnosticCorrectionRule:
            'Substantive auf -oge (Biologe, Soziologe, Geologe) folgen ausnahmslos der N-Deklination.',
      ),
    );

    // 14. Monosyllabic Historic: der Nachbar (Cross-border Infrastructure)
    _catalog.add(
      const NDeclensionNounModel(
        id: 'NDEC-NACHBAR-14',
        baseLemma: 'der Nachbar',
        declensionClass: NDeclensionClass.monosyllabicHistoricExceptions,
        domain: CommunicativeDomain.renewableEnergy,
        nominativeForm: 'der Nachbar',
        accusativeForm: 'den Nachbarn',
        dativeForm: 'dem Nachbarn',
        genitiveForm: 'des Nachbarn',
        pluralForm: 'die Nachbarn',
        requiresNsInGenitive: false,
        sampleSentence:
            'Die Stromtrasse wurde in enger technischer Abstimmung mit dem östlichen Nachbarn ausgebaut.',
        arabicTranslation:
            'تم توسيع مسار خط نقل الكهرباء بتنسيق فني وثيق مع الجار الشرقي.',
        grammaticalAnalysisArabic:
            'مجرور بالداتيف بعد حرف الجر mit بإضافة -n (dem Nachbarn).',
        grammaticalAnalysisGerman:
            'Historisches Schwach-Maskulinum auf -ar: nimmt in allen obliquen Kasus -n an.',
        commonLearnerMistake:
            'Auslassung der Endung: "*mit dem Nachbar".',
        diagnosticCorrectionRule:
            '"Der Nachbar" wird im Singular obliqu mit -n dekliniert ("des/dem/den Nachbarn").',
      ),
    );
  }

  /// Automatically inflects an N-declension noun for any requested case.
  String inflectNoun(String baseLemma, GermanCase targetCase, {bool isPlural = false}) {
    final entry = _catalog.firstWhere(
      (m) => m.baseLemma.toLowerCase() == baseLemma.toLowerCase(),
      orElse: () => throw ArgumentError('Substantiv $baseLemma nicht im N-Deklinationskatalog vorhanden.'),
    );

    if (isPlural) {
      return entry.pluralForm;
    }

    switch (targetCase) {
      case GermanCase.nominative:
        return entry.nominativeForm;
      case GermanCase.accusative:
        return entry.accusativeForm;
      case GermanCase.dative:
        return entry.dativeForm;
      case GermanCase.genitive:
        return entry.genitiveForm;
    }
  }

  /// Validates whether a noun in a sentence correctly respects N-declension inflection rules.
  NDeclensionValidationReport validateSentenceNoun({
    required String baseLemma,
    required String writtenNounForm,
    required GermanCase targetCase,
    required bool isPlural,
  }) {
    final issues = <String>[];
    final steps = <String>[];

    final expectedForm = inflectNoun(baseLemma, targetCase, isPlural: isPlural);
    final isCorrect = writtenNounForm.trim().toLowerCase() == expectedForm.split(' ').last.toLowerCase();

    if (!isCorrect) {
      issues.add(
        'Morphologische Diskrepanz: "$writtenNounForm" ist in der Funktion als $targetCase nicht korrekt flektiert. Erwartet wird: "$expectedForm".',
      );
      steps.add('Bestimmen Sie den Kasus des Nomens (hier: $targetCase).');
      steps.add('Prüfen Sie die Zugehörigkeit zur N-Deklination (Schwaches Maskulinum / Mischklasse).');
      steps.add('Hängen Sie die korrekte Endung -(e)n bzw. -(e)ns an den Stamm an.');
    }

    final isValid = issues.isEmpty;
    final arabicVerdict = isValid
        ? 'الإعراب الصرفي للاسم التابع لفئة N-Deklination صحيح تماماً ومتطابق مع المعايير الفصيحة.'
        : 'تم رصد خطأ صرفي في تصريف الاسم الضعيف (إغفال اللاحقة n أو ns في حالة $targetCase).';

    return NDeclensionValidationReport(
      isValid: isValid,
      isNAppliedCorrectly: isCorrect,
      isMixedGenitiveHandled: isCorrect,
      issues: issues,
      correctionSteps: steps,
      arabicDiagnosticVerdict: arabicVerdict,
    );
  }

  List<NDeclensionNounModel> filterByClass(NDeclensionClass declensionClass) {
    return _catalog.where((item) => item.declensionClass == declensionClass).toList();
  }

  List<NDeclensionNounModel> filterByDomain(CommunicativeDomain domain) {
    return _catalog.where((item) => item.domain == domain).toList();
  }
}
