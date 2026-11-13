import 'dart:collection';

/// Classification of German comparative and proportional sentence structures.
enum ComparativeConstructionType {
  proportionalJeDesto(
    'Proportionalgefüge (je + Komparativ [Verbletzt] ... desto/umso + Komparativ [V2])',
    'بناء التناسب المزدوج (كلما زاد س، كلما/زاد ص على النقيض أو التوازي)',
    'Koppelt zwei komparative Skalen: Der je-Satz ist ein subordinierender Nebensatz mit Verbletztstellung; der desto/umso-Hauptsatz bindet das finite Verb direkt hinter das Komparativ-Element an (V2-Inversion).',
  ),
  counterfactualDiscrepancyZuAlsDass(
    'Diskrepanz-Komparativ (zu + Positiv, als dass + Konjunktiv II: Verhindertes Resultat)',
    'المقارنة التفاوتية المانعة للنتيجة (مفرط في الصفة إلى حد يمتنع معه تحقق الأثر)',
    'Drückt ein übermäßiges Maß aus, das den Eintritt einer Folge ausschließt: "Das Schwingungsniveau ist zu hoch, als dass der Generator sicher betrieben werden könnte."',
  ),
  negativeScalarDisproportionMehrAlsDass(
    'Qualitativer Präferenz-Komparativ (mehr / eher ..., als dass ...: Abwägung)',
    'الترجيح النوعي التبايني (أشبه بـ كذا من كونه كذا)',
    'Vergleicht zwei qualitative Sachverhalte und stuft den zweiten als unzutreffend oder nachrangig ein: "Das Phänomen war ein Messrauschen, mehr als dass es ein echtes Signal darstellte."',
  ),
  equativePositiveGleichheit(
    'Äquativer Komparativ der Gleichheit (so / ebenso / genauso + Positiv wie ...)',
    'التماثل والمطابقة التامة في الصفة (بنفس الدقة/الكفاءة تماماً كما)',
    'Vergleicht identische Grade einer Eigenschaft mit dem unveränderlichen Vergleichswort "wie": "Die zweite Schweißnaht ist genauso tragfähig wie die Referenznaht."',
  ),
  inequativeComparativeUngleichheit(
    'Inäquativer Komparativ der Ungleichheit (Komparativ + als ...)',
    'المفاضلة والتفاوت المتمايز (أعلى/أكثر دقة من)',
    'Vergleicht ungleiche Grade einer Eigenschaft mit der Konjunktion "als" (niemals "wie"): "Der Wirkungsgrad der Siliziumkarbid-Halbleiter ist signifikant höher als der herkömmlicher IGBTs."',
  ),
  proportionalCausalUmsoMehrAls(
    'Proportional-kausales Gefüge (umso mehr, als ...: Verstärkung)',
    'التعليل التناسبي التوكيدي (بدرجة أكبر بالنظر إلى / لا سيما في ضوء أن)',
    'Verstärkt eine Aussage durch einen proportional gewichteten Kausalgrund: "Die Kühlung muss verstärkt werden, umso mehr, als die Umgebungstemperatur 50 Grad erreicht."',
  );

  final String deTitle;
  final String arTitle;
  final String grammaticalDefinition;
  const ComparativeConstructionType(this.deTitle, this.arTitle, this.grammaticalDefinition);
}

/// Physical or mathematical scaling direction of proportional constructions.
enum ProportionalScalingDirection {
  directProportionalPositive('Direkt proportional (Je mehr X, desto mehr Y)', 'تناسب طردي تصاعدي متزامن'),
  inverseProportionalNegative('Invers proportional (Je höher X, desto geringer Y)', 'تناسب عكسي تنازلي'),
  nonLinearPhysicalThreshold('Nichtlinear / asymptotischer Schwellenwert', 'منحنى عتبة حرجة لا خطية');

  final String de;
  final String ar;
  const ProportionalScalingDirection(this.de, this.ar);
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

/// Structural model of an advanced German comparative/proportional sentence.
class ComparativeProportionalModel {
  final String id;
  final ComparativeConstructionType constructionType;
  final ProportionalScalingDirection scalingDirection;
  final CommunicativeDomain domain;
  final String comparativeCarrierPhrase;
  final String primaryClause;
  final String comparativeSecondaryClause;
  final String fullGermanSentence;
  final String technicalLawGerman;
  final String technicalLawArabic;
  final String wordOrderConstraintRule;

  const ComparativeProportionalModel({
    required this.id,
    required this.constructionType,
    required this.scalingDirection,
    required this.domain,
    required this.comparativeCarrierPhrase,
    required this.primaryClause,
    required this.comparativeSecondaryClause,
    required this.fullGermanSentence,
    required this.technicalLawGerman,
    required this.technicalLawArabic,
    required this.wordOrderConstraintRule,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'constructionType': constructionType.name,
    'scalingDirection': scalingDirection.name,
    'domain': domain.name,
    'comparativeCarrierPhrase': comparativeCarrierPhrase,
    'primaryClause': primaryClause,
    'comparativeSecondaryClause': comparativeSecondaryClause,
    'fullGermanSentence': fullGermanSentence,
    'technicalLawGerman': technicalLawGerman,
    'technicalLawArabic': technicalLawArabic,
    'wordOrderConstraintRule': wordOrderConstraintRule,
  };
}

/// Validation result for comparative and proportional syntax.
class ComparativeValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<String> syntacticNotes;

  const ComparativeValidationResult({
    required this.isValid,
    required this.issues,
    required this.syntacticNotes,
  });
}

/// Core Engine managing German Comparative & Proportional Syntax.
class GermanComparativeProportionalSyntaxEngine {
  final List<ComparativeProportionalModel> _catalog = [];

  GermanComparativeProportionalSyntaxEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<ComparativeProportionalModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    _catalog.addAll([
      // 1. je... desto (Invers proportional, Halbleiter)
      const ComparativeProportionalModel(
        id: 'COMP-4966-01',
        constructionType: ComparativeConstructionType.proportionalJeDesto,
        scalingDirection: ProportionalScalingDirection.inverseProportionalNegative,
        domain: CommunicativeDomain.renewableEnergyGrid,
        comparativeCarrierPhrase: 'Je höher ... desto schneller',
        primaryClause: 'Je höher die Sperrschichttemperatur des Silizium-Wechselrichters steigt',
        comparativeSecondaryClause: 'desto schneller degradiert die dielektrische Isolationsschicht',
        fullGermanSentence:
            'Je höher die Sperrschichttemperatur des Silizium-Wechselrichters steigt, desto schneller degradiert die dielektrische Isolationsschicht.',
        technicalLawGerman:
            'Arrhenius-Gesetz der thermischen Alterung: Exponentielle Verkürzung der Lebensdauer bei Temperaturanstieg.',
        technicalLawArabic:
            'قانون أرينيوس للتقادم الحراري: كلما ارتفعت حرارة وصلة المحول، كلما تسارع تدهور طبقة العزل العازلة كهربائياً.',
        wordOrderConstraintRule:
            'Je-Satz verlangt Verbletztstellung ("steigt"); desto-Satz bindet Komparativ im Vorfeld ("desto schneller") gefolgt von V2-Verb ("degradiert").',
      ),
      // 2. zu... als dass + Konjunktiv II (Diskrepanz)
      const ComparativeProportionalModel(
        id: 'COMP-4966-02',
        constructionType: ComparativeConstructionType.counterfactualDiscrepancyZuAlsDass,
        scalingDirection: ProportionalScalingDirection.nonLinearPhysicalThreshold,
        domain: CommunicativeDomain.aerospaceAndAviation,
        comparativeCarrierPhrase: 'zu tief, als dass ... könnte',
        primaryClause: 'Der Kerbschlagriss an der Titanschaufelwurzel ist bereits zu tief',
        comparativeSecondaryClause: 'als dass das Triebwerk ohne Gefährdung weiterbetrieben werden könnte',
        fullGermanSentence:
            'Der Kerbschlagriss an der Titanschaufelwurzel ist bereits zu tief, als dass das Triebwerk ohne Gefährdung weiterbetrieben werden könnte.',
        technicalLawGerman:
            'Bruchmechanisches Grenzkriterium: Risslänge überschreitet das kritische Spannungsintensitätsmaximum K_IC.',
        technicalLawArabic:
            'معيار ميكانيكا الكسر الحرج: الشرخ في قاعدة شفرة التيتانيوم غائر لدرجة يمتنع معها مواصلة تشغيل المحرك بأمان.',
        wordOrderConstraintRule:
            'Obligatorischer Konjunktiv II im als-dass-Nebensatz: "... weiterbetrieben werden KÖNNTE" (Ausschluss des Resultats).',
      ),
      // 3. mehr als dass (Qualitative Abwägung)
      const ComparativeProportionalModel(
        id: 'COMP-4966-03',
        constructionType: ComparativeConstructionType.negativeScalarDisproportionMehrAlsDass,
        scalingDirection: ProportionalScalingDirection.nonLinearPhysicalThreshold,
        domain: CommunicativeDomain.industrialRobotics,
        comparativeCarrierPhrase: 'mehr ..., als dass',
        primaryClause: 'Die gemessene Drehmomentspitze stellte ein elektromagnetisches Rauschen dar',
        comparativeSecondaryClause: 'als dass sie auf einen realen Getriebeschaden hindeutete',
        fullGermanSentence:
            'Die gemessene Drehmomentspitze stellte ein elektromagnetisches Rauschen dar, mehr als dass sie auf einen realen Getriebeschaden hindeutete.',
        technicalLawGerman:
            'Signalanalyse: Fehlinterpretation transienter elektromagnetischer Störimpulse (EMV) als mechanische Havarie.',
        technicalLawArabic:
            'تحليل الإشارات: ذروة العزم المقاسة كانت تشويشاً كهرومغناطيسياً أكثر من كونها دليلاً على تلف ميكانيكي حقيقي في التروس.',
        wordOrderConstraintRule:
            'Verbletztstellung im als-dass-Satz mit Präteritum oder Konjunktiv II ("hindeutete").',
      ),
      // 4. ebenso... wie (Gleichheit, Positiv)
      const ComparativeProportionalModel(
        id: 'COMP-4966-04',
        constructionType: ComparativeConstructionType.equativePositiveGleichheit,
        scalingDirection: ProportionalScalingDirection.directProportionalPositive,
        domain: CommunicativeDomain.civilInfrastructure,
        comparativeCarrierPhrase: 'ebenso tragfähig wie',
        primaryClause: 'Die neuartige Faserverbund-Bewehrung ist bei Zugbelastung ebenso tragfähig',
        comparativeSecondaryClause: 'wie konventioneller Rippentorstahl BSt 500 S',
        fullGermanSentence:
            'Die neuartige Faserverbund-Bewehrung ist bei Zugbelastung ebenso tragfähig wie konventioneller Rippentorstahl BSt 500 S.',
        technicalLawGerman:
            'Festigkeitsnachweis im Massivbau: Gleichwertige Zugspannungsaufnahme bei reduzierter Korrosionsanfälligkeit.',
        technicalLawArabic:
            'إثبات المتانة الإنشائية: تسليح البوليمر الليفي المبتكر يتمتع بنفس القدرة على تحمل الشد تماماً مثل حديد التسليح التقليدي.',
        wordOrderConstraintRule:
            'Gleichheitsvergleich verlangt Positiv ("tragfähig") und Partikel "wie" (niemals "als").',
      ),
      // 5. Komparativ + als (Ungleichheit)
      const ComparativeProportionalModel(
        id: 'COMP-4966-05',
        constructionType: ComparativeConstructionType.inequativeComparativeUngleichheit,
        scalingDirection: ProportionalScalingDirection.directProportionalPositive,
        domain: CommunicativeDomain.materialScience,
        comparativeCarrierPhrase: 'viermal verschleißfester als',
        primaryClause: 'Die laserauftraggeschweißte Wolframcarbid-Schutzschicht ist unter Abrasion viermal verschleißfester',
        comparativeSecondaryClause: 'als ungehärteter Vergütungsstahl 42CrMo4',
        fullGermanSentence:
            'Die laserauftraggeschweißte Wolframcarbid-Schutzschicht ist unter Abrasion viermal verschleißfester als ungehärteter Vergütungsstahl 42CrMo4.',
        technicalLawGerman:
            'Tribologischer Kennwert: Quantitativer Reib- und Verschleißbeiwert im standardisierten Pin-on-Disk-Test.',
        technicalLawArabic:
            'المفاضلة التفاوتية: طبقة كربيد التنجستن الملحومة بالليزر أكثر مقاومة للتآكل بأربعة أضعاف من صلب المعالجة الحرارية غير المقسى.',
        wordOrderConstraintRule:
            'Ungleichheitsvergleich verlangt Komparativ ("verschleißfester") und Konjunktion "als" (niemals "wie").',
      ),
      // 6. je... umso (Direkt proportional, Schifffahrt)
      const ComparativeProportionalModel(
        id: 'COMP-4966-06',
        constructionType: ComparativeConstructionType.proportionalJeDesto,
        scalingDirection: ProportionalScalingDirection.directProportionalPositive,
        domain: CommunicativeDomain.maritimeLogistics,
        comparativeCarrierPhrase: 'Je größer ... umso träger',
        primaryClause: 'Je größer die Verdrängung des beladenen Großcontainerschiffs wird',
        comparativeSecondaryClause: 'umso träger reagiert die Ruderanlage bei Revierfahrten',
        fullGermanSentence:
            'Je größer die Verdrängung des beladenen Großcontainerschiffs wird, umso träger reagiert die Ruderanlage bei Revierfahrten.',
        technicalLawGerman:
            'Hydrodynamisches Trägheitsgesetz: Quadratischer Anstieg des Brems- und Drehkreisradius mit zunehmender Tonnage.',
        technicalLawArabic:
            'قانون القصور الهيدروديناميكي: كلما زادت إزاحة سفينة الحاويات المحملة، كلما أصبحت استجابة الدفة أكثر بطئاً وتثاقلاً.',
        wordOrderConstraintRule:
            'Je-Nebensatz ("wird") + umso-Hauptsatz ("umso träger reagiert" V2).',
      ),
      // 7. umso mehr als (Kausal-proportional)
      const ComparativeProportionalModel(
        id: 'COMP-4966-07',
        constructionType: ComparativeConstructionType.proportionalCausalUmsoMehrAls,
        scalingDirection: ProportionalScalingDirection.directProportionalPositive,
        domain: CommunicativeDomain.renewableEnergyGrid,
        comparativeCarrierPhrase: 'umso mehr, als',
        primaryClause: 'Die Dämpfung harmonischer Oberschwingungen gewinnt im Verteilnetz an Bedeutung',
        comparativeSecondaryClause: 'als der Anteil leistungselektronischer Einspeiser sprunghaft zunimmt',
        fullGermanSentence:
            'Die Dämpfung harmonischer Oberschwingungen gewinnt im Verteilnetz an Bedeutung, umso mehr, als der Anteil leistungselektronischer Einspeiser sprunghaft zunimmt.',
        technicalLawGerman:
            'Netzrückwirkungslehre: Höhere Verzerrungsblindleistung durch nichtlineare Wechselrichter erfordert Aktivfilter.',
        technicalLawArabic:
            'تخميد التوافقيات الكهربائية: يكتسب تخميد التوافقيات أهمية مضاعفة لا سيما وأن نسبة محولات إلكترونيات القدرة تتزايد باطراد.',
        wordOrderConstraintRule:
            'Verbletztstellung im kausal-proportionalen Nebensatz: "... zunimmt."',
      ),
      // 8. zu... als dass (Konjunktiv II, Statik)
      const ComparativeProportionalModel(
        id: 'COMP-4966-08',
        constructionType: ComparativeConstructionType.counterfactualDiscrepancyZuAlsDass,
        scalingDirection: ProportionalScalingDirection.nonLinearPhysicalThreshold,
        domain: CommunicativeDomain.civilInfrastructure,
        comparativeCarrierPhrase: 'zu ungleichmäßig, als dass ... ließe',
        primaryClause: 'Die Setzung der Fundamentpfeiler verlief im Baugrund zu ungleichmäßig',
        comparativeSecondaryClause: 'als dass sich der Brückenüberbau ohne Zwangskräfte montieren ließe',
        fullGermanSentence:
            'Die Setzung der Fundamentpfeiler verlief im Baugrund zu ungleichmäßig, als dass sich der Brückenüberbau ohne Zwangskräfte montieren ließe.',
        technicalLawGerman:
            'Setzungsdifferenz im Brückenbau: Unzulässige Torsions- und Biegemomente im Durchlaufträger.',
        technicalLawArabic:
            'هبوط الأساسات المتفاوت: هبوط دعامات الجسر في التربة كان متفاوتاً لدرجة يستحيل معها تركيب الهيكل دون إجهادات قسرية.',
        wordOrderConstraintRule:
            'Konjunktiv II mit Passiversatzform "sich lassen": "... montieren LIEßE".',
      ),
      // 9. je... desto (Thermische Leitfähigkeit)
      const ComparativeProportionalModel(
        id: 'COMP-4966-09',
        constructionType: ComparativeConstructionType.proportionalJeDesto,
        scalingDirection: ProportionalScalingDirection.directProportionalPositive,
        domain: CommunicativeDomain.materialScience,
        comparativeCarrierPhrase: 'Je dichter ... desto höher',
        primaryClause: 'Je dichter das Kristallgitter der Kohlenstoff-Nanoröhren strukturiert ist',
        comparativeSecondaryClause: 'desto höher liegt die axiale thermische Leitfähigkeit des Verbundwerkstoffs',
        fullGermanSentence:
            'Je dichter das Kristallgitter der Kohlenstoff-Nanoröhren strukturiert ist, desto höher liegt die axiale thermische Leitfähigkeit des Verbundwerkstoffs.',
        technicalLawGerman:
            'Phononentransport in Festkörpern: Minimierung von Gitterdefekten maximiert die freie Weglänge der Phononen.',
        technicalLawArabic:
            'التوصيل الحراري الفونوني: كلما زادت كثافة وانتظام الشبكة البلورية لأنابيب الكربون النانوية، كلما ارتفعت الموصلية الحرارية للمركب.',
        wordOrderConstraintRule:
            'Je-Satz ("ist") + desto-Satz ("desto höher liegt" V2-Stellung).',
      ),
      // 10. genauso... wie (Genauigkeit)
      const ComparativeProportionalModel(
        id: 'COMP-4966-10',
        constructionType: ComparativeConstructionType.equativePositiveGleichheit,
        scalingDirection: ProportionalScalingDirection.directProportionalPositive,
        domain: CommunicativeDomain.industrialRobotics,
        comparativeCarrierPhrase: 'genauso präzise wie',
        primaryClause: 'Der kollaborative Sechsachsroboter positioniert die SMD-Bauelemente genauso präzise',
        comparativeSecondaryClause: 'wie ein spezialisierter kartesischer Bestückungsautomat',
        fullGermanSentence:
            'Der kollaborative Sechsachsroboter positioniert die SMD-Bauelemente genauso präzise wie ein spezialisierter kartesischer Bestückungsautomat.',
        technicalLawGerman:
            'Positioniergenauigkeit in der Mikromontage: Kinematische Gleichwertigkeit bei gesteigerter Flexibilität.',
        technicalLawArabic:
            'مطابقة دقة التموضع: يضع الروبوت التعاوني المكونات الإلكترونية الدقيقة بنفس الدقة تماماً مثل آلة التركيب المتخصصة.',
        wordOrderConstraintRule:
            'Äquativvergleich mit Positiv "präzise" und Konnektor "wie".',
      ),
      // 11. eher..., als dass (Verhaltensabwägung)
      const ComparativeProportionalModel(
        id: 'COMP-4966-11',
        constructionType: ComparativeConstructionType.negativeScalarDisproportionMehrAlsDass,
        scalingDirection: ProportionalScalingDirection.nonLinearPhysicalThreshold,
        domain: CommunicativeDomain.renewableEnergyGrid,
        comparativeCarrierPhrase: 'eher ..., als dass',
        primaryClause: 'Der Wechselrichter drosselt die Einspeiseleistung zum Eigenschutz thermisch ab',
        comparativeSecondaryClause: 'als dass er eine unzulässige Netzüberspannung riskiert',
        fullGermanSentence:
            'Der Wechselrichter drosselt die Einspeiseleistung zum Eigenschutz thermisch ab, eher als dass er eine unzulässige Netzüberspannung riskiert.',
        technicalLawGerman:
            'Derating-Algorithmus: Präventive Abregelung zur Vermeidung von Hardware-Zerstörung.',
        technicalLawArabic:
            'خوارزمية الحماية الذاتية: يخفض المحول طاقة الضخ حرارياً لحماية نفسه، عوضاً عن أن يخاطر بتجاوز حدود الجهد الآمنة.',
        wordOrderConstraintRule:
            'Nebensatz mit "als dass" verlangt Verbletztstellung ("riskiert").',
      ),
      // 12. deutlich robuster als (Komparativ)
      const ComparativeProportionalModel(
        id: 'COMP-4966-12',
        constructionType: ComparativeConstructionType.inequativeComparativeUngleichheit,
        scalingDirection: ProportionalScalingDirection.directProportionalPositive,
        domain: CommunicativeDomain.aerospaceAndAviation,
        comparativeCarrierPhrase: 'deutlich robuster als',
        primaryClause: 'Die monolithische Keramikfaser-Brennkammer ist gegen thermische Schockwellen deutlich robuster',
        comparativeSecondaryClause: 'als gekühlte metallische Superlegierungen',
        fullGermanSentence:
            'Die monolithische Keramikfaser-Brennkammer ist gegen thermische Schockwellen deutlich robuster als gekühlte metallische Superlegierungen.',
        technicalLawGerman:
            'Thermomechanische Ermüdungsresistenz (TMF): Keramikmatrix-Verbundwerkstoffe (CMC) tolerieren höhere Gradienten.',
        technicalLawArabic:
            'المفاضلة التفاوتية للمتانة: غرفة الاحتراق المصنوعة من ألياف السيراميك أكثر متانة بشكل ملحوظ أمام الصدمات الحرارية من السبائك المعدنية.',
        wordOrderConstraintRule:
            'Komparativ "robuster" erfordert zwingend "als" (niemals "wie").',
      ),
      // 13. je... desto (Invers, Kavitation)
      const ComparativeProportionalModel(
        id: 'COMP-4966-13',
        constructionType: ComparativeConstructionType.proportionalJeDesto,
        scalingDirection: ProportionalScalingDirection.inverseProportionalNegative,
        domain: CommunicativeDomain.maritimeLogistics,
        comparativeCarrierPhrase: 'Je niedriger ... desto intensiver',
        primaryClause: 'Je niedriger der statische Wasserdruck an den Propellerspitzen abfällt',
        comparativeSecondaryClause: 'desto intensiver tritt zerstörerische Kavitationskorrosion auf',
        fullGermanSentence:
            'Je niedriger der statische Wasserdruck an den Propellerspitzen abfällt, desto intensiver tritt zerstörerische Kavitationskorrosion auf.',
        technicalLawGerman:
            'Bernoulli-Prinzip und Dampfdruckunterschreitung: Kollabierende Dampfblasen induzieren Mikro-Materialabtrag.',
        technicalLawArabic:
            'فيزياء التكهف البحري: كلما انخفض الضغط الاستاتيكي عند أطراف ريش الرفاس، كلما ظهر تآكل التكهف التدميري بكثافة أكبر.',
        wordOrderConstraintRule:
            'Je-Satz ("abfällt") + desto-Satz ("desto intensiver tritt ... auf" V2-Trennung).',
      ),
      // 14. zu... als dass (Konjunktiv II, Roboterzelle)
      const ComparativeProportionalModel(
        id: 'COMP-4966-14',
        constructionType: ComparativeConstructionType.counterfactualDiscrepancyZuAlsDass,
        scalingDirection: ProportionalScalingDirection.nonLinearPhysicalThreshold,
        domain: CommunicativeDomain.industrialRobotics,
        comparativeCarrierPhrase: 'zu unpräzise, als dass ... genügte',
        primaryClause: 'Die optische Objekterkennung der 2D-Kamera war für den Mikromontageschritt zu unpräzise',
        comparativeSecondaryClause: 'als dass sie den geforderten Toleranzgrenzen von 5 Mikrometern genügte',
        fullGermanSentence:
            'Die optische Objekterkennung der 2D-Kamera war für den Mikromontageschritt zu unpräzise, als dass sie den geforderten Toleranzgrenzen von 5 Mikrometern genügte.',
        technicalLawGerman:
            'Messtechnische Unsicherheit: 2D-Triangulation unzureichend für Sub-10-µm-Baugruppen.',
        technicalLawArabic:
            'قصور تقنية الرؤية الثنائية: دقة الكاميرا كانت غير كافية لدرجة تمتنع معها عن تلبية معيار التسامح البالغ 5 ميكرومتر.',
        wordOrderConstraintRule:
            'Konjunktiv II Präteritum: "... genügte" (strikte Folgeverhinderung).',
      ),
      // 15. weitaus komplexer als (Komparativ)
      const ComparativeProportionalModel(
        id: 'COMP-4966-15',
        constructionType: ComparativeConstructionType.inequativeComparativeUngleichheit,
        scalingDirection: ProportionalScalingDirection.directProportionalPositive,
        domain: CommunicativeDomain.civilInfrastructure,
        comparativeCarrierPhrase: 'weitaus komplexer als',
        primaryClause: 'Die dynamische Windlastberechnung für Schrägseilbrücken ist mathematisch weitaus komplexer',
        comparativeSecondaryClause: 'als die statische Modellierung konventioneller Balkenbrücken',
        fullGermanSentence:
            'Die dynamische Windlastberechnung für Schrägseilbrücken ist mathematisch weitaus komplexer als die statische Modellierung konventioneller Balkenbrücken.',
        technicalLawGerman:
            'Aeroelastisches Flattern und Wirbelablösung: Erfordert gekoppelte Finite-Elemente- und CFD-Simulationen.',
        technicalLawArabic:
            'التعقيد الإنشائي التفاوضي: الحساب الديناميكي لرياح الجسور المعلقة بالكوابل أكثر تعقيداً رياضياً بمراحل من نمذجة الجسور الخرسانية التقليدية.',
        wordOrderConstraintRule:
            'Komparativ "komplexer" erfordert "als".',
      ),
      // 16. je... desto (Thermische Ausdehnung)
      const ComparativeProportionalModel(
        id: 'COMP-4966-16',
        constructionType: ComparativeConstructionType.proportionalJeDesto,
        scalingDirection: ProportionalScalingDirection.directProportionalPositive,
        domain: CommunicativeDomain.renewableEnergyGrid,
        comparativeCarrierPhrase: 'Je stärker ... desto größer',
        primaryClause: 'Je stärker sich die Aluminium-Leiterseile unter Sommerhöchstlast erwärmen',
        comparativeSecondaryClause: 'desto größer wird der thermische Leitungsdurchhang über Verkehrswegen',
        fullGermanSentence:
            'Je stärker sich die Aluminium-Leiterseile unter Sommerhöchstlast erwärmen, desto größer wird der thermische Leitungsdurchhang über Verkehrswegen.',
        technicalLawGerman:
            'Freileitungs-Durchhanggleichung: Thermische Längenausdehnung Delta L = L_0 * alpha * Delta T.',
        technicalLawArabic:
            'قانون التمدد الحراري لخطوط الجهد العالي: كلما زادت سخونة كابلات الألمنيوم تحت أقصى حمل صيفي، كلما زاد ارتخاء الكابلات فوق الطرق.',
        wordOrderConstraintRule:
            'Je-Satz ("erwärmen") + desto-Satz ("desto größer wird" V2-Inversion).',
      ),
    ]);
  }

  List<ComparativeProportionalModel> getByType(ComparativeConstructionType type) =>
      _catalog.where((c) => c.constructionType == type).toList();

  List<ComparativeProportionalModel> getByScaling(ProportionalScalingDirection scaling) =>
      _catalog.where((c) => c.scalingDirection == scaling).toList();

  List<ComparativeProportionalModel> getByDomain(CommunicativeDomain domain) =>
      _catalog.where((c) => c.domain == domain).toList();

  /// Validates topological word order and grammatical particles for comparative structures.
  ComparativeValidationResult validateComparativeStructure({
    required ComparativeConstructionType type,
    required bool isJeClauseVerbFinal,
    required bool isDestoClauseVerbSecondInverted,
    required bool usesAlsForInequality,
    required bool usesWieForEquality,
    required bool usesSubjunctiveInAlsDass,
  }) {
    final List<String> issues = [];
    final List<String> notes = [];

    // Rule 1: Proportional word order (je... desto/umso)
    if (type == ComparativeConstructionType.proportionalJeDesto) {
      if (!isJeClauseVerbFinal) {
        issues.add(
            'Topologie-Fehler im je-Satz: Der je-Satz ist ein subordinierender Nebensatz und MUSS strikte Verbletztstellung aufweisen (z. B. "Je höher die Last steigt...").');
      } else {
        notes.add('Je-Satz normgerecht: Verbletztstellung eingehalten.');
      }

      if (!isDestoClauseVerbSecondInverted) {
        issues.add(
            'Inversionsfehler im desto-Satz: Im Hauptsatz steht "desto/umso + Komparativ" im Vorfeld; das finite Verb MUSS unmittelbar an zweiter Position (V2) folgen.');
      } else {
        notes.add('Desto-Satz normgerecht: V2-Inversion des Verbs nach dem Komparativ gewährleistet.');
      }
    }

    // Rule 2: Equality (wie) vs. Inequality (als)
    if (type == ComparativeConstructionType.inequativeComparativeUngleichheit) {
      if (!usesAlsForInequality) {
        issues.add(
            'Grammatikfehler: Bei Ungleichheit und echtem Komparativ (z. B. "höher", "präziser") ist ausschließlich die Konjunktion "als" zulässig (nicht *"wie").');
      } else {
        notes.add('Komparativpartikel normgerecht: "als" bei Ungleichheit verwendet.');
      }
    }

    if (type == ComparativeConstructionType.equativePositiveGleichheit) {
      if (!usesWieForEquality) {
        issues.add(
            'Grammatikfehler: Bei Gleichheit und Positiv (z. B. "genauso stabil", "ebenso effizient") ist ausschließlich die Partikel "wie" zulässig (nicht *"als").');
      } else {
        notes.add('Äquativpartikel normgerecht: "wie" bei Gleichheit verwendet.');
      }
    }

    // Rule 3: zu... als dass requires Konjunktiv II
    if (type == ComparativeConstructionType.counterfactualDiscrepancyZuAlsDass) {
      if (!usesSubjunctiveInAlsDass) {
        issues.add(
            'Modusfehler: Die Konstruktion "zu [Adjektiv], als dass" erfordert zwingend den Konjunktiv II (z. B. "... betrieben werden könnte"), da die Folge als verhindert/kontrafaktisch dargestellt wird.');
      } else {
        notes.add('Modus normgerecht: Konjunktiv II im als-dass-Nebensatz implementiert.');
      }
    }

    return ComparativeValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      syntacticNotes: notes,
    );
  }

  Map<String, dynamic> generateTelemetrySnapshot() {
    return {
      'totalExemplars': _catalog.length,
      'constructionTypeDistribution': {
        for (var t in ComparativeConstructionType.values)
          t.name: _catalog.where((c) => c.constructionType == t).length,
      },
      'scalingDistribution': {
        for (var s in ProportionalScalingDirection.values)
          s.name: _catalog.where((c) => c.scalingDirection == s).length,
      },
      'domainDistribution': {
        for (var d in CommunicativeDomain.values)
          d.name: _catalog.where((c) => c.domain == d).length,
      },
      'cefrLevel': 'CEFR C1-C2 Masterclass Comparative & Proportional Syntax',
      'engineVersion': '1.0.0+subsystem1800',
    };
  }
}
