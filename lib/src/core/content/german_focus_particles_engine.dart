import 'dart:collection';

/// Classification of focus particles (Fokuspartikeln), scalar operators, and degree modifiers.
enum FocusParticleCategory {
  additiveScalar(
    'Additive Skalarpartikeln (sogar, selbst, auch)',
    'أدوات التركيز الإلحاقية التصاعدية (حتى، بالذات، أيضاً)',
    'Signalisiert den unerwarteten Einschluss eines Extremwerts auf einer Skala: Sogar der Chefingenieur...',
  ),
  restrictiveExclusive(
    'Restriktiv-exklusive Fokuspartikeln (nur, bloß, lediglich, einzig)',
    'أدوات القصر والحصر والاستثناء (فقط، فحسب، لا غير)',
    'Schließt alle Alternativen außerhalb des fokussierten Elements aus: nur dieses Modul, lediglich zwei Parameter',
  ),
  temporalScalarContrast(
    'Temporale Skalaroperatoren (erst vs. schon)',
    'المشغلات الزمنية المتقابلة (ليس قبل/فقط في وقت متأخر مقابل بالفعل/في وقت مبكر)',
    'Kardinaler Bedeutungsunterschied: "erst um 5 Uhr" (später als erwartet) vs. "schon um 5 Uhr" (früher als erwartet)',
  ),
  counterExpectationAdversative(
    'Kontra-erwartende Partikeln (ausgerechnet)',
    'أدوات معارضة التوقع والاستبعاد المفاجئ (من دون سائر الأمور / تحديداً في هذا الوقت)',
    'Hebt das am wenigsten erwartete Element hervor: Ausgerechnet während des Stresstests fiel der Server aus.',
  ),
  negativePolarityScalar(
    'Skalare Negationsoperatoren (geschweige denn, nicht einmal)',
    'أدوات التصعيد السلبي المشترطة للنفي السابق (ناهيك عن، فما بالك بـ، ولا حتى)',
    'Erfordert zwingend vorangehende Negation: Er konnte das Problem nicht lokalisieren, geschweige denn beheben.',
  ),
  evaluativeConcessive(
    'Konzessiv-evaluative Partikeln (immerhin, wenigstens, zumindest)',
    'أدوات التقييم الاستدراكي والحد الأدنى (على أية حال، على الأقل)',
    'Bewertet ein Teilergebnis positiv trotz bestehender Mängel: Immerhin läuft der Notstromgenerator stabil.',
  );

  final String germanTitle;
  final String arabicTitle;
  final String semanticFunction;
  const FocusParticleCategory(
    this.germanTitle,
    this.arabicTitle,
    this.semanticFunction,
  );
}

/// Syntactic scope (Skopus) of the focus particle.
enum FocusScopeType {
  subjectScope(
    'Subjektskopus (Fokus auf dem Satzsubjekt)',
    'التركيز على الفاعل حصراً',
  ),
  objectScope(
    'Objektskopus (Fokus auf dem Akkusativ/Dativobjekt)',
    'التركيز على المفعول به حصراً',
  ),
  adverbialScope(
    'Adverbialskopus (Fokus auf Zeit-, Orts- oder Artangabe)',
    'التركيز على الظرف أو شبه الجملة',
  ),
  predicateScope(
    'Prädikatsskopus (Fokus auf der verbalen Handlung)',
    'التركيز على الفعل والحدث بحد ذاته',
  ),
  sentenceScope(
    'Satzskopus (Fokus auf dem gesamten Sachverhalt)',
    'التركيز على مضمون الجملة ككل',
  );

  final String de;
  final String ar;
  const FocusScopeType(this.de, this.ar);
}

/// Communicative professional and engineering domains free of legal/medical liability.
enum CommunicativeDomain {
  renewableEnergyGrid('Erneuerbare Energien & Stromnetze', 'الطاقة المتجددة والشبكات الكهربائية'),
  aerospaceAndAviation('Luftfahrt & Flugbetriebssteuerung', 'الملاحة الجوية وعمليات الطيران'),
  industrialAutomation('Industrielle Fertigung & Roboterleittechnik', 'الأتمتة الصناعية وهندسة الروبوتات'),
  maritimeLogistics('Maritime Schifffahrt & Hafenumschlag', 'اللوجستيات البحرية والموانئ'),
  softwareEngineering('Softwarearchitektur & Verteilte Systeme', 'هندسة البرمجيات والأنظمة الموزعة'),
  professionalWorkplace('Betriebliche Zusammenarbeit & Instandhaltung', 'إدارة العمليات الميدانية والصيانة');

  final String de;
  final String ar;
  const CommunicativeDomain(this.de, this.ar);
}

/// Model of a focus particle construction with its scope and semantic nuances.
class FocusParticleModel {
  final String id;
  final String particle;
  final FocusParticleCategory category;
  final FocusScopeType scopeType;
  final String baseSentenceWithoutParticle;
  final String scopedSentence;
  final String focusedElement;
  final CommunicativeDomain domain;
  final String arabicTranslation;
  final String grammaticalAnalysisArabic;
  final String grammaticalAnalysisGerman;
  final String scopeShiftDemonstration;
  final String polarityRequirementNote;

  const FocusParticleModel({
    required this.id,
    required this.particle,
    required this.category,
    required this.scopeType,
    required this.baseSentenceWithoutParticle,
    required this.scopedSentence,
    required this.focusedElement,
    required this.domain,
    required this.arabicTranslation,
    required this.grammaticalAnalysisArabic,
    required this.grammaticalAnalysisGerman,
    required this.scopeShiftDemonstration,
    required this.polarityRequirementNote,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'particle': particle,
    'category': category.name,
    'scopeType': scopeType.name,
    'baseSentenceWithoutParticle': baseSentenceWithoutParticle,
    'scopedSentence': scopedSentence,
    'focusedElement': focusedElement,
    'domain': domain.name,
    'arabicTranslation': arabicTranslation,
    'grammaticalAnalysisArabic': grammaticalAnalysisArabic,
    'grammaticalAnalysisGerman': grammaticalAnalysisGerman,
    'scopeShiftDemonstration': scopeShiftDemonstration,
    'polarityRequirementNote': polarityRequirementNote,
  };
}

/// Verification report container for focus particle syntax and polarity agreement.
class FocusParticleValidationReport {
  final bool isValid;
  final bool respectsPolarityCondition;
  final bool isScopeAdjacencyCorrect;
  final List<String> issues;
  final List<String> recommendations;
  final String arabicDiagnosticVerdict;

  const FocusParticleValidationReport({
    required this.isValid,
    required this.respectsPolarityCondition,
    required this.isScopeAdjacencyCorrect,
    required this.issues,
    required this.recommendations,
    required this.arabicDiagnosticVerdict,
  });
}

/// Sovereign engine governing German Focus Particles, Scalar Operators & Scope Topography.
class GermanFocusParticlesEngine {
  final List<FocusParticleModel> _catalog = [];

  GermanFocusParticlesEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<FocusParticleModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    // 1. Additive Scalar: sogar (Focus on Subject) - Aerospace Engineering
    _catalog.add(
      const FocusParticleModel(
        id: 'FOC-SOGAR-SUBJ-01',
        particle: 'sogar',
        category: FocusParticleCategory.additiveScalar,
        scopeType: FocusScopeType.subjectScope,
        baseSentenceWithoutParticle:
            'Der Chefkonstrukteur überprüfte die aerodynamische Flügelkrümmung persönlich im Windkanal.',
        scopedSentence:
            'Sogar der Chefkonstrukteur überprüfte die aerodynamische Flügelkrümmung persönlich im Windkanal.',
        focusedElement: 'der Chefkonstrukteur (Subjekt)',
        domain: CommunicativeDomain.aerospaceAndAviation,
        arabicTranslation:
            'حتى كبير المصممين بنفسه قام بتدقيق الانحناء الإيروديناميكي للجناح شخصياً في نفق الرياح.',
        grammaticalAnalysisArabic:
            'أداة تركيز تصاعدية (sogar): تسبق الفاعل مباشرة لتسليط الضوء عليه كأقصى طرف غير متوقع على سلم المراتب، مما يضفي توكيداً بلاغياً قوياً.',
        grammaticalAnalysisGerman:
            'Additive Skalarpartikel "sogar" im Vorfeld unmittelbar vor dem fokussierten Subjektausdruck. Markiert einen unwahrscheinlichen Extremwert auf der Erwartungsskala.',
        scopeShiftDemonstration:
            'Verschiebung des Skopus: "Der Chefkonstrukteur überprüfte sogar DIE FLÜGELKRÜMMUNG..." (Fokus liegt dann auf dem Objekt statt auf der Person).',
        polarityRequirementNote:
            'Positiv polarisiert; verlangt keinen verneinten Vordersatz.',
      ),
    );

    // 2. Temporal Contrast: erst vs. schon (Late Expectation) - Renewable Energy
    _catalog.add(
      const FocusParticleModel(
        id: 'FOC-ERST-TIME-02',
        particle: 'erst',
        category: FocusParticleCategory.temporalScalarContrast,
        scopeType: FocusScopeType.adverbialScope,
        baseSentenceWithoutParticle:
            'Der Batteriespeicher speist um 18:00 Uhr Spitzenlasten in das Netz ein.',
        scopedSentence:
            'Der Batteriespeicher speist erst um 18:00 Uhr Spitzenlasten in das Netz ein.',
        focusedElement: 'um 18:00 Uhr (Temporalangabe)',
        domain: CommunicativeDomain.renewableEnergyGrid,
        arabicTranslation:
            'لا تضخ بطارية التخزين أحمال الذروة في الشبكة إلا عند الساعة السادسة مساءً (وليس قبل ذلك).',
        grammaticalAnalysisArabic:
            'المشغل الزمني التصاعدي "erst": يفيد أن الحدث لن يقع إلا في وقت متأخر نسبياً مقارنة بالتوقع (ليس قبل ذلك الوقت).',
        grammaticalAnalysisGerman:
            'Temporale Partikel "erst" markiert einen Zeitpunkt als relativ spät ("nicht früher als / erst zu diesem Zeitpunkt"). Kontrastiert mit "schon".',
        scopeShiftDemonstration:
            'Gegenüberstellung: "Der Speicher speist SCHON um 18:00 Uhr ein" bedeutet: unerwartet früh (bereits ab 18:00 Uhr).',
        polarityRequirementNote:
            'Im Deutschen ohne Negationspartikel formuliert, semantisch jedoch restriktiv-exklusiv ("nicht vor").',
      ),
    );

    // 3. Temporal Contrast: schon (Early Expectation) - Industrial Automation
    _catalog.add(
      const FocusParticleModel(
        id: 'FOC-SCHON-TIME-03',
        particle: 'schon',
        category: FocusParticleCategory.temporalScalarContrast,
        scopeType: FocusScopeType.adverbialScope,
        baseSentenceWithoutParticle:
            'Der Roboterarm beendete die Schweißnaht nach vierzig Sekunden.',
        scopedSentence:
            'Der Roboterarm beendete die Schweißnaht schon nach vierzig Sekunden.',
        focusedElement: 'nach vierzig Sekunden (Zeitdauer)',
        domain: CommunicativeDomain.industrialAutomation,
        arabicTranslation:
            'أنهى ذراع الروبوت إنجاز وصلة اللحام في غضون أربعين ثانية فقط (بوقت مبكر لافت قبل الموعد المتوقع).',
        grammaticalAnalysisArabic:
            'المشغل الزمني "schon": يدل على السبق والتبكير وتحقيق النتيجة بأسرع من المتوقع، وهو نقيض erst تماماً.',
        grammaticalAnalysisGerman:
            'Temporale Partikel "schon" indiziert das Eintreffen eines Ereignisses vor dem erwarteten Schwellenwert ("bereits").',
        scopeShiftDemonstration:
            'Gegenüberstellung: "ERST nach vierzig Sekunden" würde bedeuten: unangemessen spät / verzögert.',
        polarityRequirementNote:
            'Positive Temporalpolarität.',
      ),
    );

    // 4. Counter-Expectation: ausgerechnet - Software Engineering
    _catalog.add(
      const FocusParticleModel(
        id: 'FOC-AUSGERECHNET-04',
        particle: 'ausgerechnet',
        category: FocusParticleCategory.counterExpectationAdversative,
        scopeType: FocusScopeType.adverbialScope,
        baseSentenceWithoutParticle:
            'Während des weltweiten Rollouts traten Speicherlecks im Backend auf.',
        scopedSentence:
            'Ausgerechnet während des weltweiten Rollouts traten Speicherlecks im Backend auf.',
        focusedElement: 'während des weltweiten Rollouts (Situativer Kontext)',
        domain: CommunicativeDomain.softwareEngineering,
        arabicTranslation:
            'من دون سائر الأوقات وتحديداً أثناء مرحلة الإطلاق العالمي، طرأت تسريبات في الذاكرة بالخلفية البرمجية.',
        grammaticalAnalysisArabic:
            'أداة معارضة التوقع (ausgerechnet): تفيد أن وقوع الأمر في هذا التوقيت بالذات هو أكثر ما كان يُرجى تفاديه ومفاجئاً للمتكلم.',
        grammaticalAnalysisGerman:
            'Kontra-erwartende Fokuspartikel "ausgerechnet". Betont das Zusammentreffen mit dem denkbar ungünstigsten Umstand.',
        scopeShiftDemonstration:
            'Bei Personenbezug: "Ausgerechnet DER LEITENDE ENTWICKLER übersah den Fehler..." (Fokus auf der Person).',
        polarityRequirementNote:
            'Drückt Sprechereinstellung und emotionale Kontrastierung aus.',
      ),
    );

    // 5. Negative Polarity Scalar: geschweige denn - Aviation Operations
    _catalog.add(
      const FocusParticleModel(
        id: 'FOC-GESCHWEIGE-05',
        particle: 'geschweige denn',
        category: FocusParticleCategory.negativePolarityScalar,
        scopeType: FocusScopeType.predicateScope,
        baseSentenceWithoutParticle:
            'Das defekte Frachtflugzeug konnte bei diesem Orkan nicht einmal die Triebwerke starten.',
        scopedSentence:
            'Das defekte Frachtflugzeug konnte bei diesem Orkan nicht einmal die Triebwerke starten, geschweige denn einen sicheren Start durchführen.',
        focusedElement: 'einen sicheren Start durchführen (Höherwertige Anschlussaktion)',
        domain: CommunicativeDomain.aerospaceAndAviation,
        arabicTranslation:
            'لم تتمكن طائرة الشحن المعطلة في ظل هذا الإعصار حتى من تشغيل محركاتها، ناهيك عن الإقلاع بأمان (فما بالك بتنفيذ إقلاع آمن).',
        grammaticalAnalysisArabic:
            'رابط التصعيد السلبي المشروط (geschweige denn): يلزم أن تسبقه جملة منفية (nicht / kein / nicht einmal) لبيان امتناع الأمر الأكبر من باب أولى.',
        grammaticalAnalysisGerman:
            'Negationssensitiver Skalaroperator "geschweige denn". Erfordert zwingend eine vorangehende syntaktische Negation im Erstglied.',
        scopeShiftDemonstration:
            'Syntaktischer Fehler ohne Negation: "*Das Flugzeug startete die Triebwerke, geschweige denn hob es ab" ist grob ungrammatisch.',
        polarityRequirementNote:
            'Strikte Lizenzierung durch Negation (Negative Polarity Item - NPI).',
      ),
    );

    // 6. Restrictive Exclusive: nur (Object Scope vs. Predicate Scope) - Maritime Logistics
    _catalog.add(
      const FocusParticleModel(
        id: 'FOC-NUR-OBJ-06',
        particle: 'nur',
        category: FocusParticleCategory.restrictiveExclusive,
        scopeType: FocusScopeType.objectScope,
        baseSentenceWithoutParticle:
            'Die Terminalleitung fertigt Gefahrgutcontainer an Liegeplatz 3 ab.',
        scopedSentence:
            'Die Terminalleitung fertigt nur Gefahrgutcontainer an Liegeplatz 3 ab.',
        focusedElement: 'Gefahrgutcontainer (Akkusativobjekt)',
        domain: CommunicativeDomain.maritimeLogistics,
        arabicTranslation:
            'تتولى إدارة المحطة تفريغ ومعاملة حاويات المواد الخطرة فقط (دون غيرها من الحاويات) على الرصيف رقم 3.',
        grammaticalAnalysisArabic:
            'أداة القصر والحصر (nur): تسبق المفعول به مباشرة لقصر التفريغ على هذا النوع من الحاويات واستبعاد سائر البضائع.',
        grammaticalAnalysisGerman:
            'Restriktivpartikel "nur" direkt vor dem Akkusativobjekt grenzt die Handlung strikt auf diese Entität ein.',
        scopeShiftDemonstration:
            'Skopuswechsel: "Die Terminalleitung fertigt Gefahrgutcontainer nur AN LIEGEPLATZ 3 ab" (Ortseinschränkung statt Warentyp).',
        polarityRequirementNote:
            'Exklusiv-kontrastive Funktion.',
      ),
    );

    // 7. Negative Polarity Scalar: nicht einmal (Minimal Scalar Step) - Renewable Energy
    _catalog.add(
      const FocusParticleModel(
        id: 'FOC-NICHT-EINMAL-07',
        particle: 'nicht einmal',
        category: FocusParticleCategory.negativePolarityScalar,
        scopeType: FocusScopeType.subjectScope,
        baseSentenceWithoutParticle:
            'Die Backup-Stromversorgung überstand den dreiminütigen Netzausfall.',
        scopedSentence:
            'Nicht einmal die redundante Backup-Stromversorgung überstand den dreiminütigen Netzausfall.',
        focusedElement: 'die redundante Backup-Stromversorgung (Subjekt)',
        domain: CommunicativeDomain.renewableEnergyGrid,
        arabicTranslation:
            'ولا حتى منظومة التغذية الكهربائية الاحتياطية المكررة صمدت أمام انقطاع الشبكة الذي دام ثلاث دقائق.',
        grammaticalAnalysisArabic:
            'أداة التركيز السلبية للحد الأدنى (nicht einmal): تفيد فشل العنصر الأقوى والأكثر تحصيناً، فما دونه أولى بالفشل.',
        grammaticalAnalysisGerman:
            'Skalare Untergrenzenpartikel "nicht einmal" im Vorfeld vor dem fokussierten Subjekt zur Verdeutlichung extremer Systembelastung.',
        scopeShiftDemonstration:
            'Kann im Mittelfeld stehen: "Das System aktivierte nicht einmal DIE WARNSIGNALE."',
        polarityRequirementNote:
            'Inkorporiert die Negationspartikel "nicht".',
      ),
    );

    // 8. Evaluative Concessive: immerhin (Partial Positive Evaluation) - Professional Workplace
    _catalog.add(
      const FocusParticleModel(
        id: 'FOC-IMMERHIN-08',
        particle: 'immerhin',
        category: FocusParticleCategory.evaluativeConcessive,
        scopeType: FocusScopeType.sentenceScope,
        baseSentenceWithoutParticle:
            'Die Notfallpumpen konnten das Eindringen von Kühlwasser in die Steuerungseinheit verhindern.',
        scopedSentence:
            'Immerhin konnten die Notfallpumpen das Eindringen von Kühlwasser in die Steuerungseinheit verhindern.',
        focusedElement: 'Gesamter Teilerfolg (Satzskopus)',
        domain: CommunicativeDomain.professionalWorkplace,
        arabicTranslation:
            'على أية حال، وعلى الأقل، استطاعت مضخات الطوارئ منع تسرب مياه التبريد إلى وحدة التحكم.',
        grammaticalAnalysisArabic:
            'أداة التقييم الاستدراكي الإيجابي (immerhin): تعبر عن القناعة بنتيجة إيجابية جزئية حاسمة على الرغم من حجم الخلل الحاصل.',
        grammaticalAnalysisGerman:
            'Evaluative Abtönungs- und Fokuspartikel "immerhin" besetzt das Vorfeld und rahmt den erreichten Teilerfolg positiv ein.',
        scopeShiftDemonstration:
            'Im Mittelfeld: "Die Pumpen konnten immerhin DAS EINDRINGEN VON WASSER verhindern."',
        polarityRequirementNote:
            'Dient als pragmatischer Trostwert im technischen Schadensbericht.',
      ),
    );

    // 9. Restrictive Exclusive: lediglich (Formal Administrative Precision) - Industrial Automation
    _catalog.add(
      const FocusParticleModel(
        id: 'FOC-LEDIGLICH-09',
        particle: 'lediglich',
        category: FocusParticleCategory.restrictiveExclusive,
        scopeType: FocusScopeType.adverbialScope,
        baseSentenceWithoutParticle:
            'Der Fertigungstakt weicht um 0,2 Millisekunden von der Solltoleranz ab.',
        scopedSentence:
            'Der Fertigungstakt weicht lediglich um 0,2 Millisekunden von der Solltoleranz ab.',
        focusedElement: 'um 0,2 Millisekunden (Differenzmaß)',
        domain: CommunicativeDomain.industrialAutomation,
        arabicTranslation:
            'ينحرف توقيت دورة الإنتاج بمقدار 0.2 ميلي ثانية فحسب عن نطاق التفاوت المسموح به.',
        grammaticalAnalysisArabic:
            'أداة الحصر والتقليل الفصيحة (lediglich): تسبق المقدار العددي للدلالة على ضآلته الشديدة وانضباطه التام ضمن المعايير.',
        grammaticalAnalysisGerman:
            'Gehobene Restriktivpartikel "lediglich" (synonym zu "nur", jedoch mit formellerem Klangregister) vor der Maßangabe.',
        scopeShiftDemonstration:
            'Wirkt im technischen Prüfprotokoll beruhigend und normkonform.',
        polarityRequirementNote:
            'Neutral-positiv; betont die Geringfügigkeit.',
      ),
    );

    // 10. Additive Scalar: selbst (Uninflected Particle before Preposition) - Maritime Logistics
    _catalog.add(
      const FocusParticleModel(
        id: 'FOC-SELBST-10',
        particle: 'selbst',
        category: FocusParticleCategory.additiveScalar,
        scopeType: FocusScopeType.adverbialScope,
        baseSentenceWithoutParticle:
            'Bei Windstärke zehn blieb das hydrodynamische Rumpfdesign spurstabil.',
        scopedSentence:
            'Selbst bei Windstärke zehn blieb das hydrodynamische Rumpfdesign spurstabil.',
        focusedElement: 'bei Windstärke zehn (Extremer Umweltzustand)',
        domain: CommunicativeDomain.maritimeLogistics,
        arabicTranslation:
            'حتى عند شدة رياح بلغت الدرجة العاشرة، حافظ تصميم الهيكل الهيدروديناميكي على ثبات مساره في البحر.',
        grammaticalAnalysisArabic:
            'أداة التركيز الشمولية الجامدة (selbst): تسبق شبه الجملة المجرورة (bei Windstärke) للدلالة على تجاوز أقسى الظروف.',
        grammaticalAnalysisGerman:
            'Fokuspartikel "selbst" (unflektiert, nicht zu verwechseln mit dem Demonstrativ-/Reflexivpronomen) vor Präpositionalphrase.',
        scopeShiftDemonstration:
            'Distinktion: "Der Kapitän steuerte das Schiff SELBST" (Pronomen) vs. "SELBST der Kapitän fürchtete den Sturm" (Fokuspartikel).',
        polarityRequirementNote:
            'Dient der Extremwert-Fokussierung.',
      ),
    );

    // 11. Restrictive Exclusive: einzig und allein (Pleonasmus for Absolute Focus) - Aerospace Engineering
    _catalog.add(
      const FocusParticleModel(
        id: 'FOC-EINZIG-ALLEIN-11',
        particle: 'einzig und allein',
        category: FocusParticleCategory.restrictiveExclusive,
        scopeType: FocusScopeType.subjectScope,
        baseSentenceWithoutParticle:
            'Die thermische Schutzschicht verhinderte das Schmelzen der Triebwerksdüse.',
        scopedSentence:
            'Einzig und allein die thermische Schutzschicht verhinderte das Schmelzen der Triebwerksdüse.',
        focusedElement: 'die thermische Schutzschicht (Monokausaler Retter)',
        domain: CommunicativeDomain.aerospaceAndAviation,
        arabicTranslation:
            'الطبقة الواقية الحرارية وحدها دون سواها هي ما منع انصهار فوهة المحرك النفاث.',
        grammaticalAnalysisArabic:
            'صيغة الحصر والتوكيد البلاغي المزدوج (einzig und allein): تعزل الفاعل كسبب أوحد وحصري لإنقاذ المنظومة.',
        grammaticalAnalysisGerman:
            'Verstärkte Doppelpartikel "einzig und allein" zur absolut exklusiven Fokussierung des Erstglieds.',
        scopeShiftDemonstration:
            'Schließt kategorisch jegliche Nebenursachen oder additive Schutzfaktoren aus.',
        polarityRequirementNote:
            'Maximale Restriktionsstärke.',
      ),
    );

    // 12. Evaluative Concessive: wenigstens (Minimum Requirement) - Software Engineering
    _catalog.add(
      const FocusParticleModel(
        id: 'FOC-WENIGSTENS-12',
        particle: 'wenigstens',
        category: FocusParticleCategory.evaluativeConcessive,
        scopeType: FocusScopeType.objectScope,
        baseSentenceWithoutParticle:
            'Der Wiederherstellungsdienst konnte die Datenbank-Snapshots bis gestern retten.',
        scopedSentence:
            'Der Wiederherstellungsdienst konnte wenigstens die Datenbank-Snapshots bis gestern retten.',
        focusedElement: 'die Datenbank-Snapshots bis gestern (Minimalforderung)',
        domain: CommunicativeDomain.softwareEngineering,
        arabicTranslation:
            'استطاعت خدمة الاستعادة والاسترجاع إنقاذ لقطات قاعدة البيانات حتى يوم أمس على الأقل.',
        grammaticalAnalysisArabic:
            'أداة الحد الأدنى الاستدراكي (wenigstens): تحدد أدنى مستوى مقبول من الإنجاز أو التعويض في سياق الطوارئ التقنية.',
        grammaticalAnalysisGerman:
            'Gradpartikel "wenigstens" markiert die Befriedigung eines Mindeststandards nach einem kritischen Systemvorfall.',
        scopeShiftDemonstration:
            'Kann temporal stehen: "Konnte die Snapshots WENIGSTENS BIS GESTERN retten."',
        polarityRequirementNote:
            'Setzt eine zuvor unerfüllte Maximalerwartung voraus.',
      ),
    );

    // 13. Counter-Expectation: ausgerechnet (On Technical Component) - Industrial Automation
    _catalog.add(
      const FocusParticleModel(
        id: 'FOC-AUSGERECHNET-COMP-13',
        particle: 'ausgerechnet',
        category: FocusParticleCategory.counterExpectationAdversative,
        scopeType: FocusScopeType.objectScope,
        baseSentenceWithoutParticle:
            'Die Qualitätsprüfung beanstandete die teuerste Titanlegierung.',
        scopedSentence:
            'Die Qualitätsprüfung beanstandete ausgerechnet die teuerste Titanlegierung.',
        focusedElement: 'die teuerste Titanlegierung (Akkusativobjekt)',
        domain: CommunicativeDomain.industrialAutomation,
        arabicTranslation:
            'اعترض فحص الجودة تحديداً ومن دون سائر المكونات على سبيكة التيتانيوم الأغلى ثمناً.',
        grammaticalAnalysisArabic:
            'تسليط أداة معارضة التوقع على المفعول به: الاستغراب من أن العيب ظهر في أغلى المواد التي كان يُفترض أنها الأجود.',
        grammaticalAnalysisGerman:
            'Fokuspartikel "ausgerechnet" unmittelbar vor der Nominalphrase signalisiert die Enttäuschung einer Zuverlässigkeitserwartung.',
        scopeShiftDemonstration:
            'Fokusverschiebung auf das Subjekt: "Ausgerechnet DIE QUALITÄTSPRÜFUNG beanstandete..."',
        polarityRequirementNote:
            'Starke rhetorische Expressivität.',
      ),
    );

    // 14. Negative Polarity Scalar: geschweige denn (With Coordinate Negation) - Professional Workplace
    _catalog.add(
      const FocusParticleModel(
        id: 'FOC-GESCHWEIGE-RESOURCE-14',
        particle: 'geschweige denn',
        category: FocusParticleCategory.negativePolarityScalar,
        scopeType: FocusScopeType.objectScope,
        baseSentenceWithoutParticle:
            'Die Werkstatt verfügt über keine Ersatzteile für die Hauptturbine.',
        scopedSentence:
            'Die Werkstatt verfügt über keine Ersatzteile für die Hauptturbine, geschweige denn über ein komplettes Reserveaggregat.',
        focusedElement: 'über ein komplettes Reserveaggregat (Größeres Objekt)',
        domain: CommunicativeDomain.professionalWorkplace,
        arabicTranslation:
            'لا تمتلك الورشة أي قطع غيار للتوربين الرئيسي، ناهيك عن امتلاكها مولداً احتياطياً كاملاً.',
        grammaticalAnalysisArabic:
            'المشغل "geschweige denn" مسبوق بالنفي الصريح "keine Ersatzteile"، وتكرار حرف الجر über للمحافظة على التماثل النحوي التام.',
        grammaticalAnalysisGerman:
            'Negative Polaritätsverbindung mit paralleler Präpositionalrektion ("über keine... geschweige denn über ein...").',
        scopeShiftDemonstration:
            'Fehlt die vorangehende Negation (*Die Werkstatt verfügt über Ersatzteile, geschweige denn...), bricht die Syntax zusammen.',
        polarityRequirementNote:
            'Strikte Lizenzierung durch "keine" / Negation.',
      ),
    );
  }

  /// Validates a sentence using focus particles against scope placement and polarity licensing rules.
  FocusParticleValidationReport validateFocusConstruction({
    required String particleUsed,
    required bool isAntecedentNegated,
    required bool isPlacedDirectlyBeforeFocus,
  }) {
    final issues = <String>[];
    final recommendations = <String>[];

    final isNegativePolarityParticle =
        particleUsed.toLowerCase().contains('geschweige denn') ||
        particleUsed.toLowerCase().contains('geschweige');

    if (isNegativePolarityParticle && !isAntecedentNegated) {
      issues.add(
        'Verletzung der Negationslizenzierung: "$particleUsed" darf ausschließlich nach einem explizit negierten Teilsatz (mit nicht / kein / nie) verwendet werden.',
      );
      recommendations.add(
        'Fügen Sie eine Negationspartikel in den ersten Teilsatz ein (z. B. "konnte nicht einmal X, geschweige denn Y").',
      );
    }

    if (!isPlacedDirectlyBeforeFocus) {
      issues.add(
        'Falsche Skopusplatzierung: Fokuspartikeln müssen im Deutschen unmittelbar vor dem fokussierten Satzglied stehen, um Mehrdeutigkeiten zu vermeiden.',
      );
      recommendations.add(
        'Verschieben Sie die Partikel direkt vor das betonte Element (Subjekt, Objekt oder Adverbial).',
      );
    }

    final isValid = issues.isEmpty;
    final verdict = isValid
        ? 'استخدام أداة التركيز ومشغل السلم الدلالي مطابق تماماً لقواعد النحو ومعايير الفصاحة (C1-C2).'
        : 'تم رصد خلل في شرط النفي المسبق أو في موضع الأداة بالنسبة لمجال تركيزها.';

    return FocusParticleValidationReport(
      isValid: isValid,
      respectsPolarityCondition: issues.where((e) => e.contains('Negationslizenzierung')).isEmpty,
      isScopeAdjacencyCorrect: isPlacedDirectlyBeforeFocus,
      issues: issues,
      recommendations: recommendations,
      arabicDiagnosticVerdict: verdict,
    );
  }

  List<FocusParticleModel> filterByCategory(FocusParticleCategory category) {
    return _catalog.where((item) => item.category == category).toList();
  }

  List<FocusParticleModel> filterByScope(FocusScopeType scope) {
    return _catalog.where((item) => item.scopeType == scope).toList();
  }

  List<FocusParticleModel> filterByDomain(CommunicativeDomain domain) {
    return _catalog.where((item) => item.domain == domain).toList();
  }
}
