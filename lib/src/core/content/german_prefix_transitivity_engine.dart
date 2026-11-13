import 'dart:collection';

/// Classification of inseparable German verbal prefixes (Nicht-trennbare Präfixe).
enum InseparablePrefix {
  be('be-', 'التعدية المباشرة ونقل الأثر على المفعول به الصريح'),
  ver('ver-', 'التحول الصيروري / الخطأ والسهو / الاستهلاك التام'),
  ent('ent-', 'السلب والإزالة والفصل / ابتداء الظهور والانبثاق'),
  zer('zer-', 'التفتيت والتحطيم والتفكيك والتشظي الفيزيائي'),
  er('er-', 'بلوغ الهدف بالكد / التوليد والإحداث التام'),
  miss('miss-', 'الفشل وسوء التنفيذ ومخالفة المعيار');

  final String prefix;
  final String arabicConcept;
  const InseparablePrefix(this.prefix, this.arabicConcept);
}

/// Semantic function governed by the prefix.
enum PrefixSemanticFunction {
  transitivizingDirectObject(
    'Transitivierung (Überführung in direktes Akkusativobjekt)',
    'تعدية الفعل اللازم أو المجرور إلى مفعول به منصوب مباشر',
    'Macht intransitive oder präpositionale Verben strikt transitiv: antworten auf -> beantworten (+ Akk)',
  ),
  privativeRemoval(
    'Privativität & Trennung (Befreiung von einer Eigenschaft)',
    'السلب والإزالة والفصل والتجريد',
    'Entfernung oder Entkopplung eines Elements: koppeln -> entkoppeln, lüften -> entlüften',
  ),
  destructiveDispersion(
    'Destruktion & Fragmentierung (Zerstörung in Teile)',
    'التفتيت والتشظي والانشطار الميكانيكي',
    'Drückt das gewaltsame oder physikalische Zerfallen aus: reißen -> zerreißen, fallen -> zerfallen',
  ),
  transformativeTelic(
    'Transformative Zustandsänderung (Telizität)',
    'التحول الصيروري نحو حالة فيزيائية جديدة مكتملة',
    'Führt in einen neuen Zustand über: flüssig -> verflüssigen, fest -> verstärken',
  ),
  errorPejorative(
    'Fehlhandlung & Pejorativität (sich ver-)',
    'الخطأ والسهو والمفارقة السلبية في التنفيذ',
    'Drückt ein Versehen oder fehlerhaftes Agieren aus: rechnen -> sich verrechnen, schalten -> sich verschalten',
  ),
  acquisitionByEffort(
    'Zielerreichung durch Anstrengung & Generierung',
    'التحصيل والإنتاج وبلوغ النتيجة بالجهد والعمل',
    'Erfolg nach Arbeitsaufwand: arbeiten -> erarbeiten, forschen -> erforschen, zeugen -> erzeugen',
  ),
  negativeDistortion(
    'Fehlleitung & Missachtung',
    'الإخفاق وسوء الفهم والتجاهل المتعمد',
    'Drückt das Verfehlen einer Norm aus: verstehen -> missverstehen, achten -> missachten',
  );

  final String germanTitle;
  final String arabicTitle;
  final String definition;
  const PrefixSemanticFunction(
    this.germanTitle,
    this.arabicTitle,
    this.definition,
  );
}

/// Structural valence alternation pattern.
enum ValenceAlternationType {
  prepositionalToDirectAccusative(
    'Präpositionalobjekt -> Direktes Akkusativobjekt',
    'تحويل المفعول غير المباشر بحرف جر إلى مفعول به صريح منصوب',
  ),
  intransitiveToTransitive(
    'Intransitiv (objektlos) -> Monotransitiv (+ Akkusativ)',
    'تحويل الفعل اللازم إلى متعدٍ لمفعول واحد',
  ),
  dativeAblativeSource(
    'Ditransitiv: Dativ (Quelle) + Akkusativ (Objekt)',
    'التعدي لمفعولين: مجرور بالداتيف للمصدر ومفعول صريح منصوب',
  ),
  reflexiveErrorShift(
    'Reflexivierung mit Fehlbedeutung (sich + ver-)',
    'التحول إلى الفعل الانعكاسي الدال على السهو والخلل',
  );

  final String de;
  final String ar;
  const ValenceAlternationType(this.de, this.ar);
}

/// Professional and engineering domains free of legal/medical liability.
enum CommunicativeDomain {
  renewableEnergyGrid('Erneuerbare Energien & Netztechnik', 'الطاقة المتجددة وهندسة الشبكات'),
  aerospaceAndAviation('Luft- & Raumfahrttechnik', 'هندسة الطيران واستكشاف الفضاء'),
  industrialRobotics('Industrierobotik & Mechatronik', 'الروبوتات الصناعية والميكاترونكس'),
  civilInfrastructure('Bauingenieurwesen & Werkstoffprüfung', 'الهندسة المدنية وفحص المواد'),
  materialScience('Materialwissenschaft & Nanotechnologie', 'علم المواد والتراكيب النانوية'),
  maritimeLogistics('Maritime Schifffahrt & Hafentechnologie', 'الملاحة البحرية والشحن الدولي');

  final String de;
  final String ar;
  const CommunicativeDomain(this.de, this.ar);
}

/// Structural model of a prefix transitivity alternation.
class PrefixAlternationModel {
  final String id;
  final InseparablePrefix prefix;
  final PrefixSemanticFunction semanticFunction;
  final ValenceAlternationType alternationType;
  final String baseVerbPhrase;
  final String prefixedVerb;
  final String governingCase;
  final CommunicativeDomain domain;
  final String sampleSentence;
  final String arabicTranslation;
  final String grammaticalAnalysisArabic;
  final String grammaticalAnalysisGerman;
  final String valenceTransformationFormula;
  final String diagnosticTrapWarning;

  const PrefixAlternationModel({
    required this.id,
    required this.prefix,
    required this.semanticFunction,
    required this.alternationType,
    required this.baseVerbPhrase,
    required this.prefixedVerb,
    required this.governingCase,
    required this.domain,
    required this.sampleSentence,
    required this.arabicTranslation,
    required this.grammaticalAnalysisArabic,
    required this.grammaticalAnalysisGerman,
    required this.valenceTransformationFormula,
    required this.diagnosticTrapWarning,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'prefix': prefix.name,
    'semanticFunction': semanticFunction.name,
    'alternationType': alternationType.name,
    'baseVerbPhrase': baseVerbPhrase,
    'prefixedVerb': prefixedVerb,
    'governingCase': governingCase,
    'domain': domain.name,
    'sampleSentence': sampleSentence,
    'arabicTranslation': arabicTranslation,
    'grammaticalAnalysisArabic': grammaticalAnalysisArabic,
    'grammaticalAnalysisGerman': grammaticalAnalysisGerman,
    'valenceTransformationFormula': valenceTransformationFormula,
    'diagnosticTrapWarning': diagnosticTrapWarning,
  };
}

/// Validation report container for prefix transitivity analysis.
class PrefixTransitivityValidationReport {
  final bool isValid;
  final bool avoidsRedundantPreposition;
  final bool isCaseGovernmentCorrect;
  final List<String> issues;
  final List<String> recommendations;
  final String arabicDiagnosticVerdict;

  const PrefixTransitivityValidationReport({
    required this.isValid,
    required this.avoidsRedundantPreposition,
    required this.isCaseGovernmentCorrect,
    required this.issues,
    required this.recommendations,
    required this.arabicDiagnosticVerdict,
  });
}

/// Sovereign engine governing German Inseparable Prefix Semantics & Transitivity Alternation.
class GermanPrefixTransitivityEngine {
  final List<PrefixAlternationModel> _catalog = [];

  GermanPrefixTransitivityEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<PrefixAlternationModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    // 1. be-: arbeiten an (Dat) -> bearbeiten (+ Akk) - Industrial Robotics
    _catalog.add(
      const PrefixAlternationModel(
        id: 'PREF-BE-ARBEITEN-01',
        prefix: InseparablePrefix.be,
        semanticFunction: PrefixSemanticFunction.transitivizingDirectObject,
        alternationType: ValenceAlternationType.prepositionalToDirectAccusative,
        baseVerbPhrase: 'arbeiten an + Dativ',
        prefixedVerb: 'bearbeiten + Akkusativ',
        governingCase: 'Akkusativ (ohne Präposition)',
        domain: CommunicativeDomain.industrialRobotics,
        sampleSentence:
            'Der hochpräzise Fräsroboter bearbeitet das komplexe Werkstück aus Titanlegierung vollautomatisch.',
        arabicTranslation:
            'يقوم روبوت التفريز فائق الدقة بمعالجة وتشغيل القطعة الهندسية المعقدة المصنوعة من سبيكة التيتانيوم آلياً بالكامل.',
        grammaticalAnalysisArabic:
            'أثر اللاحقة "be-": تحول الفعل اللازم المجرور بحرف جر (arbeiten an + Dativ) إلى فعل متعدٍ لمفعول به صريح مباشر بالنصب (bearbeiten + Akkusativ: das Werkstück).',
        grammaticalAnalysisGerman:
            'Transitivierungspräfix "be-" eliminiert die Präposition "an" und hebt das vormalige Präpositionalobjekt auf die Stufe des direkten Akkusativobjekts.',
        valenceTransformationFormula:
            'Subjekt + arbeitet an + Dativ  -->  Subjekt + bearbeitet + Akkusativ',
        diagnosticTrapWarning:
            'Häufiger Fehler: Beibehaltung der Präposition (*bearbeitet an dem Werkstück ist grob fehlerhaft!).',
      ),
    );

    // 2. be-: antworten auf (Akk) -> beantworten (+ Akk) - Aerospace Aviation
    _catalog.add(
      const PrefixAlternationModel(
        id: 'PREF-BE-ANTWORTEN-02',
        prefix: InseparablePrefix.be,
        semanticFunction: PrefixSemanticFunction.transitivizingDirectObject,
        alternationType: ValenceAlternationType.prepositionalToDirectAccusative,
        baseVerbPhrase: 'antworten auf + Akkusativ',
        prefixedVerb: 'beantworten + Akkusativ',
        governingCase: 'Akkusativ (ohne Präposition)',
        domain: CommunicativeDomain.aerospaceAndAviation,
        sampleSentence:
            'Der Fluglotse beantwortete den Notruf der Frachtmaschine binnen drei Sekunden.',
        arabicTranslation:
            'أجاب مراقب الملاحة الجوية على نداء الاستغاثة الصادر عن طائرة الشحن في غضون ثلاث ثوانٍ.',
        grammaticalAnalysisArabic:
            'التحول التعديي بـ be-: يتحول الفعل من "antworten auf + Akk" إلى "beantworten + Akk" مباشرة دون حرف الجر auf.',
        grammaticalAnalysisGerman:
            '"beantworten" regiert zwingend das direkte Akkusativobjekt ("den Notruf"). Die Fügung "*beantworten auf" ist ein schwerer Grammatikfehler.',
        valenceTransformationFormula:
            'Subjekt + antwortet auf + Akkusativ  -->  Subjekt + beantwortet + Akkusativ',
        diagnosticTrapWarning:
            'Todesfalle für Deutschlerner: "*Er beantwortet auf meine Frage" statt "Er beantwortet meine Frage".',
      ),
    );

    // 3. be-: rechnen auf/mit -> berechnen (+ Akk) - Civil Infrastructure
    _catalog.add(
      const PrefixAlternationModel(
        id: 'PREF-BE-RECHNEN-03',
        prefix: InseparablePrefix.be,
        semanticFunction: PrefixSemanticFunction.transitivizingDirectObject,
        alternationType: ValenceAlternationType.prepositionalToDirectAccusative,
        baseVerbPhrase: 'rechnen mit + Dativ',
        prefixedVerb: 'berechnen + Akkusativ',
        governingCase: 'Akkusativ (ohne Präposition)',
        domain: CommunicativeDomain.civilInfrastructure,
        sampleSentence:
            'Die Statiksoftware berechnet die maximale Windlast des Brückenpfeilers unter Extrembedingungen.',
        arabicTranslation:
            'تحسب برمجية التحليل الإنشائي حمولة الرياح القصوى لدعامة الجسر تحت أقسى الظروف التشغيلية.',
        grammaticalAnalysisArabic:
            'التعدي المباشر: "berechnen" يتعدى للمفعول المنصوب الصريح (die maximale Windlast) بينما "rechnen mit" يحتاج إلى داتيف.',
        grammaticalAnalysisGerman:
            'Funktionale Valenzsteigerung: "rechnen mit" (Erwartung) vs. "berechnen" (exakte mathematische Ermittlung des Akkusativobjekts).',
        valenceTransformationFormula:
            'Subjekt + rechnet mit + Dativ  -->  Subjekt + berechnet + Akkusativ',
        diagnosticTrapWarning:
            'Verwechslung von "rechnen mit" (erwarten) und "berechnen" (kalkulieren).',
      ),
    );

    // 4. ent-: koppeln -> entkoppeln (+ Akk / von + Dat) - Renewable Energy
    _catalog.add(
      const PrefixAlternationModel(
        id: 'PREF-ENT-KOPPELN-04',
        prefix: InseparablePrefix.ent,
        semanticFunction: PrefixSemanticFunction.privativeRemoval,
        alternationType: ValenceAlternationType.intransitiveToTransitive,
        baseVerbPhrase: 'koppeln an + Akkusativ',
        prefixedVerb: 'entkoppeln + Akkusativ (von + Dativ)',
        governingCase: 'Akkusativ (optional mit von + Dativ)',
        domain: CommunicativeDomain.renewableEnergyGrid,
        sampleSentence:
            'Bei einer Netzfrequenzstörung entkoppelt der Schutzschalter den Solarpark automatisch vom Übertragungsnetz.',
        arabicTranslation:
            'عند حدوث اضطراب في تردد الشبكة، يفصل قاطع الحماية محطة الطاقة الشمسية تلقائياً عن شبكة النقل.',
        grammaticalAnalysisArabic:
            'أثر اللاحقة السالبة "ent-": تفيد الإلغاء والفصل التام للعلاقة السابقة (koppeln = ربط، entkoppeln = فصل وفك الارتباط).',
        grammaticalAnalysisGerman:
            'Privatives Präfix "ent-" kehrt die Bedeutung des Verbs um (Separierung, Lösung einer physischen oder funktionalen Verbindung).',
        valenceTransformationFormula:
            'koppeln an + Akk  -->  entkoppeln (+ Akk) von + Dativ',
        diagnosticTrapWarning:
            'Präpositionenwechsel: "koppeln an" verlangt nach Entkopplung zwingend die Separationspräposition "von + Dativ".',
      ),
    );

    // 5. ent-: lüften -> entlüften (+ Akk) - Industrial Robotics
    _catalog.add(
      const PrefixAlternationModel(
        id: 'PREF-ENT-LUEFTEN-05',
        prefix: InseparablePrefix.ent,
        semanticFunction: PrefixSemanticFunction.privativeRemoval,
        alternationType: ValenceAlternationType.intransitiveToTransitive,
        baseVerbPhrase: 'lüften (den Raum mit Luft füllen)',
        prefixedVerb: 'entlüften (eingeschlossene Luft entfernen)',
        governingCase: 'Akkusativ',
        domain: CommunicativeDomain.industrialRobotics,
        sampleSentence:
            'Vor der Inbetriebnahme muss der Wartungstechniker das Hydrauliksystem der Hebebühne vollständig entlüften.',
        arabicTranslation:
            'قبل بدء التشغيل، يجب على فني الصيانة تفريغ الهواء المحبوس بالكامل من المنظومة الهيدروليكية لمنصة الرفع.',
        grammaticalAnalysisArabic:
            'المعنى السالب الإزالي لـ ent-: في حين أن lüften تعني التهوية وإدخال الهواء، فإن entlüften تعني تفريغ الهواء المحبوس ونزعه.',
        grammaticalAnalysisGerman:
            'Semantische Antonymie durch "ent-": "lüften" (Zufuhr frischer Luft) vs. "entlüften" (Befreiung eines Rohrsystems von störenden Luftblasen).',
        valenceTransformationFormula:
            'lüften (+ Akk)  -->  entlüften (+ Akk: das System von Luft befreien)',
        diagnosticTrapWarning:
            'Katastrophaler technischer Bedeutungsunterschied: "lüften" vs. "entlüften".',
      ),
    );

    // 6. ent-: ziehen -> entziehen (Dativ + Akkusativ) - Material Science
    _catalog.add(
      const PrefixAlternationModel(
        id: 'PREF-ENT-ZIEHEN-06',
        prefix: InseparablePrefix.ent,
        semanticFunction: PrefixSemanticFunction.privativeRemoval,
        alternationType: ValenceAlternationType.dativeAblativeSource,
        baseVerbPhrase: 'ziehen aus + Dativ',
        prefixedVerb: 'entziehen + Dativ (Quelle) + Akkusativ (Objekt)',
        governingCase: 'Dativ (Ablativus) + Akkusativ',
        domain: CommunicativeDomain.materialScience,
        sampleSentence:
            'Die Vakuumtrocknungsanlage entzieht dem feuchten Granulat jegliche Restfeuchte.',
        arabicTranslation:
            'تسحب منظومة التجفيف بالتفريغ من الحبيبات الرطبة أي بقايا للرطوبة وتنزعها عنها.',
        grammaticalAnalysisArabic:
            'تعدي الفعل لمفعولين: المجرور بالداتيف يمثل المصدر المنزوع منه (dem Granulat)، والمنصوب بالأكوزاتيف يمثل الشيء المستخرج (Restfeuchte).',
        grammaticalAnalysisGerman:
            'Ditransitive Valenz mit Dativus Separativus / Ablativus ("dem Granulat") und Akkusativobjekt des entzogenen Stoffs ("Restfeuchte").',
        valenceTransformationFormula:
            'Subjekt + entzieht + [Dativ: Betroffener/Quelle] + [Akkusativ: Entzogenes Gut]',
        diagnosticTrapWarning:
            'Weglassen des Dativs oder falscher Präpositionaleinschub (*entzieht von dem Granulat ist unidiomatisch).',
      ),
    );

    // 7. zer-: reißen -> zerreißen (+ Akk) - Material Science
    _catalog.add(
      const PrefixAlternationModel(
        id: 'PREF-ZER-REISSEN-07',
        prefix: InseparablePrefix.zer,
        semanticFunction: PrefixSemanticFunction.destructiveDispersion,
        alternationType: ValenceAlternationType.intransitiveToTransitive,
        baseVerbPhrase: 'reißen (einen Riss bekommen)',
        prefixedVerb: 'zerreißen (vollständig in Stücke reißen)',
        governingCase: 'Akkusativ',
        domain: CommunicativeDomain.materialScience,
        sampleSentence:
            'Die enorme Zugspannung zerriss das Kohlenstofffaserband während des Zerreißtests in zahllose Einzelfasern.',
        arabicTranslation:
            'مزق جهد الشد الهائل شريط ألياف الكربون أثناء اختبار الشد الميكانيكي إلى ألياف مفردة لا حصر لها وشظاه.',
        grammaticalAnalysisArabic:
            'أثر اللاحقة التفتيتية "zer-": تدل دائماً على التحول إلى أجزاء وشظايا ممزقة ومحطمة (التشظي الفيزيائي التام).',
        grammaticalAnalysisGerman:
            'Destruktions- und Resultativpräfix "zer-" signalisiert die Zerstörung der materiellen Integrität eines Objekts in Einzelteile.',
        valenceTransformationFormula:
            'etwas reißt (intransitiv)  -->  etwas zerreißt ein Objekt (transitiv)',
        diagnosticTrapWarning:
            'Präfix "zer-" trägt ausnahmslos eine destruktive, irreparable Ergebnisbedeutung.',
      ),
    );

    // 8. zer-: fallen -> zerfallen (in + Akk) - Renewable Energy
    _catalog.add(
      const PrefixAlternationModel(
        id: 'PREF-ZER-FALLEN-08',
        prefix: InseparablePrefix.zer,
        semanticFunction: PrefixSemanticFunction.destructiveDispersion,
        alternationType: ValenceAlternationType.intransitiveToTransitive,
        baseVerbPhrase: 'fallen (gravitative Bewegung)',
        prefixedVerb: 'zerfallen in + Akkusativ',
        governingCase: 'in + Akkusativ (Resultat)',
        domain: CommunicativeDomain.renewableEnergyGrid,
        sampleSentence:
            'Das instabile Isotop zerfällt unter Freisetzung hochenergetischer Strahlung in zwei leichtere Atomkerne.',
        arabicTranslation:
            'يتفكك النظير غير المستقر ويتحلل، مع تحرير إشعاع عالي الطاقة، إلى نواتين ذريتين أخف وزناً.',
        grammaticalAnalysisArabic:
            'الانحلال والتفكك بـ zer-: ينتقل المعنى من مجرد السقوط الفيزيائي (fallen) إلى الانحلال والتفتت النووي أو الكيميائي (zerfallen).',
        grammaticalAnalysisGerman:
            'Intransitives Zerfallsverb mit Präposition "in" + Akkusativ zur Angabe der resultierenden Bruchstücke.',
        valenceTransformationFormula:
            'fallen (Bewegungsverb)  -->  zerfallen in + Akk (radioaktiver/chemischer Zerfall)',
        diagnosticTrapWarning:
            'Perfektbildung mit "sein" ("ist zerfallen", niemals "*hat zerfallen").',
      ),
    );

    // 9. ver-: flüssig -> verflüssigen (+ Akk) - Aerospace Aviation
    _catalog.add(
      const PrefixAlternationModel(
        id: 'PREF-VER-FLUESSIG-09',
        prefix: InseparablePrefix.ver,
        semanticFunction: PrefixSemanticFunction.transformativeTelic,
        alternationType: ValenceAlternationType.intransitiveToTransitive,
        baseVerbPhrase: 'flüssig sein/werden',
        prefixedVerb: 'verflüssigen + Akkusativ',
        governingCase: 'Akkusativ',
        domain: CommunicativeDomain.aerospaceAndAviation,
        sampleSentence:
            'Die Tieftemperatur-Kühlanlage verflüssigt den gasförmigen Wasserstoff bei minus 253 Grad Celsius.',
        arabicTranslation:
            'تقوم منظومة التبريد فائق الانخفاض بإسالة وتسييل غاز الهيدروجين عند درجة حرارة ناقص 253 مئوية.',
        grammaticalAnalysisArabic:
            'التحول الصيروري التام بـ ver-: تحويل الصفة (flüssig) إلى فعل متعدٍ تام يفيد إحداث التحول الفيزيائي في المادة (verflüssigen).',
        grammaticalAnalysisGerman:
            'Faktitives / kausatives Präfix "ver-" leitet von Adjektiven Verben ab, die das Herbeiführen dieses Zustands bedeuten.',
        valenceTransformationFormula:
            'flüssig machen  -->  verflüssigen + Akkusativ',
        diagnosticTrapWarning:
            'Sehr produktives Muster: verflüssigen, verfestigen, verdichten, verfeinern, verstärken.',
      ),
    );

    // 10. ver-: sich verrechnen (Error/Mistake) - Civil Infrastructure
    _catalog.add(
      const PrefixAlternationModel(
        id: 'PREF-VER-FEHLER-10',
        prefix: InseparablePrefix.ver,
        semanticFunction: PrefixSemanticFunction.errorPejorative,
        alternationType: ValenceAlternationType.reflexiveErrorShift,
        baseVerbPhrase: 'rechnen (kalkulieren)',
        prefixedVerb: 'sich verrechnen (einen Rechenfehler machen)',
        governingCase: 'Reflexivpronomen im Akkusativ',
        domain: CommunicativeDomain.civilInfrastructure,
        sampleSentence:
            'Hätte sich der Statiker bei der Spannungsberechnung nur um zwei Prozent verrechnet, wäre der Einsturz unvermeidbar gewesen.',
        arabicTranslation:
            'لو أن المهندس الإنشائي أخطأ وسها في حسابات الإجهاد بنسبة اثنين بالمائة فقط، لكان الانهيار أمراً لا مفر منه.',
        grammaticalAnalysisArabic:
            'دلالة الخطأ والسهو في الأفعال الانعكاسية بـ ver-: "sich verrechnen" تعني الوقوع في خطأ حسابي سهواً دون قصد.',
        grammaticalAnalysisGerman:
            'Reflexives Pejorativpräfix "sich ver-": Indiziert eine unabsichtliche Fehlleistung (sich verfahren, sich verschreiben, sich verrechnen).',
        valenceTransformationFormula:
            'rechnen (objektiv kalkulieren)  -->  sich verrechnen (einen Fehler begehen)',
        diagnosticTrapWarning:
            'Niemals transitiv gebrauchen: "*Er hat die Zahlen verrechnet" ist falsch; zwingend reflexiv: "Er hat sich verrechnet".',
      ),
    );

    // 11. er-: arbeiten -> erarbeiten (+ Akk) - Software Architecture
    _catalog.add(
      const PrefixAlternationModel(
        id: 'PREF-ER-ARBEITEN-11',
        prefix: InseparablePrefix.er,
        semanticFunction: PrefixSemanticFunction.acquisitionByEffort,
        alternationType: ValenceAlternationType.intransitiveToTransitive,
        baseVerbPhrase: 'arbeiten an + Dativ',
        prefixedVerb: 'erarbeiten + Akkusativ',
        governingCase: 'Akkusativ',
        domain: CommunicativeDomain.softwareEngineering,
        sampleSentence:
            'Das Entwicklerteam erarbeitete in dreimonatiger Klausur eine völlig neue Microservice-Architektur.',
        arabicTranslation:
            'توصل فريق المطورين بعد عمل دؤوب استمر ثلاثة أشهر إلى وضع معمارية خدمات مصغرة جديدة بالكامل وصياغتها.',
        grammaticalAnalysisArabic:
            'أثر اللاحقة "er-": تفيد التوصل إلى النتيجة الملموسة وبلوغ الهدف النهائي بفضل بذل الجهد والمثابرة (erarbeiten).',
        grammaticalAnalysisGerman:
            'Resultatives Präfix "er-" markiert den erfolgreichen Abschluss eines intensiven Arbeitsprozesses mit messbarem Resultat.',
        valenceTransformationFormula:
            'arbeiten an + Dativ  -->  erarbeiten + Akkusativ (fertiges Produkt)',
        diagnosticTrapWarning:
            'Unterschied: "an einer Lösung arbeiten" (Prozess) vs. "eine Lösung erarbeiten" (abgeschlossenes Ergebnis).',
      ),
    );

    // 12. er-: zeugen -> erzeugen (+ Akk) - Renewable Energy
    _catalog.add(
      const PrefixAlternationModel(
        id: 'PREF-ER-ZEUGEN-12',
        prefix: InseparablePrefix.er,
        semanticFunction: PrefixSemanticFunction.acquisitionByEffort,
        alternationType: ValenceAlternationType.intransitiveToTransitive,
        baseVerbPhrase: 'zeugen von + Dativ (Zeugnis ablegen)',
        prefixedVerb: 'erzeugen + Akkusativ (produzieren/generieren)',
        governingCase: 'Akkusativ',
        domain: CommunicativeDomain.renewableEnergyGrid,
        sampleSentence:
            'Die Photovoltaikanlage erzeugt an sonnigen Tagen mehr elektrische Energie als die gesamte Werkssiedlung verbraucht.',
        arabicTranslation:
            'تولد وتنتج محطة الطاقة الكهروضوئية في الأيام المشمسة طاقة كهربائية تفوق ما يستهلكه المجمع الصناعي بأكمله.',
        grammaticalAnalysisArabic:
            'التوليد والإنتاج بـ er-: تحول الفعل من "zeugen von" (يدل على / يشهد بـ) إلى "erzeugen" (يولد وينتج طاقة أو منتجاً).',
        grammaticalAnalysisGerman:
            'Kausativ-produktives Präfix "er-": Aus dem bezeugenden Stamm "zeugen" wird das technische Schlüsselverb "erzeugen" (generieren).',
        valenceTransformationFormula:
            'zeugen von + Dat  -->  erzeugen + Akkusativ (Energie/Strom)',
        diagnosticTrapWarning:
            'Kardinale Bedeutungsdiskrepanz: "zeugen von" (bezeugen) vs. "erzeugen" (herstellen).',
      ),
    );

    // 13. miss-: verstehen -> missverstehen (+ Akk) - Maritime Logistics
    _catalog.add(
      const PrefixAlternationModel(
        id: 'PREF-MISS-VERSTEHEN-13',
        prefix: InseparablePrefix.miss,
        semanticFunction: PrefixSemanticFunction.negativeDistortion,
        alternationType: ValenceAlternationType.intransitiveToTransitive,
        baseVerbPhrase: 'verstehen + Akkusativ',
        prefixedVerb: 'missverstehen + Akkusativ',
        governingCase: 'Akkusativ',
        domain: CommunicativeDomain.maritimeLogistics,
        sampleSentence:
            'Der Zweite Offizier missverstand den Funkspruch des Hafenlotsen über die geforderte Schlepperunterstützung.',
        arabicTranslation:
            'أساء الضابط الثاني فهم الرسالة اللاسلكية الواردة من مرشد الميناء بشأن الدعم المطلوب من قوارب القطر.',
        grammaticalAnalysisArabic:
            'اللاحقة السالبة "miss-": تفيد الانحراف والوقوع في الفهم الخاطئ المعاكس للمراد الأصلي (missverstehen).',
        grammaticalAnalysisGerman:
            'Pejoratives Negationspräfix "miss-": Verkehrt das Verstehen in eine inkorrekte Interpretation.',
        valenceTransformationFormula:
            'verstehen + Akk  -->  missverstehen + Akk (falsch interpretieren)',
        diagnosticTrapWarning:
            'Untrennbar: Partizip II lautet "missverstanden" (ohne ge-!).',
      ),
    );

    // 14. miss-: achten -> missachten (+ Akk) - Civil Infrastructure
    _catalog.add(
      const PrefixAlternationModel(
        id: 'PREF-MISS-ACHTEN-14',
        prefix: InseparablePrefix.miss,
        semanticFunction: PrefixSemanticFunction.negativeDistortion,
        alternationType: ValenceAlternationType.prepositionalToDirectAccusative,
        baseVerbPhrase: 'achten auf + Akkusativ',
        prefixedVerb: 'missachten + Akkusativ',
        governingCase: 'Akkusativ',
        domain: CommunicativeDomain.civilInfrastructure,
        sampleSentence:
            'Wer die vorgeschriebenen Aushärtungszeiten des Spezialbetons missachtet, gefährdet die statische Gesamtstabilität.',
        arabicTranslation:
            'من يتجاهل فترات التصلب المقررة للخرسانة الخاصة ولا يراعيها، فإنه يعرض الاستقرار الإنشائي الكلي للخطر.',
        grammaticalAnalysisArabic:
            'تحول المعنى من المراعاة والانتباه (achten auf + Akk) إلى التجاهل والمخالفة المتعمدة (missachten + Akk).',
        grammaticalAnalysisGerman:
            'Antonymbildung zu "beachten": "achten auf" wird durch "missachten" zum transitiven Verb mit der Bedeutung "vorsätzlich ignorieren".',
        valenceTransformationFormula:
            'achten auf + Akk  -->  missachten + Akk (nicht beachten)',
        diagnosticTrapWarning:
            'Partizip II heißt "missachtet" (niemals "*gemissachtet").',
      ),
    );

    // 15. be-: treten auf -> betreten (+ Akk) - Industrial Robotics
    _catalog.add(
      const PrefixAlternationModel(
        id: 'PREF-BE-TRETEN-15',
        prefix: InseparablePrefix.be,
        semanticFunction: PrefixSemanticFunction.transitivizingDirectObject,
        alternationType: ValenceAlternationType.prepositionalToDirectAccusative,
        baseVerbPhrase: 'treten in/auf + Akkusativ',
        prefixedVerb: 'betreten + Akkusativ',
        governingCase: 'Akkusativ (ohne Präposition)',
        domain: CommunicativeDomain.industrialRobotics,
        sampleSentence:
            'Unbefugtes Personal darf den abgesicherten Schwenkbereich des Schweißroboters unter keinen Umständen betreten.',
        arabicTranslation:
            'يُحظر على الأفراد غير المصرح لهم دخول نطاق الحركة والدوران المؤمن لروبوت اللحام تحت أي ظرف من الظروف.',
        grammaticalAnalysisArabic:
            'تعدية بـ be-: يتحول الفعل من "treten in + Akk" إلى "betreten + Akk" مباشرة دون أي حرف جر.',
        grammaticalAnalysisGerman:
            '"betreten" ist zwingend transitiv: "den Schwenkbereich betreten". Die Formulierung "*in den Bereich betreten" ist ungrammatisch.',
        valenceTransformationFormula:
            'treten in + Akkusativ  -->  betreten + Akkusativ',
        diagnosticTrapWarning:
            'Klassischer Fehler: Fälschliches Mitziehen der Präposition (*in den Raum betreten).',
      ),
    );

    // 16. ver-: dichten -> verdichten (+ Akk) - Aerospace Aviation
    _catalog.add(
      const PrefixAlternationModel(
        id: 'PREF-VER-DICHTEN-16',
        prefix: InseparablePrefix.ver,
        semanticFunction: PrefixSemanticFunction.transformativeTelic,
        alternationType: ValenceAlternationType.intransitiveToTransitive,
        baseVerbPhrase: 'dicht sein/machen',
        prefixedVerb: 'verdichten + Akkusativ',
        governingCase: 'Akkusativ',
        domain: CommunicativeDomain.aerospaceAndAviation,
        sampleSentence:
            'Der mehrstufige Axialkompressor verdichtet die angesaugte Luft vor dem Eintritt in die Brennkammer um das Dreißigfache.',
        arabicTranslation:
            'يقوم الضاغط المحوري متعدد المراحل بضغط الهواء المسحوب وتكثيفه ثلاثين ضعفاً قبل دخوله إلى غرفة الاحتراق.',
        grammaticalAnalysisArabic:
            'فعل صيروري تحويلي بـ ver-: تحويل الهواء إلى حالة عالية الكثافة والضغط (verdichten + Akkusativ: die Luft).',
        grammaticalAnalysisGerman:
            'Faktitives Verb der Druck- und Dichteerhöhung. Das physikalische Akkusativobjekt "die angesaugte Luft" erfährt die Modifikation.',
        valenceTransformationFormula:
            'dicht machen  -->  verdichten + Akkusativ',
        diagnosticTrapWarning:
            'Unterscheidung zu "abdichten" (versiegeln gegen Austritt) vs. "verdichten" (Druck/Dichte erhöhen).',
      ),
    );
  }

  /// Evaluates an input sentence for correct prefix verb valence and redundant preposition pitfalls.
  PrefixTransitivityValidationReport validateVerbTransitivity({
    required InseparablePrefix prefix,
    required String prefixVerb,
    required bool containsRedundantPreposition,
    required bool isCaseAccusativeForBe,
  }) {
    final issues = <String>[];
    final recommendations = <String>[];

    if (prefix == InseparablePrefix.be && containsRedundantPreposition) {
      issues.add(
        'Schwerer Rektionsfehler (Redundante Präposition): Das Präfixverb "$prefixVerb" ist durch "be-" transitiviert worden und regiert das direkte Akkusativobjekt. Präpositionen (wie auf, an, in) sind unzulässig.',
      );
      recommendations.add(
        'Streichen Sie die Präposition (z. B. "die Frage beantworten", nicht "*auf die Frage beantworten").',
      );
    }

    if (prefix == InseparablePrefix.be && !isCaseAccusativeForBe) {
      issues.add(
        'Falscher Kasus: Mit "be-" transitivierte Verben fordern zwingend den Akkusativ für das direkte Objekt.',
      );
      recommendations.add('Setzen Sie das Objekt in den Akkusativ.');
    }

    final isValid = issues.isEmpty;
    final verdict = isValid
        ? 'التركيب النحوي لتعدية الفعل المشتق بالسابقة سليم تماماً وخالٍ من حروف الجر الزائدة ومطابق لمعايير C1-C2.'
        : 'تم رصد خطأ في تعدية الفعل بالسابقة (استخدام حرف جر زائد مكرر أو خطأ في حالة النصب الصريح).';

    return PrefixTransitivityValidationReport(
      isValid: isValid,
      avoidsRedundantPreposition: !containsRedundantPreposition,
      isCaseGovernmentCorrect: isCaseAccusativeForBe,
      issues: issues,
      recommendations: recommendations,
      arabicDiagnosticVerdict: verdict,
    );
  }

  List<PrefixAlternationModel> filterByPrefix(InseparablePrefix prefix) {
    return _catalog.where((item) => item.prefix == prefix).toList();
  }

  List<PrefixAlternationModel> filterByDomain(CommunicativeDomain domain) {
    return _catalog.where((item) => item.domain == domain).toList();
  }
}
