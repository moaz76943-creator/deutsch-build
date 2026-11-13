import 'dart:collection';

/// Grammatical cases.
enum GrammaticalCase {
  nominative('Nominativ', 'الرفع'),
  accusative('Akkusativ', 'النصب'),
  dative('Dativ', 'الجر'),
  genitive('Genitiv', 'الإضافة');

  final String de;
  final String ar;
  const GrammaticalCase(this.de, this.ar);
}

/// Grammatical gender and number categories.
enum GrammaticalGender {
  masculine('Maskulinum', 'مذكر'),
  feminine('Femininum', 'مؤنث'),
  neuter('Neutrum', 'محايد'),
  plural('Plural', 'جمع');

  final String de;
  final String ar;
  const GrammaticalGender(this.de, this.ar);
}

/// Classification of determiners governing adjective inflection patterns.
enum DeterminerClass {
  definiteLikeWeak(
    'Artikelwörter mit schwacher Folgeflexion',
    'محددات تلزم الصفة بعدها بالإعراب الضعيف (alle, sämtliche, beide, diese, welche)',
    'Verhalten sich wie der bestimmte Artikel: sämtliche neuen Module, alle wichtigen Daten',
  ),
  adjectiveLikeParallelStrong(
    'Zahladjektive mit paralleler Starkflexion',
    'أسماء عدد وصفات إبهام تعرب بالتوازي بالإعراب القوي (viele, wenige, einige, mehrere, etliche)',
    'Deklinieren parallel zum Adjektiv stark: viele neue Entdeckungen, mit einigen neuen Methoden',
  ),
  fluctuatingDoubleForm(
    'Schwankende Pronomina (folgende, vorstehende, obige)',
    'الضمائر المترددة بين الإعراب القوي والضعيف حسب المعيار الأسلوبي',
    'Duden lässt beides zu: folgende wichtige Hinweise (stark) vs. folgende wichtigen Hinweise (schwach)',
  ),
  uninflectedDeterminers(
    'Undeklinierbare Partikeln mit starkem Adjektiv',
    'أدوات وجزيئات غير معربة تتبعها صفة معربة إعراباً قوياً (allerlei, mancherlei, etwas, genug, lauter)',
    'Bleiben endungslos, Adjektiv trägt die volle Kasusendung: allerlei nützliche Werkzeuge, mit etwas frischem Wasser',
  ),
  splitPronounConstructions(
    'Getrennte Pronominalgefüge (solch ein, welch ein, was für ein)',
    'التراكيب الضميرية المجزأة',
    'solch ein neuer Ansatz (Adjektiv stark/gemischt) vs. ein solcher neuer Ansatz',
  );

  final String germanTitle;
  final String arabicTitle;
  final String morphologicalRule;
  const DeterminerClass(
    this.germanTitle,
    this.arabicTitle,
    this.morphologicalRule,
  );
}

/// Communicative domains strictly free of legal and medical liability.
enum CommunicativeDomain {
  aerospaceEngineering('Luft- & Raumfahrttechnik', 'هندسة الطيران واستكشاف الفضاء'),
  renewablePowerGrid('Erneuerbare Energien & Netztechnik', 'الطاقة المتجددة وشبكات التوزيع'),
  industrialRobotics('Industrierobotik & Automatisierung', 'الروبوتات الصناعية والأتمتة'),
  maritimeNavigation('Maritime Schifffahrt & Hafentechnik', 'الملاحة البحرية وتقنيات الموانئ'),
  civilInfrastructure('Bauingenieurwesen & Statik', 'الهندسة المدنية والبنية التحتية'),
  materialScience('Werkstoffwissenschaft & Nanotechnologie', 'علم المواد وتكنولوجيا النانو');

  final String de;
  final String ar;
  const CommunicativeDomain(this.de, this.ar);
}

/// Data model representing a fluctuating or determiner-governed adjective phrase.
class FluctuatingAdjectiveModel {
  final String id;
  final String determinerWord;
  final DeterminerClass determinerClass;
  final GrammaticalCase appliedCase;
  final GrammaticalGender gender;
  final String adjectiveBase;
  final String expectedAdjectiveEnding;
  final String fullDeterminerAdjectivePhrase;
  final String nounComplement;
  final CommunicativeDomain domain;
  final String fullSentence;
  final String arabicTranslation;
  final String grammaticalAnalysisArabic;
  final String grammaticalAnalysisGerman;
  final String commonErrorAnalysis;
  final String dudenGuidelineRule;

  const FluctuatingAdjectiveModel({
    required this.id,
    required this.determinerWord,
    required this.determinerClass,
    required this.appliedCase,
    required this.gender,
    required this.adjectiveBase,
    required this.expectedAdjectiveEnding,
    required this.fullDeterminerAdjectivePhrase,
    required this.nounComplement,
    required this.domain,
    required this.fullSentence,
    required this.arabicTranslation,
    required this.grammaticalAnalysisArabic,
    required this.grammaticalAnalysisGerman,
    required this.commonErrorAnalysis,
    required this.dudenGuidelineRule,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'determinerWord': determinerWord,
    'determinerClass': determinerClass.name,
    'appliedCase': appliedCase.name,
    'gender': gender.name,
    'adjectiveBase': adjectiveBase,
    'expectedAdjectiveEnding': expectedAdjectiveEnding,
    'fullDeterminerAdjectivePhrase': fullDeterminerAdjectivePhrase,
    'nounComplement': nounComplement,
    'domain': domain.name,
    'fullSentence': fullSentence,
    'arabicTranslation': arabicTranslation,
    'grammaticalAnalysisArabic': grammaticalAnalysisArabic,
    'grammaticalAnalysisGerman': grammaticalAnalysisGerman,
    'commonErrorAnalysis': commonErrorAnalysis,
    'dudenGuidelineRule': dudenGuidelineRule,
  };
}

/// Validation report container for fluctuating adjective declensions.
class AdjectiveDeclensionValidationReport {
  final bool isValid;
  final bool matchesStandardNorm;
  final bool isStrongWeakChoiceCorrect;
  final List<String> issues;
  final List<String> recommendations;
  final String arabicDiagnosticVerdict;

  const AdjectiveDeclensionValidationReport({
    required this.isValid,
    required this.matchesStandardNorm,
    required this.isStrongWeakChoiceCorrect,
    required this.issues,
    required this.recommendations,
    required this.arabicDiagnosticVerdict,
  });
}

/// Sovereign engine governing German Fluctuating Adjective Declension & Determiner-Governed Flexion.
class GermanFluctuatingAdjectiveDeclensionEngine {
  final List<FluctuatingAdjectiveModel> _catalog = [];

  GermanFluctuatingAdjectiveDeclensionEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<FluctuatingAdjectiveModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    // 1. Definite-like: sämtliche (Weak ending -en in plural Nominative)
    _catalog.add(
      const FluctuatingAdjectiveModel(
        id: 'DEC-SAEMTLICH-01',
        determinerWord: 'sämtliche',
        determinerClass: DeterminerClass.definiteLikeWeak,
        appliedCase: GrammaticalCase.nominative,
        gender: GrammaticalGender.plural,
        adjectiveBase: 'neu',
        expectedAdjectiveEnding: '-en',
        fullDeterminerAdjectivePhrase: 'sämtliche neuen',
        nounComplement: 'Messmodule',
        domain: CommunicativeDomain.aerospaceEngineering,
        fullSentence:
            'Sämtliche neuen Messmodule wurden vor dem Testflug im thermischen Vakuumlabor kalibriert.',
        arabicTranslation:
            'تمت معايرة كافة وحدات القياس الجديدة في مختبر التفريغ الحراري قبل إجراء رحلة الاختبار.',
        grammaticalAnalysisArabic:
            'المحدد "sämtliche" يعامل معاملة أداة التعريف في الجمع، فتأخذ الصفة بعده لاحقة الإعراب الضعيف (-en) وجوباً: sämtliche neuen.',
        grammaticalAnalysisGerman:
            'Nach "sämtliche" folgt im Plural stets schwache Adjektivdeklination auf -en (wie nach dem bestimmten Artikel "die").',
        commonErrorAnalysis:
            'Häufiger Fehler: Verwendung der starken Pluralendung -e (*sämtliche neue Module).',
        dudenGuidelineRule:
            'Duden Band 9: Nach "alle", "sämtliche", "beide" wird das Adjektiv im Plural ausnahmslos schwach flektiert (-en).',
      ),
    );

    // 2. Parallel Strong: viele (Parallel strong ending -e in plural Nominative)
    _catalog.add(
      const FluctuatingAdjectiveModel(
        id: 'DEC-VIELE-02',
        determinerWord: 'viele',
        determinerClass: DeterminerClass.adjectiveLikeParallelStrong,
        appliedCase: GrammaticalCase.nominative,
        gender: GrammaticalGender.plural,
        adjectiveBase: 'innovativ',
        expectedAdjectiveEnding: '-e',
        fullDeterminerAdjectivePhrase: 'viele innovative',
        nounComplement: 'Lösungsansätze',
        domain: CommunicativeDomain.renewablePowerGrid,
        fullSentence:
            'Viele innovative Lösungsansätze zur Netzstabilisierung basieren auf intelligenten Batteriespeichern.',
        arabicTranslation:
            'تعتمد العديد من المداخل والحلول الابتكارية لتثبيت شبكات الكهرباء على بطاريات التخزين الذكية.',
        grammaticalAnalysisArabic:
            'اسم العدد المبهم "viele" يعرب كصفة متوازية؛ لذا تأخذ الصفة بعده علامة الإعراب القوي (-e) بالتوازي مع viele.',
        grammaticalAnalysisGerman:
            'Parallelflexion: Nach "viele", "wenige", "einige", "mehrere" folgt im Plural Nom/Akk starke Adjektivendung (-e).',
        commonErrorAnalysis:
            'Fälschliche Schwachdeklination: "*viele innovativen Lösungsansätze".',
        dudenGuidelineRule:
            'Zahladjektive ohne Artikel verlangen starke Parallelflexion des nachfolgenden Adjektivs.',
      ),
    );

    // 3. Parallel Strong: mehrere in Dativ Plural (-en / -en)
    _catalog.add(
      const FluctuatingAdjectiveModel(
        id: 'DEC-MEHRERE-DAT-03',
        determinerWord: 'mehreren',
        determinerClass: DeterminerClass.adjectiveLikeParallelStrong,
        appliedCase: GrammaticalCase.dative,
        gender: GrammaticalGender.plural,
        adjectiveBase: 'hochpräzis',
        expectedAdjectiveEnding: '-en',
        fullDeterminerAdjectivePhrase: 'mehreren hochpräzisen',
        nounComplement: 'Sensoren',
        domain: CommunicativeDomain.industrialRobotics,
        fullSentence:
            'Die autonome Fräseinheit ist mit mehreren hochpräzisen Sensoren zur Vibrationsmessung ausgestattet.',
        arabicTranslation:
            'تم تزويد وحدة التفريز ذاتية القيادة بالعديد من المستشعرات فائقة الدقة لقياس الاهتزازات.',
        grammaticalAnalysisArabic:
            'حالة الجر (Dativ Plural): يأخذ المحدد "mehreren" لاحقة الجر القوية -en، وكذلك الصفة "hochpräzisen" بالتماثل التام.',
        grammaticalAnalysisGerman:
            'Dativ Plural: Sowohl "mehreren" als auch das Adjektiv "hochpräzisen" tragen die starke Dativendung -en.',
        commonErrorAnalysis:
            'Weglassen der Dativ-Kennzeichnung am Nomen oder der Endung am Zahladjektiv.',
        dudenGuidelineRule:
            'Strikte Kasuskongruenz im Dativ Plural mit -en für Determinierer, Adjektiv und Substantiv.',
      ),
    );

    // 4. Fluctuating: folgende (Strong form preferred in modern technical writing)
    _catalog.add(
      const FluctuatingAdjectiveModel(
        id: 'DEC-FOLGEND-04',
        determinerWord: 'folgende',
        determinerClass: DeterminerClass.fluctuatingDoubleForm,
        appliedCase: GrammaticalCase.nominative,
        gender: GrammaticalGender.plural,
        adjectiveBase: 'wesentlich',
        expectedAdjectiveEnding: '-e (oder -en)',
        fullDeterminerAdjectivePhrase: 'folgende wesentliche (bzw. wesentlichen)',
        nounComplement: 'Sicherheitsrichtlinien',
        domain: CommunicativeDomain.civilInfrastructure,
        fullSentence:
            'Für den Bau der Hängebrücke gelten folgende wesentliche Sicherheitsrichtlinien der Prüfstatik.',
        arabicTranslation:
            'تسري على أعمال تشييد الجسر المعلق الإرشادات والتوجيهات الأمنية الجوهرية التالية الخاصة بالسلامة الإنشائية.',
        grammaticalAnalysisArabic:
            'الاسم "folgende" متردد بين الإعرابين: يجوز إعراب الصفة بعده إعراباً قوياً (wesentliche) وهو الأكثر شيوعاً، أو ضعيفاً (wesentlichen).',
        grammaticalAnalysisGerman:
            'Schwankende Deklination: Sowohl die starke Endung (-e) als auch die schwache (-en) sind standardsprachlich legitimiert.',
        commonErrorAnalysis:
            'Ungerechtfertigte Korrektur der starken Form als "Fehler"; beide Varianten sind standardsprachlich zulässig.',
        dudenGuidelineRule:
            'Duden: Nach "folgende", "vorstehende", "obige" überwiegt in neuerer Zeit die starke Flexion (-e).',
      ),
    );

    // 5. Undeclined Determiner: allerlei (Adjektiv takes full strong ending)
    _catalog.add(
      const FluctuatingAdjectiveModel(
        id: 'DEC-ALLERLEI-05',
        determinerWord: 'allerlei',
        determinerClass: DeterminerClass.uninflectedDeterminers,
        appliedCase: GrammaticalCase.accusative,
        gender: GrammaticalGender.plural,
        adjectiveBase: 'nützlich',
        expectedAdjectiveEnding: '-e',
        fullDeterminerAdjectivePhrase: 'allerlei nützliche',
        nounComplement: 'Diagnosewerkzeuge',
        domain: CommunicativeDomain.industrialRobotics,
        fullSentence:
            'Der Servicekoffer enthält allerlei nützliche Diagnosewerkzeuge für die mobile Fehlerbehebung.',
        arabicTranslation:
            'تحتوي حقيبة الصيانة على شتى أنواع أدوات التشخيص المفيدة والنافعة لمعالجة الأعطال الميدانية.',
        grammaticalAnalysisArabic:
            'الأداة "allerlei" كلمة مبنية غير معربة لا تقبل علامات الإعراب؛ لذا تتحمل الصفة بعدها عبء الإعراب القوي كاملاً: nützliche.',
        grammaticalAnalysisGerman:
            'Unflektierbares Indefinitum "allerlei": Da der Begleiter keine Endung trägt, muss das Adjektiv stark flektieren (-e).',
        commonErrorAnalysis:
            'Fälschliches Anhängen einer Endung an "allerlei" (*allerleie) oder Schwachdeklination (*allerlei nützlichen).',
        dudenGuidelineRule:
            'Nach indeklinablen Pronominaladjektiven (allerlei, mancherlei, etwas, genug) steht ausnahmslos starke Adjektivdeklination.',
      ),
    );

    // 6. Undeclined Determiner: etwas (Neuter Dativ with strong ending -em)
    _catalog.add(
      const FluctuatingAdjectiveModel(
        id: 'DEC-ETWAS-06',
        determinerWord: 'etwas',
        determinerClass: DeterminerClass.uninflectedDeterminers,
        appliedCase: GrammaticalCase.dative,
        gender: GrammaticalGender.neuter,
        adjectiveBase: 'technisch',
        expectedAdjectiveEnding: '-em',
        fullDeterminerAdjectivePhrase: 'mit etwas technischem',
        nounComplement: 'Geschick',
        domain: CommunicativeDomain.materialScience,
        fullSentence:
            'Mit etwas technischem Geschick lässt sich die nanostrukturierte Beschichtung gleichmäßig auftragen.',
        arabicTranslation:
            'بقليل من المهارة والبراعة التقنية، يمكن تطبيق وطلاء الطبقة النانوية بصورة متجانسة ومتساوية.',
        grammaticalAnalysisArabic:
            'الأداة "etwas" مجردة من الإعراب، لذا تعرب الصفة بالداتيف المحايد القوي باللاحقة -em: mit etwas technischem Geschick.',
        grammaticalAnalysisGerman:
            'Dativ Neutrum stark: "etwas" ist unflektierbar, folglich signalisiert das Adjektiv den Kasus durch die Endung -em.',
        commonErrorAnalysis:
            'Verwendung der schwachen Endung: "*mit etwas technischen Geschick".',
        dudenGuidelineRule:
            'Nach "etwas" und "viel" (unflektiert) trägt das Adjektiv im Dativ Maskulinum/Neutrum zwingend -em.',
      ),
    );

    // 7. Split Construction: solch ein vs. ein solcher
    _catalog.add(
      const FluctuatingAdjectiveModel(
        id: 'DEC-SOLCH-EIN-07',
        determinerWord: 'solch ein',
        determinerClass: DeterminerClass.splitPronounConstructions,
        appliedCase: GrammaticalCase.nominative,
        gender: GrammaticalGender.masculine,
        adjectiveBase: 'revolutionär',
        expectedAdjectiveEnding: '-er',
        fullDeterminerAdjectivePhrase: 'solch ein revolutionärer',
        nounComplement: 'Festkörperakkumulator',
        domain: CommunicativeDomain.renewablePowerGrid,
        fullSentence:
            'Solch ein revolutionärer Festkörperakkumulator könnte die Reichweite von Elektroflugzeugen vervielfachen.',
        arabicTranslation:
            'إن مركماً وبطارية صلبة ثورية من هذا القبيل كفيلة بمضاعفة مدى طيران الطائرات الكهربائية عدة مرات.',
        grammaticalAnalysisArabic:
            'عند تقدم "solch" بدون إعراب متبوعة بـ "ein"، تعامل الصفة معاملة الإعراب المختلط بعد أداة النكرة، فتأخذ علامة الرفع المذكر القوية -er.',
        grammaticalAnalysisGerman:
            'Undekliniertes "solch" vor unbestimmtem Artikel: "ein" fordert im Nominativ Maskulinum die Endung -er am Adjektiv.',
        commonErrorAnalysis:
            'Fehlende Endung am Adjektiv: "*solch ein revolutionäre Akku".',
        dudenGuidelineRule:
            'Strukturformel: solch ein + [Adjektiv mit Mischflexionsendung] + Substantiv.',
      ),
    );

    // 8. Definite-like: beide (Weak ending -en in Dative Plural)
    _catalog.add(
      const FluctuatingAdjectiveModel(
        id: 'DEC-BEIDE-08',
        determinerWord: 'beiden',
        determinerClass: DeterminerClass.definiteLikeWeak,
        appliedCase: GrammaticalCase.dative,
        gender: GrammaticalGender.plural,
        adjectiveBase: 'neu',
        expectedAdjectiveEnding: '-en',
        fullDeterminerAdjectivePhrase: 'von beiden neuen',
        nounComplement: 'Triebwerkstypen',
        domain: CommunicativeDomain.aerospaceEngineering,
        fullSentence:
            'Die Effizienzdaten von beiden neuen Triebwerkstypen übertrafen die ursprünglichen Modellrechnungen.',
        arabicTranslation:
            'تجاوزت بيانات كفاءة كلا الطرازين الجديدين من المحركات الحسابات النموذجية الأولية المقدرة.',
        grammaticalAnalysisArabic:
            'الكلمة "beide" تعامل معاملة أداة التعريف التامة، فتتبعها الصفة بالإعراب الضعيف (-en): von beiden neuen Triebwerkstypen.',
        grammaticalAnalysisGerman:
            'Pronominaladjektiv "beide" fungiert syntaktisch als Artikelwort; nachfolgende Adjektive erhalten ausnahmslos -en.',
        commonErrorAnalysis:
            'Unzulässige starke Endung am Adjektiv: "*von beiden neue Typen".',
        dudenGuidelineRule:
            'Nach flektierten Formen von "beide" gilt ausnahmslos die schwache Adjektivdeklination.',
      ),
    );

    // 9. Parallel Strong: etliche (Accusative Plural strong -e)
    _catalog.add(
      const FluctuatingAdjectiveModel(
        id: 'DEC-ETLICHE-09',
        determinerWord: 'etliche',
        determinerClass: DeterminerClass.adjectiveLikeParallelStrong,
        appliedCase: GrammaticalCase.accusative,
        gender: GrammaticalGender.plural,
        adjectiveBase: 'schwer',
        expectedAdjectiveEnding: '-e',
        fullDeterminerAdjectivePhrase: 'etliche schwere',
        nounComplement: 'Frachtcontainer',
        domain: CommunicativeDomain.maritimeNavigation,
        fullSentence:
            'Der Hafenportalkran verfrachtete etliche schwere Frachtcontainer direkt auf den Güterzug.',
        arabicTranslation:
            'نقلت رافعة الميناء الجسرية عدداً لا بأس به من حاويات الشحن الثقيلة مباشرة إلى قطار البضائع.',
        grammaticalAnalysisArabic:
            'الأداة "etliche" تتبع نظام التوازي القوي؛ فتأخذ هي والصفة لاحقة النصب الجمع القوية -e.',
        grammaticalAnalysisGerman:
            'Parallelflexion im Akkusativ Plural: "etliche" + starkes Adjektiv auf -e ("schwere").',
        commonErrorAnalysis:
            'Fälschlicherweise schwaches -en: "*etliche schweren Container".',
        dudenGuidelineRule:
            '"Etliche" verhält sich wie "viele" und "einige" und erzwingt starke Parallelflexion.',
      ),
    );

    // 10. Definite-like: welche (Weak declension in Nominative Plural)
    _catalog.add(
      const FluctuatingAdjectiveModel(
        id: 'DEC-WELCHE-10',
        determinerWord: 'welche',
        determinerClass: DeterminerClass.definiteLikeWeak,
        appliedCase: GrammaticalCase.nominative,
        gender: GrammaticalGender.plural,
        adjectiveBase: 'konkret',
        expectedAdjectiveEnding: '-en',
        fullDeterminerAdjectivePhrase: 'welche konkreten',
        nounComplement: 'Maßnahmen',
        domain: CommunicativeDomain.civilInfrastructure,
        fullSentence:
            'Die Gutachter prüften sorgfältig, welche konkreten Maßnahmen zur Hangsicherung erforderlich sind.',
        arabicTranslation:
            'دقق الخبراء بعناية فائقة لتحديد أي التدابير الملموسة والمحددة يلزم اتخاذها لتثبيت المنحدر الجبلي.',
        grammaticalAnalysisArabic:
            'اسم الاستفهام "welche" يعمل كأداة تعريف تامة، فتعرب الصفة بعده إعراباً ضعيفاً باللاحقة -en: welche konkreten Maßnahmen.',
        grammaticalAnalysisGerman:
            'Interrogativartikel "welch-" steuert schwache Adjektivdeklination im Plural.',
        commonErrorAnalysis:
            'Starke Endung: "*welche konkrete Maßnahmen".',
        dudenGuidelineRule:
            'Nach flektiertem "welch-" steht das Adjektiv im Plural stets mit -en.',
      ),
    );

    // 11. Parallel Strong: wenige (Genitive Plural with strong -er)
    _catalog.add(
      const FluctuatingAdjectiveModel(
        id: 'DEC-WENIGE-GEN-11',
        determinerWord: 'weniger',
        determinerClass: DeterminerClass.adjectiveLikeParallelStrong,
        appliedCase: GrammaticalCase.genitive,
        gender: GrammaticalGender.plural,
        adjectiveBase: 'hochqualifiziert',
        expectedAdjectiveEnding: '-er',
        fullDeterminerAdjectivePhrase: 'wegen weniger hochqualifizierter',
        nounComplement: 'Spezialkräfte',
        domain: CommunicativeDomain.aerospaceEngineering,
        fullSentence:
            'Wegen weniger hochqualifizierter Spezialkräfte musste der Schichtplan flexibel angepasst werden.',
        arabicTranslation:
            'نظراً لقلة الكفاءات التخصصية المؤهلة تأهيلاً عالياً، كان لزاماً تعديل جدول المناوبات بمرونة.',
        grammaticalAnalysisArabic:
            'إضافة الجمع (Genitiv Plural): المحدد والصفة يعربان بالتوازي باللاحقة القوية -er: wegen weniger hochqualifizierter Kräfte.',
        grammaticalAnalysisGerman:
            'Genitiv Plural starke Parallelflexion: Sowohl "weniger" als auch das Adjektiv tragen die starke Endung -er.',
        commonErrorAnalysis:
            'Schwache Endung am Adjektiv (*wegen weniger hochqualifizierten).',
        dudenGuidelineRule:
            'Zahladjektiv im Genitiv Plural verlangt identische starke Endung -er am Adjektiv.',
      ),
    );

    // 12. Undeclined Determiner: mancherlei (Plural strong ending -e)
    _catalog.add(
      const FluctuatingAdjectiveModel(
        id: 'DEC-MANCHERLEI-12',
        determinerWord: 'mancherlei',
        determinerClass: DeterminerClass.uninflectedDeterminers,
        appliedCase: GrammaticalCase.nominative,
        gender: GrammaticalGender.plural,
        adjectiveBase: 'unerwartet',
        expectedAdjectiveEnding: '-e',
        fullDeterminerAdjectivePhrase: 'mancherlei unerwartete',
        nounComplement: 'Herausforderungen',
        domain: CommunicativeDomain.materialScience,
        fullSentence:
            'Bei der Synthese des Nanomaterials traten mancherlei unerwartete Herausforderungen auf.',
        arabicTranslation:
            'أثناء تخليق المادة النانوية، طرأت شتى التحديات والصعوبات غير المتوقعة.',
        grammaticalAnalysisArabic:
            'الأداة "mancherlei" لفظة غير متصرفة؛ لذا تأخذ الصفة بعدها علامة الإعراب القوي الجمع -e: mancherlei unerwartete.',
        grammaticalAnalysisGerman:
            'Undeklinierbare Partikel auf -erlei: Vollständige starke Kasuskennzeichnung durch das Folgeadjektiv (-e).',
        commonErrorAnalysis:
            'Schwachdeklination (*mancherlei unerwarteten).',
        dudenGuidelineRule:
            'Indeklinable Formen erzwingen stets starke Adjektivendung.',
      ),
    );

    // 13. Split Construction: was für ein (Mixed declension in Accusative)
    _catalog.add(
      const FluctuatingAdjectiveModel(
        id: 'DEC-WAS-FUER-13',
        determinerWord: 'was für einen',
        determinerClass: DeterminerClass.splitPronounConstructions,
        appliedCase: GrammaticalCase.accusative,
        gender: GrammaticalGender.masculine,
        adjectiveBase: 'enorm',
        expectedAdjectiveEnding: '-en',
        fullDeterminerAdjectivePhrase: 'was für einen enormen',
        nounComplement: 'Wirkungsgrad',
        domain: CommunicativeDomain.renewablePowerGrid,
        fullSentence:
            'Die Messprotokolle verdeutlichen, was für einen enormen Wirkungsgrad die neue Turbinengeneration erzielt.',
        arabicTranslation:
            'توضح محاضر القياس وتثبت أي قدر هائل من الكفاءة ومردود الطاقة يحققه هذا الجيل الجديد من التوربينات.',
        grammaticalAnalysisArabic:
            'أسلوب التعجب والاستفهام "was für ein": يعرب "einen" بالنصب المذكر، وتتبعه الصفة باللاحقة -en التزاماً بالإعراب المختلط.',
        grammaticalAnalysisGerman:
            'Akkusativ Maskulinum: "einen" fordert nach den Regeln der gemischten Deklination das Suffix -en am Adjektiv.',
        commonErrorAnalysis:
            'Falscher Kasus oder unflektiertes Adjektiv (*was für ein enorm Wirkungsgrad).',
        dudenGuidelineRule:
            'Das Pronomen "was für ein" flektiert regulär wie der unbestimmte Artikel.',
      ),
    );

    // 14. Euphemistic Genitive: guten Mutes (Singular Neuter/Masculine -en avoidance of double -es)
    _catalog.add(
      const FluctuatingAdjectiveModel(
        id: 'DEC-EUPH-GEN-14',
        determinerWord: 'Nullartikel',
        determinerClass: DeterminerClass.adjectiveLikeParallelStrong,
        appliedCase: GrammaticalCase.genitive,
        gender: GrammaticalGender.masculine,
        adjectiveBase: 'gut',
        expectedAdjectiveEnding: '-en',
        fullDeterminerAdjectivePhrase: 'guten',
        nounComplement: 'Mutes',
        domain: CommunicativeDomain.civilInfrastructure,
        fullSentence:
            'Die Bauingenieure blickten guten Mutes auf den bevorstehenden Belastungstest der Pfeilerkonstruktion.',
        arabicTranslation:
            'تطلع مهندسو البناء بمعنويات عالية وثقة تامة نحو اختبار التحمل المرتقب لهيكل الدعامات الإنشائية.',
        grammaticalAnalysisArabic:
            'ظاهرة التخفيف ومنع توالي صوت الصغير (Euphemismus / Wohlklangs-n): في إضافة المذكر والمحايد بدون أداة، تأخذ الصفة -en بدلاً من -es لتفادي ثقل التكرار مع s الاسم (guten Mutes).',
        grammaticalAnalysisGerman:
            'Traditionelle Vermeidung von Doppel-es im Genitiv Singular: Das Adjektiv flektiert auf -en ("guten Mutes"), nicht "*gutes Mutes".',
        commonErrorAnalysis:
            'Hyperkorrektur mit starkem -es: "*gutes Mutes".',
        dudenGuidelineRule:
            'Feste Genitivfügungen mit Substantiven auf -s/-es weisen historisch die Adjektivendung -en auf.',
      ),
    );
  }

  /// Automatically derives the expected adjective form given a determiner and target grammar slots.
  String inflectAdjectivePhrase({
    required String determiner,
    required String adjectiveBase,
    required GrammaticalCase targetCase,
    required GrammaticalGender gender,
  }) {
    final entry = _catalog.firstWhere(
      (m) =>
          m.determinerWord.toLowerCase().contains(determiner.toLowerCase()) &&
          m.appliedCase == targetCase &&
          m.gender == gender,
      orElse: () => _catalog.first,
    );
    return entry.fullDeterminerAdjectivePhrase;
  }

  /// Validates an adjective ending against the rigorous determiner classification rules.
  AdjectiveDeclensionValidationReport validateAdjectivePhrase({
    required String determiner,
    required String writtenAdjectiveEnding,
    required GrammaticalCase targetCase,
    required GrammaticalGender gender,
  }) {
    final issues = <String>[];
    final recommendations = <String>[];

    final matchingEntries = _catalog.where(
      (m) =>
          m.determinerWord.toLowerCase().contains(determiner.toLowerCase()) &&
          m.appliedCase == targetCase &&
          m.gender == gender,
    );

    bool isValid = true;
    if (matchingEntries.isNotEmpty) {
      final target = matchingEntries.first;
      final expected = target.expectedAdjectiveEnding.replaceAll('-', '').trim();
      final actual = writtenAdjectiveEnding.replaceAll('-', '').trim();

      if (!expected.contains(actual)) {
        isValid = false;
        issues.add(
          'Inkorrekte Adjektivendung: Nach "$determiner" im $targetCase ($gender) ist die Endung "-$actual" standardsprachlich unzulässig. Erwartet wird: "${target.expectedAdjectiveEnding}".',
        );
        recommendations.add(target.dudenGuidelineRule);
        recommendations.add('Prüfen Sie, ob der Begleiter zu Artikelwörtern (schwach) oder Zahladjektiven (parallel stark) gehört.');
      }
    }

    final verdict = isValid
        ? 'تصريف الصفة بعد المحدد متطابق تماماً مع معايير اللغة الألمانية الفصيحة (Duden Band 9 / C1-C2).'
        : 'تم رصد خطأ صرفي في لاحقة الصفة بعد المحدد المبهم؛ يلزم تصحيح علامة الإعراب القوي أو الضعيف.';

    return AdjectiveDeclensionValidationReport(
      isValid: isValid,
      matchesStandardNorm: isValid,
      isStrongWeakChoiceCorrect: isValid,
      issues: issues,
      recommendations: recommendations,
      arabicDiagnosticVerdict: verdict,
    );
  }

  List<FluctuatingAdjectiveModel> filterByClass(DeterminerClass dClass) {
    return _catalog.where((item) => item.determinerClass == dClass).toList();
  }

  List<FluctuatingAdjectiveModel> filterByDomain(CommunicativeDomain domain) {
    return _catalog.where((item) => item.domain == domain).toList();
  }
}
