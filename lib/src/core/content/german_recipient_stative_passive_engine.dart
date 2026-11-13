import 'dart:collection';

/// Classification of German passive voice variants and recipient/stative alternations.
enum PassiveVoiceType {
  rezipientenpassivErhalten(
    'Rezipientenpassiv mit "erhalten" (Gehobene Fach- & Amtssprache)',
    'المبني للمجهول الموجه للمتلقي بصيغة erhalten (فصحى راقية ورسمية)',
    'Das Dativobjekt des Aktivsatzes wird zum Subjekt (Nominativ): Das Unternehmen erhält den Innovationspreis verliehen.',
  ),
  rezipientenpassivBekommen(
    'Rezipientenpassiv mit "bekommen" (Standardsprache)',
    'المبني للمجهول الموجه للمتلقي بصيغة bekommen (المعيار الفصيح العام)',
    'Der Servicetechniker bekommt die neuen Baupläne ausgehändigt. Akkusativobjekt ("die Pläne") bleibt erhalten.',
  ),
  rezipientenpassivKriegen(
    'Rezipientenpassiv mit "kriegen" (Umgangssprachlich)',
    'المبني للمجهول الموجه للمتلقي بصيغة kriegen (تخاطب شفهي غير رسمي)',
    'Die Monteure kriegen den Lohn überwiesen. Grammatisch identisch, jedoch umgangssprachliches Register.',
  ),
  zustandspassivStative(
    'Zustandspassiv mit "sein" (Resultat & abgeschlossener Zustand)',
    'المبني للمجهول الدال على الحالة والنتيجة المستقرة (sein + Partizip II)',
    'Beschreibt das fertige Resultat einer vorangegangenen Handlung: Die Hochspannungsleitung ist freigeschaltet.',
  ),
  vorgangspassivProcess(
    'Vorgangspassiv mit "werden" (Dynamischer Prozess & Handlung)',
    'المبني للمجهول الدال على الحدث والعملية الحركية (werden + Partizip II)',
    'Beschreibt die fortschreitende Handlung: Die Hochspannungsleitung wird gegenwärtig freigeschaltet.',
  ),
  subjektlosesPassivImpersonal(
    'Subjektloses Passiv bei intransitiven Verben',
    'المبني للمجهول غير الشخصي المجرد من الفاعل (للأفعال اللازمة)',
    'Ausgangsverb hat kein Akkusativobjekt: In der Leitwarte wird rund um die Uhr konzentriert gearbeitet.',
  );

  final String germanTitle;
  final String arabicTitle;
  final String grammaticalPattern;
  const PassiveVoiceType(
    this.germanTitle,
    this.arabicTitle,
    this.grammaticalPattern,
  );
}

/// Register tier of the passive construction.
enum AuxiliaryRegister {
  formalTechnical('Gehobene Wissenschafts- & Fachsprache (erhalten/sein/werden)', 'أكاديمي ورسمي رفيع'),
  standardGeneral('Gepflegte Standardsprache (bekommen/sein/werden)', 'فصيح معياري'),
  colloquialSpoken('Mündliche Umgangssprache (kriegen)', 'دارج شفهي');

  final String de;
  final String ar;
  const AuxiliaryRegister(this.de, this.ar);
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

/// Model of a passive transformation with case preservation and recipient dynamics.
class PassiveTransformationModel {
  final String id;
  final PassiveVoiceType passiveType;
  final AuxiliaryRegister register;
  final String activeCanonicalSentence;
  final String passiveTransformedSentence;
  final String originalDativeRecipient;
  final String newNominativeSubject;
  final String retainedAccusativeObject;
  final CommunicativeDomain domain;
  final String arabicTranslation;
  final String grammaticalAnalysisArabic;
  final String grammaticalAnalysisGerman;
  final String registerNote;
  final String structuralFormula;

  const PassiveTransformationModel({
    required this.id,
    required this.passiveType,
    required this.register,
    required this.activeCanonicalSentence,
    required this.passiveTransformedSentence,
    required this.originalDativeRecipient,
    required this.newNominativeSubject,
    required this.retainedAccusativeObject,
    required this.domain,
    required this.arabicTranslation,
    required this.grammaticalAnalysisArabic,
    required this.grammaticalAnalysisGerman,
    required this.registerNote,
    required this.structuralFormula,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'passiveType': passiveType.name,
    'register': register.name,
    'activeCanonicalSentence': activeCanonicalSentence,
    'passiveTransformedSentence': passiveTransformedSentence,
    'originalDativeRecipient': originalDativeRecipient,
    'newNominativeSubject': newNominativeSubject,
    'retainedAccusativeObject': retainedAccusativeObject,
    'domain': domain.name,
    'arabicTranslation': arabicTranslation,
    'grammaticalAnalysisArabic': grammaticalAnalysisArabic,
    'grammaticalAnalysisGerman': grammaticalAnalysisGerman,
    'registerNote': registerNote,
    'structuralFormula': structuralFormula,
  };
}

/// Verification report container for recipient and stative passive validation.
class PassiveValidationReport {
  final bool isValid;
  final bool isRecipientNominative;
  final bool isPatientAccusativeRetained;
  final bool isRegisterCompliant;
  final List<String> issues;
  final List<String> recommendations;
  final String arabicDiagnosticVerdict;

  const PassiveValidationReport({
    required this.isValid,
    required this.isRecipientNominative,
    required this.isPatientAccusativeRetained,
    required this.isRegisterCompliant,
    required this.issues,
    required this.recommendations,
    required this.arabicDiagnosticVerdict,
  });
}

/// Sovereign engine governing German Recipient Passive, Impersonal & Stative Voice Architecture.
class GermanRecipientStativePassiveEngine {
  final List<PassiveTransformationModel> _catalog = [];

  GermanRecipientStativePassiveEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<PassiveTransformationModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    // 1. Rezipientenpassiv mit erhalten (Formal) - Renewable Energy
    _catalog.add(
      const PassiveTransformationModel(
        id: 'PASS-REZ-ERHALTEN-01',
        passiveType: PassiveVoiceType.rezipientenpassivErhalten,
        register: AuxiliaryRegister.formalTechnical,
        activeCanonicalSentence:
            'Die Regulierungsbehörde erteilt dem Solarpark-Betreiber die offizielle Netzeinspeisegenehmigung.',
        passiveTransformedSentence:
            'Der Solarpark-Betreiber erhält die offizielle Netzeinspeisegenehmigung von der Regulierungsbehörde erteilt.',
        originalDativeRecipient: 'dem Solarpark-Betreiber (Dativ)',
        newNominativeSubject: 'Der Solarpark-Betreiber (Nominativ)',
        retainedAccusativeObject: 'die offizielle Netzeinspeisegenehmigung (Akkusativ)',
        domain: CommunicativeDomain.renewableEnergyGrid,
        arabicTranslation:
            'يستلم مشغل محطة الطاقة الشمسية تصريح الضخ والتغذية الرسمي للشبكة ممنوحاً له من قِبل الهيئة التنظيمية.',
        grammaticalAnalysisArabic:
            'المبني للمجهول الموجه للمتلقي (Rezipientenpassiv): تحول المتلقي المجرور بالداتيف (dem Betreiber) إلى فاعل في الرفع (Der Betreiber)، مع استخدام الفعل المساعد erhalten، واحتفاظ المفعول به الصريح (Genehmigung) بحالة النصب.',
        grammaticalAnalysisGerman:
            'Rezipientenpassiv mit "erhalten": Das Dativobjekt des Aktivsatzes rückt in die Subjektposition (Nominativ). Das Akkusativobjekt bleibt unverändert im Akkusativ erhalten. Das Vollverb steht als Partizip II ("erteilt").',
        registerNote:
            'Stilistisch höchstes Register; bevorzugt in behördlichen, kaufmännischen und ingenieurtechnischen Dokumenten.',
        structuralFormula:
            '[Dativobjekt -> Nominativsubjekt] + erhält + [Akkusativobjekt unverändert] + [Partizip II]',
      ),
    );

    // 2. Rezipientenpassiv mit bekommen (Standard) - Industrial Robotics
    _catalog.add(
      const PassiveTransformationModel(
        id: 'PASS-REZ-BEKOMMEN-02',
        passiveType: PassiveVoiceType.rezipientenpassivBekommen,
        register: AuxiliaryRegister.standardGeneral,
        activeCanonicalSentence:
            'Der Mechatroniker übergibt dem Werksmonteur das neu kalibrierte Drehmomentwerkzeug.',
        passiveTransformedSentence:
            'Der Werksmonteur bekommt das neu kalibrierte Drehmomentwerkzeug vom Mechatroniker übergeben.',
        originalDativeRecipient: 'dem Werksmonteur (Dativ)',
        newNominativeSubject: 'Der Werksmonteur (Nominativ)',
        retainedAccusativeObject: 'das neu kalibrierte Drehmomentwerkzeug (Akkusativ)',
        domain: CommunicativeDomain.industrialRobotics,
        arabicTranslation:
            'يستلم عامل التركيب في المصنع أداة عزم الدوران المعايرة حديثاً مسلَّمةً إليه من قِبل مهندس الميكاترونكس.',
        grammaticalAnalysisArabic:
            'صيغة bekommen القياسية: الفاعل الجديد (Der Werksmonteur) في الرفع، والمفعول المتسلم (das Werkzeug) منصوب بالأكوزاتيف، واسم المفعول (übergeben) في نهاية الجملة.',
        grammaticalAnalysisGerman:
            'Standarddeutsches Rezipientenpassiv mit "bekommen". Perfekte Perspektivierung auf den Empfänger der Handlung bei Bewahrung des Akkusativpatienten.',
        registerNote:
            'Standard im professionellen Werks- und Werkstattdiskurs.',
        structuralFormula:
            '[Subjekt im Nominativ] + bekommt + [Akkusativobjekt] + [Partizip II am Satzende]',
      ),
    );

    // 3. Rezipientenpassiv mit entziehen (Deprivative Rection) - Civil Infrastructure
    _catalog.add(
      const PassiveTransformationModel(
        id: 'PASS-REZ-ENTZIEHEN-03',
        passiveType: PassiveVoiceType.rezipientenpassivErhalten,
        register: AuxiliaryRegister.formalTechnical,
        activeCanonicalSentence:
            'Das Bauaufsichtsamt entzog dem unzuverlässigen Generalunternehmer die Ausführungslizenz.',
        passiveTransformedSentence:
            'Der unzuverlässige Generalunternehmer erhielt die Ausführungslizenz vom Bauaufsichtsamt entzogen.',
        originalDativeRecipient: 'dem unzuverlässigen Generalunternehmer (Dativus Incommodi)',
        newNominativeSubject: 'Der unzuverlässige Generalunternehmer (Nominativ)',
        retainedAccusativeObject: 'die Ausführungslizenz (Akkusativ)',
        domain: CommunicativeDomain.civilInfrastructure,
        arabicTranslation:
            'جُرِّد المقاول العام غير الموثوق من رخصة التنفيذ مسحوبةً منه من قِبل هيئة الرقابة على البناء.',
        grammaticalAnalysisArabic:
            'تطبيق Rezipientenpassiv مع أفعال السلب والتجريد (Dativus Incommodi): المتضرر يصبح فاعلاً بصيغة "erhielt ... entzogen" مع بقاء الرخصة منصوبة.',
        grammaticalAnalysisGerman:
            'Anwendung bei privativer Valenz ("jemandem etwas entziehen"): Das betroffene Patiens wird grammatisches Subjekt mit "erhalten".',
        registerNote:
            'Häufig in bauvertraglichen und gutachterlichen Schadensberichten.',
        structuralFormula:
            '[Geschädigter im Nominativ] + erhielt + [Entzogenes Gut im Akkusativ] + entzogen',
      ),
    );

    // 4. Zustandspassiv (Resultant State) vs. Vorgangspassiv - Aerospace Aviation
    _catalog.add(
      const PassiveTransformationModel(
        id: 'PASS-ZUSTAND-AERO-04',
        passiveType: PassiveVoiceType.zustandspassivStative,
        register: AuxiliaryRegister.formalTechnical,
        activeCanonicalSentence:
            'Das Bodenpersonal hat die Sauerstoffventile der Raumkapsel druckfest verriegelt.',
        passiveTransformedSentence:
            'Die Sauerstoffventile der Raumkapsel sind nun vollständig und druckfest verriegelt.',
        originalDativeRecipient: 'Kein Dativobjekt vorhanden',
        newNominativeSubject: 'Die Sauerstoffventile der Raumkapsel',
        retainedAccusativeObject: 'Keines (wurde zum Subjekt)',
        domain: CommunicativeDomain.aerospaceAndAviation,
        arabicTranslation:
            'صمامات الأكسجين الخاصة بالكبسولة الفضائية مقفلة ومؤمنة الآن بإحكام ضد الضغط (حالة إغلاق مستقرة منجزة).',
        grammaticalAnalysisArabic:
            'مبني للمجهول دال على الحالة المنجزة (Zustandspassiv): استخدام فعل الكينونة sein مع اسم المفعول (sind verriegelt) لوصف النتيجة المستقرة، وليس العملية الجارية.',
        grammaticalAnalysisGerman:
            'Zustandspassiv mit "sein": Drückt den erreichten Zustand und die fertige Sicherheit aus. Kontrastiert mit dem Vorgangspassiv ("werden verriegelt").',
        registerNote:
            'Präzisionsstandard für Checklisten und Statusabfragen in der Luft- und Raumfahrt.',
        structuralFormula:
            '[Subjekt] + ist/sind + [Partizip II] (Zustand als Resultat)',
      ),
    );

    // 5. Vorgangspassiv (Ongoing Process) - Aerospace Aviation
    _catalog.add(
      const PassiveTransformationModel(
        id: 'PASS-VORGANG-AERO-05',
        passiveType: PassiveVoiceType.vorgangspassivProcess,
        register: AuxiliaryRegister.formalTechnical,
        activeCanonicalSentence:
            'Das Bodenpersonal verriegelt gegenwärtig die Sauerstoffventile der Raumkapsel.',
        passiveTransformedSentence:
            'Die Sauerstoffventile der Raumkapsel werden gegenwärtig vom Bodenpersonal druckfest verriegelt.',
        originalDativeRecipient: 'Kein Dativobjekt vorhanden',
        newNominativeSubject: 'Die Sauerstoffventile der Raumkapsel',
        retainedAccusativeObject: 'Keines (Akkusativobjekt wird Subjekt)',
        domain: CommunicativeDomain.aerospaceAndAviation,
        arabicTranslation:
            'يجري حالياً قفل صمامات الأكسجين للكبسولة الفضائية وتأمينها بإحكام من قِبل الطاقم الأرضي (عملية مستمرة قيد التنفيذ).',
        grammaticalAnalysisArabic:
            'مبني للمجهول حركي دال على الحدث (Vorgangspassiv): استخدام werden مع اسم المفعول (werden verriegelt) لبيان أن الفعل يقع الآن في هذه اللحظة.',
        grammaticalAnalysisGerman:
            'Vorgangspassiv mit "werden": Betont den dynamischen Handlungsablauf im Präsens unter Nennung des Agens ("vom Bodenpersonal").',
        registerNote:
            'Standard zur Beschreibung laufender technischer Prozeduren.',
        structuralFormula:
            '[Subjekt] + wird/werden + (von + Dativ) + [Partizip II] (dynamischer Prozess)',
      ),
    );

    // 6. Subjektloses Passiv (Impersonal Passive) - Renewable Energy
    _catalog.add(
      const PassiveTransformationModel(
        id: 'PASS-SUBJEKTLOS-ENERGY-06',
        passiveType: PassiveVoiceType.subjektlosesPassivImpersonal,
        register: AuxiliaryRegister.formalTechnical,
        activeCanonicalSentence:
            'In der zentralen Leitwarte arbeitet das Personal hochkonzentriert an der Netzstabilisierung.',
        passiveTransformedSentence:
            'In der zentralen Leitwarte wird hochkonzentriert an der Netzstabilisierung gearbeitet.',
        originalDativeRecipient: 'Kein Dativobjekt (intransitives Verb)',
        newNominativeSubject: 'Kein grammatisches Subjekt (subjektlos!)',
        retainedAccusativeObject: 'Kein Akkusativobjekt vorhanden',
        domain: CommunicativeDomain.renewableEnergyGrid,
        arabicTranslation:
            'يُعمل في غرفة التحكم المركزية بتركيز فائق وعناية تامة على استقرار وتثبيت الشبكة الكهربائية.',
        grammaticalAnalysisArabic:
            'مبني للمجهول غير شخصي مجرد من الفاعل (Subjektloses Passiv): مشتق من فعل لازم (arbeiten)، فلا يوجد فاعل نحوي، ويبقى الفعل المصرف مفرداً دائماً (wird).',
        grammaticalAnalysisGerman:
            'Subjektloses Passiv von intransitiven Verben. Das Vorfeld wird durch ein Adverbial besetzt; ein Platzhalter-es entfällt im Mittelfeld komplett.',
        registerNote:
            'Kennzeichnend für sachliche deutsche Einsatzberichte und Schichtübergaben.',
        structuralFormula:
            '[Adverbiale Bestimmung] + wird + [Partizip II des intransitiven Verbs]',
      ),
    );

    // 7. Subjektloses Passiv mit Dativerhalt - Maritime Logistics
    _catalog.add(
      const PassiveTransformationModel(
        id: 'PASS-SUBJEKTLOS-DATIV-07',
        passiveType: PassiveVoiceType.subjektlosesPassivImpersonal,
        register: AuxiliaryRegister.formalTechnical,
        activeCanonicalSentence:
            'Die Rettungsleitstelle half den in Not geratenen Frachterbesatzungen unverzüglich.',
        passiveTransformedSentence:
            'Den in Not geratenen Frachterbesatzungen wurde von der Rettungsleitstelle unverzüglich geholfen.',
        originalDativeRecipient: 'Den Frachterbesatzungen (bleibt Dativ!)',
        newNominativeSubject: 'Kein Subjekt im Nominativ (Dativ bleibt unangetastet)',
        retainedAccusativeObject: 'Keines',
        domain: CommunicativeDomain.maritimeLogistics,
        arabicTranslation:
            'طواقم سفن الشحن التي تعرضت للخطر قُدِّمت إليها المساعدة فوراً ودون أي إبطاء من قِبل مركز الإنقاذ.',
        grammaticalAnalysisArabic:
            'مبني للمجهول مع بقاء الداتيف دون تغيير: الفعل helfen يتعدى بالداتيف فقط، لذا في المبني للمجهول يظل المفعول مجروراً بالداتيف (Den Besatzungen) ولا يتحول لفاعل!',
        grammaticalAnalysisGerman:
            'Dativbeibehaltung im unpersönlichen Passiv: Da "helfen" nur den Dativ regiert, kann kein Nominativsubjekt entstehen ("Den Besatzungen wurde geholfen").',
        registerNote:
            'Häufige Fehlerquelle bei Deutschlernenden; Dativ darf im Passiv niemals zum Nominativ werden.',
        structuralFormula:
            '[Dativobjekt bleibt Dativ] + wurde + [Partizip II]',
      ),
    );

    // 8. Rezipientenpassiv mit zustellen (Delivery) - Maritime Logistics
    _catalog.add(
      const PassiveTransformationModel(
        id: 'PASS-REZ-ZUSTELLEN-08',
        passiveType: PassiveVoiceType.rezipientenpassivErhalten,
        register: AuxiliaryRegister.formalTechnical,
        activeCanonicalSentence:
            'Der Speditionsdienstleister stellt dem Importeur die Frachtdokumente fristgerecht zu.',
        passiveTransformedSentence:
            'Der Importeur erhält die Frachtdokumente fristgerecht vom Speditionsdienstleister zugestellt.',
        originalDativeRecipient: 'dem Importeur (Dativ)',
        newNominativeSubject: 'Der Importeur (Nominativ)',
        retainedAccusativeObject: 'die Frachtdokumente (Akkusativ)',
        domain: CommunicativeDomain.maritimeLogistics,
        arabicTranslation:
            'يستلم المستورد وثائق الشحن مسلَّمةً إليه في الموعد المحدد من قِبل مزود الخدمات اللوجستية.',
        grammaticalAnalysisArabic:
            'المستورد أصبح فاعلاً (Der Importeur) بصيغة erhält zugestellt، بينما بقيت وثائق الشحن (die Frachtdokumente) مفعولاً به منصوباً.',
        grammaticalAnalysisGerman:
            'Empfängerpassiv zur geschäftsmäßigen Akzentuierung des Empfängers bei Erhalt von Frachtgut oder Papieren.',
        registerNote:
            'Kernstruktur im internationalen Handels- und Speditionsverkehr.',
        structuralFormula:
            '[Empfänger: Nom] + erhält + [Dokumente: Akk] + zugestellt',
      ),
    );

    // 9. Zustandspassiv im Präteritum - Material Science
    _catalog.add(
      const PassiveTransformationModel(
        id: 'PASS-ZUSTAND-PRAET-09',
        passiveType: PassiveVoiceType.zustandspassivStative,
        register: AuxiliaryRegister.formalTechnical,
        activeCanonicalSentence:
            'Die Versuchsleiter hatten die Testkammer bereits evakuiert.',
        passiveTransformedSentence:
            'Die Hochvakuumkammer war bereits vollständig evakuiert, als die Gaseinspeisung begann.',
        originalDativeRecipient: 'Keines',
        newNominativeSubject: 'Die Hochvakuumkammer',
        retainedAccusativeObject: 'Keines',
        domain: CommunicativeDomain.materialScience,
        arabicTranslation:
            'كانت حجرة التفريغ فائق الدقة مفرغة من الهواء بالكامل بالفعل عندما بدأ حقن الغاز (حالة تفريغ ماضية مكتملة).',
        grammaticalAnalysisArabic:
            'المبني للمجهول للحالة في الزمن الماضي (Zustandspassiv Präteritum): استخدام war evakuiert لبيان أن الحالة كانت قائمة ومكتملة قبل بدء الإجراء التالي.',
        grammaticalAnalysisGerman:
            'Zustandspassiv im Präteritum ("war evakuiert") zur Schilderung eines in der Vergangenheit bereits bestehenden Zustands.',
        registerNote:
            'Etablierte Zeitform in Labor- und Forschungsberichten.',
        structuralFormula:
            '[Subjekt] + war/waren + [Partizip II] (Zustand in der Vergangenheit)',
      ),
    );

    // 10. Rezipientenpassiv mit genehmigen - Civil Infrastructure
    _catalog.add(
      const PassiveTransformationModel(
        id: 'PASS-REZ-GENEHMIGEN-10',
        passiveType: PassiveVoiceType.rezipientenpassivBekommen,
        register: AuxiliaryRegister.standardGeneral,
        activeCanonicalSentence:
            'Das Bauprüfamt genehmigt dem Ingenieurbüro den geänderten Trassenverlauf.',
        passiveTransformedSentence:
            'Das Ingenieurbüro bekommt den geänderten Trassenverlauf vom Bauprüfamt genehmigt.',
        originalDativeRecipient: 'dem Ingenieurbüro (Dativ)',
        newNominativeSubject: 'Das Ingenieurbüro (Nominativ)',
        retainedAccusativeObject: 'den geänderten Trassenverlauf (Akkusativ)',
        domain: CommunicativeDomain.civilInfrastructure,
        arabicTranslation:
            'ينال المكتب الهندسي الموافقة على مسار خط النقل المعدل معتمداً له من قِبل مكتب تدقيق البناء.',
        grammaticalAnalysisArabic:
            'المكتب الهندسي تحول من مجرور بالداتيف إلى فاعل مرفوع، مع بقاء المسار المعدل (den Trassenverlauf) منصوباً بالأكوزاتيف المذكر الصريح.',
        grammaticalAnalysisGerman:
            'Dativsubstituierendes Empfängerpassiv: "Das Ingenieurbüro bekommt [Akkusativobjekt] genehmigt".',
        registerNote:
            'Sehr geläufig im Dialog zwischen Auftragnehmer und Behörden.',
        structuralFormula:
            '[Begünstigter: Nom] + bekommt + [Objekt: Akk] + genehmigt',
      ),
    );

    // 11. Rezipientenpassiv mit zuschlagen (Auction/Procurement) - Renewable Energy
    _catalog.add(
      const PassiveTransformationModel(
        id: 'PASS-REZ-ZUSCHLAGEN-11',
        passiveType: PassiveVoiceType.rezipientenpassivErhalten,
        register: AuxiliaryRegister.formalTechnical,
        activeCanonicalSentence:
            'Die Bundesnetzagentur schlug dem Energiekonzern die Offshore-Fläche für 500 Megawatt zu.',
        passiveTransformedSentence:
            'Der Energiekonzern erhielt die Offshore-Fläche für 500 Megawatt von der Bundesnetzagentur zugeschlagen.',
        originalDativeRecipient: 'dem Energiekonzern (Dativ)',
        newNominativeSubject: 'Der Energiekonzern (Nominativ)',
        retainedAccusativeObject: 'die Offshore-Fläche (Akkusativ)',
        domain: CommunicativeDomain.renewableEnergyGrid,
        arabicTranslation:
            'نالت شركة الطاقة رسو المزاد على المساحة البحرية بقدرة 500 ميغاوات ممنوحةً لها من قِبل وكالة الشبكات الاتحادية.',
        grammaticalAnalysisArabic:
            'استعمال Rezipientenpassiv في المزادات والمناقصات: "erhielt zugeschlagen" لنقل التركيز على الشركة الفائزة بالترسية.',
        grammaticalAnalysisGerman:
            'Fachsprachliches Vergabepassiv: "jemandem etwas zuschlagen" -> "jemand erhält etwas zugeschlagen".',
        registerNote:
            'Fachterminus im öffentlichen Vergabewesen von Energieprojekten.',
        structuralFormula:
            '[Gewinner: Nom] + erhielt + [Fläche: Akk] + zugeschlagen',
      ),
    );

    // 12. Zustandspassiv Perfekt (ist gewesen) - Industrial Robotics
    _catalog.add(
      const PassiveTransformationModel(
        id: 'PASS-ZUSTAND-PERF-12',
        passiveType: PassiveVoiceType.zustandspassivStative,
        register: AuxiliaryRegister.formalTechnical,
        activeCanonicalSentence:
            'Die Schutzkappe war vor dem Schweißzyklus geschlossen.',
        passiveTransformedSentence:
            'Die Schutzkappe ist während des gesamten Schweißzyklus sicher geschlossen gewesen.',
        originalDativeRecipient: 'Keines',
        newNominativeSubject: 'Die Schutzkappe',
        retainedAccusativeObject: 'Keines',
        domain: CommunicativeDomain.industrialRobotics,
        arabicTranslation:
            'كانت قبعة الحماية مغلقة بإحكام وثبات طوال دورة اللحام بأكملها (حالة مكتملة في الماضي التام).',
        grammaticalAnalysisArabic:
            'المبني للمجهول للحالة في الماضي التام (Zustandspassiv Perfekt): صيغة "ist geschlossen gewesen" لتوثيق أن حالة الإغلاق كانت سائدة ومتحققة.',
        grammaticalAnalysisGerman:
            'Zustandspassiv im Perfekt mit Doppelform "ist ... gewesen". Dokumentiert das ununterbrochene Vorliegen eines Sicherheitszustands.',
        registerNote:
            'Relevante Form in forensischen Schadensanalysen und Sicherheitsaudits.',
        structuralFormula:
            '[Subjekt] + ist + [Partizip II] + gewesen',
      ),
    );

    // 13. Rezipientenpassiv mit verweigern - Maritime Logistics
    _catalog.add(
      const PassiveTransformationModel(
        id: 'PASS-REZ-VERWEIGERN-13',
        passiveType: PassiveVoiceType.rezipientenpassivErhalten,
        register: AuxiliaryRegister.formalTechnical,
        activeCanonicalSentence:
            'Die Küstenwache verweigerte dem havarierten Tanker die Einfahrt in die Bucht.',
        passiveTransformedSentence:
            'Der havarierte Tanker erhielt die Einfahrt in die geschützte Bucht von der Küstenwache verweigert.',
        originalDativeRecipient: 'dem havarierten Tanker (Dativ)',
        newNominativeSubject: 'Der havarierte Tanker (Nominativ)',
        retainedAccusativeObject: 'die Einfahrt in die geschützte Bucht (Akkusativ)',
        domain: CommunicativeDomain.maritimeLogistics,
        arabicTranslation:
            'قوبلت ناقلة النفط المنكوبة برفض الإذن لها بدخول الخليج المحمي مرفوضاً من قِبل خفر السواحل.',
        grammaticalAnalysisArabic:
            'المتضرر الحامل للضرر (Der Tanker) في الرفع، وإذن الدخول المنصوب مفعولاً به (die Einfahrt) بصيغة erhielt verweigert.',
        grammaticalAnalysisGerman:
            'Rezipientenpassiv bei adversen Rechtsakten ("jemandem etwas verweigern" -> "jemand erhält etwas verweigert").',
        registerNote:
            'Häufig im Seerechts- und Havariewesen.',
        structuralFormula:
            '[Betroffener: Nom] + erhielt + [Verweigertes Recht: Akk] + verweigert',
      ),
    );

    // 14. Vorgangspassiv Futur I - Renewable Energy
    _catalog.add(
      const PassiveTransformationModel(
        id: 'PASS-VORGANG-FUTUR-14',
        passiveType: PassiveVoiceType.vorgangspassivProcess,
        register: AuxiliaryRegister.formalTechnical,
        activeCanonicalSentence:
            'Die Ingenieure werden die neuen Batteriespeicher im nächsten Quartal anschließen.',
        passiveTransformedSentence:
            'Die neuen Batteriespeicher werden im nächsten Quartal an das Höchstspannungsnetz angeschlossen werden.',
        originalDativeRecipient: 'Keines',
        newNominativeSubject: 'Die neuen Batteriespeicher',
        retainedAccusativeObject: 'Keines',
        domain: CommunicativeDomain.renewableEnergyGrid,
        arabicTranslation:
            'سيتم ربط مدخرات البطاريات الجديدة بشبكة الجهد الفائق في الربع السنوي القادم (عملية مستقبلية قيد التخطيط).',
        grammaticalAnalysisArabic:
            'مبني للمجهول حركي في زمن المستقبل الأول (Vorgangspassiv Futur I): يجمع بين الفعل المساعد werden في المركز الثاني والمصدر werden في الختام (werden angeschlossen werden).',
        grammaticalAnalysisGerman:
            'Futur-I-Vorgangspassiv: Doppelte "werden"-Klammer ("werden ... angeschlossen werden") zur Kennzeichnung künftiger Vorhaben.',
        registerNote:
            'Standard in Netzausbauplänen und Projektprognosen.',
        structuralFormula:
            '[Subjekt] + wird/werden + [Partizip II] + werden',
      ),
    );

    // 15. Rezipientenpassiv mit gutschreiben - Renewable Energy
    _catalog.add(
      const PassiveTransformationModel(
        id: 'PASS-REZ-GUTSCHREIBEN-15',
        passiveType: PassiveVoiceType.rezipientenpassivBekommen,
        register: AuxiliaryRegister.standardGeneral,
        activeCanonicalSentence:
            'Der Netzbetreiber schreibt dem Einspeiser die vermiedenen Netzentgelte auf dem Abrechnungskonto gut.',
        passiveTransformedSentence:
            'Der Einspeiser bekommt die vermiedenen Netzentgelte auf dem Abrechnungskonto gutgeschrieben.',
        originalDativeRecipient: 'dem Einspeiser (Dativ)',
        newNominativeSubject: 'Der Einspeiser (Nominativ)',
        retainedAccusativeObject: 'die vermiedenen Netzentgelte (Akkusativ)',
        domain: CommunicativeDomain.renewableEnergyGrid,
        arabicTranslation:
            'ينال منتج الطاقة قيد رسوم استخدام الشبكة المتفاداة مقيدةً لحسابه ومودعةً في حسابه الختامي.',
        grammaticalAnalysisArabic:
            'صيغة "bekommt gutgeschrieben": المستفيد أصبح فاعلاً مرفوعاً، والمبالغ المالية (die Netzentgelte) مفعولاً به منصوباً.',
        grammaticalAnalysisGerman:
            'Rezipientenpassiv mit trennbarem Verb ("gutschreiben" -> "gutgeschrieben bekommen").',
        registerNote:
            'Standardmuster in energiewirtschaftlichen Abrechnungsverfahren.',
        structuralFormula:
            '[Begünstigter: Nom] + bekommt + [Betrag: Akk] + gutgeschrieben',
      ),
    );

    // 16. Zustandspassiv Futur I - Material Science
    _catalog.add(
      const PassiveTransformationModel(
        id: 'PASS-ZUSTAND-FUTUR-16',
        passiveType: PassiveVoiceType.zustandspassivStative,
        register: AuxiliaryRegister.formalTechnical,
        activeCanonicalSentence:
            'Die Nanobeschichtung wird morgen früh vollständig ausgehärtet sein.',
        passiveTransformedSentence:
            'Die Schutzschicht der Titanprobe wird morgen früh vollständig ausgehärtet sein.',
        originalDativeRecipient: 'Keines',
        newNominativeSubject: 'Die Schutzschicht der Titanprobe',
        retainedAccusativeObject: 'Keines',
        domain: CommunicativeDomain.materialScience,
        arabicTranslation:
            'ستكون الطبقة الواقية لعينة التيتانيوم متصلبة بالكامل بحلول صباح الغد (حالة نتيجة مستقبلية منجزة).',
        grammaticalAnalysisArabic:
            'مبني للمجهول للحالة في زمن المستقبل (Zustandspassiv Futur I): يركز على تحقق حالة التصلب التام في المستقبل عبر التركيب "wird ausgehärtet sein".',
        grammaticalAnalysisGerman:
            'Zustandspassiv im Futur I: Drückt die begründete Erwartung aus, dass ein vollendeter Materialzustand zu einem künftigen Zeitpunkt vorliegen wird.',
        registerNote:
            'Wichtig für Fertigungszeitpläne und Materialhärtungsprotokolle.',
        structuralFormula:
            '[Subjekt] + wird/werden + [Partizip II] + sein',
      ),
    );
  }

  /// Evaluates an input sentence for correct recipient passive case government and auxiliary selection.
  PassiveValidationReport validateRecipientPassive({
    required String auxiliaryUsed,
    required bool isRecipientInNominative,
    required bool isAccusativeObjectRetained,
    required bool isRegisterAcceptable,
  }) {
    final issues = <String>[];
    final recommendations = <String>[];

    final isRecipientAuxiliary =
        auxiliaryUsed.toLowerCase() == 'bekommen' ||
        auxiliaryUsed.toLowerCase() == 'erhalten' ||
        auxiliaryUsed.toLowerCase() == 'kriegen';

    if (isRecipientAuxiliary && !isRecipientInNominative) {
      issues.add(
        'Kardinalfehler im Rezipientenpassiv: Der Empfänger (ursprüngliches Dativobjekt) MUSS im Rezipientenpassiv zum Nominativsubjekt werden. Eine Beibehaltung des Dativs (*Dem Techniker bekommt übergeben) ist grob ungrammatisch.',
      );
      recommendations.add(
        'Setzen Sie den Empfänger in den Nominativ (z. B. "Der Techniker bekommt die Pläne übergeben").',
      );
    }

    if (isRecipientAuxiliary && !isAccusativeObjectRetained) {
      issues.add(
        'Kasusfehler beim Akkusativpatienten: Das übertragene Gut/Objekt muss im Rezipientenpassiv zwingend im Akkusativ verbleiben.',
      );
      recommendations.add(
        'Belassen Sie das direkte Objekt im Akkusativ (z. B. "bekommt DEN neuen Plan übergeben").',
      );
    }

    if (auxiliaryUsed.toLowerCase() == 'kriegen' && !isRegisterAcceptable) {
      issues.add(
        'Stilistischer Registerkonflikt: "kriegen" gilt als rein umgangssprachlich und ist in Fachtexten, Gutachten und Berichten unzulässig; verwenden Sie "erhalten" oder "bekommen".',
      );
      recommendations.add('Ersetzen Sie "kriegen" durch "erhalten" (gehoben) oder "bekommen" (standard).');
    }

    final isValid = issues.isEmpty;
    final verdict = isValid
        ? 'التركيب النحوي للمبني للمجهول الموجه للمتلقي/المبني للمجهول الدال على الحالة صحيح تماماً ومطابق لمعايير C1-C2.'
        : 'تم رصد خلل في إعراب المتلقي (عدم رفعه للفاعلية)، أو في نصب المفعول المحتفظ به، أو في مستوى الفصاحة الأسلوبية.';

    return PassiveValidationReport(
      isValid: isValid,
      isRecipientInNominative: isRecipientInNominative,
      isPatientAccusativeRetained: isAccusativeObjectRetained,
      isRegisterCompliant: issues.where((e) => e.contains('Registerkonflikt')).isEmpty,
      issues: issues,
      recommendations: recommendations,
      arabicDiagnosticVerdict: verdict,
    );
  }

  List<PassiveTransformationModel> filterByType(PassiveVoiceType type) {
    return _catalog.where((item) => item.passiveType == type).toList();
  }

  List<PassiveTransformationModel> filterByDomain(CommunicativeDomain domain) {
    return _catalog.where((item) => item.domain == domain).toList();
  }
}
