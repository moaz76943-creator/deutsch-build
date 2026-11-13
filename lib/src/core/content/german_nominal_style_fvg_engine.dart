import 'dart:collection';

/// Classification of aspectual Aktionsart in German Functional Verb Complexes (Funktionsverbgefüge).
enum FvgAktionsartType {
  inchoativeStateEntry(
    'Inchoativ (Zustandseintritt / Prozessbeginn: in Betrieb nehmen, in Gang setzen)',
    'الدخول في الحالة وبدء العملية التشغيلية (in Betrieb nehmen / zur Anwendung bringen)',
    'Kennzeichnet den aktiven Beginn eines technischen Vorgangs oder die Inbetriebnahme eines Aggregats.',
  ),
  durativeStateContinuance(
    'Durativ (Zustandsfortdauer: in Betrieb sein, in Gang halten, unter Beobachtung stehen)',
    'استمرار الحالة والدوام التشغيلي (in Betrieb sein / zur Anwendung kommen)',
    'Drückt das ununterbrochene Fortdauern eines technischen Zustands oder einer Überwachung aus.',
  ),
  terminativeStateClosure(
    'Terminativ (Zustandsabschluss: außer Betrieb setzen, zum Abschluss bringen)',
    'إنهاء الحالة وإغلاق العملية التشغيلية (außer Betrieb setzen / zum Abschluss bringen)',
    'Signalisiert die kontrollierte Beendigung, Stilllegung oder den erfolgreichen Projektabschluss.',
  ),
  causativeAction(
    'Kausativ / Aktiv (Veranlassung durch Agens: zur Verfügung stellen, unter Beweis stellen)',
    'التسبيب والتوفير الفعال (zur Verfügung stellen / unter Beweis stellen)',
    'Das Subjekt bewirkt aktiv, dass eine Ressource oder ein Nachweis für Dritte bereitgestellt wird.',
  ),
  perceptivePassiveEquivalence(
    'Passiväquivalent / Rezipient (zur Verfügung stehen, Beachtung finden)',
    'المكافئ المبني للمجهول والاستقبالي (zur Verfügung stehen / Beachtung finden)',
    'Das grammatische Subjekt erfährt den Prozess passiv oder profitiert von einer bereitgestellten Leistung.',
  );

  final String deTitle;
  final String arTitle;
  final String aspectualDefinition;
  const FvgAktionsartType(this.deTitle, this.arTitle, this.aspectualDefinition);
}

/// Prepositional rection and case governance in technical FVG.
enum PrepositionalRektionCase {
  inPlusAccusative('in + Akkusativ (in Betrieb nehmen, in Betracht ziehen)', 'in + حالة النصب (حركي غائي)'),
  inPlusDative('in + Dativ (in Betrieb sein, in Gang halten)', 'in + حالة الجر (موقعي استقراري)'),
  zuPlusDative('zu/zur/zum + Dativ (zur Anwendung bringen/kommen, zum Abschluss bringen)', 'zu + حالة الجر (غائي إنجازي)'),
  unterPlusDative('unter + Dativ (unter Beobachtung stehen, unter Aufsicht arbeiten)', 'unter + حالة الجر (خضوع رقابي مستقر)'),
  unterPlusAccusative('unter + Akkusativ (unter Beweis stellen, unter Druck setzen)', 'unter + حالة النصب (إخضاع فعال للبرهان أو الضغط)'),
  aufPlusAccusative('auf + Akkusativ (Bezug nehmen auf, Rücksicht nehmen auf)', 'auf + حالة النصب (إحالة ومرجعية تقنية)'),
  pureAccusativeNoPreposition('Reines Akkusativobjekt ohne Präposition (eine Entscheidung treffen)', 'مفعول به صريح مجرد دون حرف جر');

  final String de;
  final String ar;
  const PrepositionalRektionCase(this.de, this.ar);
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

/// Structural model of a German Nominal Style vs. Verbal Style occurrence.
class NominalStyleFvgModel {
  final String id;
  final FvgAktionsartType aktionsartType;
  final PrepositionalRektionCase rektionCase;
  final CommunicativeDomain domain;
  final String fvgExpression;
  final String baseVerbEquivalent;
  final String nominalStyleSentence;
  final String verbalizedPlainSentence;
  final String operationalContextGerman;
  final String operationalContextArabic;
  final String prepositionalRektionRule;

  const NominalStyleFvgModel({
    required this.id,
    required this.aktionsartType,
    required this.rektionCase,
    required this.domain,
    required this.fvgExpression,
    required this.baseVerbEquivalent,
    required this.nominalStyleSentence,
    required this.verbalizedPlainSentence,
    required this.operationalContextGerman,
    required this.operationalContextArabic,
    required this.prepositionalRektionRule,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'aktionsartType': aktionsartType.name,
    'rektionCase': rektionCase.name,
    'domain': domain.name,
    'fvgExpression': fvgExpression,
    'baseVerbEquivalent': baseVerbEquivalent,
    'nominalStyleSentence': nominalStyleSentence,
    'verbalizedPlainSentence': verbalizedPlainSentence,
    'operationalContextGerman': operationalContextGerman,
    'operationalContextArabic': operationalContextArabic,
    'prepositionalRektionRule': prepositionalRektionRule,
  };
}

/// Validation result for FVG syntax and verbal-nominal conversion.
class FvgValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<String> stylisticNotes;

  const FvgValidationResult({
    required this.isValid,
    required this.issues,
    required this.stylisticNotes,
  });
}

/// Core Engine managing German Nominal Style & Functional Verb Complexes.
class GermanNominalStyleFvgEngine {
  final List<NominalStyleFvgModel> _catalog = [];

  GermanNominalStyleFvgEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<NominalStyleFvgModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    _catalog.addAll([
      // 1. in Betrieb nehmen (Inchoativ, in + Akk)
      const NominalStyleFvgModel(
        id: 'FVG-4964-01',
        aktionsartType: FvgAktionsartType.inchoativeStateEntry,
        rektionCase: PrepositionalRektionCase.inPlusAccusative,
        domain: CommunicativeDomain.renewableEnergyGrid,
        fvgExpression: 'in Betrieb nehmen',
        baseVerbEquivalent: 'inbetriebsetzen / starten',
        nominalStyleSentence:
            'Die Netzbetreiber nehmen die neue 110-kV-Gasisolierte Schaltanlage nach erfolgreicher Druckprüfung feierlich in Betrieb.',
        verbalizedPlainSentence:
            'Die Netzbetreiber starten die neue 110-kV-Schaltanlage, nachdem sie die Druckprüfung erfolgreich bestanden hat.',
        operationalContextGerman:
            'Inchoativer Beginn des Netzbetriebs: "in Betrieb nehmen" betont den formalen Rechtsakt der Inbetriebnahme.',
        operationalContextArabic:
            'الدخول في الخدمة التشغيلية: تركيب وظيفي (in Betrieb nehmen) يعبر عن التدشين الرسمي لمحطة التوزيع الكهربائي.',
        prepositionalRektionRule: 'Feste Rektion: "in" + Akkusativ maskulin ("in [den] Betrieb").',
      ),
      // 2. in Betrieb sein (Durativ, in + Dat)
      const NominalStyleFvgModel(
        id: 'FVG-4964-02',
        aktionsartType: FvgAktionsartType.durativeStateContinuance,
        rektionCase: PrepositionalRektionCase.inPlusDative,
        domain: CommunicativeDomain.renewableEnergyGrid,
        fvgExpression: 'in Betrieb sein',
        baseVerbEquivalent: 'laufen / arbeiten',
        nominalStyleSentence:
            'Die Offshore-Windenergieanlage ist seit über 72 Stunden unter Volllastbedingungen störungsfrei in Betrieb.',
        verbalizedPlainSentence:
            'Die Offshore-Windenergieanlage läuft seit über 72 Stunden störungsfrei mit voller Leistung.',
        operationalContextGerman:
            'Durativer Zustand: "in Betrieb sein" beschreibt die kontinuierliche Stromerzeugung ohne Unterbrechung.',
        operationalContextArabic:
            'استمرار تشغيلي دائم: تركيب وظيفي في حالة الجر (in Betrieb sein) يصف استمرار عمل التوربين البحري دون انقطاع.',
        prepositionalRektionRule: 'Feste Rektion: "in" + Dativ ("im/in Betrieb sein").',
      ),
      // 3. außer Betrieb setzen (Terminativ, Dativ/Akkusativ)
      const NominalStyleFvgModel(
        id: 'FVG-4964-03',
        aktionsartType: FvgAktionsartType.terminativeStateClosure,
        rektionCase: PrepositionalRektionCase.inPlusAccusative,
        domain: CommunicativeDomain.aerospaceAndAviation,
        fvgExpression: 'außer Betrieb setzen',
        baseVerbEquivalent: 'stilllegen / abschalten',
        nominalStyleSentence:
            'Der Flugingenieur setzt das fehlerhafte Hilfstriebwerk infolge überhöhter Abgastemperaturen vorsorglich außer Betrieb.',
        verbalizedPlainSentence:
            'Der Flugingenieur schaltet das Hilfstriebwerk ab, weil die Abgastemperaturen zu stark ansteigen.',
        operationalContextGerman:
            'Terminativer Abschluss: Kontrollierte Stilllegung zur Vermeidung von Triebwerksschäden.',
        operationalContextArabic:
            'إخراج المنظومة من الخدمة: تركيب وظيفي منهي للعملية (außer Betrieb setzen) لإيقاف المحرك المساعد احترازياً.',
        prepositionalRektionRule: 'Feste Rektion: "außer" + Dativ ("außer Betrieb").',
      ),
      // 4. zur Anwendung bringen (Kausativ, zu + Dat)
      const NominalStyleFvgModel(
        id: 'FVG-4964-04',
        aktionsartType: FvgAktionsartType.causativeAction,
        rektionCase: PrepositionalRektionCase.zuPlusDative,
        domain: CommunicativeDomain.materialScience,
        fvgExpression: 'zur Anwendung bringen',
        baseVerbEquivalent: 'anwenden / einsetzen',
        nominalStyleSentence:
            'Die Werkstoffprüfer bringen bei der Rissprüfung ein fluoreszierendes Farbeindringverfahren zur Anwendung.',
        verbalizedPlainSentence:
            'Die Werkstoffprüfer wenden ein fluoreszierendes Farbeindringverfahren an, um Risse im Metall zu prüfen.',
        operationalContextGerman:
            'Kausative Veranlassung: Das Prüfteam wendet die fluoreszierende Methode gezielt an.',
        operationalContextArabic:
            'تطبيق إجرائي فاعل: وضع تقنية الفحص بالأصباغ الفلورية قيد التطبيق الميداني الفعلي للكشف عن الشروخ.',
        prepositionalRektionRule: 'Feste Rektion: "zu" + Dativ feminin ("zur Anwendung").',
      ),
      // 5. zur Anwendung kommen (Passiväquivalent, zu + Dat)
      const NominalStyleFvgModel(
        id: 'FVG-4964-05',
        aktionsartType: FvgAktionsartType.perceptivePassiveEquivalence,
        rektionCase: PrepositionalRektionCase.zuPlusDative,
        domain: CommunicativeDomain.materialScience,
        fvgExpression: 'zur Anwendung kommen',
        baseVerbEquivalent: 'angewendet werden',
        nominalStyleSentence:
            'Bei der Fertigung von Turbinenschaufeln kommt bevorzugt das Vakuum-Feingussverfahren zur Anwendung.',
        verbalizedPlainSentence:
            'Wenn Turbinenschaufeln gefertigt werden, wird bevorzugt das Vakuum-Feingussverfahren angewendet.',
        operationalContextGerman:
            'Passivisches FVG: Das Gussverfahren wird angewendet, ohne dass der Gießer explizit genannt werden muss.',
        operationalContextArabic:
            'مكافئ مبني للمجهول: تقنية الصب الدقيق في التفريغ تطبق كخيار مفضل لصناعة شفرات التوربينات.',
        prepositionalRektionRule: 'Feste Rektion: "zu" + Dativ feminin ("zur Anwendung").',
      ),
      // 6. unter Beweis stellen (Kausativ, unter + Akk)
      const NominalStyleFvgModel(
        id: 'FVG-4964-06',
        aktionsartType: FvgAktionsartType.causativeAction,
        rektionCase: PrepositionalRektionCase.unterPlusAccusative,
        domain: CommunicativeDomain.industrialRobotics,
        fvgExpression: 'unter Beweis stellen',
        baseVerbEquivalent: 'beweisen / nachweisen',
        nominalStyleSentence:
            'Der Knickarmroboter stellte seine dynamische Wiederholgenauigkeit von 0,02 Millimetern im Dauertest unter Beweis.',
        verbalizedPlainSentence:
            'Der Roboter bewies im Dauertest, dass er Punkte bis auf 0,02 Millimeter genau wiederholt anfahren kann.',
        operationalContextGerman:
            'Kausativer Leistungsnachweis: Betont das erfolgreiche Erbringen des Genauigkeitsbeweises.',
        operationalContextArabic:
            'إثبات الكفاءة عملياً: إخضاع دقة تكرار حركة الروبوت للبرهان القطعي أثناء اختبارات التحمل الشاقة.',
        prepositionalRektionRule: 'Feste Rektion: "unter" + Akkusativ maskulin ("unter Beweis").',
      ),
      // 7. zur Verfügung stehen (Passiväquivalent, zu + Dat)
      const NominalStyleFvgModel(
        id: 'FVG-4964-07',
        aktionsartType: FvgAktionsartType.perceptivePassiveEquivalence,
        rektionCase: PrepositionalRektionCase.zuPlusDative,
        domain: CommunicativeDomain.civilInfrastructure,
        fvgExpression: 'zur Verfügung stehen',
        baseVerbEquivalent: 'verfügbar sein / bereitstehen',
        nominalStyleSentence:
            'Für die statische Sanierung des Autobahnviadukts stehen ausreichend Spezialpressen zur Verfügung.',
        verbalizedPlainSentence:
            'Die Bauleiter können für die Sanierung des Viadukts genügend Spezialpressen nutzen.',
        operationalContextGerman:
            'Verfügbarkeitszustand: Ausrüstung ist vorhanden und einsatzbereit.',
        operationalContextArabic:
            'جاهزية الموارد: المكابس الهيدروليكية الخاصة متاحة وتحت تصرف فريق ترميم الجسر الخرساني.',
        prepositionalRektionRule: 'Feste Rektion: "zu" + Dativ feminin ("zur Verfügung").',
      ),
      // 8. zur Verfügung stellen (Kausativ, zu + Dat)
      const NominalStyleFvgModel(
        id: 'FVG-4964-08',
        aktionsartType: FvgAktionsartType.causativeAction,
        rektionCase: PrepositionalRektionCase.zuPlusDative,
        domain: CommunicativeDomain.civilInfrastructure,
        fvgExpression: 'zur Verfügung stellen',
        baseVerbEquivalent: 'bereitstellen / überlassen',
        nominalStyleSentence:
            'Die Maschinenbaufirma stellt den Bauleitern mobile Schwerlastkräne termingerecht zur Verfügung.',
        verbalizedPlainSentence:
            'Die Maschinenbaufirma stellt den Bauleitern pünktlich mobile Schwerlastkräne bereit.',
        operationalContextGerman:
            'Aktives Bereitstellen von Baumaschinen durch das Lieferunternehmen.',
        operationalContextArabic:
            'توفير الإمكانيات: تضع شركة المقاولات الرافعات الثقيلة تحت تصرف مهندسي الموقع في الموعد المحدد.',
        prepositionalRektionRule: 'Feste Rektion: "zu" + Dativ feminin ("zur Verfügung").',
      ),
      // 9. unter Beobachtung stehen (Durativ, unter + Dat)
      const NominalStyleFvgModel(
        id: 'FVG-4964-09',
        aktionsartType: FvgAktionsartType.durativeStateContinuance,
        rektionCase: PrepositionalRektionCase.unterPlusDative,
        domain: CommunicativeDomain.maritimeLogistics,
        fvgExpression: 'unter Beobachtung stehen',
        baseVerbEquivalent: 'beobachtet werden',
        nominalStyleSentence:
            'Der Schleusenbereich steht während der Passage des Großtankers unter lückenloser Radarüberwachung.',
        verbalizedPlainSentence:
            'Radargeräte überwachen den Schleusenbereich lückenlos, während der Großtanker hindurchfährt.',
        operationalContextGerman:
            'Passivisch-durativer Überwachungszustand zur Gewährleistung der Schifffahrtssicherheit.',
        operationalContextArabic:
            'حالة خضوع للرقابة: حوض هويس القناة يقع تحت المراقبة الرادارية الدقيقة أثناء عبور ناقلة النفط.',
        prepositionalRektionRule: 'Feste Rektion: "unter" + Dativ feminin ("unter Beobachtung").',
      ),
      // 10. in Erwägung ziehen (Kausativ / Kognitiv, in + Akk)
      const NominalStyleFvgModel(
        id: 'FVG-4964-10',
        aktionsartType: FvgAktionsartType.causativeAction,
        rektionCase: PrepositionalRektionCase.inPlusAccusative,
        domain: CommunicativeDomain.aerospaceAndAviation,
        fvgExpression: 'in Erwägung ziehen',
        baseVerbEquivalent: 'erwägen / prüfen',
        nominalStyleSentence:
            'Die Systemarchitekten ziehen bei der Neukonstruktion des Rumpfes kohlenstofffaserverstärkte Kunststoffe in Erwägung.',
        verbalizedPlainSentence:
            'Die Systemarchitekten erwägen, für den neuen Rumpf kohlenstofffaserverstärkte Kunststoffe zu verwenden.',
        operationalContextGerman:
            'Planerische Entscheidungsfindung im Entwicklungsstadium.',
        operationalContextArabic:
            'دراسة الخيارات الهندسية: يضع معماريو الطيران استخدام بوليمرات ألياف الكربون قيد الدراسة والاعتبار.',
        prepositionalRektionRule: 'Feste Rektion: "in" + Akkusativ feminin ("in Erwägung").',
      ),
      // 11. zum Abschluss bringen (Terminativ, zu + Dat)
      const NominalStyleFvgModel(
        id: 'FVG-4964-11',
        aktionsartType: FvgAktionsartType.terminativeStateClosure,
        rektionCase: PrepositionalRektionCase.zuPlusDative,
        domain: CommunicativeDomain.industrialRobotics,
        fvgExpression: 'zum Abschluss bringen',
        baseVerbEquivalent: 'abschließen / beenden',
        nominalStyleSentence:
            'Das Entwicklerteam bringt die Software-Zertifizierung des Roboter-Controllers erfolgreich zum Abschluss.',
        verbalizedPlainSentence:
            'Das Team schließt die Software-Zertifizierung des Roboter-Controllers erfolgreich ab.',
        operationalContextGerman:
            'Terminative Vollendung eines Meilensteins im agilen Entwicklungszyklus.',
        operationalContextArabic:
            'إتمام وإغلاق المرحلة: إنجاز متطلبات اعتماد برمجيات وحدة تحكم الروبوت بنجاح واختتامها رسمياً.',
        prepositionalRektionRule: 'Feste Rektion: "zu" + Dativ maskulin ("zum Abschluss").',
      ),
      // 12. zur Kenntnis nehmen (Rezipient / Kognitiv, zu + Dat)
      const NominalStyleFvgModel(
        id: 'FVG-4964-12',
        aktionsartType: FvgAktionsartType.perceptivePassiveEquivalence,
        rektionCase: PrepositionalRektionCase.zuPlusDative,
        domain: CommunicativeDomain.renewableEnergyGrid,
        fvgExpression: 'zur Kenntnis nehmen',
        baseVerbEquivalent: 'bemerken / registrieren',
        nominalStyleSentence:
            'Die Leitstandsfahrer nehmen die automatisierte Alarmmeldung über die Frequenzabweichung unverzüglich zur Kenntnis.',
        verbalizedPlainSentence:
            'Die Leitstandsfahrer registrieren die Alarmmeldung über die Frequenzabweichung sofort.',
        operationalContextGerman:
            'Formales Registrieren eines Alarms im Leitsystem ohne emotionale Bewertung.',
        operationalContextArabic:
            'الإحاطة والتسجيل الرسمي: إحاطة مشغلي غرفة التحكم بإنذار انحراف التردد الكهربائي وتوثيقه فوراً.',
        prepositionalRektionRule: 'Feste Rektion: "zu" + Dativ feminin ("zur Kenntnis").',
      ),
      // 13. Bezug nehmen auf (Präpositionales Objekt, auf + Akk)
      const NominalStyleFvgModel(
        id: 'FVG-4964-13',
        aktionsartType: FvgAktionsartType.causativeAction,
        rektionCase: PrepositionalRektionCase.aufPlusAccusative,
        domain: CommunicativeDomain.materialScience,
        fvgExpression: 'Bezug nehmen auf',
        baseVerbEquivalent: 'sich beziehen auf',
        nominalStyleSentence:
            'Der Schadensbericht nimmt detailliert Bezug auf die im Labor ermittelten Schwingungsdaten.',
        verbalizedPlainSentence:
            'Der Schadensbericht bezieht sich detailliert auf die Schwingungsdaten, die das Labor ermittelt hat.',
        operationalContextGerman:
            'Referenzierung im Gutachtenstil: Formale Verknüpfung von Befund und Messreihe.',
        operationalContextArabic:
            'الإسناد المرجعي: استناد تقرير الأضرار بدقة وتفصيل إلى بيانات الاهتزازات المحسوبة في المختبر.',
        prepositionalRektionRule: 'Feste Rektion: "auf" + Akkusativ ("Bezug nehmen auf + Akk").',
      ),
      // 14. in Gang setzen (Inchoativ, in + Akk)
      const NominalStyleFvgModel(
        id: 'FVG-4964-14',
        aktionsartType: FvgAktionsartType.inchoativeStateEntry,
        rektionCase: PrepositionalRektionCase.inPlusAccusative,
        domain: CommunicativeDomain.maritimeLogistics,
        fvgExpression: 'in Gang setzen',
        baseVerbEquivalent: 'anwerfen / starten',
        nominalStyleSentence:
            'Der Maschinist setzt die Notkühlpumpen über die autarke USV-Batterieanlage unverzüglich in Gang.',
        verbalizedPlainSentence:
            'Der Maschinist startet die Notkühlpumpen sofort mithilfe der autarken USV-Batterie.',
        operationalContextGerman:
            'Inchoativer Notstart: Mechanisches oder elektrisches Ingangsetzen von Nebenaggregaten.',
        operationalContextArabic:
            'تشغيل وتحريك المنظومة: تشغيل مضخات التبريد الطارئة فوراً بالاعتماد على بطاريات التغذية اللامنقطعة.',
        prepositionalRektionRule: 'Feste Rektion: "in" + Akkusativ maskulin ("in Gang").',
      ),
      // 15. eine Entscheidung treffen (Reines Akkusativobjekt)
      const NominalStyleFvgModel(
        id: 'FVG-4964-15',
        aktionsartType: FvgAktionsartType.causativeAction,
        rektionCase: PrepositionalRektionCase.pureAccusativeNoPreposition,
        domain: CommunicativeDomain.civilInfrastructure,
        fvgExpression: 'eine Entscheidung treffen',
        baseVerbEquivalent: 'sich entscheiden / beschließen',
        nominalStyleSentence:
            'Die Baukommission trifft hinsichtlich der Tiefgründungsmethode eine technisch fundierte Entscheidung.',
        verbalizedPlainSentence:
            'Die Baukommission entscheidet sich nach gründlicher technischer Prüfung für eine Tiefgründungsmethode.',
        operationalContextGerman:
            'Verbindlicher Beschluss über Gründungsvarianten im Brückenbau.',
        operationalContextArabic:
            'اتخاذ القرار الهندسي: اتخاذ لجنة التشييد قراراً فنياً حاسماً ومدروساً بشأن طريقة حفر الأساسات العميقة.',
        prepositionalRektionRule: 'Feste Verbindung: "eine Entscheidung treffen" (Akkusativobjekt).',
      ),
      // 16. unter Spannung setzen (Kausativ, unter + Akk)
      const NominalStyleFvgModel(
        id: 'FVG-4964-16',
        aktionsartType: FvgAktionsartType.causativeAction,
        rektionCase: PrepositionalRektionCase.unterPlusAccusative,
        domain: CommunicativeDomain.renewableEnergyGrid,
        fvgExpression: 'unter Spannung setzen',
        baseVerbEquivalent: 'zuschalten / bestromen',
        nominalStyleSentence:
            'Die Elektrofachkraft setzt den transformierten Strangabschnitt erst nach Freigabe aller Schutzbereiche unter Spannung.',
        verbalizedPlainSentence:
            'Die Elektrofachkraft schaltet den Strom erst ein, wenn alle Schutzbereiche freigegeben sind.',
        operationalContextGerman:
            'Elektrotechnischer Sicherheitsvorgang: Bestromung erst nach formaler Freigabeprozedur.',
        operationalContextArabic:
            'تطبيق الجهد الكهربائي: وضع قطاع الكابلات تحت الجهد وتمرير التيار فقط بعد إخلاء مناطق الأمان.',
        prepositionalRektionRule: 'Feste Rektion: "unter" + Akkusativ feminin ("unter Spannung").',
      ),
    ]);
  }

  List<NominalStyleFvgModel> getByAktionsart(FvgAktionsartType type) =>
      _catalog.where((f) => f.aktionsartType == type).toList();

  List<NominalStyleFvgModel> getByRektionCase(PrepositionalRektionCase rektion) =>
      _catalog.where((f) => f.rektionCase == rektion).toList();

  List<NominalStyleFvgModel> getByDomain(CommunicativeDomain domain) =>
      _catalog.where((f) => f.domain == domain).toList();

  /// Validates prepositional rection, Aktionsart pairing, and verbalization clarity.
  FvgValidationResult validateFvgStructure({
    required String fvgExpression,
    required PrepositionalRektionCase rektionCase,
    required bool isPrepositionCorrect,
    required bool isVerbalAlternativeEquipollent,
  }) {
    final List<String> issues = [];
    final List<String> notes = [];

    if (!isPrepositionCorrect) {
      issues.add(
          'Rektionsfehler im FVG: Die Verbindung "$fvgExpression" verlangt eine feste Präposition und einen festen Kasus. Abweichungen verletzen das idiomatisierte Gefüge.');
    } else {
      notes.add('Rektion normgerecht: Präposition und Kasus stimmen exakt mit dem FVG-Katalog überein.');
    }

    if (!isVerbalAlternativeEquipollent) {
      issues.add(
          'Dekompositionsfehler: Die verbalisierte Plain-Language-Alternative muss bedeutungsgleich ohne Informationsverlust formuliert sein.');
    } else {
      notes.add('Stilistisch ausgewogen: Verbale Plain-Language-Paraphrase gewährleistet optimale Lesbarkeit in Betriebsanweisungen.');
    }

    return FvgValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      stylisticNotes: notes,
    );
  }

  Map<String, dynamic> generateTelemetrySnapshot() {
    return {
      'totalExemplars': _catalog.length,
      'aktionsartDistribution': {
        for (var a in FvgAktionsartType.values)
          a.name: _catalog.where((f) => f.aktionsartType == a).length,
      },
      'rektionDistribution': {
        for (var r in PrepositionalRektionCase.values)
          r.name: _catalog.where((f) => f.rektionCase == r).length,
      },
      'domainDistribution': {
        for (var d in CommunicativeDomain.values)
          d.name: _catalog.where((f) => f.domain == d).length,
      },
      'cefrLevel': 'CEFR C1-C2 Masterclass Nominal Style & FVG Deconstruction',
      'engineVersion': '1.0.0+subsystem1798',
    };
  }
}
