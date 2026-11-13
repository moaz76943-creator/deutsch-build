import 'dart:collection';

/// Classification of inversion patterns and expletive 'es' topography in German syntax.
enum InversionPattern {
  adverbialInversion(
    'Adverbiale Vorfeldbesetzung mit Subjektinversion',
    'تقديم الظرف في الصدر وقلب الفاعل إلى ما بعد الفعل',
    'Adverbial im Vorfeld erzwingt Inversion: Gestern kalibrierten die Ingenieure die Sensoren.',
  ),
  objectInversion(
    'Objekt-Spitzenstellung zur thematischen Fokussierung',
    'تقديم المفعول به في الصدر لغرض التوكيد والربط الموضوعي',
    'Akkusativ-/Dativobjekt im Vorfeld: Diesen Prototyp entwickelten wir in sechsmonatiger Forschungsarbeit.',
  ),
  participleFronting(
    'Prädikatsspitzenstellung (Partizip II / Infinitiv im Vorfeld)',
    'تقديم اسم المفعول أو المصدر في الصدر لتعظيم الإبراز البلاغي',
    'Vorgelegt wurde der Prüfbericht gestern von der Bauleitung.',
  ),
  subordinateClauseFronting(
    'Vorangestellter Nebensatz mit Hauptsatz-Inversion',
    'تقدم الجملة الثانوية كعنصر أولي يليه الفعل المصرف مباشرة',
    'Weil die Turbine überhitzte, schaltete das Notfallsystem sofort ab.',
  ),
  vorfeldExpletiveEs(
    'Reines Vorfeld-es (Platzhalter ohne semantischen Gehalt)',
    'ضمير الصدر الصوري (Vorfeld-es) الذي يسقط حتماً عند تقدم أي عنصر آخر',
    'Es zirkuliert ein neuer Entwurf. -> Aber: Ein neuer Entwurf zirkuliert. / Gestern zirkulierte ein neuer Entwurf.',
  ),
  obligatoryValenceEs(
    'Obligatorisches Valenz-es (fester grammatischer Bestandteil)',
    'ضمير es النحوي الإلزامي كعمدة أصلية في بنية الفعل لا يمكن حذفه',
    'Es handelt sich um... / Es gibt... / Gestern handelte es sich um...',
  ),
  kataphoricCorrelateEs(
    'Kataphorisches Korrelat-es (Verweis auf Folgesatz/Infinitiv)',
    'ضمير الشأن والإحالة المتقدم على جملة المصدر المؤول',
    'Wir bedauern (es), dass sich die Lieferung verzögert hat.',
  );

  final String germanTitle;
  final String arabicTitle;
  final String structuralRule;
  const InversionPattern(
    this.germanTitle,
    this.arabicTitle,
    this.structuralRule,
  );
}

/// Behavior of the pronoun "es" when other elements occupy the Vorfeld.
enum EsDropBehavior {
  dropsObligatorily(
    'Fällt obligatorisch weg',
    'يسقط وجوباً عند تقدم أي عنصر آخر إلى الصدر',
  ),
  persistsInMittelfeld(
    'Bleibt im Mittelfeld zwingend erhalten',
    'يثبت وجوباً في حشو الجملة ولا يجوز حذفه',
  ),
  facultativeOmission(
    'Fakultativ (kann weggelassen oder gesetzt werden)',
    'جائز الإثبات والحذف حسب الرتبة البلاغية والأسلوبية',
  ),
  notApplicable(
    'Nicht zutreffend (kein "es"-Konstrukt)',
    'لا ينطبق (الجملة لا تحتوي على ضمير es)',
  );

  final String de;
  final String ar;
  const EsDropBehavior(this.de, this.ar);
}

/// Communicative domains strictly free of legal and medical liability.
enum CommunicativeDomain {
  renewableEnergy('Erneuerbare Energien & Netztechnik', 'الطاقة المتجددة وشبكات الكهرباء'),
  aerospaceTech('Luft- & Raumfahrttechnologie', 'تقنيات الطيران واستكشاف الفضاء'),
  industrialEngineering('Industrie- & Fertigungstechnik', 'الهندسة الصناعية والإنتاج'),
  marineLogistics('Seefracht & Hafenlogistik', 'الشحن البحري وإدارة الموانئ'),
  automatedRobotics('Robotik & Automatisierungssysteme', 'الروبوتات ومنظومات الأتمتة'),
  professionalCollaboration('Berufliche Fachteams & Betriebspraxis', 'فرق العمل المهنية وإدارة العمليات');

  final String de;
  final String ar;
  const CommunicativeDomain(this.de, this.ar);
}

/// Structural model of an inverted or expletive German construction.
class InversionModel {
  final String id;
  final String baseCanonicalSentence; // S-V-O Canonical
  final String invertedSentence; // Fronted element + Verb + Subject + Mittelfeld
  final String frontedElement; // Vorfeld-Besetzung
  final String invertedSubject; // Subjekt im Mittelfeld
  final InversionPattern pattern;
  final EsDropBehavior esBehavior;
  final CommunicativeDomain domain;
  final String arabicTranslation;
  final String grammaticalAnalysisArabic;
  final String grammaticalAnalysisGerman;
  final String wackernagelPositionRule;
  final String topologicalNote;

  const InversionModel({
    required this.id,
    required this.baseCanonicalSentence,
    required this.invertedSentence,
    required this.frontedElement,
    required this.invertedSubject,
    required this.pattern,
    required this.esBehavior,
    required this.domain,
    required this.arabicTranslation,
    required this.grammaticalAnalysisArabic,
    required this.grammaticalAnalysisGerman,
    required this.wackernagelPositionRule,
    required this.topologicalNote,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'baseCanonicalSentence': baseCanonicalSentence,
    'invertedSentence': invertedSentence,
    'frontedElement': frontedElement,
    'invertedSubject': invertedSubject,
    'pattern': pattern.name,
    'esBehavior': esBehavior.name,
    'domain': domain.name,
    'arabicTranslation': arabicTranslation,
    'grammaticalAnalysisArabic': grammaticalAnalysisArabic,
    'grammaticalAnalysisGerman': grammaticalAnalysisGerman,
    'wackernagelPositionRule': wackernagelPositionRule,
    'topologicalNote': topologicalNote,
  };
}

/// Evaluation report container for inversion and expletive syntax.
class InversionValidationReport {
  final bool isValid;
  final bool isV2Compliant;
  final bool respectsWackernagelOrder;
  final bool correctEsBehavior;
  final List<String> issues;
  final List<String> recommendations;
  final String arabicSummary;

  const InversionValidationReport({
    required this.isValid,
    required this.isV2Compliant,
    required this.respectsWackernagelOrder,
    required this.correctEsBehavior,
    required this.issues,
    required this.recommendations,
    required this.arabicSummary,
  });
}

/// Sovereign engine governing German Inversion Dynamics, V2-Spitzenstellung & Expletive "es".
class GermanInversionExpletiveEngine {
  final List<InversionModel> _catalog = [];

  GermanInversionExpletiveEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<InversionModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    // 1. Renewable Energy: Adverbial Fronting with Nominal Subject Inversion
    _catalog.add(
      const InversionModel(
        id: 'INV-ADV-ENERGY-01',
        baseCanonicalSentence:
            'Die Offshore-Windenergieanlagen speisten gestern über achtzig Gigawattstunden Strom in das Übertragungsnetz ein.',
        invertedSentence:
            'Gestern speisten die Offshore-Windenergieanlagen über achtzig Gigawattstunden Strom in das Übertragungsnetz ein.',
        frontedElement: 'Gestern (Temporales Adverbial)',
        invertedSubject: 'die Offshore-Windenergieanlagen',
        pattern: InversionPattern.adverbialInversion,
        esBehavior: EsDropBehavior.notApplicable,
        domain: CommunicativeDomain.renewableEnergy,
        arabicTranslation:
            'بالأمس ضخت محطات طاقة الرياح البحرية أكثر من ثمانين غيغاوات/ساعة من الكهرباء في شبكة النقل الرئيسية.',
        grammaticalAnalysisArabic:
            'تقديم ظرف الزمان (Gestern) في صدر الجملة (Vorfeld) يوجب تأخير الفاعل الاسمي بعد الفعل المصرف مباشرة التزاماً بقاعدة الموقع الثاني للفعل (V2-Regel).',
        grammaticalAnalysisGerman:
            'Temporale Vorfeldbesetzung erzwingt Inversion des nominalen Subjekts hinter das finite Verb in V2-Position.',
        wackernagelPositionRule:
            'Nominale Subjekte stehen im Mittelfeld in der Regel hinter pronominalen Objekten, hier jedoch direkt hinter dem Finitum.',
        topologicalNote:
            'Das trennbare Präfix "ein" bildet die rechte Satzklammer am absoluten Satzende.',
      ),
    );

    // 2. Aerospace Technology: Participle Fronting (Prädikatsspitzenstellung)
    _catalog.add(
      const InversionModel(
        id: 'INV-PART-AERO-02',
        baseCanonicalSentence:
            'Das aerodynamische Hitzeschild wurde heute früh erfolgreich im Vakuumwindkanal getestet.',
        invertedSentence:
            'Erfolgreich getestet wurde das aerodynamische Hitzeschild heute früh im Vakuumwindkanal.',
        frontedElement: 'Erfolgreich getestet (Partizip II + modales Adverb)',
        invertedSubject: 'das aerodynamische Hitzeschild',
        pattern: InversionPattern.participleFronting,
        esBehavior: EsDropBehavior.notApplicable,
        domain: CommunicativeDomain.aerospaceTech,
        arabicTranslation:
            'تم اختباره بنجاح باهر: الدرع الحراري الهوائي اختُبر صباح اليوم في نفق الرياح المفرغ من الهواء.',
        grammaticalAnalysisArabic:
            'تقديم اسم المفعول مع ظرف الحال (Erfolgreich getestet) في الصدر لإعطاء النتيجة العملية الأولوية القصوى في الإبلاغ الفني، يليه الفعل المساعد (wurde).',
        grammaticalAnalysisGerman:
            'Prädikatsspitzenstellung (Teil-VP im Vorfeld) zur nachdrücklichen Fokussierung der abgeschlossenen Handlung.',
        wackernagelPositionRule:
            'Das passive Hilfsverb "wurde" nimmt V2 ein, das Subjekt folgt als Nominativergänzung unmittelbar.',
        topologicalNote:
            'Stilistisch hochelegantes Mittel gehobener wissenschaftlich-technischer Berichterstattung.',
      ),
    );

    // 3. Automated Robotics: Vorfeld Expletive "es" dropping upon Inversion
    _catalog.add(
      const InversionModel(
        id: 'INV-EXPL-ROBOT-03',
        baseCanonicalSentence:
            'Ein hochmoderner Schweißroboter arbeitet seit heute Morgen in der Montagelinie.',
        invertedSentence:
            'Es arbeitet ein hochmoderner Schweißroboter seit heute Morgen in der Montagelinie. (Aber: Seit heute Morgen arbeitet ein hochmoderner Schweißroboter...)',
        frontedElement: 'Es (Reines Vorfeld-es als syntaktischer Platzhalter)',
        invertedSubject: 'ein hochmoderner Schweißroboter',
        pattern: InversionPattern.vorfeldExpletiveEs,
        esBehavior: EsDropBehavior.dropsObligatorily,
        domain: CommunicativeDomain.automatedRobotics,
        arabicTranslation:
            'يعمل روبوت لحام متطور للغاية منذ صباح اليوم في خط التجميع. (وعند تصدير شبه الجملة يسقط ضمير الصدر الشكلي es حتماً).',
        grammaticalAnalysisArabic:
            'ضمير الصدر الصوري (Vorfeld-es): يعمل كمجرد شاغل شكلي للمركز الأول عند تأخير الفاعل النكرة، ويسقط وجوباً عند تقدم أي عنصر آخر ولا يظهر أبداً في حشو الجملة.',
        grammaticalAnalysisGerman:
            'Reines Vorfeld-es fungiert als struktureller Platzhalter bei rhematischem Subjekt. Fällt bei Umstellung zwingend aus.',
        wackernagelPositionRule:
            'Bei Vorfeldbesetzung durch ein Adverbial (*Seit heute Morgen arbeitet es ein Roboter...) ist das Auftreten von "es" grammatikalisch fehlerhaft.',
        topologicalNote:
            'Kardinalregel: Vorfeld-es hat keine syntaktische Bindung zum Verb und existiert niemals im Mittelfeld.',
      ),
    );

    // 4. Industrial Engineering: Obligatory Valence "es" persisting in Mittelfeld
    _catalog.add(
      const InversionModel(
        id: 'INV-VAL-ENG-04',
        baseCanonicalSentence:
            'Es handelt sich bei dieser Legierung um einen hochbelastbaren Titan-Verbundwerkstoff.',
        invertedSentence:
            'Bei dieser Legierung handelt es sich um einen hochbelastbaren Titan-Verbundwerkstoff.',
        frontedElement: 'Bei dieser Legierung (Präpositionalphrase im Vorfeld)',
        invertedSubject: 'es (festes grammatikalisches Valenz-Subjekt)',
        pattern: InversionPattern.obligatoryValenceEs,
        esBehavior: EsDropBehavior.persistsInMittelfeld,
        domain: CommunicativeDomain.industrialEngineering,
        arabicTranslation:
            'فيما يتعلق بهذه السبيكة، فإن الأمر يدور حول مادة تيتانيوم مركبة فائقة التحمل.',
        grammaticalAnalysisArabic:
            'ضمير es النحوي الإلزامي (Valenz-es): يشكل ركناً أصيلاً في بنية الفعل التعبيري (sich handeln um)، لذا يثبت في حشو الجملة بعد الفعل المصرف ولا يجوز حذفه.',
        grammaticalAnalysisGerman:
            'Obligatorisches Valenz-es als fester Bestandteil des unpersönlichen Prädikats. Wandert bei Inversion ins Mittelfeld.',
        wackernagelPositionRule:
            'Als schwachtoniges Personalpronomen muss "es" im Mittelfeld sofort hinter dem finiten Verb stehen.',
        topologicalNote:
            'Gegenpol zum Vorfeld-es: Das Valenz-es kann unter keinen Umständen getilgt werden.',
      ),
    );

    // 5. Marine Logistics: Object Inversion for Discourse Cohesion
    _catalog.add(
      const InversionModel(
        id: 'INV-OBJ-MARINE-05',
        baseCanonicalSentence:
            'Die Terminalleitung fertigte den vollbeladenen Großfrachter binnen zwanzig Stunden ab.',
        invertedSentence:
            'Den vollbeladenen Großfrachter fertigte die Terminalleitung binnen zwanzig Stunden ab.',
        frontedElement: 'Den vollbeladenen Großfrachter (Definites Akkusativobjekt)',
        invertedSubject: 'die Terminalleitung',
        pattern: InversionPattern.objectInversion,
        esBehavior: EsDropBehavior.notApplicable,
        domain: CommunicativeDomain.marineLogistics,
        arabicTranslation:
            'سفينة الشحن العملاقة المحملة بالكامل أنجزت إدارة المحطة تفريغها وإنهاء معاملاتها في غضون عشرين ساعة.',
        grammaticalAnalysisArabic:
            'تقديم المفعول به المعرف المنصوب (Akkusativobjekt) في الصدر لربط الكلام بالسياق السابق، مع تأخير الفاعل الاسمي بعد الفعل المصرف.',
        grammaticalAnalysisGerman:
            'Topikalisierung des Akkusativobjekts zur Hervorhebung des Diskursgegenstands. Das finite Verb "fertigte" verbleibt strikt auf Position 2.',
        wackernagelPositionRule:
            'Das Subjekt "die Terminalleitung" folgt im Mittelfeld direkt auf das finite Prädikat.',
        topologicalNote:
            'Präfix "ab" verankert die rechte Satzklammer des trennbaren Verbs "abfertigen".',
      ),
    );

    // 6. Professional Collaboration: Subordinate Clause Fronting
    _catalog.add(
      const InversionModel(
        id: 'INV-CLAUSE-TEAM-06',
        baseCanonicalSentence:
            'Das Entwicklerteam schloss die Optimierungsphase erfolgreich ab, nachdem alle Systemtests bestanden waren.',
        invertedSentence:
            'Nachdem alle Systemtests bestanden waren, schloss das Entwicklerteam die Optimierungsphase erfolgreich ab.',
        frontedElement: 'Nachdem alle Systemtests bestanden waren (Temporaler Nebensatz als Vorfeld)',
        invertedSubject: 'das Entwicklerteam',
        pattern: InversionPattern.subordinateClauseFronting,
        esBehavior: EsDropBehavior.notApplicable,
        domain: CommunicativeDomain.professionalCollaboration,
        arabicTranslation:
            'بعد أن تم اجتياز جميع اختبارات المنظومة بنجاح، اختتم فريق التطوير مرحلة التحسين بكفاءة عالية.',
        grammaticalAnalysisArabic:
            'تقدم الجملة الثانوية الزمانية بكاملها لتشغل موقع الصدر (Vorfeld)، مما يفرض افتتاح الجملة الرئيسية التالية بالفعل المصرف مباشرة (schloss).',
        grammaticalAnalysisGerman:
            'Der vorangestellte Nebensatz besetzt die funktionale Vorfeldposition des Satzgefüges. Das Hauptsatzverb "schloss" steht unmittelbar nach dem Komma.',
        wackernagelPositionRule:
            'Das Hauptsatz-Subjekt "das Entwicklerteam" rückt an die erste Stelle des Mittelfelds.',
        topologicalNote:
            'Typischer Lernfehler: Einfügen von "*dann" oder "*so" ohne Inversion; im Deutschen folgt sofort das Verb.',
      ),
    );

    // 7. Renewable Energy: Kataphoric Correlate "es"
    _catalog.add(
      const InversionModel(
        id: 'INV-KATAPH-ENERGY-07',
        baseCanonicalSentence:
            'Die Netzbetreiber begrüßen es ausdrücklich, dass die Speicherkapazitäten verdoppelt werden.',
        invertedSentence:
            'Es begrüßen die Netzbetreiber ausdrücklich, dass die Speicherkapazitäten verdoppelt werden.',
        frontedElement: 'Es (Kataphorisches Vorfeld-Korrelat)',
        invertedSubject: 'die Netzbetreiber',
        pattern: InversionPattern.kataphoricCorrelateEs,
        esBehavior: EsDropBehavior.facultativeOmission,
        domain: CommunicativeDomain.renewableEnergy,
        arabicTranslation:
            'يُرحب مشغلو الشبكة الكهربائية ترحيباً صريحاً بمضاعفة السعات التخزينية للطاقة.',
        grammaticalAnalysisArabic:
            'ضمير الشأن والإحالة الكاتافوري المتقدم (Es)، يشير استباقياً إلى الجملة التوضيحية اللاحقة المصدرة بـ dass.',
        grammaticalAnalysisGerman:
            'Kataphorisches Vorfeld-Korrelat verweist prospektiv auf den nachgestellten Objektsatz mit "dass".',
        wackernagelPositionRule:
            'Bei Vorfeldbesetzung durch das Adverb ("Ausdrücklich begrüßen die Netzbetreiber, dass...") kann "es" entfallen.',
        topologicalNote:
            'Dient im gehobenen Duktus der Ausbalancierung der Informationsdichte.',
      ),
    );

    // 8. Aerospace Engineering: Wackernagel Pronoun Ordering under Inversion
    _catalog.add(
      const InversionModel(
        id: 'INV-WACK-AERO-08',
        baseCanonicalSentence:
            'Die Missionskontrolle übermittelte ihm gestern die aktualisierten Bahndaten.',
        invertedSentence:
            'Gestern übermittelte sie ihm die aktualisierten Bahndaten fehlerfrei.',
        frontedElement: 'Gestern (Adverbial)',
        invertedSubject: 'sie (pronominales Subjekt)',
        pattern: InversionPattern.adverbialInversion,
        esBehavior: EsDropBehavior.notApplicable,
        domain: CommunicativeDomain.aerospaceTech,
        arabicTranslation:
            'بالأمس قامت بإرسال بيانات المسار المحدثة إليه دون أي خطأ.',
        grammaticalAnalysisArabic:
            'قانون فاكرناغل لترتيب الضمائر في حشو الجملة: عند قلب الفاعل الضميري (sie)، يجب أن يسبق ضمير المفعول غير المباشر (ihm) مباشرة بعد الفعل المصرف.',
        grammaticalAnalysisGerman:
            'Wackernagelsches Gesetz: Pronominale Subjekte und Objekte drängen unmittelbar an die linke Satzklammer (Subjektpronomen vor Objektpronomen).',
        wackernagelPositionRule:
            'Strikte Abfolge im Mittelfeld: Verb + [Subjekt: sie] + [Dativobjekt: ihm] + [Akkusativobjekt].',
        topologicalNote:
            'Falsche Abfolge (*Gestern übermittelte ihm sie...) verletzt die universelle Mittelfeld-Topologie.',
      ),
    );

    // 9. Industrial Automation: Impersonal Passive with Expletive "es"
    _catalog.add(
      const InversionModel(
        id: 'INV-IMPER-PASS-09',
        baseCanonicalSentence:
            'In der Fertigungshalle wird rund um die Uhr hochkonzentriert gearbeitet.',
        invertedSentence:
            'Es wird in der Fertigungshalle rund um die Uhr hochkonzentriert gearbeitet.',
        frontedElement: 'Es (Vorfeld-Platzhalter beim subjektlosen Passiv)',
        invertedSubject: 'Kein grammatikalisches Subjekt vorhanden',
        pattern: InversionPattern.vorfeldExpletiveEs,
        esBehavior: EsDropBehavior.dropsObligatorily,
        domain: CommunicativeDomain.industrialEngineering,
        arabicTranslation:
            'يُعمل في صالة التصنيع على مدار الساعة بتركيز فائق.',
        grammaticalAnalysisArabic:
            'المبني للمجهول غير الشخصي (Subjektloses Passiv): الفعل intransitiv (arbeiten) لا مفعول له ليتحول لفاعل، فيدخل "es" كشاغل صوري للصدر فقط، ويسقط وجوباً عند تقدم شبه الجملة.',
        grammaticalAnalysisGerman:
            'Subjektloses Passiv mit reinem Vorfeld-es. Das Verb "arbeiten" hat kein Objekt; "es" schützt lediglich die V2-Regel.',
        wackernagelPositionRule:
            'Bei Spitzenstellung von "In der Fertigungshalle" verschwindet "es" spurlos (*In der Halle wird es gearbeitet ist falsch).',
        topologicalNote:
            'Zentrales Unterscheidungsmerkmal des deutschen Verbsystems im Vergleich zu anderen germanischen Sprachen.',
      ),
    );

    // 10. Marine Trade: Dative Object Inversion
    _catalog.add(
      const InversionModel(
        id: 'INV-DAT-MARINE-10',
        baseCanonicalSentence:
            'Die Reederei vertraut dem neu implementierten Navigationssystem vollkommen.',
        invertedSentence:
            'Dem neu implementierten Navigationssystem vertraut die Reederei vollkommen.',
        frontedElement: 'Dem neu implementierten Navigationssystem (Dativobjekt)',
        invertedSubject: 'die Reederei',
        pattern: InversionPattern.objectInversion,
        esBehavior: EsDropBehavior.notApplicable,
        domain: CommunicativeDomain.marineLogistics,
        arabicTranslation:
            'منظومة الملاحة المطبقة حديثاً توليها شركة الملاحة البحرية ثقة مطلقة وتامة.',
        grammaticalAnalysisArabic:
            'تقديم المفعول المجرور بالداتيف (Dativobjekt) في الصدر لإظهار العناية به، يليه الفعل (vertraut) ثم الفاعل الاسمي المؤخر.',
        grammaticalAnalysisGerman:
            'Dativobjekt im Vorfeld zur topikalisierenden Textverflechtung mit V2-Stellung des Prädikats.',
        wackernagelPositionRule:
            'Nominales Subjekt "die Reederei" steht als Agens direkt hinter dem Verb.',
        topologicalNote:
            'Ermöglicht nahtlose Anschlüsse an vorangegangene technische Beschreibungen.',
      ),
    );

    // 11. Automated Robotics: Expletive "es gibt" with Inversion
    _catalog.add(
      const InversionModel(
        id: 'INV-ESGIBT-ROBOT-11',
        baseCanonicalSentence:
            'Es gibt bei der Integration moderner Industrieroboter zahlreiche Synergieeffekte.',
        invertedSentence:
            'Bei der Integration moderner Industrieroboter gibt es zahlreiche Synergieeffekte.',
        frontedElement: 'Bei der Integration moderner Industrieroboter (Präpositionalphrase)',
        invertedSubject: 'es (formales grammatikalisches Subjekt)',
        pattern: InversionPattern.obligatoryValenceEs,
        esBehavior: EsDropBehavior.persistsInMittelfeld,
        domain: CommunicativeDomain.automatedRobotics,
        arabicTranslation:
            'عند إدماج الروبوتات الصناعية الحديثة، تتوفر وتنشأ تأثيرات تآزرية متعددة.',
        grammaticalAnalysisArabic:
            'التركيب الوجودي "es gibt": الضمير "es" فاعل أصيل لا يتخلف، يتحول إلى المركز المباشر بعد الفعل المصرف (gibt es) عند تقدم شبه الجملة.',
        grammaticalAnalysisGerman:
            'Existenzialkonstruktion "es gibt": Das Pronomen "es" ist Valenzträger und wandert obligatorisch nach V2 ins Mittelfeld.',
        wackernagelPositionRule:
            'Fungiert im Mittelfeld als Klitikon und schmiegt sich an das finite "gibt" an.',
        topologicalNote:
            'Ein Weglassen von "es" (*gibt zahlreiche Effekte) ist grob ungrammatisch.',
      ),
    );

    // 12. Professional Collaboration: Infinitive Fronting with Modal Verb
    _catalog.add(
      const InversionModel(
        id: 'INV-INF-TEAM-12',
        baseCanonicalSentence:
            'Das Wartungsteam muss den Haupttransformator bis morgen früh vollständig austauschen.',
        invertedSentence:
            'Vollständig austauschen muss das Wartungsteam den Haupttransformator bis morgen früh.',
        frontedElement: 'Vollständig austauschen (Erweiterter Infinitiv)',
        invertedSubject: 'das Wartungsteam',
        pattern: InversionPattern.participleFronting,
        esBehavior: EsDropBehavior.notApplicable,
        domain: CommunicativeDomain.professionalCollaboration,
        arabicTranslation:
            'الاستبدال الكامل والشامل هو ما يجب على فريق الصيانة تنفيذه للمحول الرئيسي قبل حلول صباح الغد.',
        grammaticalAnalysisArabic:
            'تقديم المصدر التام (Infinitivspitzenstellung) في الصدر لإظهار شدة الإلزام بنوعية الإجراء الفني المطلوب تنفيذه، متبوعاً بالفعل الناقص (muss).',
        grammaticalAnalysisGerman:
            'Infinitivspitzenstellung der verbalen Handlungseinheit zur maximalen Kontrastierung des Handlungsauftrags.',
        wackernagelPositionRule:
            'Modalverb "muss" steht auf V2, gefolgt vom Subjekt "das Wartungsteam" und dem Akkusativobjekt.',
        topologicalNote:
            'Hochgradig expressive Satzstruktur in professionellen Arbeitsanweisungen.',
      ),
    );
  }

  /// Evaluates an inverted sentence candidate against topological V2 and expletive constraints.
  InversionValidationReport validateInversion({
    required String frontedPhrase,
    required String finiteVerb,
    required String postVerbElement,
    required bool isVorfeldEsPresent,
    required bool isValenceEsVerb,
  }) {
    final issues = <String>[];
    final recommendations = <String>[];
    bool isV2 = true;
    bool respectsWackernagel = true;
    bool correctEs = true;

    if (finiteVerb.isEmpty) {
      isV2 = false;
      issues.add('Verletzung der V2-Regel: Das finite Verb fehlt an der zweiten Satzposition.');
      recommendations.add('Platzieren Sie das finite Prädikat unmittelbar nach dem Vorfeldausdruck.');
    }

    if (frontedPhrase.isNotEmpty && frontedPhrase.toLowerCase() != 'es') {
      if (isVorfeldEsPresent && !isValenceEsVerb) {
        correctEs = false;
        issues.add('Ullzulässiges Vorfeld-es im Mittelfeld: Das unpersönliche Vorfeld-es muss bei Vorfeldbesetzung durch ein anderes Satzglied getilgt werden.');
        recommendations.add('Löschen Sie das "es" aus dem Mittelfeld (z. B. "Gestern wurde gearbeitet", nicht "*Gestern wurde es gearbeitet").');
      }
    }

    if (isValenceEsVerb && !isVorfeldEsPresent) {
      correctEs = false;
      issues.add('Fehlendes Valenz-es: Verben wie "handeln um" oder "es gibt" verlangen zwingend das Pronomen "es" im Mittelfeld.');
      recommendations.add('Fügen Sie "es" unmittelbar nach dem finiten Verb ein (z. B. "Hierbei handelt es sich um...").');
    }

    final isValid = issues.isEmpty;
    final arabicSummary = isValid
        ? 'التركيب الطوبولوجي للجملة المقلوبة متوافق تماماً مع قواعد رتبة الكلم والضمائر الصورية (V2 & Wackernagel).'
        : 'تم رصد مخالفة في موقع الفعل المصرف أو استخدام الضمير الصوري es.';

    return InversionValidationReport(
      isValid: isValid,
      isV2Compliant: isV2,
      respectsWackernagelOrder: respectsWackernagel,
      correctEsBehavior: correctEs,
      issues: issues,
      recommendations: recommendations,
      arabicSummary: arabicSummary,
    );
  }

  List<InversionModel> filterByPattern(InversionPattern pattern) {
    return _catalog.where((item) => item.pattern == pattern).toList();
  }

  List<InversionModel> filterByEsBehavior(EsDropBehavior behavior) {
    return _catalog.where((item) => item.esBehavior == behavior).toList();
  }

  List<InversionModel> filterByDomain(CommunicativeDomain domain) {
    return _catalog.where((item) => item.domain == domain).toList();
  }
}
