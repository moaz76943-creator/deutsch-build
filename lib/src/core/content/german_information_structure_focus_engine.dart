import 'dart:collection';

/// Classification of information packaging in German sentence topology.
enum InformationPackagingType {
  neutralFocusProjection(
    'Neutrale Fokusprojektion (Breiter Fokus)',
    'إسقاط البؤرة المحايد (البؤرة العريضة للجملة بأكملها)',
    'Der Nuklearakzent liegt auf dem prädikatsnächsten internen Argument; die gesamte Proposition wird als neue Information transportiert.',
  ),
  narrowContrastiveFocus(
    'Enger Kontrastfokus (Selektive Akzentuierung)',
    'بؤرة التباين الضيقة (حصر الدلالة ونفي البدائل الأخرى)',
    'Ein einzelnes Satzglied wird intonatorisch hervorgehoben, um alternative Kandidaten im Diskurskontext explizit abzuweisen.',
  ),
  contrastiveTopicIKontur(
    'Kontrastives Thema (I-Kontur / Hutfeld)',
    'المبتدأ التبايني ذو النبرة الصاعدة ثم الهابطة (I-Kontur)',
    'Kombination aus ansteigender Brückenintonation auf dem Thema im Vorfeld und fallendem Hauptakzent auf dem Rhema im Mittelfeld.',
  ),
  givenBeforeNewScrambling(
    'Topologisches Scrambling (Thema vor Rhema)',
    'إعادة الترتيب الطوبولوجي (تقديم المعلوم على المجهول الجديد)',
    'Definite, bekannte Konstituenten wandern im Mittelfeld nach links, während unbestimmte neue Rhema-Elemente rechts fokussiert werden.',
  ),
  verumFocusAffirmation(
    'Verum-Fokus (Bekräftigung des Wahrheitswerts)',
    'بؤرة إثبات الحقيقة والتوكيد القطعي (النبر على الفعل المصرف)',
    'Der Nuklearakzent fällt auf das finite Verb (oder die Konjunktion), um die Gültigkeit der Proposition gegen Zweifel zu verteidigen.',
  ),
  exhaustiveExclusionFocus(
    'Exhaustiver Exklusionsfokus (Spalt- / Alleinstellungsfokus)',
    'بؤرة الحصر الشامل والاستثناء المطلق',
    'Fokussierung mit Exklusivpartikeln (nur, einzig), die alle anderen Komponenten aus der Gültigkeitsmenge ausschließt.',
  );

  final String deTitle;
  final String arTitle;
  final String grammaticalDescription;
  const InformationPackagingType(this.deTitle, this.arTitle, this.grammaticalDescription);
}

/// Positioning and phonetic target of the nuclear pitch accent (Nuklearakzent).
enum NuclearAccentPlacement {
  preverbalInternalArgument('Internes Argument vor der rechten Klammer', 'المكمل الداخلي الملاصق للقوس الفعلي الأيمن'),
  frontedVorfeldConstituent('Hervorgehobenes Vorfeld-Element', 'عنصر الصدارة المائل في الحقل الأمامي'),
  finiteVerbVerum('Finites Verb in linker Satzklammer (Verum)', 'الفعل المصرف في القوس الأيسر لتوكيد الحقيقة'),
  negationParticleScope('Negationspartikel (nicht) / Fokuspartikel', 'أداة النفي أو الحصر المركزة على العنصر'),
  scrambledDativeSubject('Topologisch vorangestelltes Dativ-Objekt', 'شبه الجملة المجرورة المتقدمة للتخصيص');

  final String de;
  final String ar;
  const NuclearAccentPlacement(this.de, this.ar);
}

/// Professional and engineering communicative domains free of legal/medical liability.
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

/// Structural model of an information structure and focus occurrence.
class InformationStructureModel {
  final String id;
  final InformationPackagingType packagingType;
  final NuclearAccentPlacement accentPlacement;
  final CommunicativeDomain domain;
  final String unmarkedSentence;
  final String markedFocusSentence;
  final String capitalizedNuclearAccentWord;
  final String topicConstituent;
  final String focusDomainConstituent;
  final String pragmaticContextGerman;
  final String pragmaticContextArabic;
  final String alternativeSetRejection;

  const InformationStructureModel({
    required this.id,
    required this.packagingType,
    required this.accentPlacement,
    required this.domain,
    required this.unmarkedSentence,
    required this.markedFocusSentence,
    required this.capitalizedNuclearAccentWord,
    required this.topicConstituent,
    required this.focusDomainConstituent,
    required this.pragmaticContextGerman,
    required this.pragmaticContextArabic,
    required this.alternativeSetRejection,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'packagingType': packagingType.name,
    'accentPlacement': accentPlacement.name,
    'domain': domain.name,
    'unmarkedSentence': unmarkedSentence,
    'markedFocusSentence': markedFocusSentence,
    'capitalizedNuclearAccentWord': capitalizedNuclearAccentWord,
    'topicConstituent': topicConstituent,
    'focusDomainConstituent': focusDomainConstituent,
    'pragmaticContextGerman': pragmaticContextGerman,
    'pragmaticContextArabic': pragmaticContextArabic,
    'alternativeSetRejection': alternativeSetRejection,
  };
}

/// Validation report for information-structural compliance.
class InformationStructureValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<String> acousticAndTopologicalNotes;

  const InformationStructureValidationResult({
    required this.isValid,
    required this.issues,
    required this.acousticAndTopologicalNotes,
  });
}

/// Core Engine managing German Information Structure & Focus-Background Partitioning.
class GermanInformationStructureFocusEngine {
  final List<InformationStructureModel> _catalog = [];

  GermanInformationStructureFocusEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<InformationStructureModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    _catalog.addAll([
      const InformationStructureModel(
        id: 'INFO-4957-01',
        packagingType: InformationPackagingType.neutralFocusProjection,
        accentPlacement: NuclearAccentPlacement.preverbalInternalArgument,
        domain: CommunicativeDomain.renewableEnergyGrid,
        unmarkedSentence:
            'Der Chefingenieur hat gestern die Steuerungssoftware der Netzstation aktualisiert.',
        markedFocusSentence:
            'Der Chefingenieur hat gestern die Steuerungssoftware der Netzstation AKTUALISIERT.',
        capitalizedNuclearAccentWord: 'AKTUALISIERT',
        topicConstituent: 'Der Chefingenieur / die Steuerungssoftware',
        focusDomainConstituent: 'die Steuerungssoftware der Netzstation aktualisiert (Breiter Fokus)',
        pragmaticContextGerman:
            'Antwort auf die offene Frage: "Was ist gestern im Umspannwerk geschehen?"',
        pragmaticContextArabic:
            'إجابة على سؤال عام مفتوح: "ماذا حدث بالأمس؟"؛ حيث يمتد التركيز ليشمل كامل الحدث دون حصر.',
        alternativeSetRejection: 'Keine Kontrastierung; neutrale Propositionseinführung.',
      ),
      const InformationStructureModel(
        id: 'INFO-4957-02',
        packagingType: InformationPackagingType.narrowContrastiveFocus,
        accentPlacement: NuclearAccentPlacement.frontedVorfeldConstituent,
        domain: CommunicativeDomain.aerospaceAndAviation,
        unmarkedSentence:
            'Wir müssen die Haupttreibstoffleitung austauschen, nicht die Hydraulikpumpe.',
        markedFocusSentence:
            'Die HAUPTTREIBSTOFFLEITUNG müssen wir austauschen, nicht die Hydraulikpumpe!',
        capitalizedNuclearAccentWord: 'HAUPTTREIBSTOFFLEITUNG',
        topicConstituent: 'wir / austauschen',
        focusDomainConstituent: 'Die Haupttreibstoffleitung (Enger Kontrastfokus)',
        pragmaticContextGerman:
            'Korrektur eines Missverständnisses im Triebwerksprotokoll: Das defekte Bauteil wird scharf kontrastiert.',
        pragmaticContextArabic:
            'تصحيح فوري لخطأ في قراءة تقرير الصيانة بحصر الاستبدال في أنبوب الوقود الرئيسي ونفي مضخة الهيدروليك.',
        alternativeSetRejection: 'Schließt {Hydraulikpumpe, Druckventil, Zündkerze} explizit aus.',
      ),
      const InformationStructureModel(
        id: 'INFO-4957-03',
        packagingType: InformationPackagingType.contrastiveTopicIKontur,
        accentPlacement: NuclearAccentPlacement.frontedVorfeldConstituent,
        domain: CommunicativeDomain.industrialRobotics,
        unmarkedSentence:
            'Die Kinematik-Parameter haben wir kalibriert, aber die Greiferkraft haben wir noch nicht optimiert.',
        markedFocusSentence:
            'Die KINEMATIK-Parameter / haben wir KALIBRIERT \\, aber die Greiferkraft noch nicht.',
        capitalizedNuclearAccentWord: 'KINEMATIK / KALIBRIERT',
        topicConstituent: 'Die Kinematik-Parameter (Kontrastives Thema mit steigendem Ton /)',
        focusDomainConstituent: 'kalibriert (Fallender Hauptakzent \\)',
        pragmaticContextGerman:
            'Doppelte I-Kontur (Wurzelkontur): Gliedert zwei Subthemen einer komplexen Montageabnahme gegeneinander ab.',
        pragmaticContextArabic:
            'نبرة مزدوجة متعاكسة (صاعدة على المبتدأ وهابطة على الخبر) لتوزيع إنجاز المعايرة مقارنة بقوة المقبض.',
        alternativeSetRejection: 'Hebt Teilabnahme hervor, lässt {Greiferkraft, Taktzeit} offen/unerledigt.',
      ),
      const InformationStructureModel(
        id: 'INFO-4957-04',
        packagingType: InformationPackagingType.givenBeforeNewScrambling,
        accentPlacement: NuclearAccentPlacement.preverbalInternalArgument,
        domain: CommunicativeDomain.civilInfrastructure,
        unmarkedSentence:
            'Der Statiker hat einen neuen Riss dem Prüfingenieur gemeldet.',
        markedFocusSentence:
            'Der Statiker hat dem Prüfingenieur [Thema/bekannt] einen neuen RISS [Rhema/neu] gemeldet.',
        capitalizedNuclearAccentWord: 'RISS',
        topicConstituent: 'dem Prüfingenieur (bekannter Referent)',
        focusDomainConstituent: 'einen neuen Riss (neuer diskursiver Referent)',
        pragmaticContextGerman:
            'Topologisches Scrambling im Mittelfeld: Das bekannte definite Dativobjekt rückt vor das neue unbestimmte Akkusativobjekt.',
        pragmaticContextArabic:
            'إعادة الترتيب الطوبولوجي بتقديم المفعول المجرور المعرف مسبقاً على المفعول به النكرة المستجد.',
        alternativeSetRejection: 'Vermeidet unnatürliche Voranstellung des Rhemakerns vor thematische Konstituenten.',
      ),
      const InformationStructureModel(
        id: 'INFO-4957-05',
        packagingType: InformationPackagingType.verumFocusAffirmation,
        accentPlacement: NuclearAccentPlacement.finiteVerbVerum,
        domain: CommunicativeDomain.materialScience,
        unmarkedSentence:
            'Die Kohlenstofffaser hält der Scherspannung stand.',
        markedFocusSentence:
            'Die Kohlenstofffaser HÄLT der berechneten Scherspannung stand (auch wenn der Gutachter zweifelte).',
        capitalizedNuclearAccentWord: 'HÄLT',
        topicConstituent: 'Die Kohlenstofffaser / der Scherspannung stand',
        focusDomainConstituent: 'Wahrheitswert der finiten Prädikation (Verum)',
        pragmaticContextGerman:
            'Verum-Fokus: Betont den Wahrheitswert der Aussage gegen den geäußerten Zweifel des Prüfers.',
        pragmaticContextArabic:
            'بؤرة توكيد الحقيقة بالنبر الحاسم على الفعل المصرف لدحض شكوك المدقق حول متانة ألياف الكربون.',
        alternativeSetRejection: 'Widerlegt die Kontrastannahme: {hält nicht stand}.',
      ),
      const InformationStructureModel(
        id: 'INFO-4957-06',
        packagingType: InformationPackagingType.exhaustiveExclusionFocus,
        accentPlacement: NuclearAccentPlacement.negationParticleScope,
        domain: CommunicativeDomain.maritimeLogistics,
        unmarkedSentence:
            'Der Schwerlastkran darf nur den vorgegebenen Containerbrückenbereich ansteuern.',
        markedFocusSentence:
            'Der Schwerlastkran darf NUR den vorgegebenen Containerbrückenbereich ansteuern.',
        capitalizedNuclearAccentWord: 'NUR',
        topicConstituent: 'Der Schwerlastkran / ansteuern',
        focusDomainConstituent: 'den vorgegebenen Containerbrückenbereich',
        pragmaticContextGerman:
            'Exhaustiver Fokus mittels Fokuspartikel: Verbietet strikt das Befahren aller anderen Terminalzonen.',
        pragmaticContextArabic:
            'بؤرة الحصر الشامل بأداة القصر "nur" لمنع تحرك الرافعة البحرية خارج مسار جسر الحاويات المعتمد.',
        alternativeSetRejection: 'Schließt alle übrigen Terminalzonen {Kai 3, Leerlager, Bahnverladung} aus.',
      ),
      const InformationStructureModel(
        id: 'INFO-4957-07',
        packagingType: InformationPackagingType.narrowContrastiveFocus,
        accentPlacement: NuclearAccentPlacement.preverbalInternalArgument,
        domain: CommunicativeDomain.renewableEnergyGrid,
        unmarkedSentence:
            'Wir müssen die Blindleistungskompensation im Umspannwerk optimieren.',
        markedFocusSentence:
            'Wir müssen die BLINDLEISTUNGSKOMPENSATION optimieren, nicht die Wirkleistung!',
        capitalizedNuclearAccentWord: 'BLINDLEISTUNGSKOMPENSATION',
        topicConstituent: 'Wir / optimieren',
        focusDomainConstituent: 'die Blindleistungskompensation',
        pragmaticContextGerman:
            'Kontrastive Spezifizierung der elektrotechnischen Messgröße zur Vermeidung von Fehlregelungen.',
        pragmaticContextArabic:
            'تحديد تبايني دقيق لمعامل تعويض القدرة غير الفعالة مع نفي استهداف القدرة الفعالة منعاً للخلل.',
        alternativeSetRejection: 'Schließt {Wirkleistung, Netzfrequenz, Scheinfaktor} aus.',
      ),
      const InformationStructureModel(
        id: 'INFO-4957-08',
        packagingType: InformationPackagingType.givenBeforeNewScrambling,
        accentPlacement: NuclearAccentPlacement.scrambledDativeSubject,
        domain: CommunicativeDomain.aerospaceAndAviation,
        unmarkedSentence:
            'Die Missionskontrolle hat dem Navigationscomputer die neuen Bahndaten übermittelt.',
        markedFocusSentence:
            'Die Missionskontrolle hat dem Navigationscomputer [Thema] die neuen BAHNDATEN [Rhema] übermittelt.',
        capitalizedNuclearAccentWord: 'BAHNDATEN',
        topicConstituent: 'dem Navigationscomputer',
        focusDomainConstituent: 'die neuen Bahndaten',
        pragmaticContextGerman:
            'Linearisierung im Mittelfeld: Das bekannte Steuerungsziel steht links; das neue Orbitmanöver bildet den Akzentgipfel.',
        pragmaticContextArabic:
            'تقديم الحاسوب الملاحي المعروف كأرضية موضوعية وإبراز بيانات المدار الفضائي الجديدة كبؤرة إخبارية.',
        alternativeSetRejection: 'Ordnet Telemetrie logisch nach Vorwissensgrad.',
      ),
      const InformationStructureModel(
        id: 'INFO-4957-09',
        packagingType: InformationPackagingType.verumFocusAffirmation,
        accentPlacement: NuclearAccentPlacement.finiteVerbVerum,
        domain: CommunicativeDomain.civilInfrastructure,
        unmarkedSentence:
            'Das Fundament erfüllt die Anforderungen an die Erdbebensicherheit.',
        markedFocusSentence:
            'Das Fundament ERFÜLLT die geforderten Normen zur Erdbebensicherheit (entgegen den Bedenken).',
        capitalizedNuclearAccentWord: 'ERFÜLLT',
        topicConstituent: 'Das Fundament / die geforderten Normen',
        focusDomainConstituent: 'Wahrheitswert des Prädikats erfüllen',
        pragmaticContextGerman:
            'Nachdrückliche Verum-Bestätigung nach kritischer Nachprüfung durch den Bauherrn.',
        pragmaticContextArabic:
            'توكيد قطعي لفعل "المطابقة" لمواصفات الزلازل في وجه تشكيك المقاول الميداني.',
        alternativeSetRejection: 'Negiert {erfüllt nicht / scheitert an der Norm}.',
      ),
      const InformationStructureModel(
        id: 'INFO-4957-10',
        packagingType: InformationPackagingType.contrastiveTopicIKontur,
        accentPlacement: NuclearAccentPlacement.frontedVorfeldConstituent,
        domain: CommunicativeDomain.materialScience,
        unmarkedSentence:
            'Die Zugfestigkeit haben wir im Prüflabor ermittelt, aber die Bruchdehnung müssen wir noch berechnen.',
        markedFocusSentence:
            'Die ZUGFESTIGKEIT / haben wir im Prüflabor ERMITTELT \\, die Bruchdehnung noch nicht.',
        capitalizedNuclearAccentWord: 'ZUGFESTIGKEIT / ERMITTELT',
        topicConstituent: 'Die Zugfestigkeit (steigend /)',
        focusDomainConstituent: 'ermittelt (fallend \\)',
        pragmaticContextGerman:
            'Gegenüberstellung zweier Materialkennwerte mit prototypischer Hutfeld-/Brückenintonation.',
        pragmaticContextArabic:
            'تقابل نبري بين معيار قوة الشد المنجز مخبرياً ومعيار استطالة الانكسار المؤجل حسابياً.',
        alternativeSetRejection: 'Grenzt {Zugfestigkeit} von {Bruchdehnung, Kerbschlagarbeit} ab.',
      ),
      const InformationStructureModel(
        id: 'INFO-4957-11',
        packagingType: InformationPackagingType.narrowContrastiveFocus,
        accentPlacement: NuclearAccentPlacement.frontedVorfeldConstituent,
        domain: CommunicativeDomain.industrialRobotics,
        unmarkedSentence:
            'Der Servomotor der zweiten Achse hat blockiert, nicht das Getriebe.',
        markedFocusSentence:
            'Der SERVOMOTOR der zweiten Achse hat blockiert, nicht das Getriebe!',
        capitalizedNuclearAccentWord: 'SERVOMOTOR',
        topicConstituent: 'der zweiten Achse / hat blockiert',
        focusDomainConstituent: 'Der Servomotor (Kontrastfokus)',
        pragmaticContextGerman:
            'Präzise Lokalisierung der Schadensursache zur Einleitung zielgerichteter Instandsetzung.',
        pragmaticContextArabic:
            'حصر موضع العطل الميكانيكي في محرك المحور الثاني تحديداً وتبرئة صندوق التروس.',
        alternativeSetRejection: 'Schließt {Getriebe, Wellenkupplung, Encoder} aus.',
      ),
      const InformationStructureModel(
        id: 'INFO-4957-12',
        packagingType: InformationPackagingType.exhaustiveExclusionFocus,
        accentPlacement: NuclearAccentPlacement.negationParticleScope,
        domain: CommunicativeDomain.renewableEnergyGrid,
        unmarkedSentence:
            'Die Sicherheitsabschaltung reagiert allein auf Überstromspitzen im Primärkreis.',
        markedFocusSentence:
            'Die Sicherheitsabschaltung reagiert ALLEIN auf Überstromspitzen im Primärkreis.',
        capitalizedNuclearAccentWord: 'ALLEIN',
        topicConstituent: 'Die Sicherheitsabschaltung / reagiert',
        focusDomainConstituent: 'auf Überstromspitzen im Primärkreis',
        pragmaticContextGerman:
            'Exklusiver Fokus zur Vermeidung von Fehlauslösungen bei transienten Spannungsschwankungen.',
        pragmaticContextArabic:
            'قصر استجابة قاطع الأمان على ذروات التيار الزائد حصرياً وتجاهل التموجات الهامشية.',
        alternativeSetRejection: 'Schließt {Spannungsabfall, Frequenzzittern, Temperaturanstieg} als Auslöser aus.',
      ),
      const InformationStructureModel(
        id: 'INFO-4957-13',
        packagingType: InformationPackagingType.neutralFocusProjection,
        accentPlacement: NuclearAccentPlacement.preverbalInternalArgument,
        domain: CommunicativeDomain.maritimeLogistics,
        unmarkedSentence:
            'Das Frachtschiff hat heute früh den Nord-Ostsee-Kanal passiert.',
        markedFocusSentence:
            'Das Frachtschiff hat heute früh den Nord-Ostsee-Kanal PASSIERT.',
        capitalizedNuclearAccentWord: 'PASSIERT',
        topicConstituent: 'Das Frachtschiff / heute früh',
        focusDomainConstituent: 'den Nord-Ostsee-Kanal passiert (All-New VP Focus)',
        pragmaticContextGerman:
            'Logistisches Standard-Situationsupdate ohne Einengung auf einzelne Konstituenten.',
        pragmaticContextArabic:
            'تحديث ملاحي قياسي يفيد بعبور السفينة لقناة كيل دون توجيه نبرة تباينية خاصة.',
        alternativeSetRejection: 'Keine Abweisung; unmarkierter Nachrichtenübertrag.',
      ),
      const InformationStructureModel(
        id: 'INFO-4957-14',
        packagingType: InformationPackagingType.givenBeforeNewScrambling,
        accentPlacement: NuclearAccentPlacement.preverbalInternalArgument,
        domain: CommunicativeDomain.materialScience,
        unmarkedSentence:
            'Die Forscher haben der Versuchslegierung seltene Erden beigemischt.',
        markedFocusSentence:
            'Die Forscher haben der Versuchslegierung [Thema] seltene ERDEN [Rhema] beigemischt.',
        capitalizedNuclearAccentWord: 'ERDEN',
        topicConstituent: 'der Versuchslegierung (bereits eingeführte Basis)',
        focusDomainConstituent: 'seltene Erden (neu hinzugefügtes Additiv)',
        pragmaticContextGerman:
            'Das Grundmetall ist das Thema des Versuchs; der Nuklearakzent fokussiert das innovative Dotiermaterial.',
        pragmaticContextArabic:
            'تقديم السبيكة التجريبية كقاعدة بحثية سابقة ونبر العناصر الأرضية النادرة كعنصر مضاف مبتكر.',
        alternativeSetRejection: 'Folgt dem natürlichen Informationsfluss von Bekanntem zu Unbekanntem.',
      ),
      const InformationStructureModel(
        id: 'INFO-4957-15',
        packagingType: InformationPackagingType.verumFocusAffirmation,
        accentPlacement: NuclearAccentPlacement.finiteVerbVerum,
        domain: CommunicativeDomain.aerospaceAndAviation,
        unmarkedSentence:
            'Die Bremsklappen wurden vor dem Aufsetzen voll ausgefahren.',
        markedFocusSentence:
            'Die Bremsklappen WURDEN vor dem Aufsetzen voll ausgefahren (das Flugschreiberprotokoll belegt es).',
        capitalizedNuclearAccentWord: 'WURDEN',
        topicConstituent: 'Die Bremsklappen / voll ausgefahren',
        focusDomainConstituent: 'Wahrheitswert des Passivhilfsverbs (Wurden)',
        pragmaticContextGerman:
            'Entlastende Verum-Betonung bei der Auswertung eines Zwischenfallberichts.',
        pragmaticContextArabic:
            'توكيد وقوع نشر كوابح الطائرة بناءً على معطيات الصندوق الأسود رداً على افتراض التقصير.',
        alternativeSetRejection: 'Widerlegt Vorwurf: {Bremsklappen blieben eingefahren}.',
      ),
      const InformationStructureModel(
        id: 'INFO-4957-16',
        packagingType: InformationPackagingType.contrastiveTopicIKontur,
        accentPlacement: NuclearAccentPlacement.frontedVorfeldConstituent,
        domain: CommunicativeDomain.civilInfrastructure,
        unmarkedSentence:
            'Den Brückenüberbau haben wir schwingungstechnisch geprüft, aber die Gründungssohle müssen wir noch untersuchen.',
        markedFocusSentence:
            'Den BRÜCKENÜBERBAU / haben wir schwingungstechnisch GEPRÜFT \\, die Gründungssohle noch nicht.',
        capitalizedNuclearAccentWord: 'BRÜCKENÜBERBAU / GEPRÜFT',
        topicConstituent: 'Den Brückenüberbau (steigende Brückentonhöhe /)',
        focusDomainConstituent: 'geprüft (fallender Nuklearakzent \\)',
        pragmaticContextGerman:
            'Präzise Diskursgliederung bei Bauabnahmen: Trennt geprüfte Tragwerke von ausstehenden Tiefbautests.',
        pragmaticContextArabic:
            'توزيع نبري يبرز انتهاء فحص الهيكل العلوي للجسر مع إبقاء فحص قاع الأساسات قيد الانتظار.',
        alternativeSetRejection: 'Grenzt {Überbau} gegen {Unterbau, Gründungspfähle} ab.',
      ),
    ]);
  }

  List<InformationStructureModel> getByType(InformationPackagingType type) =>
      _catalog.where((e) => e.packagingType == type).toList();

  List<InformationStructureModel> getByDomain(CommunicativeDomain domain) =>
      _catalog.where((e) => e.domain == domain).toList();

  List<InformationStructureModel> getByAccentPlacement(NuclearAccentPlacement placement) =>
      _catalog.where((e) => e.accentPlacement == placement).toList();

  /// Validates information packaging topology and intonational stress rules.
  InformationStructureValidationResult validateInformationStructure({
    required InformationPackagingType packagingType,
    required bool hasCapitalizedAccentWord,
    required bool isGivenPlacedBeforeNew,
    required bool isVerumOnFiniteVerb,
  }) {
    final List<String> issues = [];
    final List<String> notes = [];

    if (!hasCapitalizedAccentWord) {
      issues.add('Phonetischer Mangel: Der Nuklearakzent muss durch Versalschreibung eindeutig markiert sein.');
    }

    if (packagingType == InformationPackagingType.givenBeforeNewScrambling && !isGivenPlacedBeforeNew) {
      issues.add('Topologischer Verstoß: Bekannte definite Konstituenten müssen vor unbestimmte neue Rhema-Elemente gestellt werden.');
    } else if (packagingType == InformationPackagingType.givenBeforeNewScrambling) {
      notes.add('Topologisch optimal: Thema vor Rhema (Scrambling gesichert).');
    }

    if (packagingType == InformationPackagingType.verumFocusAffirmation && !isVerumOnFiniteVerb) {
      issues.add('Fokus-Fehler: Verum-Fokus verlangt den Hauptakzent auf dem finiten Verb in Position II (bzw. I).');
    } else if (packagingType == InformationPackagingType.verumFocusAffirmation) {
      notes.add('Pragmatisch optimal: Verum-Fokus liegt exakt auf der finiten Satzklammer.');
    }

    if (packagingType == InformationPackagingType.contrastiveTopicIKontur) {
      notes.add('Intonatorisch fundiert: I-Kontur (steigender Thema-Akzent im Vorfeld, fallender Rhema-Akzent im Mittelfeld).');
    }

    return InformationStructureValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      acousticAndTopologicalNotes: notes,
    );
  }

  Map<String, dynamic> generateTelemetrySnapshot() {
    return {
      'totalExemplars': _catalog.length,
      'typeDistribution': {
        for (var t in InformationPackagingType.values)
          t.name: _catalog.where((e) => e.packagingType == t).length,
      },
      'domainDistribution': {
        for (var d in CommunicativeDomain.values)
          d.name: _catalog.where((e) => e.domain == d).length,
      },
      'accentPlacementDistribution': {
        for (var p in NuclearAccentPlacement.values)
          p.name: _catalog.where((e) => e.accentPlacement == p).length,
      },
      'cefrLevel': 'CEFR C1-C2 Masterclass Information Structure',
      'engineVersion': '1.0.0+subsystem1791',
    };
  }
}
