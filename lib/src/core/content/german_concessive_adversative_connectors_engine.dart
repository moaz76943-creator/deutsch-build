import 'dart:collection';

/// Classification of complex technical connectors in CEFR C1-C2 German discourse.
enum ConnectorTopologyType {
  restrictiveConditional(
    'Restriktiv-konditional (insofern / insoweit [als]: Einschränkung des Geltungsbereichs)',
    'التقييد الشرطي ونطاق الصلاحية (بقدر ما / شريطة أن / في حدود ما: حصر المعيار الفني)',
    'Definiert den exakten mathematischen oder betrieblichen Gültigkeitsbereich einer Garantie oder Auslegung: "Die Garantie greift, insofern die Betriebstemperatur 65 Grad nicht überschreitet."',
  ),
  elevatedConcessiveSubordinating(
    'Gehoben-konzessiv subordinierend (wenngleich, wiewohl, obgleich: Einräumung)',
    'التنازل والتعارض الرفيع ذو التبعية النحوية (وإن كان / على الرغم من أن: أسلوب تقارير التدقيق)',
    'Leitet einen Nebensatz mit Verbletztstellung ein, um ein Gegenargument stilistisch anspruchsvoll einzuräumen: "Wenngleich die Messkurve leichte Oszillationen aufwies, blieb das Netz stabil."',
  ),
  negativeScalarAdditive(
    'Negativ-skalar additiv (geschweige denn: Steigerung nach Negation)',
    'الإضافة التدريجية السالبة (ناهيك عن / فكيف بـ: اشتراط وجود نفي سابق في الجملة الرئيسية)',
    'Verstärkt eine vorausgegangene Verneinung durch Ausschluss einer noch naheliegenderen oder anspruchsvolleren Option: "Die Pumpe erreicht nicht einmal 2 bar, geschweige denn den Nenndruck von 6 bar."',
  ),
  comparativeAdversative(
    'Komparativ-adversativ (wohingegen, währendhingegen: Gegenüberstellung zweier Fakten)',
    'المقابلة التناقضية المباشرة (في حين أن / بينما على النقيض: مضاهاة خاصيتين فيزيائيتين)',
    'Stellt zwei objektive Messgrößen oder Werkstoffeigenschaften kontrastierend gegenüber: "Stahl widersteht Scherkräften, wohingegen Keramik spröde bricht."',
  ),
  causalReinforcingIntensifier(
    'Kausal verstärkend / nachgeschoben (zumal [da]: Zusätzliche Begründung)',
    'التعليل التوكيدي الإضافي (لا سيما وأن / خصوصاً وأن: حجة إضافية حاسمة ترجح القرار)',
    'Fügt einen entscheidenden, verstärkenden Kausalgrund an: "Die Anlage wurde notabgeschaltet, zumal der Drucksensor unplausible Werte lieferte."',
  ),
  prepositionalAdverbialCohesive(
    'Präpositional-adverbial kohäsiv (ungeachtet dessen, demzufolge: V2-Konnexion)',
    'الربط الظرفي المجرور (بصرف النظر عن ذلك / بناءً على ذلك: روابط الصدارة برتبة V2)',
    'Verbindet Sätze über Absatzgrenzen hinweg im Vorfeld mit obligatorischer Verbzweitstellung (Inversion).',
  );

  final String deTitle;
  final String arTitle;
  final String grammaticalDefinition;
  const ConnectorTopologyType(this.deTitle, this.arTitle, this.grammaticalDefinition);
}

/// Syntactic positioning and word order constraint governed by the connector.
enum ClausePositionSyntax {
  subordinatingVerbFinal('Subordinierender Nebensatz (Konnektor + Verbletztstellung)', 'جملة فرعية تابعة بفعل مؤخر في نهاية الجملة'),
  adverbialVerbSecondInversion('Adverbialer Hauptsatz (Konnektor im Vorfeld + V2-Inversion)', 'جملة رئيسية بتقديم الرابط في الصدارة وتأخير الفاعل بعد الفعل'),
  ellipticalScalarPostposition('Skalare Anschlussposition (geschweige denn + DP/Infinitiv)', 'وصل تدريجي بعد النفي متبوع بمركب اسمي أو مصدري');

  final String de;
  final String ar;
  const ClausePositionSyntax(this.de, this.ar);
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

/// Structural model of a complex German connector occurrence.
class ConcessiveAdversativeConnectorModel {
  final String id;
  final ConnectorTopologyType topologyType;
  final ClausePositionSyntax positionSyntax;
  final CommunicativeDomain domain;
  final String connectorPhrase;
  final String basePrimaryClause;
  final String secondaryLinkedClause;
  final String fullGermanSentence;
  final String pragmaticDiscourseFunctionGerman;
  final String pragmaticDiscourseFunctionArabic;
  final bool negativePolarityRequirement;
  final String topologicalOrderRule;

  const ConcessiveAdversativeConnectorModel({
    required this.id,
    required this.topologyType,
    required this.positionSyntax,
    required this.domain,
    required this.connectorPhrase,
    required this.basePrimaryClause,
    required this.secondaryLinkedClause,
    required this.fullGermanSentence,
    required this.pragmaticDiscourseFunctionGerman,
    required this.pragmaticDiscourseFunctionArabic,
    this.negativePolarityRequirement = false,
    required this.topologicalOrderRule,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'topologyType': topologyType.name,
    'positionSyntax': positionSyntax.name,
    'domain': domain.name,
    'connectorPhrase': connectorPhrase,
    'basePrimaryClause': basePrimaryClause,
    'secondaryLinkedClause': secondaryLinkedClause,
    'fullGermanSentence': fullGermanSentence,
    'pragmaticDiscourseFunctionGerman': pragmaticDiscourseFunctionGerman,
    'pragmaticDiscourseFunctionArabic': pragmaticDiscourseFunctionArabic,
    'negativePolarityRequirement': negativePolarityRequirement,
    'topologicalOrderRule': topologicalOrderRule,
  };
}

/// Validation result for connector syntax and polarity.
class ConnectorValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<String> topologicalNotes;

  const ConnectorValidationResult({
    required this.isValid,
    required this.issues,
    required this.topologicalNotes,
  });
}

/// Core Engine managing German Complex Concessive, Adversative & Restrictive Connectors.
class GermanConcessiveAdversativeConnectorsEngine {
  final List<ConcessiveAdversativeConnectorModel> _catalog = [];

  GermanConcessiveAdversativeConnectorsEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<ConcessiveAdversativeConnectorModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    _catalog.addAll([
      // 1. insofern als (Restriktiv, Verbletzt)
      const ConcessiveAdversativeConnectorModel(
        id: 'CONN-4965-01',
        topologyType: ConnectorTopologyType.restrictiveConditional,
        positionSyntax: ClausePositionSyntax.subordinatingVerbFinal,
        domain: CommunicativeDomain.renewableEnergyGrid,
        connectorPhrase: 'insofern als',
        basePrimaryClause:
            'Die Betriebserlaubnis für den Batteriespeicher bleibt aufrechterhalten',
        secondaryLinkedClause:
            'die Zelltemperatur den Grenzwert von 45 Grad Celsius zu keinem Zeitpunkt übersteigt',
        fullGermanSentence:
            'Die Betriebserlaubnis für den Batteriespeicher bleibt aufrechterhalten, insofern als die Zelltemperatur den Grenzwert von 45 Grad Celsius zu keinem Zeitpunkt übersteigt.',
        pragmaticDiscourseFunctionGerman:
            'Restriktiv-konditionale Eingrenzung: Formuliert die präzise technische Bedingung, unter der die Betriebsgenehmigung fortbesteht.',
        pragmaticDiscourseFunctionArabic:
            'تقييد شرطي دقيق: بقاء رخصة تشغيل بطارية التخزين سارية بقدر ما لا تتجاوز حرارة الخلايا 45 درجة مئوية.',
        topologicalOrderRule: 'Subordinierend mit Verbletztstellung: "... übersteigt."',
      ),
      // 2. wenngleich (Gehoben-konzessiv, Verbletzt)
      const ConcessiveAdversativeConnectorModel(
        id: 'CONN-4965-02',
        topologyType: ConnectorTopologyType.elevatedConcessiveSubordinating,
        positionSyntax: ClausePositionSyntax.subordinatingVerbFinal,
        domain: CommunicativeDomain.aerospaceAndAviation,
        connectorPhrase: 'wenngleich',
        basePrimaryClause:
            'Das Fahrwerk absorbierte die vertikale Aufsetzkraft ohne strukturelle Deformation',
        secondaryLinkedClause:
            'die Sinkgeschwindigkeit geringfügig über dem projektierten Standardwert lag',
        fullGermanSentence:
            'Das Fahrwerk absorbierte die vertikale Aufsetzkraft ohne strukturelle Deformation, wenngleich die Sinkgeschwindigkeit geringfügig über dem projektierten Standardwert lag.',
        pragmaticDiscourseFunctionGerman:
            'Stilistisch gehobene Konzession: Räumt ein erhöhtes Landegewicht ein, bestätigt aber die Robustheit der Mechanik.',
        pragmaticDiscourseFunctionArabic:
            'تنازل فني رفيع المستوى: امتصاص منظومة الهبوط لقوة الصدمة الرأسية وإن كانت سرعة الهبوط أعلى من المعيار المحدد.',
        topologicalOrderRule: 'Subordinierender Nebensatz: "... lag."',
      ),
      // 3. geschweige denn (Negativ-skalar, strikte Negationspolarität)
      const ConcessiveAdversativeConnectorModel(
        id: 'CONN-4965-03',
        topologyType: ConnectorTopologyType.negativeScalarAdditive,
        positionSyntax: ClausePositionSyntax.ellipticalScalarPostposition,
        domain: CommunicativeDomain.industrialRobotics,
        connectorPhrase: 'geschweige denn',
        basePrimaryClause:
            'Der fehlerhaft montierte Servomotor konnte nicht einmal das Haltemoment aufbringen',
        secondaryLinkedClause:
            'den sechsachsigen Knickarm unter Vollast beschleunigen',
        fullGermanSentence:
            'Der fehlerhaft montierte Servomotor konnte nicht einmal das Haltemoment aufbringen, geschweige denn den sechsachsigen Knickarm unter Vollast beschleunigen.',
        pragmaticDiscourseFunctionGerman:
            'Negative Polaritätspflicht: "geschweige denn" verlangt zwingend die Negationspartikel "nicht einmal" im Hauptsatz.',
        pragmaticDiscourseFunctionArabic:
            'إضافة تدريجية سالبة ملزمة بنفي سابق: عجز المحرك عن مجرد تثبيت العزم ناهيك عن تسريع ذراع الروبوت بكامل الحمولة.',
        negativePolarityRequirement: true,
        topologicalOrderRule: 'Anschluss an negierten Hauptsatz; elliptische Weiterführung mit Infinitiv/Akkusativ.',
      ),
      // 4. wohingegen (Komparativ-adversativ, Verbletzt)
      const ConcessiveAdversativeConnectorModel(
        id: 'CONN-4965-04',
        topologyType: ConnectorTopologyType.comparativeAdversative,
        positionSyntax: ClausePositionSyntax.subordinatingVerbFinal,
        domain: CommunicativeDomain.materialScience,
        connectorPhrase: 'wohingegen',
        basePrimaryClause:
            'Austenitischer Chrom-Nickel-Stahl zeichnet sich durch hohe Duktilität bei kryogenen Temperaturen aus',
        secondaryLinkedClause:
            'ferritische Legierungen unterhalb von minus 40 Grad zu sprödem Kaltbruch neigen',
        fullGermanSentence:
            'Austenitischer Chrom-Nickel-Stahl zeichnet sich durch hohe Duktilität bei kryogenen Temperaturen aus, wohingegen ferritische Legierungen unterhalb von minus 40 Grad zu sprödem Kaltbruch neigen.',
        pragmaticDiscourseFunctionGerman:
            'Kontrastierende Gegenüberstellung zweier Materialeigenschaften ohne temporale Verwechslungsgefahr.',
        pragmaticDiscourseFunctionArabic:
            'مقابلة تناقضية علمية: تميز الصلب الأوستنيتي بمرونة فائقة بالبرودة في حين تميل السبائك الفيريتية للكسر الهش.',
        topologicalOrderRule: 'Verbletztstellung im Nebensatz: "... neigen."',
      ),
      // 5. zumal (Kausal-verstärkend, Verbletzt)
      const ConcessiveAdversativeConnectorModel(
        id: 'CONN-4965-05',
        topologyType: ConnectorTopologyType.causalReinforcingIntensifier,
        positionSyntax: ClausePositionSyntax.subordinatingVerbFinal,
        domain: CommunicativeDomain.civilInfrastructure,
        connectorPhrase: 'zumal',
        basePrimaryClause:
            'Die Bauaufsicht verweigerte die Freigabe des Spannbetonträgers',
        secondaryLinkedClause:
            'die Rissbreite an der Unterseite den statischen Grenzwert von 0,2 Millimetern deutlich überschritt',
        fullGermanSentence:
            'Die Bauaufsicht verweigerte die Freigabe des Spannbetonträgers, zumal die Rissbreite an der Unterseite den statischen Grenzwert von 0,2 Millimetern deutlich überschritt.',
        pragmaticDiscourseFunctionGerman:
            'Verstärkende Kausalbegründung: "zumal" führt das ausschlaggebende, verschärfende Argument für den Baustopp an.',
        pragmaticDiscourseFunctionArabic:
            'تعليل توكيدي مشدد: رفض هيئة الرقابة اعتماد العارضة الخرسانية لا سيما وأن اتساع الشروخ تجاوز الحد المسموح به.',
        topologicalOrderRule: 'Subordinierende Kausalverknüpfung mit Verbletztstellung: "... überschritt."',
      ),
      // 6. ungeachtet dessen (Adverbial, V2-Inversion)
      const ConcessiveAdversativeConnectorModel(
        id: 'CONN-4965-06',
        topologyType: ConnectorTopologyType.prepositionalAdverbialCohesive,
        positionSyntax: ClausePositionSyntax.adverbialVerbSecondInversion,
        domain: CommunicativeDomain.maritimeLogistics,
        connectorPhrase: 'ungeachtet dessen',
        basePrimaryClause:
            'Der Windmesser am Leuchtturm registrierte orkanartige Böen der Stärke 10',
        secondaryLinkedClause:
            'entschied der Hafenkapitän, den Schleppverband mit zwei Zusatzschleppern sicher einzubringen',
        fullGermanSentence:
            'Der Windmesser am Leuchtturm registrierte orkanartige Böen der Stärke 10. Ungeachtet dessen entschied der Hafenkapitän, den Schleppverband mit zwei Zusatzschleppern sicher einzubringen.',
        pragmaticDiscourseFunctionGerman:
            'Vorfeld-Konnektor mit V2-Inversion: "Ungeachtet dessen" steht auf Position 1, gefolgt vom finiten Verb "entschied".',
        pragmaticDiscourseFunctionArabic:
            'ربط ظرفي مجرور بصدارة الجملة: بصرف النظر عن الرياح العاصفة، قرر قبطان الميناء إدخال القاطرة بسفينتي سحب إضافيتين.',
        topologicalOrderRule: 'Vorfeld-Positionierung erzwingt V2-Inversion (Verb "entschied" vor Subjekt "der Hafenkapitän").',
      ),
      // 7. insoweit als (Restriktiv, Verbletzt)
      const ConcessiveAdversativeConnectorModel(
        id: 'CONN-4965-07',
        topologyType: ConnectorTopologyType.restrictiveConditional,
        positionSyntax: ClausePositionSyntax.subordinatingVerbFinal,
        domain: CommunicativeDomain.renewableEnergyGrid,
        connectorPhrase: 'insoweit als',
        basePrimaryClause:
            'Der Netzkoppler gleicht transiente Frequenzabweichungen im Millisekundenbereich aus',
        secondaryLinkedClause:
            'die Speicherkapazität des Schwungrad-Energiespeichers nicht erschöpft ist',
        fullGermanSentence:
            'Der Netzkoppler gleicht transiente Frequenzabweichungen im Millisekundenbereich aus, insoweit als die Speicherkapazität des Schwungrad-Energiespeichers nicht erschöpft ist.',
        pragmaticDiscourseFunctionGerman:
            'Präzise Festlegung der Pufferkapazitätsgrenze im Stromnetz.',
        pragmaticDiscourseFunctionArabic:
            'حصر تقييدي لطاقة الموازنة: محول الربط يعوض تذبذب التردد في حدود ما لا تنفد طاقة تخزين الحدافة الدوارة.',
        topologicalOrderRule: 'Verbletztstellung: "... erschöpft ist."',
      ),
      // 8. wiewohl (Gehoben-konzessiv, Verbletzt)
      const ConcessiveAdversativeConnectorModel(
        id: 'CONN-4965-08',
        topologyType: ConnectorTopologyType.elevatedConcessiveSubordinating,
        positionSyntax: ClausePositionSyntax.subordinatingVerbFinal,
        domain: CommunicativeDomain.materialScience,
        connectorPhrase: 'wiewohl',
        basePrimaryClause:
            'Die nanostrukturierte Beschichtung zeigte eine bemerkenswerte Kavitationsbeständigkeit',
        secondaryLinkedClause:
            'sie im Laborversuch extremen hydrodynamischen Druckstößen ausgesetzt war',
        fullGermanSentence:
            'Die nanostrukturierte Beschichtung zeigte eine bemerkenswerte Kavitationsbeständigkeit, wiewohl sie im Laborversuch extremen hydrodynamischen Druckstößen ausgesetzt war.',
        pragmaticDiscourseFunctionGerman:
            'Archaistisch-eleganter Konzessivkonnektor in wissenschaftlichen Publikationen.',
        pragmaticDiscourseFunctionArabic:
            'أداة تنازل بلاغية رفيعة: الطلاء النانوي أظهر صموداً مذهلاً أمام التكهف وإن كان خاضعاً لضغوط هيدروديناميكية قاسية.',
        topologicalOrderRule: 'Verbletztstellung: "... ausgesetzt war."',
      ),
      // 9. geschweige denn (Negative Polarität mit "kein")
      const ConcessiveAdversativeConnectorModel(
        id: 'CONN-4965-09',
        topologyType: ConnectorTopologyType.negativeScalarAdditive,
        positionSyntax: ClausePositionSyntax.ellipticalScalarPostposition,
        domain: CommunicativeDomain.aerospaceAndAviation,
        connectorPhrase: 'geschweige denn',
        basePrimaryClause:
            'Die beschädigte Hydraulikleitung konnte keinen messbaren Betriebsdruck mehr aufbauen',
        secondaryLinkedClause:
            'die schweren Fahrwerksklappen gegen den Fahrtwind öffnen',
        fullGermanSentence:
            'Die beschädigte Hydraulikleitung konnte keinen messbaren Betriebsdruck mehr aufbauen, geschweige denn die schweren Fahrwerksklappen gegen den Fahrtwind öffnen.',
        pragmaticDiscourseFunctionGerman:
            'Skalare Negationsfolge gestützt durch "keinen messbaren Betriebsdruck".',
        pragmaticDiscourseFunctionArabic:
            'استحالة تصاعدية بعد نفي مطلق: عجز أنبوب الهيدروليك عن توليد أي ضغط فكيف بفتح أغطية العجلات أمام مقاومة الرياح.',
        negativePolarityRequirement: true,
        topologicalOrderRule: 'Erzwingt Negationsanker ("keinen") im übergeordneten Satz.',
      ),
      // 10. demzufolge (Adverbial, V2-Inversion)
      const ConcessiveAdversativeConnectorModel(
        id: 'CONN-4965-10',
        topologyType: ConnectorTopologyType.prepositionalAdverbialCohesive,
        positionSyntax: ClausePositionSyntax.adverbialVerbSecondInversion,
        domain: CommunicativeDomain.industrialRobotics,
        connectorPhrase: 'demzufolge',
        basePrimaryClause:
            'Der Feldbus-Controller verlor das Synchronisationstelegramm der Leitebene',
        secondaryLinkedClause:
            'schaltete das Sicherheitsrelais die gesamte Schweißstraße in den Not-Halt-Zustand',
        fullGermanSentence:
            'Der Feldbus-Controller verlor das Synchronisationstelegramm der Leitebene. Demzufolge schaltete das Sicherheitsrelais die gesamte Schweißstraße in den Not-Halt-Zustand.',
        pragmaticDiscourseFunctionGerman:
            'Konsekutives Satzadverb mit Inversion: V2-Stellung des Verbs "schaltete".',
        pragmaticDiscourseFunctionArabic:
            'ربط سببي نتيجي قطعي بصدارة الجملة: فقدان برقية التزامن وبناءً على ذلك أسقط مرحل الأمان خط اللحام في الإيقاف الطارئ.',
        topologicalOrderRule: 'Vorfeld-Positionierung von "Demzufolge" erzwingt V2-Stellung des finiten Verbs.',
      ),
      // 11. währendhingegen (Komparativ-adversativ)
      const ConcessiveAdversativeConnectorModel(
        id: 'CONN-4965-11',
        topologyType: ConnectorTopologyType.comparativeAdversative,
        positionSyntax: ClausePositionSyntax.subordinatingVerbFinal,
        domain: CommunicativeDomain.civilInfrastructure,
        connectorPhrase: 'währendhingegen',
        basePrimaryClause:
            'Gussasphaltbeläge bieten eine vollständige Abdichtung gegen tausalzhaltiges Sickerwasser',
        secondaryLinkedClause:
            'offenporige Asphaltschichten eine gezielte Entwässerung der Fahrbahnoberfläche bewirken',
        fullGermanSentence:
            'Gussasphaltbeläge bieten eine vollständige Abdichtung gegen tausalzhaltiges Sickerwasser, währendhingegen offenporige Asphaltschichten eine gezielte Entwässerung der Fahrbahnoberfläche bewirken.',
        pragmaticDiscourseFunctionGerman:
            'Verdoppelter Adversativkonnektor zur scharfen Differenzierung zweier Straßenbaustoffe.',
        pragmaticDiscourseFunctionArabic:
            'مقارنة تناقضية مزدوجة: عزل الأسفلت المصبوب التام لمياه الأملاح بينما على النقيض يحقق الأسفلت المسامي تصريف المياه.',
        topologicalOrderRule: 'Subordinierend mit Verbletztstellung: "... bewirken."',
      ),
      // 12. zumal da (Kausal-verstärkend)
      const ConcessiveAdversativeConnectorModel(
        id: 'CONN-4965-12',
        topologyType: ConnectorTopologyType.causalReinforcingIntensifier,
        positionSyntax: ClausePositionSyntax.subordinatingVerbFinal,
        domain: CommunicativeDomain.maritimeLogistics,
        connectorPhrase: 'zumal da',
        basePrimaryClause:
            'Das Löschen der Gefahrgutcontainer am Containerterminal wurde vorübergehend untersagt',
        secondaryLinkedClause:
            'die Brandmeldeanlage im Gefahrstofflager eine thermische Warnung ausgab',
        fullGermanSentence:
            'Das Löschen der Gefahrgutcontainer am Containerterminal wurde vorübergehend untersagt, zumal da die Brandmeldeanlage im Gefahrstofflager eine thermische Warnung ausgab.',
        pragmaticDiscourseFunctionGerman:
            'Nachdrückliche Kausalverknüpfung mit "zumal da" zur Begründung eines Gefahrenstopps.',
        pragmaticDiscourseFunctionArabic:
            'تعليل مشدد بـ (zumal da): تعليق تفريغ حاويات المواد الخطرة لا سيما وأن جهاز الإنذار أصدر تحذيراً حرارياً.',
        topologicalOrderRule: 'Verbletztstellung: "... ausgab."',
      ),
      // 13. dessen ungeachtet (Adverbial, V2-Inversion)
      const ConcessiveAdversativeConnectorModel(
        id: 'CONN-4965-13',
        topologyType: ConnectorTopologyType.prepositionalAdverbialCohesive,
        positionSyntax: ClausePositionSyntax.adverbialVerbSecondInversion,
        domain: CommunicativeDomain.materialScience,
        connectorPhrase: 'dessen ungeachtet',
        basePrimaryClause:
            'Die thermochemische Simulation prognostizierte eine vorzeitige Oxidation der Wolframcarbid-Phase',
        secondaryLinkedClause:
            'behielt der Werkstoff im Hochtemperaturofen seine strukturelle Integrität bei',
        fullGermanSentence:
            'Die thermochemische Simulation prognostizierte eine vorzeitige Oxidation der Wolframcarbid-Phase. Dessen ungeachtet behielt der Werkstoff im Hochtemperaturofen seine strukturelle Integrität bei.',
        pragmaticDiscourseFunctionGerman:
            'Genitivisch-postpositionales Adverbialgefüge im Vorfeld mit V2-Inversion ("behielt").',
        pragmaticDiscourseFunctionArabic:
            'ربط تعارضي إضافي بالصدارة: بصرف النظر عن توقع الأكسدة، حافظت المادة في الفرن الحراري على سلامتها البنيوية.',
        topologicalOrderRule: 'V2-Inversion: Finites Verb "behielt" folgt unmittelbar auf das Vorfeldgefüge.',
      ),
      // 14. insofern als (Systemische Gültigkeit)
      const ConcessiveAdversativeConnectorModel(
        id: 'CONN-4965-14',
        topologyType: ConnectorTopologyType.restrictiveConditional,
        positionSyntax: ClausePositionSyntax.subordinatingVerbFinal,
        domain: CommunicativeDomain.aerospaceAndAviation,
        connectorPhrase: 'insofern als',
        basePrimaryClause:
            'Die redundanten Flugsteuerungsrechner gewährleisten eine Ausfallsicherheit von 10 hoch minus 9',
        secondaryLinkedClause:
            'keine simultanen elektromagnetischen Störimpulse beide Buskanäle lahmlegen',
        fullGermanSentence:
            'Die redundanten Flugsteuerungsrechner gewährleisten eine Ausfallsicherheit von 10 hoch minus 9, insofern als keine simultanen elektromagnetischen Störimpulse beide Buskanäle lahmlegen.',
        pragmaticDiscourseFunctionGerman:
            'Sicherheitstechnische Einschränkung des probabilistischen Zuverlässigkeitsnachweises.',
        pragmaticDiscourseFunctionArabic:
            'تقييد شرطي للموثوقية الحسابية: ضمان سلامة حواسيب الطيران باحتمالية 10 أس -9 شريطة عدم تعطيل النبضات الكهرومغناطيسية للقنوات.',
        topologicalOrderRule: 'Verbletztstellung: "... lahmlegen."',
      ),
      // 15. obgleich (Gehoben-konzessiv)
      const ConcessiveAdversativeConnectorModel(
        id: 'CONN-4965-15',
        topologyType: ConnectorTopologyType.elevatedConcessiveSubordinating,
        positionSyntax: ClausePositionSyntax.subordinatingVerbFinal,
        domain: CommunicativeDomain.renewableEnergyGrid,
        connectorPhrase: 'obgleich',
        basePrimaryClause:
            'Der Windpark speiste kontinuierlich 240 Megawatt in das Höchstspannungsnetz ein',
        secondaryLinkedClause:
            'starke Böen die aerodynamische Pitch-Regelung der Rotorblätter an ihre Belastungsgrenze brachten',
        fullGermanSentence:
            'Der Windpark speiste kontinuierlich 240 Megawatt in das Höchstspannungsnetz ein, obgleich starke Böen die aerodynamische Pitch-Regelung der Rotorblätter an ihre Belastungsgrenze brachten.',
        pragmaticDiscourseFunctionGerman:
            'Formale Konzession in der technischen Netzbetriebsberichterstattung.',
        pragmaticDiscourseFunctionArabic:
            'تنازل رسمي رصين: استمرار حقن مزرعة الرياح لـ 240 ميغاوات في الشبكة رغم بلوغ زوايا الشفرات حدود التحمل القصوى.',
        topologicalOrderRule: 'Subordinierend mit Verbletztstellung: "... brachten."',
      ),
      // 16. geschweige denn (Negative Polarität mit "kaum")
      const ConcessiveAdversativeConnectorModel(
        id: 'CONN-4965-16',
        topologyType: ConnectorTopologyType.negativeScalarAdditive,
        positionSyntax: ClausePositionSyntax.ellipticalScalarPostposition,
        domain: CommunicativeDomain.civilInfrastructure,
        connectorPhrase: 'geschweige denn',
        basePrimaryClause:
            'Der durchnässte Lehmboden konnte kaum das Eigengewicht der mobilen Baucontainer tragen',
        secondaryLinkedClause:
            'als sichere Aufstellfläche für den 200-Tonnen-Raupenkran dienen',
        fullGermanSentence:
            'Der durchnässte Lehmboden konnte kaum das Eigengewicht der mobilen Baucontainer tragen, geschweige denn als sichere Aufstellfläche für den 200-Tonnen-Raupenkran dienen.',
        pragmaticDiscourseFunctionGerman:
            'Skalare Negation durch das Adverb "kaum" im Primärsatz: Schließt die schwere Kranlast a fortiori aus.',
        pragmaticDiscourseFunctionArabic:
            'استبعاد تدريجي مشدود بنفي نسبي (kaum): عجز التربة الطينية عن حمل حاويات الورشة فكيف بأن تكون قاعدة لرافعة بوزن 200 طن.',
        negativePolarityRequirement: true,
        topologicalOrderRule: 'Erfordert semantische Negationspräsenz ("kaum") im Hauptsatz.',
      ),
    ]);
  }

  List<ConcessiveAdversativeConnectorModel> getByTopology(ConnectorTopologyType type) =>
      _catalog.where((c) => c.topologyType == type).toList();

  List<ConcessiveAdversativeConnectorModel> getBySyntax(ClausePositionSyntax syntax) =>
      _catalog.where((c) => c.positionSyntax == syntax).toList();

  List<ConcessiveAdversativeConnectorModel> getByDomain(CommunicativeDomain domain) =>
      _catalog.where((c) => c.domain == domain).toList();

  /// Validates topological word order and polarity constraints for German complex connectors.
  ConnectorValidationResult validateConnectorSyntax({
    required ConnectorTopologyType type,
    required bool hasNegativePolarityInPrimary,
    required bool isVerbFinalInSubordinate,
    required bool isV2InvertedInMain,
  }) {
    final List<String> issues = [];
    final List<String> notes = [];

    // Rule 1: Negative Polarity for "geschweige denn"
    if (type == ConnectorTopologyType.negativeScalarAdditive) {
      if (!hasNegativePolarityInPrimary) {
        issues.add(
            'Polaritätsfehler: Der Konnektor "geschweige denn" erfordert zwingend eine Negation (nicht, kein, kaum, nie) im vorangegangenen Hauptsatz.');
      } else {
        notes.add('Polarität korrekt: Vorangegangene Negation erfüllt die Lizenzierungsbedingung für "geschweige denn".');
      }
    }

    // Rule 2: Subordinating connectors require verb-final order
    if (type == ConnectorTopologyType.restrictiveConditional ||
        type == ConnectorTopologyType.elevatedConcessiveSubordinating ||
        type == ConnectorTopologyType.comparativeAdversative ||
        type == ConnectorTopologyType.causalReinforcingIntensifier) {
      if (!isVerbFinalInSubordinate) {
        issues.add(
            'Topologie-Fehler: Subordinierende Konnektoren (insofern als, wenngleich, wohingegen, zumal) verlangen ausnahmslos Verbletztstellung im Nebensatz.');
      } else {
        notes.add('Topologisch korrekt: Verbletztstellung im subordinierenden Nebensatz eingehalten.');
      }
    }

    // Rule 3: Adverbial connectors in Vorfeld require V2 inversion
    if (type == ConnectorTopologyType.prepositionalAdverbialCohesive) {
      if (!isV2InvertedInMain) {
        issues.add(
            'Inversionsfehler: Vorfeld-Konnektoren (ungeachtet dessen, demzufolge) belegen Position 1 und erzwingen die Inversion des finiten Verbs vor das Subjekt (V2).');
      } else {
        notes.add('Topologisch korrekt: V2-Inversion nach Vorfeld-Adverbialgefüge gewahrt.');
      }
    }

    return ConnectorValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      topologicalNotes: notes,
    );
  }

  Map<String, dynamic> generateTelemetrySnapshot() {
    return {
      'totalExemplars': _catalog.length,
      'topologyDistribution': {
        for (var t in ConnectorTopologyType.values)
          t.name: _catalog.where((c) => c.topologyType == t).length,
      },
      'syntaxDistribution': {
        for (var s in ClausePositionSyntax.values)
          s.name: _catalog.where((c) => c.positionSyntax == s).length,
      },
      'domainDistribution': {
        for (var d in CommunicativeDomain.values)
          d.name: _catalog.where((c) => c.domain == d).length,
      },
      'negativePolarityCount': _catalog.where((c) => c.negativePolarityRequirement).length,
      'cefrLevel': 'CEFR C1-C2 Masterclass Complex Connectors & Topology',
      'engineVersion': '1.0.0+subsystem1799',
    };
  }
}
