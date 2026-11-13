import 'dart:collection';

/// Classification of German infinitival adjunct clauses vs. finite subordinating counterparts.
enum InfinitivalAdjunctType {
  finalUmZu(
    'Finaler Infinitivsatz (um ... zu: identisches Subjekt) vs. damit (verschiedene Subjekte)',
    'جملة الغاية المصدرية (um... zu عند تطابق الفاعل) مقابل (damit عند اختلاف الفاعلين)',
    'Drückt Ziel/Zweck aus. "um... zu" ist NUR zulässig, wenn das logische Subjekt des Infinitivs exakt mit dem Subjekt des Hauptsatzes übereinstimmt.',
  ),
  modalNegatedOhneZu(
    'Modal-negierter Begleitsatz (ohne ... zu: identisches Subjekt) vs. ohne dass',
    'جملة الحال المنفية المصدرية (ohne... zu عند تطابق الفاعل) مقابل (ohne dass عند اختلافهما)',
    'Drückt aus, dass ein erwarteter Begleitvorgang ausbleibt: "Der Roboter schweißt die Naht, ohne das Blech zu verformen."',
  ),
  substitutiveAnstattZu(
    'Substitutiver Infinitivsatz ((an)statt ... zu: identisches Subjekt) vs. (an)statt dass',
    'جملة الاستبدال المصدرية (anstatt... zu عند تطابق الفاعل) مقابل (anstatt dass عند اختلافهما)',
    'Stellt die realisierte Handlung einer unterlassenen Alternative gegenüber: "Anstatt den Filter zu reinigen, tauschte der Techniker die Pumpe."',
  ),
  comparativeExcessAlsZu(
    'Komparativer Infinitivanschluss (zu [Adj.], um ... zu / als dass)',
    'الربط المصدري التفاوتي المانع (أكبر من أن يسمح بـ: zu... um... zu)',
    'Koppelt ein Übermaß im Hauptsatz mit einer Unmöglichkeitsfolge im Infinitiv bei identischem Subjekt.',
  ),
  restrictiveAusserZu(
    'Restriktiver Ausnahmesatz (außer ... zu / außer dass)',
    'جملة الاستثناء المصدرية (باستثناء أن / سوى أن: außer... zu)',
    'Grenzt eine einzige verbleibende Handlungsoption oder Systemausnahme ein.',
  );

  final String deTitle;
  final String arTitle;
  final String grammaticalDefinition;
  const InfinitivalAdjunctType(this.deTitle, this.arTitle, this.grammaticalDefinition);
}

/// Subject control status determining whether infinitival reduction is grammatical.
enum SubjectControlStatus {
  identicalActiveSubject('Identisches aktives Subjekt (Infinitivsatz obligatorisch/bevorzugt)', 'تطابق الفاعل المعلوم (الجملة المصدرية هي الفصحى)'),
  identicalPassiveSubject('Identisches passivisches Subjekt (zu + Partizip II + werden)', 'تطابق النائب عن الفاعل (تستوجب صيغة المجهول المصدرية)'),
  divergentSubjectsFiniteRequired('Verschiedene Subjekte (Nebensatz mit damit/ohne dass/anstatt dass zwingend)', 'اختلاف الفاعلين (يُمنع المصدر وتلزم الجملة الفعلية الفرعية)'),
  impersonalPassiveViolation('Unpersönliches Passiv ohne Agens-Subjekt (Infinitiv verboten!)', 'مجهول غير شخصي بلا فاعل ظاهر (يحظر استخدام um... zu)');

  final String de;
  final String ar;
  const SubjectControlStatus(this.de, this.ar);
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

/// Structural model of a German infinitival adjunct construction.
class InfinitivalAdjunctModel {
  final String id;
  final InfinitivalAdjunctType adjunctType;
  final SubjectControlStatus controlStatus;
  final CommunicativeDomain domain;
  final String subordinatingPhrase;
  final String fullGermanSentence;
  final String ungrammaticalDanglingCounterExample;
  final String finiteClauseAlternative;
  final String controlRuleGerman;
  final String controlRuleArabic;
  final bool hasSeparableInnerZu;

  const InfinitivalAdjunctModel({
    required this.id,
    required this.adjunctType,
    required this.controlStatus,
    required this.domain,
    required this.subordinatingPhrase,
    required this.fullGermanSentence,
    required this.ungrammaticalDanglingCounterExample,
    required this.finiteClauseAlternative,
    required this.controlRuleGerman,
    required this.controlRuleArabic,
    this.hasSeparableInnerZu = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'adjunctType': adjunctType.name,
    'controlStatus': controlStatus.name,
    'domain': domain.name,
    'subordinatingPhrase': subordinatingPhrase,
    'fullGermanSentence': fullGermanSentence,
    'ungrammaticalDanglingCounterExample': ungrammaticalDanglingCounterExample,
    'finiteClauseAlternative': finiteClauseAlternative,
    'controlRuleGerman': controlRuleGerman,
    'controlRuleArabic': controlRuleArabic,
    'hasSeparableInnerZu': hasSeparableInnerZu,
  };
}

/// Validation result for infinitival adjuncts and subject identity.
class InfinitivalAdjunctValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<String> syntacticNotes;

  const InfinitivalAdjunctValidationResult({
    required this.isValid,
    required this.issues,
    required this.syntacticNotes,
  });
}

/// Core Engine managing German Infinitival Adjuncts & Subject-Identity Control.
class GermanInfinitivalAdjunctsControlEngine {
  final List<InfinitivalAdjunctModel> _catalog = [];

  GermanInfinitivalAdjunctsControlEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<InfinitivalAdjunctModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    _catalog.addAll([
      // 1. Final (um... zu, Identisches Subjekt, trennbares Verb)
      const InfinitivalAdjunctModel(
        id: 'INF-4972-01',
        adjunctType: InfinitivalAdjunctType.finalUmZu,
        controlStatus: SubjectControlStatus.identicalActiveSubject,
        domain: CommunicativeDomain.renewableEnergyGrid,
        subordinatingPhrase: 'um ... abzufangen',
        fullGermanSentence:
            'Der Netzbetreiber installiert großskalige Schwungradspeicher, um kurzfristige Frequenzschwankungen im Millisekundenbereich abzufangen.',
        ungrammaticalDanglingCounterExample:
            '*Um kurzfristige Frequenzschwankungen abzufangen, werden großskalige Schwungradspeicher installiert (Subjektwechsel: Speicher fangen ab, nicht "es wird installiert").',
        finiteClauseAlternative:
            'Der Netzbetreiber installiert großskalige Schwungradspeicher, damit er kurzfristige Frequenzschwankungen abfängt.',
        controlRuleGerman:
            'Subjektidentität ("Der Netzbetreiber") lizenziert "um... zu"; bei trennbarem Verb "abfangen" rückt "zu" zwischen Präfix und Stamm ("ab-zu-fangen").',
        controlRuleArabic:
            'تطابق الفاعل (مشغل الشبكة) يُجيز (um... zu)، ويدخل (zu) داخل الفعل المنفصل: (abzufangen).',
        hasSeparableInnerZu: true,
      ),
      // 2. Final (damit bei verschiedenen Subjekten)
      const InfinitivalAdjunctModel(
        id: 'INF-4972-02',
        adjunctType: InfinitivalAdjunctType.finalUmZu,
        controlStatus: SubjectControlStatus.divergentSubjectsFiniteRequired,
        domain: CommunicativeDomain.aerospaceAndAviation,
        subordinatingPhrase: 'damit (Subjektwechsel)',
        fullGermanSentence:
            'Die Bodenmannschaft versorgt das geparkte Flugzeug mit externem Bodenstrom, damit die Bordavionik ohne Triebwerksstart hochgefahren werden kann.',
        ungrammaticalDanglingCounterExample:
            '*Die Bodenmannschaft versorgt das Flugzeug mit Bodenstrom, um die Bordavionik hochgefahren werden zu können (Subjektwechsel verbietet um... zu!).',
        finiteClauseAlternative:
            'Nur bei Subjektidentität möglich: Die Bordavionik wird mit Bodenstrom versorgt, um ohne Triebwerksstart hochgefahren zu werden.',
        controlRuleGerman:
            'Subjekt I = "Die Bodenmannschaft", Subjekt II = "die Bordavionik": Bei Subjektwechsel ist "damit" zwingend vorgeschrieben!',
        controlRuleArabic:
            'اختلاف الفاعلين (الطاقم الأرضي مقابل إلكترونيات الطائرة) يمنع (um... zu) ويفرض استخدام (damit).',
      ),
      // 3. Modal-negierter Begleitsatz (ohne... zu, Identisches Subjekt)
      const InfinitivalAdjunctModel(
        id: 'INF-4972-03',
        adjunctType: InfinitivalAdjunctType.modalNegatedOhneZu,
        controlStatus: SubjectControlStatus.identicalActiveSubject,
        domain: CommunicativeDomain.industrialRobotics,
        subordinatingPhrase: 'ohne ... zu überschreiten',
        fullGermanSentence:
            'Der kollaborative Roboterarm schwenkt mit hoher Geschwindigkeit zur Montagestation, ohne die zulässige Kontaktkraft von 150 Newton zu überschreiten.',
        ungrammaticalDanglingCounterExample:
            '*Der Roboterarm schwenkt zur Station, ohne dass zu überschreiten.',
        finiteClauseAlternative:
            'Der Roboterarm schwenkt zur Station, ohne dass er die zulässige Kontaktkraft überschreitet.',
        controlRuleGerman:
            '"ohne ... zu" bei identischem Subjekt ("Der Roboterarm"): Untrennbares Verb "überschreiten" erhält vorangestelltes "zu".',
        controlRuleArabic:
            'جملة حال منفية بـ (ohne... zu) لتطابق الفاعل (ذراع الروبوت)، مع وضع (zu) قبل الفعل غير المنفصل.',
      ),
      // 4. Modal-negierter Begleitsatz (ohne dass bei Subjektwechsel)
      const InfinitivalAdjunctModel(
        id: 'INF-4972-04',
        adjunctType: InfinitivalAdjunctType.modalNegatedOhneZu,
        controlStatus: SubjectControlStatus.divergentSubjectsFiniteRequired,
        domain: CommunicativeDomain.materialScience,
        subordinatingPhrase: 'ohne dass (Subjektwechsel)',
        fullGermanSentence:
            'Die lasergeschweißte Naht verbindet die beiden Aluminiumlegierungen dauerhaft, ohne dass sich eine spröde intermetallische Phase bildet.',
        ungrammaticalDanglingCounterExample:
            '*Die Naht verbindet die Legierungen, ohne sich eine spröde Phase zu bilden (verbotener Subjektwechsel!).',
        finiteClauseAlternative:
            'Nur bei Subjektwechsel zulässig: "ohne dass" mit Verbletztstellung ("bildet").',
        controlRuleGerman:
            'Subjekt I = "Die Naht", Subjekt II = "eine spröde Phase": Zwingt zu "ohne dass".',
        controlRuleArabic:
            'اختلاف الفاعلين (اللحام مقابل الطور الهش) يستوجب (ohne dass) ويُبطل الجملة المصدرية.',
      ),
      // 5. Substitutiver Infinitivsatz (anstatt... zu, trennbares Verb)
      const InfinitivalAdjunctModel(
        id: 'INF-4972-05',
        adjunctType: InfinitivalAdjunctType.substitutiveAnstattZu,
        controlStatus: SubjectControlStatus.identicalActiveSubject,
        domain: CommunicativeDomain.civilInfrastructure,
        subordinatingPhrase: 'anstatt ... abzudichten',
        fullGermanSentence:
            'Anstatt die feuchte Kellerwand von außen fachgerecht abzudichten, trug der Subunternehmer lediglich einen Innenputz auf.',
        ungrammaticalDanglingCounterExample:
            '*Anstatt die Kellerwand von außen abzudichten, wurde lediglich ein Innenputz aufgetragen (Subjektloses Passiv!).',
        finiteClauseAlternative:
            'Anstatt dass der Subunternehmer die Kellerwand abdichtete, trug er lediglich einen Innenputz auf.',
        controlRuleGerman:
            'Voranstellung von "anstatt ... zu" verlangt identisches Agens-Subjekt ("der Subunternehmer") im Hauptsatz.',
        controlRuleArabic:
            'تقديم (anstatt... zu) يشترط تطابق الفاعل (المقاول الفرعي) ويدمج (zu) داخل الفعل المنفصل (abzudichten).',
        hasSeparableInnerZu: true,
      ),
      // 6. Substitutiv (anstatt dass bei Subjektwechsel)
      const InfinitivalAdjunctModel(
        id: 'INF-4972-06',
        adjunctType: InfinitivalAdjunctType.substitutiveAnstattZu,
        controlStatus: SubjectControlStatus.divergentSubjectsFiniteRequired,
        domain: CommunicativeDomain.maritimeLogistics,
        subordinatingPhrase: 'anstatt dass (Subjektwechsel)',
        fullGermanSentence:
            'Die Schleusenkammer wurde manuell geflutet, anstatt dass das automatische Leitsystem die Einlassventile freigab.',
        ungrammaticalDanglingCounterExample:
            '*Die Schleusenkammer wurde geflutet, anstatt das Leitsystem die Ventile freizugeben.',
        finiteClauseAlternative:
            'Zwingender Nebensatz mit "anstatt dass" wegen Subjektwechsels (Schleusenkammer vs. Leitsystem).',
        controlRuleGerman:
            'Passiver Hauptsatz (Schleusenkammer) und aktiver Nebensatz (Leitsystem) erzwingen "anstatt dass".',
        controlRuleArabic:
            'تباين الفاعلين (حوض الهويس مقابل نظام التحكم) يفرض الصيغة الفعلية (anstatt dass).',
      ),
      // 7. Komparativer Infinitivanschluss (zu..., um... zu)
      const InfinitivalAdjunctModel(
        id: 'INF-4972-07',
        adjunctType: InfinitivalAdjunctType.comparativeExcessAlsZu,
        controlStatus: SubjectControlStatus.identicalActiveSubject,
        domain: CommunicativeDomain.aerospaceAndAviation,
        subordinatingPhrase: 'zu schwer, um ... zu erreichen',
        fullGermanSentence:
            'Die konventionelle Blei-Säure-Batterie ist bei Weitem zu schwer, um in der elektrischen Luftfahrt die geforderte Reichweite zu erreichen.',
        ungrammaticalDanglingCounterExample:
            '*Die Batterie ist zu schwer, um das Flugzeug die Reichweite zu erreichen (Subjektwechsel erfordert "als dass"!).',
        finiteClauseAlternative:
            'Die Batterie ist zu schwer, als dass sie die geforderte Reichweite erreichen könnte.',
        controlRuleGerman:
            '"zu + Adjektiv, um... zu" gilt nur bei Subjektidentität; bei Subjektwechsel muss "zu + Adjektiv, als dass + Konjunktiv II" stehen.',
        controlRuleArabic:
            'الصيغة التفاوتية (zu schwer, um... zu) تشترط تطابق الفاعل؛ وإلا وجب التحول لـ (als dass + Konjunktiv II).',
      ),
      // 8. Passivischer Infinitivsatz (um... getestet zu werden)
      const InfinitivalAdjunctModel(
        id: 'INF-4972-08',
        adjunctType: InfinitivalAdjunctType.finalUmZu,
        controlStatus: SubjectControlStatus.identicalPassiveSubject,
        domain: CommunicativeDomain.materialScience,
        subordinatingPhrase: 'um ... unterzogen zu werden',
        fullGermanSentence:
            'Die geschweißte Stahlprobe gelangt direkt in das Prüflabor, um einer zerstörungsfreien Ultraschallprüfung unterzogen zu werden.',
        ungrammaticalDanglingCounterExample:
            '*Die Stahlprobe gelangt ins Labor, um einer Ultraschallprüfung zu unterziehen (Aktiv/Passiv-Kollision!).',
        finiteClauseAlternative:
            'Die Stahlprobe gelangt in das Prüflabor, damit sie einer Ultraschallprüfung unterzogen wird.',
        controlRuleGerman:
            'Wenn das Subjekt ("Die Stahlprobe") Patient der Handlung ist, MUSS der Infinitivsatz im Vorgangspassiv ("... unterzogen zu werden") stehen!',
        controlRuleArabic:
            'بما أن الفاعل (عينة الفولاذ) هو المتأثر بالفحص، يجب بناء الجملة المصدرية للمجهول (unterzogen zu werden).',
      ),
      // 9. Unpersönliches Passiv (Verbot von um... zu!)
      const InfinitivalAdjunctModel(
        id: 'INF-4972-09',
        adjunctType: InfinitivalAdjunctType.finalUmZu,
        controlStatus: SubjectControlStatus.impersonalPassiveViolation,
        domain: CommunicativeDomain.industrialRobotics,
        subordinatingPhrase: 'damit (statt fehlerhaftem um... zu bei unpersönlichem Passiv)',
        fullGermanSentence:
            'Damit die Taktzeit verkürzt wird, wird in der Endmontage künftig mit zwei synchronisierten Portalen gearbeitet.',
        ungrammaticalDanglingCounterExample:
            '*Um die Taktzeit zu verkürzen, wird in der Endmontage mit zwei Portalen gearbeitet (Dangling Infinitive!).',
        finiteClauseAlternative:
            'Aktiv mit Subjekt: Um die Taktzeit zu verkürzen, arbeitet das Werk künftig mit zwei synchronisierten Portalen.',
        controlRuleGerman:
            'Häufigster C1-Fehler: Im unpersönlichen Passiv ("wird gearbeitet") existiert kein Subjekt; ein vorangestelltes "um... zu" hängt syntaktisch in der Luft!',
        controlRuleArabic:
            'أخطر أخطاء المستوى C1: وجود المبني للمجهول غير الشخصي بلا فاعل (wird gearbeitet) يحظر استخدام (um... zu) ويلزم (damit).',
      ),
      // 10. Restriktiver Ausnahmesatz (außer... zu)
      const InfinitivalAdjunctModel(
        id: 'INF-4972-10',
        adjunctType: InfinitivalAdjunctType.restrictiveAusserZu,
        controlStatus: SubjectControlStatus.identicalActiveSubject,
        domain: CommunicativeDomain.renewableEnergyGrid,
        subordinatingPhrase: 'außer ... abzuschalten',
        fullGermanSentence:
            'Bei akutem Kurzschluss im Mittelspannungsring blieb dem Netzschutz keine andere Wahl, außer den betroffenen Strang sofort abzuschalten.',
        ungrammaticalDanglingCounterExample:
            '*blieb keine andere Wahl, außer den Strang sofort abschalten (fehlendes "zu" im Infinitiv).',
        finiteClauseAlternative:
            'Es blieb keine andere Wahl, als dass der betroffene Strang abgeschaltet wurde.',
        controlRuleGerman:
            'Restriktives "außer" bindet einen Infinitivsatz mit "zu" (bei trennbarem Verb "ab-zu-schalten").',
        controlRuleArabic:
            'أداة الاستثناء (außer) ترتبط بالجملة المصدرية المقترنة بـ (zu) مع تفكيك الفعل (abzuschalten).',
        hasSeparableInnerZu: true,
      ),
      // 11. Modal-negierter Infinitiv (Passiv: ohne... beschädigt zu werden)
      const InfinitivalAdjunctModel(
        id: 'INF-4972-11',
        adjunctType: InfinitivalAdjunctType.modalNegatedOhneZu,
        controlStatus: SubjectControlStatus.identicalPassiveSubject,
        domain: CommunicativeDomain.civilInfrastructure,
        subordinatingPhrase: 'ohne ... beeinträchtigt zu werden',
        fullGermanSentence:
            'Die vorgespannte Brückenkonstruktion übersteht leichte Bodenabsenkungen, ohne in ihrer statischen Tragfähigkeit beeinträchtigt zu werden.',
        ungrammaticalDanglingCounterExample:
            '*Die Brückenkonstruktion übersteht Absenkungen, ohne in ihrer Tragfähigkeit zu beeinträchtigen.',
        finiteClauseAlternative:
            'Die Brückenkonstruktion übersteht Absenkungen, ohne dass ihre Tragfähigkeit beeinträchtigt wird.',
        controlRuleGerman:
            'Passivischer ohne-Infinitiv: Bewahrt die Patientenrolle des Subjekts ("Brückenkonstruktion") mittels "Partizip II + zu werden".',
        controlRuleArabic:
            'جملة حال منفية مبنية للمجهول (ohne... beeinträchtigt zu werden) للحفاظ على الدور الانفعالي للجسر.',
      ),
      // 12. Final (um... einzuleiten, trennbares Verb)
      const InfinitivalAdjunctModel(
        id: 'INF-4972-12',
        adjunctType: InfinitivalAdjunctType.finalUmZu,
        controlStatus: SubjectControlStatus.identicalActiveSubject,
        domain: CommunicativeDomain.maritimeLogistics,
        subordinatingPhrase: 'um ... einzuleiten',
        fullGermanSentence:
            'Der Kapitän aktiviert die Querstrahlruder am Bug, um das Anlegemanöver bei starker Querströmung kontrolliert einzuleiten.',
        ungrammaticalDanglingCounterExample:
            '*Der Kapitän aktiviert die Querstrahlruder, um zu einleiten (falsche Stellung von "zu" vor dem Präfix).',
        finiteClauseAlternative:
            'Der Kapitän aktiviert die Querstrahlruder, damit er das Anlegemanöver kontrolliert einleitet.',
        controlRuleGerman:
            'Trennbares Verb "einleiten": Das Infix "-zu-" tritt exakt zwischen "ein-" und "-leiten".',
        controlRuleArabic:
            'الفعل المنفصل (einleiten) يدمج أداة المصدر في المنتصف (einzuleiten) لإطلاق مناورة الرسو البحري.',
        hasSeparableInnerZu: true,
      ),
      // 13. Substitutiv (anstatt... auszutauschen, trennbar)
      const InfinitivalAdjunctModel(
        id: 'INF-4972-13',
        adjunctType: InfinitivalAdjunctType.substitutiveAnstattZu,
        controlStatus: SubjectControlStatus.identicalActiveSubject,
        domain: CommunicativeDomain.materialScience,
        subordinatingPhrase: 'anstatt ... auszutauschen',
        fullGermanSentence:
            'Anstatt die gesamte Keramikauskleidung kostspielig auszutauschen, versiegelten die Werkstofftechniker die Mikroporen mittels Plasmaspritzen.',
        ungrammaticalDanglingCounterExample:
            '*Anstatt die Keramikauskleidung zu austauschen, versiegelten die Techniker die Mikroporen.',
        finiteClauseAlternative:
            'Anstatt dass sie die Keramikauskleidung austauschten, versiegelten sie die Mikroporen.',
        controlRuleGerman:
            'Trennbares Verb "austauschen" mit zwingendem Binnen-"zu": "aus-zu-tauschen".',
        controlRuleArabic:
            'تقديم الاستبدال المصدري مع الفعل المنفصل (auszutauschen) بوضع (zu) بين السابقة والجذر.',
        hasSeparableInnerZu: true,
      ),
      // 14. Modal-negierter Infinitiv (ohne... aufzugeben, trennbar)
      const InfinitivalAdjunctModel(
        id: 'INF-4972-14',
        adjunctType: InfinitivalAdjunctType.modalNegatedOhneZu,
        controlStatus: SubjectControlStatus.identicalActiveSubject,
        domain: CommunicativeDomain.aerospaceAndAviation,
        subordinatingPhrase: 'ohne ... aufzugeben',
        fullGermanSentence:
            'Das autonome Flugsteuersystem kompensiert den Ausfall eines Höhenruders, ohne die aerodynamische Lagestabilität aufzugeben.',
        ungrammaticalDanglingCounterExample:
            '*Das Flugsteuersystem kompensiert den Ausfall, ohne die Lagestabilität zu aufgeben.',
        finiteClauseAlternative:
            'Das System kompensiert den Ausfall, ohne dass es die Lagestabilität aufgibt.',
        controlRuleGerman:
            'Trennbares Verb "aufgeben" im modalen ohne-Satz: "auf-zu-geben".',
        controlRuleArabic:
            'جملة حال منفية مع فعل منفصل (aufzugeben) لتأكيد الحفاظ على توازن الطائرة رغم العطل.',
        hasSeparableInnerZu: true,
      ),
      // 15. Komparativer Infinitivanschluss (zu..., um... zu bei Passiv)
      const InfinitivalAdjunctModel(
        id: 'INF-4972-15',
        adjunctType: InfinitivalAdjunctType.comparativeExcessAlsZu,
        controlStatus: SubjectControlStatus.identicalPassiveSubject,
        domain: CommunicativeDomain.renewableEnergyGrid,
        subordinatingPhrase: 'zu instabil, um ... zugeschaltet zu werden',
        fullGermanSentence:
            'Die Inselnetz-Frequenz war nach dem Gewitter noch zu instabil, um sofort wieder dem Verbundnetz zugeschaltet zu werden.',
        ungrammaticalDanglingCounterExample:
            '*Die Frequenz war zu instabil, um dem Verbundnetz zuzuschalten (fehlender Passivinfinitiv!).',
        finiteClauseAlternative:
            'Die Frequenz war zu instabil, als dass sie sofort wieder dem Verbundnetz hätte zugeschaltet werden können.',
        controlRuleGerman:
            'Passivische Zu-Um-Zu-Konstruktion mit trennbarem Partizip II ("zugeschaltet zu werden").',
        controlRuleArabic:
            'تركيب تفاوتي مانع مبني للمجهول: تردد الشبكة غير مستقر لدرجة تحول دون إعادة ربطه بالشبكة الموحدة.',
      ),
      // 16. Final (damit bei Subjektwechsel im Prüffeld)
      const InfinitivalAdjunctModel(
        id: 'INF-4972-16',
        adjunctType: InfinitivalAdjunctType.finalUmZu,
        controlStatus: SubjectControlStatus.divergentSubjectsFiniteRequired,
        domain: CommunicativeDomain.industrialRobotics,
        subordinatingPhrase: 'damit (Subjektwechsel)',
        fullGermanSentence:
            'Der Konstrukteur platziert die optische Sicherheitslichtschranke im Mindestabstand von 80 Zentimetern, damit die Roboterachse vor Körperkontakt vollständig zum Stillstand kommt.',
        ungrammaticalDanglingCounterExample:
            '*Der Konstrukteur platziert die Lichtschranke, um die Roboterachse zum Stillstand zu kommen.',
        finiteClauseAlternative:
            'Subjektwechsel (Konstrukteur -> Roboterachse) macht "damit" unverzichtbar.',
        controlRuleGerman:
            'Strikte Trennung der Aktanten verhindert gefährliche Syntax-Ambiguitäten in Sicherheitsnormen.',
        controlRuleArabic:
            'تباين الفاعلين (المصمم مقابل محور الروبوت) يوجب استخدام (damit) لضمان وضوح لوائح الأمان.',
      ),
    ]);
  }

  List<InfinitivalAdjunctModel> getByType(InfinitivalAdjunctType type) =>
      _catalog.where((i) => i.adjunctType == type).toList();

  List<InfinitivalAdjunctModel> getByControlStatus(SubjectControlStatus status) =>
      _catalog.where((i) => i.controlStatus == status).toList();

  List<InfinitivalAdjunctModel> getByDomain(CommunicativeDomain domain) =>
      _catalog.where((i) => i.domain == domain).toList();

  /// Validates subject identity constraints, impersonal passive prohibitions, and separable "zu".
  InfinitivalAdjunctValidationResult validateInfinitivalAdjunct({
    required SubjectControlStatus controlStatus,
    required bool usesInfinitiveUmOhneStattZu,
    required bool isSeparableVerb,
    required bool hasInnerZuInSeparableVerb,
    required bool matchesPassiveVoiceWhenSubjectIsPatient,
  }) {
    final List<String> issues = [];
    final List<String> notes = [];

    // Rule 1: Subject Identity Enforcement
    if (usesInfinitiveUmOhneStattZu) {
      if (controlStatus == SubjectControlStatus.divergentSubjectsFiniteRequired) {
        issues.add(
            'Subjektkontroll-Verstoß: Bei unterschiedlichen Subjekten in Haupt- und Nebensatz ist der Infinitivsatz (um/ohne/anstatt... zu) streng verboten! Nutzen Sie "damit / ohne dass / anstatt dass".');
      } else if (controlStatus == SubjectControlStatus.impersonalPassiveViolation) {
        issues.add(
            'Dangling-Modifier-Fehler: Im unpersönlichen Passiv ("wird gearbeitet") existiert kein Subjekt. Ein Infinitivsatz mit "um... zu" ist ungrammatisch!');
      } else {
        notes.add('Kontrollregel konform: Identisches Subjekt lizenziert den Infinitivanschluss.');
      }
    } else {
      if (controlStatus == SubjectControlStatus.divergentSubjectsFiniteRequired ||
          controlStatus == SubjectControlStatus.impersonalPassiveViolation) {
        notes.add('Normgerecht: Finiter Nebensatz (damit / ohne dass / anstatt dass) vermeidet Subjektbruch.');
      }
    }

    // Rule 2: Separable verb inner "zu"
    if (usesInfinitiveUmOhneStattZu && isSeparableVerb && !hasInnerZuInSeparableVerb) {
      issues.add(
          'Morphologie-Fehler: Bei trennbaren Verben muss "zu" im Infinitiv exakt zwischen Präfix und Verbstamm stehen (z. B. ab-zu-schalten, nicht *"zu abschalten").');
    } else if (usesInfinitiveUmOhneStattZu && isSeparableVerb) {
      notes.add('Morphologisch korrekt: Infix "-zu-" zwischen Vorsilbe und Stamm eingefügt.');
    }

    // Rule 3: Passive voice when subject is patient
    if (!matchesPassiveVoiceWhenSubjectIsPatient) {
      issues.add(
          'Diathesen-Fehler: Ist das gemeinsame Subjekt Patient der Infinitivhandlung, muss der Passivinfinitiv ("... geprüft zu werden") verwendet werden.');
    }

    return InfinitivalAdjunctValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      syntacticNotes: notes,
    );
  }

  Map<String, dynamic> generateTelemetrySnapshot() {
    return {
      'totalExemplars': _catalog.length,
      'adjunctTypeDistribution': {
        for (var t in InfinitivalAdjunctType.values)
          t.name: _catalog.where((i) => i.adjunctType == t).length,
      },
      'controlStatusDistribution': {
        for (var s in SubjectControlStatus.values)
          s.name: _catalog.where((i) => i.controlStatus == s).length,
      },
      'domainDistribution': {
        for (var d in CommunicativeDomain.values)
          d.name: _catalog.where((i) => i.domain == d).length,
      },
      'separableInnerZuCount': _catalog.where((i) => i.hasSeparableInnerZu).length,
      'cefrLevel': 'CEFR C1-C2 Masterclass Infinitival Adjuncts & Subject Control',
      'engineVersion': '1.0.0+subsystem1806',
    };
  }
}
