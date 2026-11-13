import 'dart:collection';

/// Classification of correlate structures in German complex complementation.
enum CorrelateCategory {
  obligatoryPrepositionalDa(
    'Obligatorisches Präpositional-Korrelat (darauf, darin, dazu, daran + dass/zu)',
    'رابط حرف الجر الإلزامي (darauf / darin / dazu: لا تصح الجملة بدونه عند ربط جملة فرعية)',
    'Verben mit festem Präpositionalobjekt verlangen bei Nebensatz- oder Infinitivanschluss zwingend das Pronominaladverb: "Die Sicherheit beruht DARAUF, dass..."',
  ),
  optionalPrepositionalDa(
    'Fakultatives Präpositional-Korrelat (daran / darüber / davon [optional] + dass/ob)',
    'رابط حرف الجر الاختياري (daran / darüber: يجوز حذفه أو إثباته لتقوية التركيز)',
    'Bei manchen Verben der Wahrnehmung oder Mitteilung ist das Korrelat fakultativ: "Wir achten (darauf), dass die Grenzwerte eingehalten werden."',
  ),
  obligatoryObjectCorrelativeEs(
    'Obligatorisches Objekt-Korrelat "es" (etwas für wichtig halten + es + zu/dass)',
    'ضمير الربط الإلزامي في حالة المفعول به (es: إجباري مع الأفعال ذات المفعولين أو التقدير)',
    'Steht als Platzhalter im Mittelfeld bei Verben mit Prädikativum ("es für nötig halten, zu...") oder bestimmten Kognitionsverben.',
  ),
  vorfeldExpletiveEsDisappearing(
    'Vorfeld-Platzhalter "es" (fällt bei Inversion/Passiv weg)',
    'ضمير الصدارة التمهيدي الزائل (es: يظهر في الصدارة فقط ويسقط عند تقديم أي عنصر آخر)',
    'Reines Stellungs-"es" in Position 1 bei unpersönlichem Passiv oder Subjektnachstellung; verschwindet zwingend bei Vorfeldbesetzung: "Es wird geprüft..." -> "Heute wird geprüft..."',
  ),
  prohibitedCorrelateZero(
    'Korrelatverbot (Null-Korrelat bei reinen Akkusativ-/Subjektverben)',
    'حظر الرابط التمهيدي (يُمنع وضع da- أو es مع أفعال معينة مثل anfangen / aufhören)',
    'Verben wie "aufhören", "versuchen" oder "beabsichtigen" erlauben bei Infinitivanschluss KEIN Korrelat (*"damit aufhören, zu...").',
  );

  final String deTitle;
  final String arTitle;
  final String grammaticalDefinition;
  const CorrelateCategory(this.deTitle, this.arTitle, this.grammaticalDefinition);
}

/// Type of embedded complement clause anchored by the correlate.
enum EmbeddedClauseType {
  dassFiniteClause('dass-Nebensatz (finite Proposition)', 'جملة فرعية مصدرية مبدوءة بـ dass'),
  zuInfinitivePhrase('zu-Infinitivsatz (kontrollierte Handlung)', 'جملة مصدرية مقترنة بـ zu'),
  obIndirectPolarQuestion('ob-Nebensatz (indirekte Entscheidungsfrage)', 'جملة استفهامية غير مباشرة بـ ob'),
  wInterrogativeClause('W-Nebensatz (indirekte Ergänzungsfrage)', 'جملة استفهامية فرعية بأداة استفهام');

  final String de;
  final String ar;
  const EmbeddedClauseType(this.de, this.ar);
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

/// Structural model of a German prepositional correlate or expletive "es" construction.
class PrepositionalCorrelateModel {
  final String id;
  final CorrelateCategory category;
  final EmbeddedClauseType embeddedClauseType;
  final CommunicativeDomain domain;
  final String governingVerbOrPredicate;
  final String correlateToken;
  final String fullGermanSentence;
  final String ungrammaticalCounterExample;
  final String syntacticExplanationGerman;
  final String syntacticExplanationArabic;
  final bool isCorrelateObligatory;

  const PrepositionalCorrelateModel({
    required this.id,
    required this.category,
    required this.embeddedClauseType,
    required this.domain,
    required this.governingVerbOrPredicate,
    required this.correlateToken,
    required this.fullGermanSentence,
    required this.ungrammaticalCounterExample,
    required this.syntacticExplanationGerman,
    required this.syntacticExplanationArabic,
    required this.isCorrelateObligatory,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.name,
    'embeddedClauseType': embeddedClauseType.name,
    'domain': domain.name,
    'governingVerbOrPredicate': governingVerbOrPredicate,
    'correlateToken': correlateToken,
    'fullGermanSentence': fullGermanSentence,
    'ungrammaticalCounterExample': ungrammaticalCounterExample,
    'syntacticExplanationGerman': syntacticExplanationGerman,
    'syntacticExplanationArabic': syntacticExplanationArabic,
    'isCorrelateObligatory': isCorrelateObligatory,
  };
}

/// Validation result for prepositional correlates and expletive "es".
class CorrelateValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<String> syntacticNotes;

  const CorrelateValidationResult({
    required this.isValid,
    required this.issues,
    required this.syntacticNotes,
  });
}

/// Core Engine managing German Prepositional Correlates & Expletive/Correlative "es".
class GermanPrepositionalCorrelatesEsEngine {
  final List<PrepositionalCorrelateModel> _catalog = [];

  GermanPrepositionalCorrelatesEsEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<PrepositionalCorrelateModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    _catalog.addAll([
      // 1. Obligatorisches Korrelat: beruhen auf -> darauf, dass
      const PrepositionalCorrelateModel(
        id: 'CORR-4967-01',
        category: CorrelateCategory.obligatoryPrepositionalDa,
        embeddedClauseType: EmbeddedClauseType.dassFiniteClause,
        domain: CommunicativeDomain.renewableEnergyGrid,
        governingVerbOrPredicate: 'beruhen auf + Dativ',
        correlateToken: 'darauf',
        fullGermanSentence:
            'Die Frequenzstabilität des Verbundnetzes beruht darauf, dass rotierende Schwungmassen und Wechselrichter synchron geregelt werden.',
        ungrammaticalCounterExample:
            '*Die Frequenzstabilität beruht, dass rotierende Schwungmassen geregelt werden.',
        syntacticExplanationGerman:
            'Das Verb "beruhen auf" verlangt bei Satzkomplementierung zwingend das Korrelat "darauf"; ein Weglassen macht den Satz ungrammatisch.',
        syntacticExplanationArabic:
            'الفعل (beruhen auf) يوجب وجود الرابط (darauf) قبل الجملة الفرعية؛ وحذفه يخل ببنية الجملة نحوياً.',
        isCorrelateObligatory: true,
      ),
      // 2. Obligatorisches Korrelat: beitragen zu -> dazu, zu + Infinitiv
      const PrepositionalCorrelateModel(
        id: 'CORR-4967-02',
        category: CorrelateCategory.obligatoryPrepositionalDa,
        embeddedClauseType: EmbeddedClauseType.zuInfinitivePhrase,
        domain: CommunicativeDomain.aerospaceAndAviation,
        governingVerbOrPredicate: 'beitragen zu + Dativ',
        correlateToken: 'dazu',
        fullGermanSentence:
            'Moderne Keramikmatrix-Verbundwerkstoffe tragen wesentlich dazu bei, den Treibstoffverbrauch von Strahltriebwerken um 14 Prozent zu senken.',
        ungrammaticalCounterExample:
            '*Moderne Verbundwerkstoffe tragen wesentlich bei, den Treibstoffverbrauch zu senken.',
        syntacticExplanationGerman:
            'Das trennbare Verb "beitragen zu" erfordert das Präpositionaladverb "dazu" im Mittelfeld als Anker für den Infinitivsatz.',
        syntacticExplanationArabic:
            'الفعل المركب (beitragen zu) يشترط تثبيت الرابط (dazu) في الوسط لربطه بالجملة المصدرية المقترنة بـ zu.',
        isCorrelateObligatory: true,
      ),
      // 3. Obligatorisches Korrelat: bestehen in -> darin, zu + Infinitiv
      const PrepositionalCorrelateModel(
        id: 'CORR-4967-03',
        category: CorrelateCategory.obligatoryPrepositionalDa,
        embeddedClauseType: EmbeddedClauseType.zuInfinitivePhrase,
        domain: CommunicativeDomain.industrialRobotics,
        governingVerbOrPredicate: 'bestehen in + Dativ',
        correlateToken: 'darin',
        fullGermanSentence:
            'Die Hauptaufgabe der optischen Sensorfusion besteht darin, Latenzzeiten bei der Kollisionsvermeidung unter zwei Millisekunden zu drücken.',
        ungrammaticalCounterExample:
            '*Die Hauptaufgabe besteht, Latenzzeiten unter zwei Millisekunden zu drücken.',
        syntacticExplanationGerman:
            '"bestehen in" (im Sinne von "Inhalt/Ziel sein") bindet den Infinitivsatz obligatorisch über "darin" ein.',
        syntacticExplanationArabic:
            'الفعل (bestehen in) بمعنى "يكمن في" يلزم وجود الرابط (darin) لتمهيد الجملة المصدرية اللاحقة.',
        isCorrelateObligatory: true,
      ),
      // 4. Obligatorisches Korrelat: abhängen von -> davon, ob
      const PrepositionalCorrelateModel(
        id: 'CORR-4967-04',
        category: CorrelateCategory.obligatoryPrepositionalDa,
        embeddedClauseType: EmbeddedClauseType.obIndirectPolarQuestion,
        domain: CommunicativeDomain.materialScience,
        governingVerbOrPredicate: 'abhängen von + Dativ',
        correlateToken: 'davon',
        fullGermanSentence:
            'Die Ermüdungslebensdauer der Titanlegierung hängt maßgeblich davon ab, ob während des Vakuumschmelzens sämtliche Gaseinschlüsse entfernt wurden.',
        ungrammaticalCounterExample:
            '*Die Ermüdungslebensdauer hängt maßgeblich ab, ob Gaseinschlüsse entfernt wurden.',
        syntacticExplanationGerman:
            'Indirekte Entscheidungsfragen mit "ob" nach "abhängen von" verlangen zwingend das Korrelat "davon" vor der rechten Verbklammer ("ab").',
        syntacticExplanationArabic:
            'الاستفهام غير المباشر بـ (ob) مع الفعل (abhängen von) يوجب وضع الرابط (davon) قبل القوس الفعلي الأخير.',
        isCorrelateObligatory: true,
      ),
      // 5. Obligatorisches Objekt-Korrelat "es": es für erforderlich halten, zu
      const PrepositionalCorrelateModel(
        id: 'CORR-4967-05',
        category: CorrelateCategory.obligatoryObjectCorrelativeEs,
        embeddedClauseType: EmbeddedClauseType.zuInfinitivePhrase,
        domain: CommunicativeDomain.civilInfrastructure,
        governingVerbOrPredicate: 'etwas für erforderlich halten',
        correlateToken: 'es',
        fullGermanSentence:
            'Der Prüfstatiker hält es für technisch erforderlich, die vorgespannten Brückenseile vor der Verkehrsfreigabe erneut zu röntgen.',
        ungrammaticalCounterExample:
            '*Der Prüfstatiker hält für technisch erforderlich, die Brückenseile zu röntgen.',
        syntacticExplanationGerman:
            'Verben mit Akkusativobjekt + prädikativem "für + Adjektiv" (für nötig/erforderlich/ratsam halten) verlangen zwingend das Platzhalter-"es" im Mittelfeld.',
        syntacticExplanationArabic:
            'أفعال التقدير المقترنة بـ (für + صفة) توجب وجود الضمير (es) في الحقل الأوسط نائباً عن الجملة المصدرية.',
        isCorrelateObligatory: true,
      ),
      // 6. Vorfeld-Platzhalter "es" (verschwindet bei Inversion)
      const PrepositionalCorrelateModel(
        id: 'CORR-4967-06',
        category: CorrelateCategory.vorfeldExpletiveEsDisappearing,
        embeddedClauseType: EmbeddedClauseType.dassFiniteClause,
        domain: CommunicativeDomain.maritimeLogistics,
        governingVerbOrPredicate: 'Es hat sich gezeigt, dass... (Vorfeld-es)',
        correlateToken: 'Es (nur im Vorfeld)',
        fullGermanSentence:
            'Es hat sich in der Praxis gezeigt, dass eine hydrodynamische Rumpfbeschichtung den Treibstoffbedarf auf Langstrecken um acht Prozent reduziert.',
        ungrammaticalCounterExample:
            '*In der Praxis hat es sich gezeigt, dass eine Rumpfbeschichtung... (fehlerhaftes "es" nach Vorfeldbesetzung)',
        syntacticExplanationGerman:
            'Das reine Vorfeld-Platzhalter-"es" besetzt Position 1, wenn das Subjekt (der dass-Satz) im Nachfeld steht; rückt "In der Praxis" ins Vorfeld, fällt "es" weg!',
        syntacticExplanationArabic:
            'الضمير الصوري التمهيدي (Es) يشغل الصدارة فقط عند تأخير الفاعل، ويسقط وجوباً بمجرد تقديم أي ظرف إلى الصدارة.',
        isCorrelateObligatory: false,
      ),
      // 7. Fakultatives Korrelat: achten auf -> (darauf), dass
      const PrepositionalCorrelateModel(
        id: 'CORR-4967-07',
        category: CorrelateCategory.optionalPrepositionalDa,
        embeddedClauseType: EmbeddedClauseType.dassFiniteClause,
        domain: CommunicativeDomain.industrialRobotics,
        governingVerbOrPredicate: 'achten auf + Akkusativ',
        correlateToken: 'darauf (fakultativ)',
        fullGermanSentence:
            'Bei der Programmierung der Schweißbahn achten die Ingenieure (darauf), dass der Lichtbogen keine thermischen Verwerfungen im Dünnblech auslöst.',
        ungrammaticalCounterExample:
            '*Die Ingenieure achten es, dass der Lichtbogen keine Verwerfungen auslöst.',
        syntacticExplanationGerman:
            'Bei "achten auf" ist "darauf" fakultativ (stilistisch empfohlen zur Hervorhebung), jedoch ist ein Ersatz durch *"es" streng verboten!',
        syntacticExplanationArabic:
            'مع الفعل (achten auf) يكون الرابط (darauf) اختيارياً للتوكيد، لكن يُحظر تماماً استبداله بالضمير (es).',
        isCorrelateObligatory: false,
      ),
      // 8. Korrelatverbot: aufhören zu (kein Korrelat erlaubt)
      const PrepositionalCorrelateModel(
        id: 'CORR-4967-08',
        category: CorrelateCategory.prohibitedCorrelateZero,
        embeddedClauseType: EmbeddedClauseType.zuInfinitivePhrase,
        domain: CommunicativeDomain.renewableEnergyGrid,
        governingVerbOrPredicate: 'anfangen / aufhören / beabsichtigen',
        correlateToken: '∅ (Korrelat verboten)',
        fullGermanSentence:
            'Das automatische Lastmanagementsystem beginnt sofort damit? Nein: Es beginnt ohne Korrelat, die nicht-kritischen Verbraucher stufenweise abzuschalten.',
        ungrammaticalCounterExample:
            '*Das Lastmanagementsystem beabsichtigt es/dazu, die Verbraucher abzuschalten.',
        syntacticExplanationGerman:
            'Kontrollverben wie "beabsichtigen", "versuchen" oder "beginnen" (ohne Präpositionalobjekt) verbieten ein Korrelat vor dem zu-Infinitiv.',
        syntacticExplanationArabic:
            'أفعال التحكم المباشر مثل (beabsichtigen / versuchen) تمنع وضع أي رابط تمهيدي قبل الجملة المصدرية.',
        isCorrelateObligatory: false,
      ),
      // 9. Obligatorisches Korrelat: sich verlassen auf -> darauf, dass
      const PrepositionalCorrelateModel(
        id: 'CORR-4967-09',
        category: CorrelateCategory.obligatoryPrepositionalDa,
        embeddedClauseType: EmbeddedClauseType.dassFiniteClause,
        domain: CommunicativeDomain.aerospaceAndAviation,
        governingVerbOrPredicate: 'sich verlassen auf + Akkusativ',
        correlateToken: 'darauf',
        fullGermanSentence:
            'Die Besatzung verlässt sich im Blindflug darauf, dass die dreifach redundanten Trägheitsnavigationssysteme konsistente Lagedaten liefern.',
        ungrammaticalCounterExample:
            '*Die Besatzung verlässt sich, dass die Navigationssysteme konsistente Daten liefern.',
        syntacticExplanationGerman:
            'Reflexive Verben mit Präpositionalrektion ("sich verlassen auf") erfordern zwingend "darauf" vor einem dass-Satz.',
        syntacticExplanationArabic:
            'الفعل الانعكاسي المقيد بحرف جر (sich verlassen auf) يوجب إدراج (darauf) لربط جملة الاعتماد الفرعية.',
        isCorrelateObligatory: true,
      ),
      // 10. Obligatorisches Korrelat: hinweisen auf -> darauf, dass
      const PrepositionalCorrelateModel(
        id: 'CORR-4967-10',
        category: CorrelateCategory.obligatoryPrepositionalDa,
        embeddedClauseType: EmbeddedClauseType.dassFiniteClause,
        domain: CommunicativeDomain.civilInfrastructure,
        governingVerbOrPredicate: 'hinweisen auf + Akkusativ',
        correlateToken: 'darauf',
        fullGermanSentence:
            'Das geotechnische Gutachten weist ausdrücklich darauf hin, dass die Spundwände im Grundwasserbereich um drei Meter vertieft werden müssen.',
        ungrammaticalCounterExample:
            '*Das Gutachten weist ausdrücklich hin, dass die Spundwände vertieft werden müssen.',
        syntacticExplanationGerman:
            '"hinweisen auf" erfordert bei nachgestelltem Nebensatz das pronominale Korrelat "darauf" vor der Verbpartikel "hin".',
        syntacticExplanationArabic:
            'الفعل (hinweisen auf) يستلزم تثبيت الرابط (darauf) قبل الجزء المنفصل (hin) عند وجود جملة تابعة بـ dass.',
        isCorrelateObligatory: true,
      ),
      // 11. Obligatorisches Objekt-Korrelat "es": es ermöglichen, zu
      const PrepositionalCorrelateModel(
        id: 'CORR-4967-11',
        category: CorrelateCategory.obligatoryObjectCorrelativeEs,
        embeddedClauseType: EmbeddedClauseType.zuInfinitivePhrase,
        domain: CommunicativeDomain.materialScience,
        governingVerbOrPredicate: 'es jemandem ermöglichen, zu',
        correlateToken: 'es',
        fullGermanSentence:
            'Die Rastertunnelmikroskopie ermöglicht es den Forschern, einzelne Atomanordnungen auf der Kristalloberfläche direkt abzubilden.',
        ungrammaticalCounterExample:
            '*Die Mikroskopie ermöglicht den Forschern, einzelne Atomanordnungen abzubilden (stilistisch defekt bei Dativergänzung).',
        syntacticExplanationGerman:
            'Bei "ermöglichen + Dativ + zu-Infinitiv" fungiert das Korrelat-"es" als syntaktischer Platzhalter für das komplexe Akkusativobjekt im Nachfeld.',
        syntacticExplanationArabic:
            'مع الفعل (ermöglichen) والمفعول المجرور، يعمل الضمير (es) كنائب نحوي إلزامي عن الجملة المصدرية المؤخرة.',
        isCorrelateObligatory: true,
      ),
      // 12. Fakultatives Korrelat: sich erkundigen nach -> (danach), wie/wann
      const PrepositionalCorrelateModel(
        id: 'CORR-4967-12',
        category: CorrelateCategory.optionalPrepositionalDa,
        embeddedClauseType: EmbeddedClauseType.wInterrogativeClause,
        domain: CommunicativeDomain.maritimeLogistics,
        governingVerbOrPredicate: 'sich erkundigen nach + Dativ',
        correlateToken: 'danach (fakultativ)',
        fullGermanSentence:
            'Der Hafenlotse erkundigte sich bei der Revierzentrale (danach), wann die Flutwelle den maximalen Tiefgang für die Einfahrt freigibt.',
        ungrammaticalCounterExample:
            '*Der Hafenlotse erkundigte sich es, wann die Flutwelle den Tiefgang freigibt.',
        syntacticExplanationGerman:
            'Bei indirekten W-Fragen nach "sich erkundigen nach" ist "danach" fakultativ, markiert aber die präpositionale Bindung präzise.',
        syntacticExplanationArabic:
            'في الأسئلة غير المباشرة مع (sich erkundigen nach) يكون الرابط (danach) اختيارياً لتوضيح التبعية لحرف الجر.',
        isCorrelateObligatory: false,
      ),
      // 13. Obligatorisches Korrelat: führen zu -> dazu, dass
      const PrepositionalCorrelateModel(
        id: 'CORR-4967-13',
        category: CorrelateCategory.obligatoryPrepositionalDa,
        embeddedClauseType: EmbeddedClauseType.dassFiniteClause,
        domain: CommunicativeDomain.renewableEnergyGrid,
        governingVerbOrPredicate: 'führen zu + Dativ',
        correlateToken: 'dazu',
        fullGermanSentence:
            'Ein unkompensierter Blindleistungsanstieg führt unweigerlich dazu, dass die Übertragungsverluste auf der 380-kV-Trasse drastisch anwachsen.',
        ungrammaticalCounterExample:
            '*Ein Blindleistungsanstieg führt unweigerlich, dass die Übertragungsverluste anwachsen.',
        syntacticExplanationGerman:
            'Kausales "führen zu" verlangt ausnahmslos "dazu" vor der Konjunktion "dass".',
        syntacticExplanationArabic:
            'الفعل السببي (führen zu) يشترط حتماً وجود الرابط (dazu) قبل (dass) للربط بين السبب والنتيجة.',
        isCorrelateObligatory: true,
      ),
      // 14. Obligatorisches Korrelat: bestehen auf -> darauf, dass
      const PrepositionalCorrelateModel(
        id: 'CORR-4967-14',
        category: CorrelateCategory.obligatoryPrepositionalDa,
        embeddedClauseType: EmbeddedClauseType.dassFiniteClause,
        domain: CommunicativeDomain.industrialRobotics,
        governingVerbOrPredicate: 'bestehen auf + Dativ/Akkusativ',
        correlateToken: 'darauf',
        fullGermanSentence:
            'Die Sicherheitsnorm ISO 10218 besteht strikt darauf, dass der Kollaborationsraum durch redundante Laserscanner überwacht wird.',
        ungrammaticalCounterExample:
            '*Die Sicherheitsnorm besteht strikt, dass der Kollaborationsraum überwacht wird.',
        syntacticExplanationGerman:
            'Anders als "bestehen in" (darin) verlangt "bestehen auf" (Forderung/Auflage) zwingend das Korrelat "darauf".',
        syntacticExplanationArabic:
            'الفعل (bestehen auf) بمعنى "يُصر على/يشترط" يوجب الرابط (darauf)، بخلاف (bestehen in) الذي يوجب (darin).',
        isCorrelateObligatory: true,
      ),
      // 15. Vorfeld-Platzhalter "es" bei Subjektsatz-Ausklammerung
      const PrepositionalCorrelateModel(
        id: 'CORR-4967-15',
        category: CorrelateCategory.vorfeldExpletiveEsDisappearing,
        embeddedClauseType: EmbeddedClauseType.zuInfinitivePhrase,
        domain: CommunicativeDomain.aerospaceAndAviation,
        governingVerbOrPredicate: 'Es ist unzulässig, zu...',
        correlateToken: 'Es (nur bei Nachstellung)',
        fullGermanSentence:
            'Es ist luftrechtlich streng unzulässig, das Triebwerk ohne dokumentierte Endoskopie-Freigabe wieder in Betrieb zu nehmen.',
        ungrammaticalCounterExample:
            '*Das Triebwerk wieder in Betrieb zu nehmen, ist es streng unzulässig.',
        syntacticExplanationGerman:
            'Steht der Infinitivsatz selbst im Vorfeld, entfällt das Platzhalter-"es" im Hauptsatz restlos!',
        syntacticExplanationArabic:
            'إذا قُدمت الجملة المصدرية نفسها إلى الصدارة سقط الضمير التمهيدي (es) وجوباً من الجملة الرئيسية.',
        isCorrelateObligatory: false,
      ),
      // 16. Korrelatverbot: vermeiden zu (reines Akkusativobjekt)
      const PrepositionalCorrelateModel(
        id: 'CORR-4967-16',
        category: CorrelateCategory.prohibitedCorrelateZero,
        embeddedClauseType: EmbeddedClauseType.zuInfinitivePhrase,
        domain: CommunicativeDomain.materialScience,
        governingVerbOrPredicate: 'vermeiden, zu...',
        correlateToken: '∅ (Korrelat verboten)',
        fullGermanSentence:
            'Durch kontrollierte Schutzgaszufuhr vermeiden die Metallurgen, spröde Oxidationsphasen entlang der Korngrenzen zu bilden.',
        ungrammaticalCounterExample:
            '*Die Metallurgen vermeiden es/davor, spröde Oxidationsphasen zu bilden.',
        syntacticExplanationGerman:
            'Reine transitive Verben wie "vermeiden" schließen einen einfachen zu-Infinitiv direkt ohne pronominales Korrelat an.',
        syntacticExplanationArabic:
            'الفعل المتعدي الصريح (vermeiden) يرتبط مباشرة بالجملة المصدرية دون وساطة ضمائر ربط أو حروف جر.',
        isCorrelateObligatory: false,
      ),
    ]);
  }

  List<PrepositionalCorrelateModel> getByCategory(CorrelateCategory category) =>
      _catalog.where((c) => c.category == category).toList();

  List<PrepositionalCorrelateModel> getByEmbeddedType(EmbeddedClauseType type) =>
      _catalog.where((c) => c.embeddedClauseType == type).toList();

  List<PrepositionalCorrelateModel> getByDomain(CommunicativeDomain domain) =>
      _catalog.where((c) => c.domain == domain).toList();

  /// Validates correlate presence, da(r)- vs. es selection, and Vorfeld-expletive deletion.
  CorrelateValidationResult validateCorrelateUsage({
    required CorrelateCategory category,
    required bool hasDaCorrelate,
    required bool hasEsCorrelate,
    required bool isVorfeldOccupiedByOtherElement,
  }) {
    final List<String> issues = [];
    final List<String> notes = [];

    if (category == CorrelateCategory.obligatoryPrepositionalDa) {
      if (!hasDaCorrelate) {
        issues.add(
            'Korrelatfehler: Dieses Verb mit festem Präpositionalobjekt verlangt zwingend das da(r)-Korrelat (z. B. darauf, dazu, darin, davon).');
      } else if (hasEsCorrelate) {
        issues.add(
            'Rektionsfehler: Ein präpositionales Korrelat (darauf/dazu) darf niemals durch ein bloßes "es" ersetzt werden.');
      } else {
        notes.add('Korrelat normgerecht: Obligatorisches da(r)-Präpositionaladverb korrekt gesetzt.');
      }
    }

    if (category == CorrelateCategory.obligatoryObjectCorrelativeEs) {
      if (!hasEsCorrelate) {
        issues.add(
            'Platzhalterfehler: Prädikative Konstruktionen (für nötig halten, ermöglichen + Dativ) verlangen zwingend das Objekt-Korrelat "es".');
      } else {
        notes.add('Objekt-Korrelat normgerecht: "es" im Mittelfeld verankert.');
      }
    }

    if (category == CorrelateCategory.vorfeldExpletiveEsDisappearing) {
      if (isVorfeldOccupiedByOtherElement && hasEsCorrelate) {
        issues.add(
            'Topologie-Fehler: Das reine Vorfeld-Platzhalter-"es" MUSS bei anderweitiger Vorfeldbesetzung entfallen!');
      } else {
        notes.add('Stellungs-"es" normgerecht behandelt.');
      }
    }

    if (category == CorrelateCategory.prohibitedCorrelateZero) {
      if (hasDaCorrelate || hasEsCorrelate) {
        issues.add(
            'Redundanzfehler: Dieses Kontrollverb verbietet ein vorangestelltes Korrelat (*"damit aufhören, zu..." / *"es vermeiden, zu...").');
      } else {
        notes.add('Null-Korrelat normgerecht: Direkter Anschluss ohne überflüssigen Platzhalter.');
      }
    }

    return CorrelateValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      syntacticNotes: notes,
    );
  }

  Map<String, dynamic> generateTelemetrySnapshot() {
    return {
      'totalExemplars': _catalog.length,
      'categoryDistribution': {
        for (var c in CorrelateCategory.values)
          c.name: _catalog.where((e) => e.category == c).length,
      },
      'embeddedTypeDistribution': {
        for (var t in EmbeddedClauseType.values)
          t.name: _catalog.where((e) => e.embeddedClauseType == t).length,
      },
      'domainDistribution': {
        for (var d in CommunicativeDomain.values)
          d.name: _catalog.where((e) => e.domain == d).length,
      },
      'obligatoryCorrelatesCount': _catalog.where((e) => e.isCorrelateObligatory).length,
      'cefrLevel': 'CEFR C1-C2 Masterclass Prepositional Correlates & Expletive es',
      'engineVersion': '1.0.0+subsystem1801',
    };
  }
}
