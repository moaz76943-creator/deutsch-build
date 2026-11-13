import 'dart:collection';

/// Variable prefixes that switch between separable (trennbar) and inseparable (untrennbar).
enum PrefixMorpheme {
  durch('durch-', 'عبرَ / خلالَ / اختراقاً'),
  uber('über-', 'فوقَ / تجاوزاً / إفراطاً'),
  unter('unter-', 'تحتَ / تدقيقاً / خضوعاً'),
  um('um-', 'حولَ / تحويلاً / إحاطةً'),
  wider('wider-', 'ضدَّ / مقاومةً / ارتداداً'),
  hinter('hinter-', 'خلفَ / مكراً / توارياً');

  final String de;
  final String ar;
  const PrefixMorpheme(this.de, this.ar);
}

/// Morphosyntactic and prosodic status of the prefix.
enum SeparabilityStatus {
  separableAccented(
    'Trennbar (Betontes Präfix: úm-, dúrch-, über-)',
    'منفصل ذو نبر على السابقة (دلالة مكانية حسية ومسار غائي محدد)',
    'Trägt den Hauptakzent; trennt sich im Hauptsatz (V2); bildet Partizip II mit -ge- (durch-ge-brochen) und Infinitiv mit -zu- (durch-zu-brechen). Semantik: meist räumlich, konkret, telisch.',
  ),
  inseparableUnaccented(
    'Untrennbar (Unbetontes Präfix: um-, durch-, über-)',
    'متصل غير منبور (دلالة معنوية مجازية وشمولية وتأثير كلي)',
    'Das Präfix ist unbetont; bleibt stets mit dem Stamm verschmolzen; Partizip II ohne -ge- (durchbrochen); Infinitiv mit vorangestelltem "zu" (zu durchbrechen). Semantik: abstrakt, figurativ, oft transitivierend.',
  );

  final String deTitle;
  final String arTitle;
  final String grammaticalCriteria;
  const SeparabilityStatus(this.deTitle, this.arTitle, this.grammaticalCriteria);
}

/// Lexical Aktionsart and semantic valence shift caused by prefixation.
enum LexicalAktionsart {
  telicSpatialMovement('Telische Ortsveränderung (Zielgerichtet)', 'حركة مكانية فيزيائية غائية ذات نقطة انتهاء محددة'),
  holisticAbstractPermeation('Holistische Durchdringung (Ganzheitlich)', 'تأثير شمولي معنوي يحيط بالكيان بأكمله'),
  transitivityShift('Transitivitätswechsel (Intransitiv -> Transitiv)', 'تحول الفعل من لازم إلى متعدٍ لمفعول صريح'),
  rotationalCirculation('Rotatorische Dynamik (Kreislauf/Umlauf)', 'حركة دائرية مستمرة أو التفاف حركي حول مركز'),
  destructiveRupture('Destruktive Trennung / Materialversagen', 'انكسار أو تمزق مادي ملموس في بنية المادة');

  final String de;
  final String ar;
  const LexicalAktionsart(this.de, this.ar);
}

/// Technical communicative domain.
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

/// Structural model of a variable prefix verb pair/occurrence.
class VariablePrefixVerbModel {
  final String id;
  final String verbLemma;
  final PrefixMorpheme prefix;
  final SeparabilityStatus separabilityStatus;
  final LexicalAktionsart aktionsart;
  final CommunicativeDomain domain;
  final String accentedSyllableForm;
  final String presentTenseV2Example;
  final String perfectTenseParticipleExample;
  final String infinitiveWithZuExample;
  final String meaningGerman;
  final String meaningArabic;
  final String valencePattern;

  const VariablePrefixVerbModel({
    required this.id,
    required this.verbLemma,
    required this.prefix,
    required this.separabilityStatus,
    required this.aktionsart,
    required this.domain,
    required this.accentedSyllableForm,
    required this.presentTenseV2Example,
    required this.perfectTenseParticipleExample,
    required this.infinitiveWithZuExample,
    required this.meaningGerman,
    required this.meaningArabic,
    required this.valencePattern,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'verbLemma': verbLemma,
    'prefix': prefix.name,
    'separabilityStatus': separabilityStatus.name,
    'aktionsart': aktionsart.name,
    'domain': domain.name,
    'accentedSyllableForm': accentedSyllableForm,
    'presentTenseV2Example': presentTenseV2Example,
    'perfectTenseParticipleExample': perfectTenseParticipleExample,
    'infinitiveWithZuExample': infinitiveWithZuExample,
    'meaningGerman': meaningGerman,
    'meaningArabic': meaningArabic,
    'valencePattern': valencePattern,
  };
}

/// Validation result for variable prefix syntax and morphology.
class PrefixValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<String> morphosyntacticNotes;

  const PrefixValidationResult({
    required this.isValid,
    required this.issues,
    required this.morphosyntacticNotes,
  });
}

/// Core Engine managing German Variable Prefix Verbs & Lexical Aspect.
class GermanVariablePrefixVerbsEngine {
  final List<VariablePrefixVerbModel> _catalog = [];

  GermanVariablePrefixVerbsEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<VariablePrefixVerbModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    _catalog.addAll([
      // 1. durchbrechen (trennbar)
      const VariablePrefixVerbModel(
        id: 'PREF-4958-01',
        verbLemma: 'durchbrechen',
        prefix: PrefixMorpheme.durch,
        separabilityStatus: SeparabilityStatus.separableAccented,
        aktionsart: LexicalAktionsart.destructiveRupture,
        domain: CommunicativeDomain.civilInfrastructure,
        accentedSyllableForm: 'dúrchbrechen',
        presentTenseV2Example:
            'Der hydraulische Meißel bricht den bewehrten Betonbalken präzise durch.',
        perfectTenseParticipleExample:
            'Die Abbruchmaschine hat das alte Fundament vollständig durchgebrochen.',
        infinitiveWithZuExample:
            'Es ist erforderlich, den Träger an der Sollbruchstelle durchzubrechen.',
        meaningGerman: 'Physisch in zwei Teile zerbrechen (konkret-mechanisch).',
        meaningArabic: 'كسر الشيء فيزيائياً وفصله إلى شطرين (ميكانيكي ملموس).',
        valencePattern: 'Subjekt + Akkusativobjekt (transitiv, telisch)',
      ),
      // 2. durchbrechen (untrennbar)
      const VariablePrefixVerbModel(
        id: 'PREF-4958-02',
        verbLemma: 'durchbrechen',
        prefix: PrefixMorpheme.durch,
        separabilityStatus: SeparabilityStatus.inseparableUnaccented,
        aktionsart: LexicalAktionsart.holisticAbstractPermeation,
        domain: CommunicativeDomain.aerospaceAndAviation,
        accentedSyllableForm: 'durchbréchen',
        presentTenseV2Example:
            'Das Überschallflugzeug durchbricht die Schallmauer in 11.000 Metern Höhe.',
        perfectTenseParticipleExample:
            'Der Prototyp hat die kritische aerodynamische Grenze sicher durchbrochen.',
        infinitiveWithZuExample:
            'Das Triebwerk ist ausgelegt, um den Mach-Widerstand zu durchbrechen.',
        meaningGerman: 'Eine Barriere oder Grenze überwinden (übertragen-abstrakt).',
        meaningArabic: 'اختراق حاجز أو حد فيزيائي اعتباري (كحاجز الصوت).',
        valencePattern: 'Subjekt + Akkusativobjekt (transitiv, holistisch)',
      ),
      // 3. durchlaufen (trennbar)
      const VariablePrefixVerbModel(
        id: 'PREF-4958-03',
        verbLemma: 'durchlaufen',
        prefix: PrefixMorpheme.durch,
        separabilityStatus: SeparabilityStatus.separableAccented,
        aktionsart: LexicalAktionsart.telicSpatialMovement,
        domain: CommunicativeDomain.materialScience,
        accentedSyllableForm: 'dúrchlaufen',
        presentTenseV2Example:
            'Das Kühlmittel läuft durch den mikroporösen Wärmetauscher hindurch.',
        perfectTenseParticipleExample:
            'Die Prüfflüssigkeit ist ohne Druckabfall durchgelaufen.',
        infinitiveWithZuExample:
            'Das Filtrat ist bereit, den Aktivkohlefilter durchzulaufen.',
        meaningGerman: 'Räumlich von einem Ende zum anderen fließen/laufen.',
        meaningArabic: 'الجريان والعبور المادي للسائل من طرف إلى آخر عبر مسام.',
        valencePattern: 'Subjekt + (Direktionaladverbial) (intransitiv, telisch)',
      ),
      // 4. durchlaufen (untrennbar)
      const VariablePrefixVerbModel(
        id: 'PREF-4958-04',
        verbLemma: 'durchlaufen',
        prefix: PrefixMorpheme.durch,
        separabilityStatus: SeparabilityStatus.inseparableUnaccented,
        aktionsart: LexicalAktionsart.holisticAbstractPermeation,
        domain: CommunicativeDomain.industrialRobotics,
        accentedSyllableForm: 'durchlaúfen',
        presentTenseV2Example:
            'Der Roboterarm durchläuft den definierten Schweißzyklus in 42 Sekunden.',
        perfectTenseParticipleExample:
            'Das Steuerungsprogramm hat alle Validierungsphasen fehlerfrei durchlaufen.',
        infinitiveWithZuExample:
            'Es gilt, sämtliche Prüfschritte ohne manuellen Eingriff zu durchlaufen.',
        meaningGerman: 'Einen Prozess, eine Ausbildung oder einen Zyklus absolvieren.',
        meaningArabic: 'اجتياز دورة تشغيلية أو مرحلة اختبارية كاملة من بدايتها لنهايتها.',
        valencePattern: 'Subjekt + Akkusativobjekt (transitiv, vollendend)',
      ),
      // 5. umfahren (trennbar)
      const VariablePrefixVerbModel(
        id: 'PREF-4958-05',
        verbLemma: 'umfahren',
        prefix: PrefixMorpheme.um,
        separabilityStatus: SeparabilityStatus.separableAccented,
        aktionsart: LexicalAktionsart.destructiveRupture,
        domain: CommunicativeDomain.maritimeLogistics,
        accentedSyllableForm: 'úmfahren',
        presentTenseV2Example:
            'Der automatisierte Schlepper fährt die Markierungsboje versehentlich um.',
        perfectTenseParticipleExample:
            'Das Transportfahrzeug hat die Begrenzungssäule am Kaifeld umgefahren.',
        infinitiveWithZuExample:
            'Der Fahrer versucht, die Hindernisse keinesfalls umzufahren.',
        meaningGerman: 'Gegen einen Gegenstand fahren, sodass er zu Boden stürzt.',
        meaningArabic: 'الاصطدام بالحاجز أو العمود وإسقاطه أرضاً بفعل المركبة.',
        valencePattern: 'Subjekt + Akkusativobjekt (transitiv, destruktiv)',
      ),
      // 6. umfahren (untrennbar)
      const VariablePrefixVerbModel(
        id: 'PREF-4958-06',
        verbLemma: 'umfahren',
        prefix: PrefixMorpheme.um,
        separabilityStatus: SeparabilityStatus.inseparableUnaccented,
        aktionsart: LexicalAktionsart.rotationalCirculation,
        domain: CommunicativeDomain.maritimeLogistics,
        accentedSyllableForm: 'umfáhren',
        presentTenseV2Example:
            'Das Frachtschiff umfährt das stürmische Seegebiet im weiten Bogen.',
        perfectTenseParticipleExample:
            'Der Kapitän hat die gefährliche Untiefe weiträumig umfahren.',
        infinitiveWithZuExample:
            'Die Routenplanung empfiehlt, das Hochdruckgebiet nördlich zu umfahren.',
        meaningGerman: 'Einen Bogen um ein Hindernis machen / ausweichen.',
        meaningArabic: 'الالتفاف حول العائق الملاحي أو العاصفة وتفاديها بحرياً.',
        valencePattern: 'Subjekt + Akkusativobjekt (transitiv, zirkulär)',
      ),
      // 7. übersetzen (trennbar)
      const VariablePrefixVerbModel(
        id: 'PREF-4958-07',
        verbLemma: 'übersetzen',
        prefix: PrefixMorpheme.uber,
        separabilityStatus: SeparabilityStatus.separableAccented,
        aktionsart: LexicalAktionsart.telicSpatialMovement,
        domain: CommunicativeDomain.civilInfrastructure,
        accentedSyllableForm: 'úbersetzen',
        presentTenseV2Example:
            'Die Arbeitsfähre setzt die Bautrupps sicher ans andere Flussufer über.',
        perfectTenseParticipleExample:
            'Das Transportboot hat die Bagger bereits übergesetzt.',
        infinitiveWithZuExample:
            'Es ist geplant, das Material noch vor Flutbeginn überzusetzen.',
        meaningGerman: 'Personen oder Fracht über ein Gewässer transportieren.',
        meaningArabic: 'نقل العمال والمعدات عبر المسطح المائي إلى الضفة المقابلة.',
        valencePattern: 'Subjekt + Akkusativobjekt + Direktionaladverbial (transitiv)',
      ),
      // 8. übersetzen (untrennbar)
      const VariablePrefixVerbModel(
        id: 'PREF-4958-08',
        verbLemma: 'übersetzen',
        prefix: PrefixMorpheme.uber,
        separabilityStatus: SeparabilityStatus.inseparableUnaccented,
        aktionsart: LexicalAktionsart.holisticAbstractPermeation,
        domain: CommunicativeDomain.industrialRobotics,
        accentedSyllableForm: 'übersétzen',
        presentTenseV2Example:
            'Das Planetengetriebe übersetzt das hohe Drehmoment in schnelle Drehzahl.',
        perfectTenseParticipleExample:
            'Die mechanische Kupplung hat die Motorleistung verlustarm übersetzt.',
        infinitiveWithZuExample:
            'Die Übersetzungseinheit dient dazu, die Kraft winkelgetreu zu übersetzen.',
        meaningGerman: 'Mechanische Kraft übersetzen oder Text in eine andere Sprache übertragen.',
        meaningArabic: 'تحويل وتكييف العزم ميكانيكياً (أو ترجمة النصوص إلى لغة أخرى).',
        valencePattern: 'Subjekt + Akkusativobjekt + in + Akk (transitiv)',
      ),
      // 9. unterstellen (trennbar)
      const VariablePrefixVerbModel(
        id: 'PREF-4958-09',
        verbLemma: 'unterstellen',
        prefix: PrefixMorpheme.unter,
        separabilityStatus: SeparabilityStatus.separableAccented,
        aktionsart: LexicalAktionsart.telicSpatialMovement,
        domain: CommunicativeDomain.renewableEnergyGrid,
        accentedSyllableForm: 'únterstellen',
        presentTenseV2Example:
            'Die Techniker stellen die mobilen Messgeräte im windgeschützten Hangar unter.',
        perfectTenseParticipleExample:
            'Das Team hat die Transformatoren vor dem Unwetter sicher untergestellt.',
        infinitiveWithZuExample:
            'Wir müssen die Elektronikboxen rechtzeitig unterzustellen.',
        meaningGerman: 'Einen Gegenstand schützend unter ein Dach stellen.',
        meaningArabic: 'إيواء المعدات الحساسة تحت سقف واقٍ لحمايتها من العوامل الجوية.',
        valencePattern: 'Subjekt + Akkusativobjekt + Situativergänzung (transitiv)',
      ),
      // 10. unterstellen (untrennbar)
      const VariablePrefixVerbModel(
        id: 'PREF-4958-10',
        verbLemma: 'unterstellen',
        prefix: PrefixMorpheme.unter,
        separabilityStatus: SeparabilityStatus.inseparableUnaccented,
        aktionsart: LexicalAktionsart.holisticAbstractPermeation,
        domain: CommunicativeDomain.aerospaceAndAviation,
        accentedSyllableForm: 'unterstéllen',
        presentTenseV2Example:
            'Die Flugunfallkommission unterstellt eine unzureichende Vorflugkontrolle.',
        perfectTenseParticipleExample:
            'Der Prüfbericht hat der Wartungscrew fahrlässiges Handeln unterstellt.',
        infinitiveWithZuExample:
            'Es verbietet sich, den Ingenieuren mangelnde Sorgfalt zu unterstellen.',
        meaningGerman: 'Hypothetisch annehmen oder fälschlich zuschreiben.',
        meaningArabic: 'افتراض أو نسبة أمر للغير مع التشكيك أو التحفظ التحقيقي.',
        valencePattern: 'Subjekt + Dativobjekt + Akkusativobjekt (transitiv)',
      ),
      // 11. umspannen (trennbar)
      const VariablePrefixVerbModel(
        id: 'PREF-4958-11',
        verbLemma: 'umspannen',
        prefix: PrefixMorpheme.um,
        separabilityStatus: SeparabilityStatus.separableAccented,
        aktionsart: LexicalAktionsart.transitivityShift,
        domain: CommunicativeDomain.renewableEnergyGrid,
        accentedSyllableForm: 'úmspannen',
        presentTenseV2Example:
            'Die Transformatorenstation spannt den erzeugten Solarstrom auf 110 kV um.',
        perfectTenseParticipleExample:
            'Das Umspannwerk hat die Windenergie netzkonform umgespannt.',
        infinitiveWithZuExample:
            'Die Anlage ist dafür ausgelegt, Hochspannung verlustarm umzuspannen.',
        meaningGerman: 'Elektrische Spannung transformieren (hoch- oder heruntertransformieren).',
        meaningArabic: 'تحويل الجهد الكهربائي في محطة المحولات إلى قيمة تشغيلية أخرى.',
        valencePattern: 'Subjekt + Akkusativobjekt + auf + Akk (transitiv)',
      ),
      // 12. umspannen (untrennbar)
      const VariablePrefixVerbModel(
        id: 'PREF-4958-12',
        verbLemma: 'umspannen',
        prefix: PrefixMorpheme.um,
        separabilityStatus: SeparabilityStatus.inseparableUnaccented,
        aktionsart: LexicalAktionsart.holisticAbstractPermeation,
        domain: CommunicativeDomain.civilInfrastructure,
        accentedSyllableForm: 'umspánnen',
        presentTenseV2Example:
            'Das geodätische Messnetz umspannt das gesamte Tal zur Hangüberwachung.',
        perfectTenseParticipleExample:
            'Die Überwachungszone hat das Bauvorhaben lückenlos umspannt.',
        infinitiveWithZuExample:
            'Das Ziel ist, die gesamte Fundamentfläche mit Sensorik zu umspannen.',
        meaningGerman: 'Räumlich umfassen / sich über ein ganzes Gebiet erstrecken.',
        meaningArabic: 'تطويق المساحة الجغرافية بأكملها والإحاطة الشاملة بها.',
        valencePattern: 'Subjekt + Akkusativobjekt (transitiv, statisch)',
      ),
      // 13. widerspiegeln (trennbar)
      const VariablePrefixVerbModel(
        id: 'PREF-4958-13',
        verbLemma: 'widerspiegeln',
        prefix: PrefixMorpheme.wider,
        separabilityStatus: SeparabilityStatus.separableAccented,
        aktionsart: LexicalAktionsart.holisticAbstractPermeation,
        domain: CommunicativeDomain.materialScience,
        accentedSyllableForm: 'wíderspiegeln',
        presentTenseV2Example:
            'Die glatt polierte Siliziumscheibe spiegelt das einfallende Laserlicht exakt wider.',
        perfectTenseParticipleExample:
            'Die Telemetriekurve hat die tatsächliche Belastung widergespiegelt.',
        infinitiveWithZuExample:
            'Die Messwerte sind geeignet, das dynamische Verhalten widerzuspiegeln.',
        meaningGerman: 'Optisch reflektieren oder inhaltlich getreu abbilden.',
        meaningArabic: 'عكس الضوء بصرياً أو محاكاة الوقائع والبيانات بدقة مطابقة.',
        valencePattern: 'Subjekt + Akkusativobjekt (transitiv)',
      ),
      // 14. widerstehen (untrennbar)
      const VariablePrefixVerbModel(
        id: 'PREF-4958-14',
        verbLemma: 'widerstehen',
        prefix: PrefixMorpheme.wider,
        separabilityStatus: SeparabilityStatus.inseparableUnaccented,
        aktionsart: LexicalAktionsart.holisticAbstractPermeation,
        domain: CommunicativeDomain.materialScience,
        accentedSyllableForm: 'widerstéhen',
        presentTenseV2Example:
            'Die nickelbasierte Superlegierung widersteht Temperaturen von über 1250 Grad.',
        perfectTenseParticipleExample:
            'Das Turbinengehäuse hat dem Explosionsdruck erfolgreich widerstanden.',
        infinitiveWithZuExample:
            'Das Schutzschild ist konstruiert, um korrosiven Gasen zu widerstehen.',
        meaningGerman: 'Äußerem Druck oder chemischen Angriffen standhalten.',
        meaningArabic: 'مقاومة الضغوط الميكانيكية الشديدة أو التآكل الكيميائي بثبات.',
        valencePattern: 'Subjekt + Dativobjekt (intransitiv, resistent)',
      ),
      // 15. hinterlegen (untrennbar)
      const VariablePrefixVerbModel(
        id: 'PREF-4958-15',
        verbLemma: 'hinterlegen',
        prefix: PrefixMorpheme.hinter,
        separabilityStatus: SeparabilityStatus.inseparableUnaccented,
        aktionsart: LexicalAktionsart.transitivityShift,
        domain: CommunicativeDomain.industrialRobotics,
        accentedSyllableForm: 'hinterlégen',
        presentTenseV2Example:
            'Der Systemadministrator hinterlegt die kryptographischen Schlüssel im Sicherheitsmodul.',
        perfectTenseParticipleExample:
            'Die Fabrikleitung hat die Notfallprotokolle digital hinterlegt.',
        infinitiveWithZuExample:
            'Es ist Pflicht, die Eichkurven im Datenspeicher zu hinterlegen.',
        meaningGerman: 'Dokumente, Werte oder Daten zur Verwahrung deponieren.',
        meaningArabic: 'إيداع وحفظ المفاتيح الرقمية أو الوثائق الرسمية في خزانة آمنة.',
        valencePattern: 'Subjekt + Akkusativobjekt + in + Dat (transitiv)',
      ),
      // 16. überholen (untrennbar)
      const VariablePrefixVerbModel(
        id: 'PREF-4958-16',
        verbLemma: 'überholen',
        prefix: PrefixMorpheme.uber,
        separabilityStatus: SeparabilityStatus.inseparableUnaccented,
        aktionsart: LexicalAktionsart.holisticAbstractPermeation,
        domain: CommunicativeDomain.aerospaceAndAviation,
        accentedSyllableForm: 'überhólen',
        presentTenseV2Example:
            'Die Triebwerksmechaniker überholen das Strahltriebwerk nach 5000 Flugstunden vollständig.',
        perfectTenseParticipleExample:
            'Die Luftfahrtwerft hat das Fahrwerk termingerecht überholt.',
        infinitiveWithZuExample:
            'Es ist technisch vorgeschrieben, die Avionik alle zwei Jahre zu überholen.',
        meaningGerman: 'Eine Maschine warten/instandsetzen (oder ein anderes Fahrzeug überholen).',
        meaningArabic: 'صيانة وتجديد المحرك المعقد جذرياً (أو تجاوز مركبة أخرى).',
        valencePattern: 'Subjekt + Akkusativobjekt (transitiv, restaurativ)',
      ),
    ]);
  }

  List<VariablePrefixVerbModel> getByPrefix(PrefixMorpheme prefix) =>
      _catalog.where((v) => v.prefix == prefix).toList();

  List<VariablePrefixVerbModel> getBySeparability(SeparabilityStatus status) =>
      _catalog.where((v) => v.separabilityStatus == status).toList();

  List<VariablePrefixVerbModel> getByDomain(CommunicativeDomain domain) =>
      _catalog.where((v) => v.domain == domain).toList();

  /// Validates the morphosyntax of a verb occurrence according to separability rules.
  PrefixValidationResult validatePrefixUsage({
    required String verbLemma,
    required bool isSeparable,
    required bool v2SeparatedInMainClause,
    required bool participleHasGe,
    required bool zuInsertedInsideVerb,
  }) {
    final List<String> issues = [];
    final List<String> notes = [];

    if (isSeparable) {
      if (!v2SeparatedInMainClause) {
        issues.add('Topologie-Fehler: Das trennbare Verb "$verbLemma" muss im Hauptsatz die Vorsilbe abspalten und ans Satzende stellen.');
      } else {
        notes.add('Topologisch korrekt: Vorsilbe im Hauptsatz nach rechts an die Satzklammer abgespalten.');
      }

      if (!participleHasGe) {
        issues.add('Morphologie-Fehler: Das Partizip II eines trennbaren Verbs verlangt die Einfügung von "-ge-" zwischen Präfix und Stamm.');
      } else {
        notes.add('Morphologisch korrekt: Partizip II mit eingeschobenem "-ge-" gebildet.');
      }

      if (!zuInsertedInsideVerb) {
        issues.add('Infinitiv-Fehler: Der Infinitiv mit "zu" bei trennbaren Verben muss "zu" zwischen Präfix und Stamm einfügen (z. B. durch-zu-brechen).');
      } else {
        notes.add('Syntaktisch korrekt: "zu" zwischen Präfix und Verbstamm eingefügt.');
      }
    } else {
      if (v2SeparatedInMainClause) {
        issues.add('Topologie-Fehler: Das untrennbare Verb "$verbLemma" darf seine Vorsilbe niemals abspalten.');
      } else {
        notes.add('Topologisch korrekt: Untrennbares Verb bleibt im V2-Satz vollständig fusioniert.');
      }

      if (participleHasGe) {
        issues.add('Morphologie-Fehler: Das Partizip II eines untrennbaren Verbs darf KEIN "-ge-" enthalten.');
      } else {
        notes.add('Morphologisch korrekt: Partizip II ohne "-ge-" gebildet.');
      }

      if (zuInsertedInsideVerb) {
        issues.add('Infinitiv-Fehler: Bei untrennbaren Verben steht "zu" als separates Wort vor dem gesamten Verb (z. B. "zu durchbrechen").');
      } else {
        notes.add('Syntaktisch korrekt: "zu" steht vor dem untrennbaren Infinitiv.');
      }
    }

    return PrefixValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      morphosyntacticNotes: notes,
    );
  }

  Map<String, dynamic> generateTelemetrySnapshot() {
    return {
      'totalExemplars': _catalog.length,
      'prefixDistribution': {
        for (var p in PrefixMorpheme.values)
          p.name: _catalog.where((v) => v.prefix == p).length,
      },
      'separabilityDistribution': {
        for (var s in SeparabilityStatus.values)
          s.name: _catalog.where((v) => v.separabilityStatus == s).length,
      },
      'domainDistribution': {
        for (var d in CommunicativeDomain.values)
          d.name: _catalog.where((v) => v.domain == d).length,
      },
      'cefrLevel': 'CEFR C1-C2 Masterclass Variable Prefixes',
      'engineVersion': '1.0.0+subsystem1792',
    };
  }
}
