import 'dart:collection';

/// Classification of infinitive governing verbs (Infinitiv-Rektion).
enum InfinitiveGovernmentType {
  pureInfinitivePerception(
    'Reiner Infinitiv bei Wahrnehmungsverben (sehen, hören, spüren - AcI)',
    'المصدر الصريح المجرد بدون zu بعد أفعال الحواس والإدراك (تركيب AcI)',
    'Regiert zwingend den reinen Infinitiv ohne "zu": Wir sehen den Druck steigen. Im Perfekt mit Ersatzinfinitiv: Wir haben ihn steigen sehen.',
  ),
  pureInfinitiveCausativePermissive(
    'Reiner Infinitiv bei "lassen" (Kausativ / Permissiv)',
    'المصدر الصريح المجرد بعد فعل lassen الدال على التمكين أو السببية',
    'Der Ingenieur lässt die Anlage prüfen. Im Perfekt mit Ersatzinfinitiv: Er hat sie prüfen lassen.',
  ),
  pureInfinitiveMotion(
    'Reiner Infinitiv bei Bewegungsverben (gehen, fahren, laufen, schicken)',
    'المصدر الصريح المجرد بعد أفعال الحركة والانتقال',
    'Der Techniker geht das Messmodul kalibrieren. Niemals mit "zu" im einfachen Zielfeld.',
  ),
  dualGovernmentVerbs(
    'Fakultative Steuerung (helfen, lernen, lehren, bleiben)',
    'أفعال التحكم المزدوج (مصدر مجرد أو مصدر مقترن بـ zu بحسب التوسع التركيبي)',
    'Ohne Erweiterung oft reiner Infinitiv; mit komplexer Phrase meist Infinitiv mit "zu" und Kommasetzung.',
  ),
  obligatoryZuInfinitive(
    'Obligatorischer Infinitiv mit "zu" (Kontroll- und Modalitätsverben)',
    'المصدر المؤول المقترن إجبارياً بـ zu بعد أفعال القصد والتردد والشروع والظن',
    'beabsichtigen, zögern, pflegen, drohen, scheinen, vermögen, versäumen verlangen zwingend "zu" (bzw. Infix bei trennbaren Verben).',
  );

  final String germanTitle;
  final String arabicTitle;
  final String syntaxRule;
  const InfinitiveGovernmentType(
    this.germanTitle,
    this.arabicTitle,
    this.syntaxRule,
  );
}

/// Tense and aspectual form of the governing verb construction.
enum TenseAspectConstruction {
  presentOrSimplePast('Präsens / Präteritum (V1/V2)', 'المضارع أو الماضي البسيط'),
  perfectErsatzinfinitiv('Perfekt mit Ersatzinfinitiv', 'الماضي التام بصيغة المصدر البديل'),
  passiveInfinitive('Passivischer Infinitiv (gewartet zu werden)', 'المصدر المبني للمجهول');

  final String de;
  final String ar;
  const TenseAspectConstruction(this.de, this.ar);
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

/// Model representing a verb's infinitive complementation behavior.
class InfinitiveComplementationModel {
  final String id;
  final String governingVerb;
  final InfinitiveGovernmentType governmentType;
  final bool allowsZu;
  final bool requiresZu;
  final bool triggersErsatzinfinitivInPerfect;
  final String sampleSentence;
  final String perfectTenseSentence;
  final CommunicativeDomain domain;
  final String arabicTranslation;
  final String grammaticalAnalysisArabic;
  final String grammaticalAnalysisGerman;
  final String separableInfixDemonstration;
  final String commonLearnerTrap;

  const InfinitiveComplementationModel({
    required this.id,
    required this.governingVerb,
    required this.governmentType,
    required this.allowsZu,
    required this.requiresZu,
    required this.triggersErsatzinfinitivInPerfect,
    required this.sampleSentence,
    required this.perfectTenseSentence,
    required this.domain,
    required this.arabicTranslation,
    required this.grammaticalAnalysisArabic,
    required this.grammaticalAnalysisGerman,
    required this.separableInfixDemonstration,
    required this.commonLearnerTrap,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'governingVerb': governingVerb,
    'governmentType': governmentType.name,
    'allowsZu': allowsZu,
    'requiresZu': requiresZu,
    'triggersErsatzinfinitivInPerfect': triggersErsatzinfinitivInPerfect,
    'sampleSentence': sampleSentence,
    'perfectTenseSentence': perfectTenseSentence,
    'domain': domain.name,
    'arabicTranslation': arabicTranslation,
    'grammaticalAnalysisArabic': grammaticalAnalysisArabic,
    'grammaticalAnalysisGerman': grammaticalAnalysisGerman,
    'separableInfixDemonstration': separableInfixDemonstration,
    'commonLearnerTrap': commonLearnerTrap,
  };
}

/// Verification report container for infinitive complementation validation.
class InfinitiveValidationReport {
  final bool isValid;
  final bool isZuCorrectlyApplied;
  final bool isErsatzinfinitivCompliant;
  final bool isSeparableInfixCorrect;
  final List<String> issues;
  final List<String> recommendations;
  final String arabicDiagnosticVerdict;

  const InfinitiveValidationReport({
    required this.isValid,
    required this.isZuCorrectlyApplied,
    required this.isErsatzinfinitivCompliant,
    required this.isSeparableInfixCorrect,
    required this.issues,
    required this.recommendations,
    required this.arabicDiagnosticVerdict,
  });
}

/// Sovereign engine governing German Infinitive Complementation, Pure Infinitive & AcI Syntax.
class GermanInfinitiveComplementationEngine {
  final List<InfinitiveComplementationModel> _catalog = [];

  GermanInfinitiveComplementationEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<InfinitiveComplementationModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    // 1. sehen (Perception AcI - Pure Infinitive) - Aerospace Aviation
    _catalog.add(
      const InfinitiveComplementationModel(
        id: 'INF-SEHEN-AERO-01',
        governingVerb: 'sehen',
        governmentType: InfinitiveGovernmentType.pureInfinitivePerception,
        allowsZu: false,
        requiresZu: false,
        triggersErsatzinfinitivInPerfect: true,
        sampleSentence:
            'Die Missionskontrolle sieht den Druck im Sauerstofftank kontinuierlich steigen.',
        perfectTenseSentence:
            'Die Missionskontrolle hat den Druck im Sauerstofftank kontinuierlich steigen sehen.',
        domain: CommunicativeDomain.aerospaceAndAviation,
        arabicTranslation:
            'يرى مركز مراقبة المهمة الضغط داخل خزان الأكسجين يرتفع باستمرار.',
        grammaticalAnalysisArabic:
            'فعل إدراك حسي (sehen) يطبق تركيب AcI: مفعول به منصوب (den Druck) يعمل كفاعل دلالي للمصدر المجرد التام بدون zu (steigen). في الماضي التام، يستخدم صيغة المصدر البديل (steigen sehen) بدلاً من اسم المفعول.',
        grammaticalAnalysisGerman:
            'Wahrnehmungsverb "sehen" steuert das AcI-Gefüge (Akkusativobjekt "den Druck" fungiert als logisches Subjekt des reinen Infinitivs "steigen"). Im Perfekt obligatorischer Ersatzinfinitiv.',
        separableInfixDemonstration:
            'Nicht anwendbar (reiner Infinitiv; kein "zu").',
        commonLearnerTrap:
            'Schwerer Fehler: Fälschliches Einfügen von "zu" (*sieht den Druck zu steigen) oder falsches Partizip II im Perfekt (*hat steigen gesehen).',
      ),
    );

    // 2. hören (Perception AcI - Pure Infinitive) - Renewable Energy
    _catalog.add(
      const InfinitiveComplementationModel(
        id: 'INF-HOEREN-ENERGY-02',
        governingVerb: 'hören',
        governmentType: InfinitiveGovernmentType.pureInfinitivePerception,
        allowsZu: false,
        requiresZu: false,
        triggersErsatzinfinitivInPerfect: true,
        sampleSentence:
            'Der Windpark-Wartungstechniker hört das Hauptgetriebe der Gondel leise vibrieren.',
        perfectTenseSentence:
            'Der Windpark-Wartungstechniker hat das Hauptgetriebe der Gondel leise vibrieren hören.',
        domain: CommunicativeDomain.renewableEnergyGrid,
        arabicTranslation:
            'يسمع فني صيانة مزرعة الرياح صندوق التروس الرئيسي للمقصورة يهتز بصوت خافت.',
        grammaticalAnalysisArabic:
            'فعل السمع (hören): يتعدى لمصدر مجرد تماماً من zu (vibrieren). وصيغة الماضي التام تأتي بـ Ersatzinfinitiv: "vibrieren hören".',
        grammaticalAnalysisGerman:
            'AcI mit "hören": Regiert reinen Infinitiv ohne Infinitivpartikel. Im Perfekt tritt die Doppelinfinitiv-Struktur auf ("haben ... vibrieren hören").',
        separableInfixDemonstration:
            'Reiner Infinitiv schließt jegliches "-zu-" aus.',
        commonLearnerTrap:
            'Verwendung von "*zu vibrieren" oder des Partizips "*hat vibrieren gehört".',
      ),
    );

    // 3. lassen (Causative - Pure Infinitive) - Industrial Robotics
    _catalog.add(
      const InfinitiveComplementationModel(
        id: 'INF-LASSEN-ROBOT-03',
        governingVerb: 'lassen',
        governmentType: InfinitiveGovernmentType.pureInfinitiveCausativePermissive,
        allowsZu: false,
        requiresZu: false,
        triggersErsatzinfinitivInPerfect: true,
        sampleSentence:
            'Der Produktionsleiter lässt die gesamte Montagelinie vor der Schichtumstellung sorgfältig reinigen.',
        perfectTenseSentence:
            'Der Produktionsleiter hat die gesamte Montagelinie vor der Schichtumstellung sorgfältig reinigen lassen.',
        domain: CommunicativeDomain.industrialRobotics,
        arabicTranslation:
            'يأمر مدير الإنتاج بتنظيف خط التجميع بأكمله بعناية قبل تبديل المناوبة (يدع الخط يُنظف).',
        grammaticalAnalysisArabic:
            'الفعل السببي "lassen": يتعدى للمصدر الصريح الخالي من zu (reinigen). وفي الماضي التام يحل المصدر البديل (lassen) محل اسم المفعول (gelassen).',
        grammaticalAnalysisGerman:
            'Kausatives "lassen" regiert den reinen Infinitiv. Im Perfekt mit abhängigem Infinitiv gilt strikt der Ersatzinfinitiv ("reinigen lassen").',
        separableInfixDemonstration:
            'Bei trennbaren Verben bleibt das Präfix geschlossen: "ausbauen lassen" (niemals "*auszubauen lassen").',
        commonLearnerTrap:
            'Kardinalfehler: "*lässt die Linie zu reinigen" oder "*hat reinigen gelassen".',
      ),
    );

    // 4. gehen (Motion Verb - Pure Infinitive) - Civil Infrastructure
    _catalog.add(
      const InfinitiveComplementationModel(
        id: 'INF-GEHEN-CIVIL-04',
        governingVerb: 'gehen',
        governmentType: InfinitiveGovernmentType.pureInfinitiveMotion,
        allowsZu: false,
        requiresZu: false,
        triggersErsatzinfinitivInPerfect: false,
        sampleSentence:
            'Der Bauprüfingenieur geht die Fundamentbewehrung der Talbrücke vor Ort inspizieren.',
        perfectTenseSentence:
            'Der Bauprüfingenieur ist die Fundamentbewehrung der Talbrücke vor Ort inspizieren gegangen.',
        domain: CommunicativeDomain.civilInfrastructure,
        arabicTranslation:
            'يذهب مهندس تدقيق البناء لمعاينة تسليح أساسات الجسر المعلق وتفقده ميدانياً.',
        grammaticalAnalysisArabic:
            'فعل حركة وانتقال (gehen): يتبعه المصدر المجرد الخالي من zu للدلالة على غاية الانتقال (inspizieren). وفي الماضي التام يأخذ sein مع Partizip II (gegangen).',
        grammaticalAnalysisGerman:
            'Bewegungsverb "gehen" verknüpft sich direkt mit dem reinen Infinitiv der Zielhandlung. Perfekt mit "sein" + regulärem Partizip II ("gegangen").',
        separableInfixDemonstration:
            'Kein "zu": "nachmessen gehen", nicht "*nachzumessen gehen".',
        commonLearnerTrap:
            'Falsches Hinzufügen von "um zu": "*geht, um zu inspizieren" (überflüssig bei einfacher Zielangabe).',
      ),
    );

    // 5. beabsichtigen (Obligatory zu-Infinitive) - Software Architecture
    _catalog.add(
      const InfinitiveComplementationModel(
        id: 'INF-BEABSICHTIGEN-SOFT-05',
        governingVerb: 'beabsichtigen',
        governmentType: InfinitiveGovernmentType.obligatoryZuInfinitive,
        allowsZu: true,
        requiresZu: true,
        triggersErsatzinfinitivInPerfect: false,
        sampleSentence:
            'Das Entwicklerteam beabsichtigt, die Datenbankabfragen durch In-Memory-Caching drastisch zu beschleunigen.',
        perfectTenseSentence:
            'Das Entwicklerteam hat beabsichtigt, die Datenbankabfragen drastisch zu beschleunigen.',
        domain: CommunicativeDomain.softwareEngineering,
        arabicTranslation:
            'ينوي فريق المطورين تسريع استعلامات قاعدة البيانات تسريعاً جذرياً عبر التخزين المؤقت في الذاكرة.',
        grammaticalAnalysisArabic:
            'فعل نية وقصد (beabsichtigen): يوجب اقتران المصدر في الشطر التابع بـ zu (zu beschleunigen)، ويفصل بين الجملتين بفاصلة وجوباً.',
        grammaticalAnalysisGerman:
            'Intentionales Kontrollverb: Verlangt obligatorisch die Infinitivphrase mit "zu" und paarige/trennende Kommasetzung.',
        separableInfixDemonstration:
            'Bei nichttrennbarem Verb steht "zu" separat: "zu beschleunigen".',
        commonLearnerTrap:
            'Weglassen von "zu": "*beabsichtigt die Abfragen beschleunigen" ist grob fehlerhaft.',
      ),
    );

    // 6. zögern (Obligatory zu-Infinitive with Separable Infix) - Maritime Logistics
    _catalog.add(
      const InfinitiveComplementationModel(
        id: 'INF-ZOEGERN-MARITIME-06',
        governingVerb: 'zögern',
        governmentType: InfinitiveGovernmentType.obligatoryZuInfinitive,
        allowsZu: true,
        requiresZu: true,
        triggersErsatzinfinitivInPerfect: false,
        sampleSentence:
            'Die Schiffsführung zögerte nicht, das Notsignal über Satellitenfunk unverzüglich auszusenden.',
        perfectTenseSentence:
            'Die Schiffsführung hat nicht gezögert, das Notsignal unverzüglich auszusenden.',
        domain: CommunicativeDomain.maritimeLogistics,
        arabicTranslation:
            'لم تتردد قيادة السفينة في بث إشارة الاستغاثة فوراً عبر الاتصالات اللاسلكية بالأقمار الاصطناعية.',
        grammaticalAnalysisArabic:
            'فعل التردد (zögern): يلزم المصدر بـ zu. ومع الفعل المنفصل (aussenden) يُقحم "zu" بين السابقة وجذر الفعل كلاحقة بينية: aus-zu-senden.',
        grammaticalAnalysisGerman:
            'Verb des Aufschubs verlangt Infinitiv mit "zu". Bei dem trennbaren Verb "aussenden" fügt sich "-zu-" als Infix ein: "auszusenden".',
        separableInfixDemonstration:
            'Trennbare Infix-Bildung: Präfix [aus] + zu + Stamm [senden] = "auszusenden".',
        commonLearnerTrap:
            'Getrenntschreibung oder falsche Position: "*aus zu senden" oder "*zu aussenden".',
      ),
    );

    // 7. helfen (Dual Government: Pure or with zu) - Industrial Robotics
    _catalog.add(
      const InfinitiveComplementationModel(
        id: 'INF-HELFEN-ROBOT-07',
        governingVerb: 'helfen',
        governmentType: InfinitiveGovernmentType.dualGovernmentVerbs,
        allowsZu: true,
        requiresZu: false,
        triggersErsatzinfinitivInPerfect: true,
        sampleSentence:
            'Der erfahrene Mechatroniker hilft dem Auszubildenden, den neuen Laserschnittkopf präzise einzustellen.',
        perfectTenseSentence:
            'Der Mechatroniker hat dem Auszubildenden geholfen (bzw. helfen), den Schnittkopf einzustellen.',
        domain: CommunicativeDomain.industrialRobotics,
        arabicTranslation:
            'يساعد مهندس الميكاترونكس المتمرس المتدرب على ضبط رأس القطع الليزري الجديد بدقة متناهية.',
        grammaticalAnalysisArabic:
            'فعل المساعدة (helfen): يقبل الإعراب المزدوج؛ عند التوسع بجملة غنية بالمفاعيل يُفضل اقتران المصدر بـ zu (einzustellen) مع الفصل بفاصلة.',
        grammaticalAnalysisGerman:
            'Fakultative Steuerung bei "helfen": Kurze Phrasen stehen oft ohne "zu" ("hilft schweißen"), erweiterte Infinitivgruppen stehen standardsprachlich mit "zu" und Komma.',
        separableInfixDemonstration:
            'Mit Infix: "einzustellen" (ein + zu + stellen).',
        commonLearnerTrap:
            'Verunsicherung über Kommasetzung: Bei erweiterter Infinitivgruppe mit "zu" ist das Komma dringend empfohlen.',
      ),
    );

    // 8. scheinen (Modalized Epistemic zu-Infinitive) - Material Science
    _catalog.add(
      const InfinitiveComplementationModel(
        id: 'INF-SCHEINEN-MAT-08',
        governingVerb: 'scheinen',
        governmentType: InfinitiveGovernmentType.obligatoryZuInfinitive,
        allowsZu: true,
        requiresZu: true,
        triggersErsatzinfinitivInPerfect: false,
        sampleSentence:
            'Die neuentwickelte Kohlenstoffmatrix scheint die mechanischen Zugkräfte optimal aufzunehmen.',
        perfectTenseSentence:
            'Die Matrix hat die Zugkräfte optimal aufzunehmen geschienen.',
        domain: CommunicativeDomain.materialScience,
        arabicTranslation:
            'يبدو أن مصفوفة الكربون المطورة حديثاً تمتص قوى الشد الميكانيكية وتستوعبها بالشكل الأمثل.',
        grammaticalAnalysisArabic:
            'فعل الظهور والرجحان (scheinen): يعمل كفعل مساعد للظن والترجيح ويلزم المصدر التابع بـ zu دائماً: auf-zu-nehmen.',
        grammaticalAnalysisGerman:
            'Subjektbezogenes Hebeverb (Raising-Konstruktion): "scheinen" verlangt ausnahmslos den Infinitiv mit "zu".',
        separableInfixDemonstration:
            'Infix bei trennbarem Verb: "aufzunehmen" (auf + zu + nehmen).',
        commonLearnerTrap:
            'Auslassung von "zu": "*scheint die Kräfte optimal aufnehmen" ist ungrammatisch.',
      ),
    );

    // 9. drohen (Imminent Risk - Obligatory zu) - Renewable Energy
    _catalog.add(
      const InfinitiveComplementationModel(
        id: 'INF-DROHEN-ENERGY-09',
        governingVerb: 'drohen',
        governmentType: InfinitiveGovernmentType.obligatoryZuInfinitive,
        allowsZu: true,
        requiresZu: true,
        triggersErsatzinfinitivInPerfect: false,
        sampleSentence:
            'Bei anhaltender Überlastung droht der Großtransformator unkontrolliert zu überhitzen.',
        perfectTenseSentence:
            'Der Großtransformator hat zu überhitzen gedroht.',
        domain: CommunicativeDomain.renewableEnergyGrid,
        arabicTranslation:
            'في حال استمرار التحميل الزائد، ينذر المحول الكهربائي الضخم بالتعرض لفرط سخونة خارج عن السيطرة (يوشك أن يسخن لدرجة الاحتراق).',
        grammaticalAnalysisArabic:
            'فعل الإنذار باقتراب الخطر (drohen): يفيد اقتراب وقوع حادث سلبي، ويلزمه المصدر المقترن بـ zu (zu überhitzen).',
        grammaticalAnalysisGerman:
            'Metaphorisches Drohverb bei unpersönlichen Subjekten zur Anzeige einer drohenden Fehlfunktion; obligatorisch mit "zu".',
        separableInfixDemonstration:
            'Nichttrennbar: "zu überhitzen".',
        commonLearnerTrap:
            'Verwechslung mit echter Personenbedrohung; bei technischen Systemen drückt "drohen + zu" unausweichliche Gefahr aus.',
      ),
    );

    // 10. vermögen (Formal Capacity - Obligatory zu) - Aerospace Aviation
    _catalog.add(
      const InfinitiveComplementationModel(
        id: 'INF-VERMOEGEN-AERO-10',
        governingVerb: 'vermögen',
        governmentType: InfinitiveGovernmentType.obligatoryZuInfinitive,
        allowsZu: true,
        requiresZu: true,
        triggersErsatzinfinitivInPerfect: false,
        sampleSentence:
            'Selbst modernste Radarsysteme vermögen die neue Stealth-Beschichtung kaum zu orten.',
        perfectTenseSentence:
            'Die Radarsysteme haben die Beschichtung kaum zu orten vermocht.',
        domain: CommunicativeDomain.aerospaceAndAviation,
        arabicTranslation:
            'حتى أحدث منظومات الرادار تكاد لا تقوى على رصد طلاء التخفي الجديد أو تحديد موقعه.',
        grammaticalAnalysisArabic:
            'فعل القدرة والاستطاعة الفصيح (vermögen): بديل راقٍ لـ können في النثر العلمي الأكاديمي، ويلزمه المصدر بـ zu (zu orten).',
        grammaticalAnalysisGerman:
            'Gehobenes Äquivalent zu "können". Während "können" den reinen Infinitiv regiert, verlangt "vermögen" strikt den Infinitiv mit "zu".',
        separableInfixDemonstration:
            'Einfaches Verb: "zu orten".',
        commonLearnerTrap:
            'Konstruktion ohne "zu" wie bei Modalverben: "*vermögen die Beschichtung orten" ist schwerer Grammatikfehler!',
      ),
    );

    // 11. pflegen (Habitual Formal Action - Obligatory zu) - Civil Infrastructure
    _catalog.add(
      const InfinitiveComplementationModel(
        id: 'INF-PFLEGEN-CIVIL-11',
        governingVerb: 'pflegen',
        governmentType: InfinitiveGovernmentType.obligatoryZuInfinitive,
        allowsZu: true,
        requiresZu: true,
        triggersErsatzinfinitivInPerfect: false,
        sampleSentence:
            'Die staatliche Materialprüfanstalt pflegt sämtliche Betonrezepturen vor Baubeginn unabhängig zu verifizieren.',
        perfectTenseSentence:
            'Die Anstalt hat die Rezepturen unabhängig zu verifizieren gepflegt.',
        domain: CommunicativeDomain.civilInfrastructure,
        arabicTranslation:
            'دأبت هيئة فحص المواد الحكومية وجرى عرفها المهني على التحقق المستقل من كافة خلطات الخرسانة قبل الشروع في البناء.',
        grammaticalAnalysisArabic:
            'فعل الاعتياد والديدن (pflegen): يفيد الجريان على عادة مؤسسية راسخة، ويلزم المصدر دائماً بـ zu: zu verifizieren.',
        grammaticalAnalysisGerman:
            'Habituelles Phasenverb im gehobenen Amts- und Gutachterstil zur Wiedergabe etablierter Praxis; obligatorisch mit "zu".',
        separableInfixDemonstration:
            'Fremdverb: "zu verifizieren".',
        commonLearnerTrap:
            'Verwechslung mit der Hauptbedeutung "pflegen" (hegen/pflegen); mit Infinitiv bedeutet es "die Gewohnheit haben".',
      ),
    );

    // 12. versäumen (Omission - Obligatory zu with Infix) - Maritime Logistics
    _catalog.add(
      const InfinitiveComplementationModel(
        id: 'INF-VERSAEUMEN-MARITIME-12',
        governingVerb: 'versäumen',
        governmentType: InfinitiveGovernmentType.obligatoryZuInfinitive,
        allowsZu: true,
        requiresZu: true,
        triggersErsatzinfinitivInPerfect: false,
        sampleSentence:
            'Der Wachoffizier versäumte es, die automatische Kollisionswarnung rechtzeitig einzuschalten.',
        perfectTenseSentence:
            'Der Wachoffizier hat es versäumt, die Warnung einzuschalten.',
        domain: CommunicativeDomain.maritimeLogistics,
        arabicTranslation:
            'أغفل ضابط النوبة تشغيل نظام التحذير الآلي من التصادم في الوقت المناسب وتكاسل عن تفعيله.',
        grammaticalAnalysisArabic:
            'فعل الإغفال والتقصير (versäumen): يستلزم مصدراً مؤولاً بـ zu مع إقحام اللاحقة البينية في الفعل المنفصل: ein-zu-schalten.',
        grammaticalAnalysisGerman:
            'Negativ-intentionelles Kontrollverb mit Korrelat "es". Die Infinitivgruppe verlangt das Infix "-zu-" bei "einschalten".',
        separableInfixDemonstration:
            'Infix: "einzuschalten" (ein + zu + schalten).',
        commonLearnerTrap:
            'Fehlerhafte Endung oder Falschplatzierung: "*einschalten zu".',
      ),
    );

    // 13. spüren (Perception AcI - Pure Infinitive) - Material Science
    _catalog.add(
      const InfinitiveComplementationModel(
        id: 'INF-SPUEREN-MAT-13',
        governingVerb: 'spüren',
        governmentType: InfinitiveGovernmentType.pureInfinitivePerception,
        allowsZu: false,
        requiresZu: false,
        triggersErsatzinfinitivInPerfect: true,
        sampleSentence:
            'Unter extremen Scherbelastungen spürt der Prüfer die Molekülketten des Polymers nachgeben.',
        perfectTenseSentence:
            'Der Prüfer hat die Molekülketten des Polymers nachgeben spüren.',
        domain: CommunicativeDomain.materialScience,
        arabicTranslation:
            'تحت قوى القص الفائقة، يستشعر الفاحص سلاسل جزيئات البوليمر وهي تتراخى وتستسلم للإجهاد.',
        grammaticalAnalysisArabic:
            'فعل استشعار حسي مادي (spüren): يتعدى لمصدر مجرد (nachgeben) دون zu. وفي الماضي التام يحل المصدر البديل (spüren) محل اسم المفعول.',
        grammaticalAnalysisGerman:
            'Wahrnehmungsverb der Haptik und Sensorik. Bildet ein klassisches AcI-Gefüge mit reinem Infinitiv.',
        separableInfixDemonstration:
            'Reiner Infinitiv: "nachgeben" (ohne -zu-!).',
        commonLearnerTrap:
            'Fehlerhafterweise Infix einfädeln: "*nachzugeben spüren" (beim AcI verboten!).',
      ),
    );

    // 14. schicken (Motion Verb - Pure Infinitive) - Industrial Robotics
    _catalog.add(
      const InfinitiveComplementationModel(
        id: 'INF-SCHICKEN-ROBOT-14',
        governingVerb: 'schicken',
        governmentType: InfinitiveGovernmentType.pureInfinitiveMotion,
        allowsZu: false,
        requiresZu: false,
        triggersErsatzinfinitivInPerfect: false,
        sampleSentence:
            'Die Leitstelle schickt den Inspektionsroboter die verengte Rohrleitung auf Lecks untersuchen.',
        perfectTenseSentence:
            'Die Leitstelle hat den Roboter die Leitung untersuchen geschickt.',
        domain: CommunicativeDomain.industrialRobotics,
        arabicTranslation:
            'ترسل غرفة التحكم روبوت الفحص ليعاين الأنبوب الضيق بحثاً عن أي تسريبات.',
        grammaticalAnalysisArabic:
            'فعل إرسال وتوجيه حركي (schicken): يتبعه المصدر الصريح الخالي من zu (untersuchen) كغاية للإرسال.',
        grammaticalAnalysisGerman:
            'Direktives Bewegungsverb "schicken" verbindet sich direkt mit dem Zielinfinitiv ohne "zu".',
        separableInfixDemonstration:
            'Reiner Infinitiv ohne "zu".',
        commonLearnerTrap:
            'Falsches Verwenden von "*zu untersuchen" oder "um zu untersuchen".',
      ),
    );

    // 15. bleiben (Dual Government - Pure State Infinitive) - Renewable Energy
    _catalog.add(
      const InfinitiveComplementationModel(
        id: 'INF-BLEIBEN-ENERGY-15',
        governingVerb: 'bleiben',
        governmentType: InfinitiveGovernmentType.dualGovernmentVerbs,
        allowsZu: false,
        requiresZu: false,
        triggersErsatzinfinitivInPerfect: false,
        sampleSentence:
            'Die redundanten Netztrenner bleiben bei Spannungsausfall dauerhaft geschlossen stehen.',
        perfectTenseSentence:
            'Die Netztrenner sind dauerhaft geschlossen stehen geblieben.',
        domain: CommunicativeDomain.renewableEnergyGrid,
        arabicTranslation:
            'تظل قواطع الشبكة الاحتياطية في حال انقطاع الجهد مستقرة وثابتة في وضع الإغلاق بشكل دائم.',
        grammaticalAnalysisArabic:
            'فعل البقاء (bleiben): يقترن بالمصدر المجرد في التراكيب الثابتة (stehen bleiben / hängen bleiben / liegen bleiben) بدون zu وبدون فاصلة.',
        grammaticalAnalysisGerman:
            'Zustandsverb "bleiben" mit partikelartigem reinem Infinitiv ("stehen bleiben"). Perfekt mit "sein".',
        separableInfixDemonstration:
            'Kein Infix: "stehen bleiben".',
        commonLearnerTrap:
            'Getrennt- oder Zusammenschreibung bei neuen Rechtschreibregeln; niemals mit "zu" (*stehen zu bleiben ist hier falsch).',
      ),
    );

    // 16. lernen (Dual Government with Extended Object) - Software Architecture
    _catalog.add(
      const InfinitiveComplementationModel(
        id: 'INF-LERNEN-SOFT-16',
        governingVerb: 'lernen',
        governmentType: InfinitiveGovernmentType.dualGovernmentVerbs,
        allowsZu: true,
        requiresZu: false,
        triggersErsatzinfinitivInPerfect: true,
        sampleSentence:
            'Das neuronale Netz lernt, komplexe Ausfallmuster in Echtzeit-Telemetriedaten selbstständig zu erkennen.',
        perfectTenseSentence:
            'Das neuronale Netz hat gelernt (bzw. lernen), Muster selbstständig zu erkennen.',
        domain: CommunicativeDomain.softwareEngineering,
        arabicTranslation:
            'تتعلم الشبكة العصبية الاصطناعية التعرف الذاتي والمستقل على أنماط الأعطال المعقدة في بيانات القياس اللحظية.',
        grammaticalAnalysisArabic:
            'فعل التعلم (lernen): عند ارتباطه بعبارة ممتدة غنية بالمفاعيل والأحوال، يلزم إدخال zu (zu erkennen) مع الفصل بفاصلة.',
        grammaticalAnalysisGerman:
            'Verb der Wissensaneignung: Einfacher Infinitiv ohne "zu" ("programmieren lernen"), erweiterte Infinitivgruppe jedoch standardmäßig mit "zu" und Komma.',
        separableInfixDemonstration:
            'Nichttrennbares Verb: "zu erkennen".',
        commonLearnerTrap:
            'Weglassen des Kommas bei ausgedehnten Infinitivphrasen.',
      ),
    );
  }

  /// Evaluates an input sentence for correct infinitive complementation, zu-placement, and Ersatzinfinitiv rules.
  InfinitiveValidationReport validateInfinitiveUsage({
    required String governingVerb,
    required bool usedZu,
    required bool isSeparableVerb,
    required String infinitiveWord,
    required bool isPerfectTense,
    required bool usedErsatzinfinitiv,
  }) {
    final issues = <String>[];
    final recommendations = <String>[];

    final matchingEntry = _catalog.firstWhere(
      (m) => m.governingVerb.toLowerCase() == governingVerb.toLowerCase(),
      orElse: () => _catalog.first,
    );

    // 1. Check if 'zu' is illegally added to pure infinitive verbs
    if (!matchingEntry.allowsZu && usedZu) {
      issues.add(
        'Ullzulässige Infinitivpartikel: Nach dem Verb "$governingVerb" (Wahrnehmungs-, Bewegungs- oder Hilfsverb) darf NIEMALS "zu" stehen. Es gilt der reine Infinitiv.',
      );
      recommendations.add(
        'Entfernen Sie "zu" bzw. das Infix "-zu-" vor dem Infinitiv (z. B. "sieht steigen", nicht "*sieht zu steigen").',
      );
    }

    // 2. Check if 'zu' is omitted where it is strictly required
    if (matchingEntry.requiresZu && !usedZu) {
      issues.add(
        'Fehlende Infinitivpartikel: Das Kontrollverb "$governingVerb" verlangt zwingend die Infinitivgruppe mit "zu".',
      );
      recommendations.add(
        'Fügen Sie "zu" vor dem Infinitiv bzw. "-zu-" zwischen Präfix und Stamm ein (z. B. "beabsichtigt zu beschleunigen").',
      );
    }

    // 3. Check separable verb infix correctness
    bool infixCorrect = true;
    if (usedZu && isSeparableVerb) {
      if (!infinitiveWord.contains('zu')) {
        infixCorrect = false;
        issues.add(
          'Infix-Fehler bei trennbarem Verb: Bei trennbaren Verben muss "-zu-" zwischen Präfix und Verbstamm eingeschoben werden (z. B. "aus-zu-senden").',
        );
        recommendations.add('Schreiben Sie das Verb als ein zusammenhängendes Wort mit "-zu-" als Fuge.');
      }
    }

    // 4. Check Ersatzinfinitiv in Perfect tense
    if (isPerfectTense && matchingEntry.triggersErsatzinfinitivInPerfect && !usedErsatzinfinitiv) {
      issues.add(
        'Fehlender Ersatzinfinitiv: Im Perfekt mit abhängigem Infinitiv muss nach "$governingVerb" der Ersatzinfinitiv (Doppelinfinitiv) stehen, nicht das reguläre Partizip II.',
      );
      recommendations.add(
        'Ersetzen Sie das Partizip II durch den Infinitiv (z. B. "hat steigen sehen", nicht "*hat steigen gesehen").',
      );
    }

    final isValid = issues.isEmpty;
    final verdict = isValid
        ? 'التركيب النحوي للمصدر وصيغته التبعية بعد الفعل الحاكم سليم تماماً ومتطابق مع معايير الفصاحة الألمانية (C1-C2).'
        : 'تم رصد خلل في اقتران المصدر (استخدام خاطئ لـ zu، أو إغفال صيغة المصدر البديل Ersatzinfinitiv، أو خطأ في لاحقة الفعل المنفصل).';

    return InfinitiveValidationReport(
      isValid: isValid,
      isZuCorrectlyApplied: (!matchingEntry.allowsZu && !usedZu) || (matchingEntry.requiresZu && usedZu) || matchingEntry.governmentType == InfinitiveGovernmentType.dualGovernmentVerbs,
      isErsatzinfinitivCompliant: !isPerfectTense || !matchingEntry.triggersErsatzinfinitivInPerfect || usedErsatzinfinitiv,
      isSeparableInfixCorrect: infixCorrect,
      issues: issues,
      recommendations: recommendations,
      arabicDiagnosticVerdict: verdict,
    );
  }

  List<InfinitiveComplementationModel> filterByType(InfinitiveGovernmentType type) {
    return _catalog.where((item) => item.governmentType == type).toList();
  }

  List<InfinitiveComplementationModel> filterByDomain(CommunicativeDomain domain) {
    return _catalog.where((item) => item.domain == domain).toList();
  }
}
