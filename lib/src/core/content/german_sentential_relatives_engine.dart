import 'dart:collection';

/// Types of sentential relative clauses (Weiterführende Nebensätze) and neuter relatives.
enum SententialRelativeType {
  propositionalWas(
    'Satzbezogenes "was"',
    'الاسم الموصول المحيل على مضمون الجملة (was)',
    'Bezieht sich auf den gesamten vorangehenden Sachverhalt: ..., was uns sehr freute.',
  ),
  pronominalAdverbRelative(
    'Pronominaladverb (wo(r)- + Präposition)',
    'ظرف الوصل الضميري المقترن بحرف جر (worüber, worauf, womit)',
    'Ersetzt Präpositionalobjekt bezogen auf Sachverhalt: ..., worüber debattiert wurde.',
  ),
  causalConsecutiveRelative(
    'Kausal-konsekutives Satzrelativ (weswegen / weshalb)',
    'الوصل السببي-التعاقبي (weshalb, weswegen)',
    'Drückt logische Folge oder Ursache des Hauptsatzes aus: ..., weshalb die OP verschoben wurde.',
  ),
  indefiniteNeuterAntecedent(
    'Relativsatz nach unbestimmtem Neutrum (alles/nichts/etwas/Superlativ)',
    'صلة الموصول بعد الضمائر المحايدة المبهمة وأسماء التفضيل',
    'Bezieht sich auf alles, nichts, etwas, vieles, das Beste + was: Alles, was er sagte...',
  );

  final String germanTitle;
  final String arabicTitle;
  final String structuralDescription;
  const SententialRelativeType(
    this.germanTitle,
    this.arabicTitle,
    this.structuralDescription,
  );
}

/// Register / Stylistic level of the sentential construction.
enum LinguisticRegister {
  academic('Wissenschaftssprache', 'أكاديمي وبحثي'),
  medical('Medizinische Fachsprache', 'طبي وسريري'),
  legalAndAdministrative('Rechts- und Verwaltungssprache', 'قانوني وإداري'),
  businessProfessional('Gehobene Verhandlungssprache', 'مهني وتفاوضي'),
  elevatedStandard('Gehobene Standardsprache', 'فصيح راقٍ');

  final String de;
  final String ar;
  const LinguisticRegister(this.de, this.ar);
}

/// Structural model of a sentential relative construction.
class SententialRelativeModel {
  final String id;
  final String antecedentClause; // Der Bezugssatz / Sachverhalt
  final String relativeConnector; // was, worüber, weshalb, womit etc.
  final SententialRelativeType type;
  final LinguisticRegister register;
  final String relativeClause; // Der weiterführende Nebensatz mit Verb-Endstellung
  final String fullCombinedSentence;
  final String arabicTranslation;
  final String grammaticalAnalysisArabic;
  final String grammaticalAnalysisGerman;
  final bool allowsPrepositionalSplit; // e.g. "über was" (umgangssprachlich) vs "worüber" (standardsprachlich)
  final String prescriptiveNote;

  const SententialRelativeModel({
    required this.id,
    required this.antecedentClause,
    required this.relativeConnector,
    required this.type,
    required this.register,
    required this.relativeClause,
    required this.fullCombinedSentence,
    required this.arabicTranslation,
    required this.grammaticalAnalysisArabic,
    required this.grammaticalAnalysisGerman,
    required this.allowsPrepositionalSplit,
    required this.prescriptiveNote,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'antecedentClause': antecedentClause,
    'relativeConnector': relativeConnector,
    'type': type.name,
    'register': register.name,
    'relativeClause': relativeClause,
    'fullCombinedSentence': fullCombinedSentence,
    'arabicTranslation': arabicTranslation,
    'grammaticalAnalysisArabic': grammaticalAnalysisArabic,
    'grammaticalAnalysisGerman': grammaticalAnalysisGerman,
    'allowsPrepositionalSplit': allowsPrepositionalSplit,
    'prescriptiveNote': prescriptiveNote,
  };
}

/// Verification result for sentential relative validation.
class SententialValidationReport {
  final bool isValid;
  final bool verbInFinalPosition;
  final bool precededByComma;
  final bool correctConnectorUsed;
  final List<String> errorList;
  final List<String> stylisticAdvice;
  final String arabicSyntacticSummary;

  const SententialValidationReport({
    required this.isValid,
    required this.verbInFinalPosition,
    required this.precededByComma,
    required this.correctConnectorUsed,
    required this.errorList,
    required this.stylisticAdvice,
    required this.arabicSyntacticSummary,
  });
}

/// Comprehensive governance engine for German Sentential Relatives (Weiterführende Nebensätze).
class GermanSententialRelativesEngine {
  final List<SententialRelativeModel> _catalog = [];

  GermanSententialRelativesEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<SententialRelativeModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    // 1. Medical Clinical Context - Propositional "was"
    _catalog.add(
      const SententialRelativeModel(
        id: 'REL-MED-WAS-01',
        antecedentClause:
            'Die Vitalwerte des Patienten stabilisierten sich nach der Notoperation rasch',
        relativeConnector: 'was',
        type: SententialRelativeType.propositionalWas,
        register: LinguisticRegister.medical,
        relativeClause:
            'was das gesamte chirurgische Team sichtlich erleichterte',
        fullCombinedSentence:
            'Die Vitalwerte des Patienten stabilisierten sich nach der Notoperation rasch, was das gesamte chirurgische Team sichtlich erleichterte.',
        arabicTranslation:
            'استقرت المؤشرات الحيوية للمريض بسرعة بعد الجراحة الطارئة، الأمر الذي أراح الفريق الجراحي بأكمله بصورة جلية.',
        grammaticalAnalysisArabic:
            'جملة صلة موصول تعقيبية (Weiterführender Nebensatz): يعود اسم الموصول "was" على مضمون الجملة الرئيسية السابقة بالكامل، مع تصريف الفعل (erleichterte) في نهاية الجملة ووجوب الفصل بفاصلة.',
        grammaticalAnalysisGerman:
            'Satzbezogenes Relativpronomen "was" referiert auf den gesamten vorangehenden Hauptsatz. Feste Verb-Endstellung (erleichterte), obligatorisches Komma.',
        allowsPrepositionalSplit: false,
        prescriptiveNote:
            'Niemals "das" verwenden! Bezieht sich der Relativsatz auf einen ganzen Satzinhalt, ist ausschließlich "was" standardsprachlich korrekt.',
      ),
    );

    // 2. Engineering & Technical Precision - Pronominal Adverb "womit"
    _catalog.add(
      const SententialRelativeModel(
        id: 'REL-ENG-WOMIT-02',
        antecedentClause:
            'Das neue Kühlsystem reduziert den thermischen Energieverlust um 35 Prozent',
        relativeConnector: 'womit',
        type: SententialRelativeType.pronominalAdverbRelative,
        register: LinguisticRegister.academic,
        relativeClause:
            'womit die geforderten DIN-Emissionsstandards vorzeitig erfüllt werden',
        fullCombinedSentence:
            'Das neue Kühlsystem reduziert den thermischen Energieverlust um 35 Prozent, womit die geforderten DIN-Emissionsstandards vorzeitig erfüllt werden.',
        arabicTranslation:
            'يقلل نظام التبريد الجديد من فقدان الطاقة الحرارية بنسبة 35 بالمائة، وهو ما يحقق معايير الانبعاثات القياسية المحددة قبل موعدها.',
        grammaticalAnalysisArabic:
            'ظرف موصول ضميري (womit = mit + Sache): يعبر عن الواسطة أو الأداة المحققة للنتيجة في سياق هندسي دقيق، مع تقدم الفاعل وتأخر الفعل المركب المبني للمجهول إلى الختام.',
        grammaticalAnalysisGerman:
            'Pronominaladverb "womit" (präpositionales Relativum) bezieht sich instrumental auf den erzielten physikalischen Effekt. Passiv mit Endstellung "erfüllt werden".',
        allowsPrepositionalSplit: false,
        prescriptiveNote:
            'Die Zerlegung "*mit was" gilt in der Fach- und Wissenschaftssprache als stilistischer Fehler; zwingend "womit".',
      ),
    );

    // 3. Legal & Contractual Adjudication - Causal "weshalb"
    _catalog.add(
      const SententialRelativeModel(
        id: 'REL-JUR-WESHALB-03',
        antecedentClause:
            'Die beklagte Partei versäumte die gerichtlich gesetzte Frist zur Klageerwiderung',
        relativeConnector: 'weshalb',
        type: SententialRelativeType.causalConsecutiveRelative,
        register: LinguisticRegister.legalAndAdministrative,
        relativeClause:
            'weshalb das Versäumnisurteil antragsgemäß erlassen wurde',
        fullCombinedSentence:
            'Die beklagte Partei versäumte die gerichtlich gesetzte Frist zur Klageerwiderung, weshalb das Versäumnisurteil antragsgemäß erlassen wurde.',
        arabicTranslation:
            'تخلّف الطرف المدعى عليه عن الالتزام بالمهلة التي حددتها المحكمة للرد على الدعوى، ولذا صدر الحكم الغيابي وفقاً للطلب.',
        grammaticalAnalysisArabic:
            'جملة تعاقبية تعليلية بأداة الوصل (weshalb): تبين الأثر القضائي المترتب حتماً على إغفال الميعاد الإجرائي، والفعل المساعد في المركز الأخير.',
        grammaticalAnalysisGerman:
            'Kausal-konsekutives Satzrelativpronomen "weshalb". Leitet einen Nebensatz mit Endstellung des finiten Hilfsverbs "wurde" ein.',
        allowsPrepositionalSplit: false,
        prescriptiveNote:
            '"Weshalb" und "weswegen" sind im juristischen Kontext absolut synonym und verdeutlichen die Kausalitätskette.',
      ),
    );

    // 4. Commercial Negotiations - Pronominal Adverb "worüber"
    _catalog.add(
      const SententialRelativeModel(
        id: 'REL-BIZ-WORUEBER-04',
        antecedentClause:
            'Beide Delegationen einigten sich auf eine langfristige Verlängerung des Lieferabkommens',
        relativeConnector: 'worüber',
        type: SententialRelativeType.pronominalAdverbRelative,
        register: LinguisticRegister.businessProfessional,
        relativeClause:
            'worüber die beteiligten Gesellschafter zeitnah informiert werden',
        fullCombinedSentence:
            'Beide Delegationen einigten sich auf eine langfristige Verlängerung des Lieferabkommens, worüber die beteiligten Gesellschafter zeitnah informiert werden.',
        arabicTranslation:
            'اتفق الوفدان على تمديد طويل الأجل لاتفاقية التوريد، وهو الأمر الذي سيتم إخطار الشركاء المعنيين بشأنه في القريب العاجل.',
        grammaticalAnalysisArabic:
            'الظرف الموصول "worüber" (über + Akkusativ/Dativ) يربط الفعل (informieren über) بالموضوع المشترك الذي اتُفِق عليه في الصدر.',
        grammaticalAnalysisGerman:
            'Syntaktische Anknüpfung an das Rektionsverb "informieren über" mittels des Satzrelativs "worüber".',
        allowsPrepositionalSplit: false,
        prescriptiveNote:
            'Vermeidung von "*über was" im gehobenen Verhandlungston.',
      ),
    );

    // 5. Indefinite Neuter Antecedent - "alles, was"
    _catalog.add(
      const SententialRelativeModel(
        id: 'REL-INDEF-ALLES-05',
        antecedentClause:
            'Der Chefarzt dokumentierte gewissenhaft alles',
        relativeConnector: 'was',
        type: SententialRelativeType.indefiniteNeuterAntecedent,
        register: LinguisticRegister.medical,
        relativeClause:
            'was während der sechsstündigen Transplantation beobachtet wurde',
        fullCombinedSentence:
            'Der Chefarzt dokumentierte gewissenhaft alles, was während der sechsstündigen Transplantation beobachtet wurde.',
        arabicTranslation:
            'وثّق رئيس الأطباء بكل دقة وأمانة كل ما تم ملاحظته ومراقبته أثناء عملية زراعة الأعضاء التي استغرقت ست ساعات.',
        grammaticalAnalysisArabic:
            'اسم الموصول "was" إلزامي بعد الضمير المحايد المبهم "alles" (وكذلك nichts، etwas، vieles)، ويُمنع استخدام "das".',
        grammaticalAnalysisGerman:
            'Obligatorisches "was" nach substantiviertem Indefinitpronomen "alles". Stark fehleranfällig bei Deutschlernern (Vermeidung von "*alles, das").',
        allowsPrepositionalSplit: false,
        prescriptiveNote:
            'Kardinalregel: Nach alles, nichts, etwas, weniges, manches steht stets "was", niemals "das".',
      ),
    );

    // 6. Superlative Neuter Antecedent - "das Beste, was"
    _catalog.add(
      const SententialRelativeModel(
        id: 'REL-INDEF-SUPERL-06',
        antecedentClause:
            'Diese innovative Entsalzungstechnologie ist das Effizienteste',
        relativeConnector: 'was',
        type: SententialRelativeType.indefiniteNeuterAntecedent,
        register: LinguisticRegister.academic,
        relativeClause:
            'was die moderne Umwelttechnik in diesem Jahrzehnt hervorgebracht hat',
        fullCombinedSentence:
            'Diese innovative Entsalzungstechnologie ist das Effizienteste, was die moderne Umwelttechnik in diesem Jahrzehnt hervorgebracht hat.',
        arabicTranslation:
            'تُعد تقنية تحلية المياه المبتكرة هذه أكفأ ما أنتجته الهندسة البيئية الحديثة في هذا العقد.',
        grammaticalAnalysisArabic:
            'استعمال "was" كاسم موصول بعد اسم التفضيل المحايد المعرف المجرد (das Effizienteste)، مع وقوع الفعل المساعد في نهاية الجملة.',
        grammaticalAnalysisGerman:
            'Relativanschluss mit "was" nach nominalisiertem neutralen Superlativ ("das Effizienteste").',
        allowsPrepositionalSplit: false,
        prescriptiveNote:
            'Auch nach "das Erste", "das Einzige", "das Letzte" ist "was" stilistisch vorzuziehen.',
      ),
    );

    // 7. Academic Research - Pronominal Adverb "woraufhin"
    _catalog.add(
      const SententialRelativeModel(
        id: 'REL-ACAD-WORAUFHIN-07',
        antecedentClause:
            'Die Kontrollgruppe zeigte unerwartete immunologische Reaktionen',
        relativeConnector: 'woraufhin',
        type: SententialRelativeType.causalConsecutiveRelative,
        register: LinguisticRegister.academic,
        relativeClause:
            'woraufhin das Prüfprotokoll sofort angepasst werden musste',
        fullCombinedSentence:
            'Die Kontrollgruppe zeigte unerwartete immunologische Reaktionen, woraufhin das Prüfprotokoll sofort angepasst werden musste.',
        arabicTranslation:
            'أظهرت المجموعة الضابطة استجابات مناعية غير متوقعة، وعلى إثر ذلك كان لا بد من تعديل بروتوكول الاختبار فوراً.',
        grammaticalAnalysisArabic:
            'الأداة "woraufhin" تفيد التعاقب الزمني والسببي المباشر (على إثر ذلك / وبناء عليه)، مع حصر الفعل المشروط والناقص في آخر الترتيب.',
        grammaticalAnalysisGerman:
            'Temporo-kausales Satzrelativ "woraufhin". Leitet die unmittelbare methodische Folgereaktion im Forschungsprozess ein.',
        allowsPrepositionalSplit: false,
        prescriptiveNote:
            '"Woraufhin" verlangt ausnahmslos Nebensatz-Wortstellung mit Verb am Satzende.',
      ),
    );

    // 8. Public Infrastructure & Urban Planning - Pronominal Adverb "wozu"
    _catalog.add(
      const SententialRelativeModel(
        id: 'REL-INFRA-WOZU-08',
        antecedentClause:
            'Die Stadtverwaltung bewilligte zusätzliche Mittel für die Photovoltaikanlagen',
        relativeConnector: 'wozu',
        type: SententialRelativeType.pronominalAdverbRelative,
        register: LinguisticRegister.elevatedStandard,
        relativeClause:
            'wozu auch die Bereitstellung städtischer Dachflächen gehört',
        fullCombinedSentence:
            'Die Stadtverwaltung bewilligte zusätzliche Mittel für die Photovoltaikanlagen, wozu auch die Bereitstellung städtischer Dachflächen gehört.',
        arabicTranslation:
            'وافقت إدارة المدينة على مخصصات إضافية لمنظومات الطاقة الشمسية، وهو ما يندرج ضمنه أيضاً تخصيص أسطح المباني البلدية.',
        grammaticalAnalysisArabic:
            'استخدام "wozu" المترتب على الفعل التلازمي (gehören zu)، حيث يحل ظرف الوصل محل شبه الجملة المجرورة بحرف الجر zu.',
        grammaticalAnalysisGerman:
            'Pronominaladverbiales Relativum "wozu" gebunden an die Rektion des Verbs "gehören zu".',
        allowsPrepositionalSplit: false,
        prescriptiveNote:
            'Präpositionale Bindung bleibt intakt, der Nebensatz verhält sich wie ein weiterführender Attributsatz.',
      ),
    );

    // 9. Everyday High-Level Exchange - "woraus"
    _catalog.add(
      const SententialRelativeModel(
        id: 'REL-DAILY-WORAUS-09',
        antecedentClause:
            'Aus den vorliegenden Messdaten lassen sich klare Muster ableiten',
        relativeConnector: 'woraus',
        type: SententialRelativeType.pronominalAdverbRelative,
        register: LinguisticRegister.academic,
        relativeClause:
            'woraus wir wertvolle Erkenntnisse für die nächste Entwicklungsphase gewinnen können',
        fullCombinedSentence:
            'Aus den vorliegenden Messdaten lassen sich klare Muster ableiten, woraus wir wertvolle Erkenntnisse für die nächste Entwicklungsphase gewinnen können.',
        arabicTranslation:
            'من واقع بيانات القياس المتوفرة يمكن استنباط أنماط واضحة، وهو ما يتيح لنا استخلاص معارف قيّمة للمرحلة التطويرية القادمة.',
        grammaticalAnalysisArabic:
            'الأداة "woraus" (aus + Sachverhalt) تفيد الاستنتاج والاستخلاص المنطقي من المعطيات السابقة.',
        grammaticalAnalysisGerman:
            'Schlussfolgerndes Pronominaladverb "woraus" mit Modalverb "können" in Spitzen-Endstellung des Nebensatzes.',
        allowsPrepositionalSplit: false,
        prescriptiveNote:
            'Schafft elegante logische Kohäsion zwischen empirischen Befunden und Folgerungen.',
      ),
    );

    // 10. Medical Ethics & Patient Consent - "wogegen"
    _catalog.add(
      const SententialRelativeModel(
        id: 'REL-ETHIC-WOGEGEN-10',
        antecedentClause:
            'Der Patient lehnte die invasive Therapieform ausdrücklich und schriftlich ab',
        relativeConnector: 'wogegen',
        type: SententialRelativeType.pronominalAdverbRelative,
        register: LinguisticRegister.medical,
        relativeClause:
            'wogegen aus ärztlicher und ethischer Sicht keine Einwände erhoben wurden',
        fullCombinedSentence:
            'Der Patient lehnte die invasive Therapieform ausdrücklich und schriftlich ab, wogegen aus ärztlicher und ethischer Sicht keine Einwände erhoben wurden.',
        arabicTranslation:
            'رفض المريض صراحة وكتابياً خيار العلاج الجراحي التداخلي، وهو الأمر الذي لم يُبدِ حياله الأطباء أي اعتراض من منظور طبي وأخلاقي.',
        grammaticalAnalysisArabic:
            'الأداة "wogegen" تعبر عن الموقف المتقابل والمتعلق بالاعتراض (Einwände erheben gegen etw.).',
        grammaticalAnalysisGerman:
            'Gegenstandsorientiertes Relativadverb "wogegen", korrelierend mit dem Nomen-Verb-Gefüge "Einwände erheben gegen".',
        allowsPrepositionalSplit: false,
        prescriptiveNote:
            'Wahrung der Patientenautonomie im medizinrechtlichen Sprachduktus.',
      ),
    );

    // 11. Complex Multi-clause Academic Research - "was" with Infinitive construction
    _catalog.add(
      const SententialRelativeModel(
        id: 'REL-ACAD-INF-11',
        antecedentClause:
            'Die Forschergruppe konnte den Wirkstoff synthetisieren',
        relativeConnector: 'was',
        type: SententialRelativeType.propositionalWas,
        register: LinguisticRegister.academic,
        relativeClause:
            'was ihr ermöglichte, die klinischen Studien unverzüglich aufzunehmen',
        fullCombinedSentence:
            'Die Forschergruppe konnte den Wirkstoff synthetisieren, was ihr ermöglichte, die klinischen Studien unverzüglich aufzunehmen.',
        arabicTranslation:
            'تمكنت المجموعة البحثية من تخليق المادة الفعالة، الأمر الذي مكّنها من الشروع في الدراسات السريرية دون أي إبطاء.',
        grammaticalAnalysisArabic:
            'جملة صلة موصول بـ was متداخلة مع جملة مصدرية بـ zu (Infinitivsatz)، يربط بينهما الفعل المتعدي (ermöglichte).',
        grammaticalAnalysisGerman:
            'Satzbezogenes "was" fungiert als Subjekt des Nebensatzes und regiert einen nachgestellten Infinitivsatz mit "zu".',
        allowsPrepositionalSplit: false,
        prescriptiveNote:
            'Hervorragendes Beispiel für hypotaktische Satzarchitektur im wissenschaftlichen Diskurs.',
      ),
    );

    // 12. Corporate Strategy & Governance - "weswegen"
    _catalog.add(
      const SententialRelativeModel(
        id: 'REL-CORP-WESWEGEN-12',
        antecedentClause:
            'Der Aufsichtsrat votierte einstimmig für die Neuausrichtung der Unternehmensstrategie',
        relativeConnector: 'weswegen',
        type: SententialRelativeType.causalConsecutiveRelative,
        register: LinguisticRegister.businessProfessional,
        relativeClause:
            'weswegen im kommenden Quartal umfassende Umstrukturierungsmaßnahmen eingeleitet werden',
        fullCombinedSentence:
            'Der Aufsichtsrat votierte einstimmig für die Neuausrichtung der Unternehmensstrategie, weswegen im kommenden Quartal umfassende Umstrukturierungsmaßnahmen eingeleitet werden.',
        arabicTranslation:
            'صوّت مجلس الرقابة بالإجماع لصالح إعادة صياغة استراتيجية الشركة، ولذلك سيتم إطلاق إجراءات إعادة هيكلة شاملة في الربع القادم.',
        grammaticalAnalysisArabic:
            'أداة الوصل السببية "weswegen" توضح العلاقة الإلزامية بين قرار الحوكمة والتنفيذ العملي المباشر.',
        grammaticalAnalysisGerman:
            'Konsekutive Satzverknüpfung mittels "weswegen" bei institutionellen Beschlüssen.',
        allowsPrepositionalSplit: false,
        prescriptiveNote:
            'Zeigt hohe stilistische Reife gegenüber einfachen Parataxen mit "deshalb" oder "deswegen".',
      ),
    );
  }

  /// Evaluates an input sentence for proper sentential relative usage.
  SententialValidationReport validateSententialSentence({
    required String text,
    required String connectorUsed,
    required bool hasPrecedingComma,
    required bool finiteVerbAtEnd,
  }) {
    final errors = <String>[];
    final advice = <String>[];

    if (!hasPrecedingComma) {
      errors.add('Fehlendes Komma: Weiterführende Nebensätze müssen durch ein Komma vom Bezugssatz abgetrennt werden.');
    }

    if (!finiteVerbAtEnd) {
      errors.add('Falsche Wortstellung: Im weiterführenden Nebensatz muss das finite Verb zwingend an letzter Stelle stehen (Nebensatz-Topologie).');
    }

    // Common error check: using "das" instead of "was"
    if (connectorUsed.toLowerCase() == 'das') {
      errors.add('Fehlerhafter Konnektor: Wenn sich der Relativsatz auf einen ganzen Sachverhalt oder ein unbestimmtes Neutrum bezieht, ist "das" unzulässig; verwenden Sie "was".');
      advice.add('Ersetzen Sie "..., das uns freute" durch "..., was uns freute".');
    }

    // Checking split prepositions like "mit was" or "über was"
    if (connectorUsed.toLowerCase().startsWith('mit was') ||
        connectorUsed.toLowerCase().startsWith('über was') ||
        connectorUsed.toLowerCase().startsWith('für was')) {
      errors.add('Umgangssprachliche Zerlegung: In der Standardsprache muss das Pronominaladverb (womit, worüber, wofür) stehen.');
      advice.add('Verwenden Sie das geschlossene Pronominaladverb anstelle der analytischen Fügung.');
    }

    final isValid = errors.isEmpty;
    final arabicSummary = isValid
        ? 'التركيب النحوي لجملة الصلة التعقيبية متطابق تماماً مع معايير اللغة الألمانية الفصيحة (C1-C2).'
        : 'تم رصد مخالفات في موقع الفعل أو أداة الوصل أو علامات الترقيم في الجملة التعقيبية.';

    return SententialValidationReport(
      isValid: isValid,
      verbInFinalPosition: finiteVerbAtEnd,
      precededByComma: hasPrecedingComma,
      correctConnectorUsed: errors.where((e) => e.contains('Konnektor')).isEmpty,
      errorList: errors,
      stylisticAdvice: advice,
      arabicSyntacticSummary: arabicSummary,
    );
  }

  List<SententialRelativeModel> filterByType(SententialRelativeType type) {
    return _catalog.where((item) => item.type == type).toList();
  }

  List<SententialRelativeModel> filterByRegister(LinguisticRegister register) {
    return _catalog.where((item) => item.register == register).toList();
  }
}
