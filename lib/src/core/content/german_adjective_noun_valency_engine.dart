import 'dart:collection';

/// Classification of adjective and noun valency rection in German technical prose.
enum ValencyGovernanceCategory {
  dativeGoverningAdjective(
    'Dativ-regierende Adjektive (überlegen, ebenbürtig, zugänglich, abträglich)',
    'الصفات المتعدية بحالة الجر مباشرة (Dativ-Adjektive: متفوق على / مكافئ لـ / مضر بـ)',
    'Prädikative Adjektive, die ein reines Dativobjekt ohne Präposition verlangen: "Siliziumkarbid ist herkömmlichem Silizium thermisch überlegen." (Niemals *"überlegen als"!).',
  ),
  genitiveGoverningAdjective(
    'Genitiv-regierende Adjektive (bedürftig, mächtig, fähig, sicher)',
    'الصفات المتعدية بحالة المضاف إليه (Genitiv-Adjektive: مفتقر إلى / جدير بـ / متمكن من)',
    'Gehobene Adjektive der C1-C2 Fachsprache, die ein Genitivkomplement binden: "Die Schweißnaht ist einer zusätzlichen Ultraschallprüfung bedürftig."',
  ),
  prepositionalAdjectiveGovernance(
    'Präpositional-regierende Adjektive (anfällig für, frei von, reich an, geeignet für)',
    'الصفات المقيدة بحروف جر ثابتة (anfällig für / frei von / reich an)',
    'Adjektive mit fester Präposition und festem Kasus: "anfällig für + Akk", "frei von + Dat", "unabhängig von + Dat", "arm/reich an + Dat".',
  ),
  deverbalNounPrepositionalGovernance(
    'Deverbale Substantiv-Rektion (Bedarf an, Zweifel an, Abhängigkeit von, Hinweis auf)',
    'الأسماء المشتقة المقيدة بحروف جر ثابتة (الاحتياج إلى / الشك في / الاعتماد على)',
    'Nominalisierungen übernehmen oder modifizieren die Präpositionalrektion ihres Basisverbs: "Der Bedarf an [Dat.] hochreinem Wasserstoff steigt."',
  ),
  attributiveDativeAdjunctFronting(
    'Voranstellung des Dativkomplements beim attributiven Adjektiv',
    'تقديم المفعول المجرور قبل الصفة المنعوتة في البناء الإضافي المعقد',
    'Bei attributiver Verwendung rückt das Dativkomplement vor das Adjektiv: "ein [dem Standardverfahren] überlegenes Prüfkonzept".',
  );

  final String deTitle;
  final String arTitle;
  final String grammaticalDefinition;
  const ValencyGovernanceCategory(this.deTitle, this.arTitle, this.grammaticalDefinition);
}

/// Exact case and preposition required by the governing adjective or noun.
enum GovernedCaseOrPreposition {
  pureDative('Reiner Dativ ohne Präposition', 'حالة الجر الصريحة بلا حرف جر'),
  pureGenitive('Reiner Genitiv ohne Präposition', 'حالة المضاف إليه الصريحة'),
  fuerPlusAccusative('für + Akkusativ (anfällig für, geeignet für, bekannt für)', 'حرف الجر für + حالة النصب'),
  vonPlusDative('von + Dativ (frei von, unabhängig von, Abhängigkeit von)', 'حرف الجر von + حالة الجر'),
  anPlusDative('an + Dativ (reich an, arm an, Bedarf an, Mangel an)', 'حرف الجر an + حالة الجر'),
  aufPlusAccusative('auf + Akkusativ (angewiesen auf, stolz auf, Hinweis auf)', 'حرف الجر auf + حالة النصب'),
  gegenPlusAccusative('gegen + Akkusativ (resistent gegen, immun gegen)', 'حرف الجر gegen + حالة النصب'),
  gegenueberPlusDative('gegenüber + Dativ (empfindlich gegenüber, aufgeschlossen gegenüber)', 'حرف الجر gegenüber + حالة الجر');

  final String de;
  final String ar;
  const GovernedCaseOrPreposition(this.de, this.ar);
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

/// Structural model of a German adjective or noun valency entry.
class AdjectiveNounValencyModel {
  final String id;
  final ValencyGovernanceCategory category;
  final GovernedCaseOrPreposition rection;
  final CommunicativeDomain domain;
  final String governingLexeme;
  final String fullGermanSentence;
  final String ungrammaticalInterferenceExample;
  final String valencyRuleGerman;
  final String valencyRuleArabic;
  final bool isAttributivePosition;

  const AdjectiveNounValencyModel({
    required this.id,
    required this.category,
    required this.rection,
    required this.domain,
    required this.governingLexeme,
    required this.fullGermanSentence,
    required this.ungrammaticalInterferenceExample,
    required this.valencyRuleGerman,
    required this.valencyRuleArabic,
    this.isAttributivePosition = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.name,
    'rection': rection.name,
    'domain': domain.name,
    'governingLexeme': governingLexeme,
    'fullGermanSentence': fullGermanSentence,
    'ungrammaticalInterferenceExample': ungrammaticalInterferenceExample,
    'valencyRuleGerman': valencyRuleGerman,
    'valencyRuleArabic': valencyRuleArabic,
    'isAttributivePosition': isAttributivePosition,
  };
}

/// Validation result for adjective and noun valency.
class ValencyValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<String> syntacticNotes;

  const ValencyValidationResult({
    required this.isValid,
    required this.issues,
    required this.syntacticNotes,
  });
}

/// Core Engine managing German Adjective & Noun Valency Governance.
class GermanAdjectiveNounValencyEngine {
  final List<AdjectiveNounValencyModel> _catalog = [];

  GermanAdjectiveNounValencyEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<AdjectiveNounValencyModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    _catalog.addAll([
      // 1. Dativ-Adjektiv: überlegen (+ Dativ)
      const AdjectiveNounValencyModel(
        id: 'VAL-4971-01',
        category: ValencyGovernanceCategory.dativeGoverningAdjective,
        rection: GovernedCaseOrPreposition.pureDative,
        domain: CommunicativeDomain.renewableEnergyGrid,
        governingLexeme: 'überlegen (+ Dativ)',
        fullGermanSentence:
            'Siliziumkarbid-Leistungshalbleiter sind herkömmlichen Silizium-IGBTs hinsichtlich der Schaltverluste deutlich überlegen.',
        ungrammaticalInterferenceExample:
            '*Siliziumkarbid-Halbleiter sind herkömmlichen IGBTs überlegen als / überlegen zu.',
        valencyRuleGerman:
            '"überlegen" regiert den reinen Dativ ohne Vergleichspartikel ("als").',
        valencyRuleArabic:
            'الصفة (überlegen) تتعدى للمفعول المجرور مباشرة بالداتيف ولا تستخدم معها أداة المقارنة (als) أبداً.',
      ),
      // 2. Dativ-Adjektiv: abträglich (+ Dativ)
      const AdjectiveNounValencyModel(
        id: 'VAL-4971-02',
        category: ValencyGovernanceCategory.dativeGoverningAdjective,
        rection: GovernedCaseOrPreposition.pureDative,
        domain: CommunicativeDomain.materialScience,
        governingLexeme: 'abträglich (+ Dativ)',
        fullGermanSentence:
            'Unkontrollierte Wasserstoffeinschlüsse sind der Dauerfestigkeit hochfester Baustähle äußerst abträglich.',
        ungrammaticalInterferenceExample:
            '*Wasserstoffeinschlüsse sind für die Dauerfestigkeit abträglich.',
        valencyRuleGerman:
            'Gehobenes Adjektiv "abträglich" (= schädlich) bindet zwingend den reinen Dativ ("der Dauerfestigkeit").',
        valencyRuleArabic:
            'الصفة الرفيعة (abträglich) بمعنى (ضار بـ) تفرض حالة الجر المباشر بالداتيف دون حرف جر.',
      ),
      // 3. Genitiv-Adjektiv: bedürftig (+ Genitiv)
      const AdjectiveNounValencyModel(
        id: 'VAL-4971-03',
        category: ValencyGovernanceCategory.genitiveGoverningAdjective,
        rection: GovernedCaseOrPreposition.pureGenitive,
        domain: CommunicativeDomain.civilInfrastructure,
        governingLexeme: 'bedürftig (+ Genitiv)',
        fullGermanSentence:
            'Die durch Tausalz geschädigten Spannbetonpfeiler der Talbrücke sind einer sofortigen statischen Sanierung bedürftig.',
        ungrammaticalInterferenceExample:
            '*Die Spannbetonpfeiler sind eine sofortige Sanierung bedürftig (falscher Akkusativ).',
        valencyRuleGerman:
            '"bedürftig" verlangt im gehobenen Gutachtenstil strikt den Genitiv ("einer Sanierung").',
        valencyRuleArabic:
            'الصفة (bedürftig) بمعنى (بحاجة ماسة إلى) تتطلب حالة المضاف إليه (Genitiv) في التقارير الهندسية.',
    ),
      // 4. Präpositional-Adjektiv: anfällig für (+ Akkusativ)
      const AdjectiveNounValencyModel(
        id: 'VAL-4971-04',
        category: ValencyGovernanceCategory.prepositionalAdjectiveGovernance,
        rection: GovernedCaseOrPreposition.fuerPlusAccusative,
        domain: CommunicativeDomain.industrialRobotics,
        governingLexeme: 'anfällig für (+ Akkusativ)',
        fullGermanSentence:
            'Ungeschirmte Feldbuskabel in der Schweißstraße sind besonders anfällig für elektromagnetische Störimpulse.',
        ungrammaticalInterferenceExample:
            '*Ungeschirmte Kabel sind anfällig zu / auf elektromagnetische Störimpulse.',
        valencyRuleGerman:
            '"anfällig" regiert ausschließlich die Präposition "für" mit dem Akkusativ.',
        valencyRuleArabic:
            'الصفة (anfällig) بمعنى (عرضة لـ / حساس تجاه) تقترن حصراً بحرف الجر (für + النصب).',
      ),
      // 5. Präpositional-Adjektiv: frei von (+ Dativ)
      const AdjectiveNounValencyModel(
        id: 'VAL-4971-05',
        category: ValencyGovernanceCategory.prepositionalAdjectiveGovernance,
        rection: GovernedCaseOrPreposition.vonPlusDative,
        domain: CommunicativeDomain.aerospaceAndAviation,
        governingLexeme: 'frei von (+ Dativ)',
        fullGermanSentence:
            'Die gereinigten Sauerstoffleitungen der Kabinenversorgung müssen absolut frei von organischen Rückständen sein.',
        ungrammaticalInterferenceExample:
            '*Die Leitungen müssen frei aus / ohne Rückstände sein (Vermischung der Rektion).',
        valencyRuleGerman:
            '"frei von + Dativ" bildet den Standardausdruck für technische Reinheitsvorschriften.',
        valencyRuleArabic:
            'الصفة (frei von + الجر) هي الصيغة القياسية للتعبير عن خلو الأنابيب الفضائية من أي شوائب.',
      ),
      // 6. Substantiv-Rektion: Bedarf an (+ Dativ)
      const AdjectiveNounValencyModel(
        id: 'VAL-4971-06',
        category: ValencyGovernanceCategory.deverbalNounPrepositionalGovernance,
        rection: GovernedCaseOrPreposition.anPlusDative,
        domain: CommunicativeDomain.renewableEnergyGrid,
        governingLexeme: 'der Bedarf an (+ Dativ)',
        fullGermanSentence:
            'Durch den Ausbau erneuerbarer Energien steigt der Bedarf an hochdynamischen Speichertechnologien kontinuierlich an.',
        ungrammaticalInterferenceExample:
            '*Der Bedarf für hochdynamische Speichertechnologien steigt an (Anglizismus-Interferenz "need for").',
        valencyRuleGerman:
            'Trotz englischem "need for" verlangt das deutsche Nomen "Bedarf" zwingend "an + Dativ"!',
        valencyRuleArabic:
            'الاسم (der Bedarf) يشترط حرف الجر (an + الجر)؛ ويجب الحذر من خطأ الترجمة الحرفية من الإنجليزية بـ (für).',
      ),
      // 7. Substantiv-Rektion: Abhängigkeit von (+ Dativ)
      const AdjectiveNounValencyModel(
        id: 'VAL-4971-07',
        category: ValencyGovernanceCategory.deverbalNounPrepositionalGovernance,
        rection: GovernedCaseOrPreposition.vonPlusDative,
        domain: CommunicativeDomain.maritimeLogistics,
        governingLexeme: 'die Abhängigkeit von (+ Dativ)',
        fullGermanSentence:
            'Automatisierte Schleppassistenten verringern die Abhängigkeit von manuellen Sichtpeilungen bei dichtem Seenebel.',
        ungrammaticalInterferenceExample:
            '*verringern die Abhängigkeit auf manuelle Sichtpeilungen.',
        valencyRuleGerman:
            'Wie "abhängen von" und "abhängig von" regiert auch "Abhängigkeit" strikt "von + Dativ".',
        valencyRuleArabic:
            'الاسم المشتق (Abhängigkeit) يحافظ على نفس حرف الجر (von + الجر) الموروث من الفعل والصفة.',
      ),
      // 8. Präpositional-Adjektiv: resistent gegen (+ Akkusativ)
      const AdjectiveNounValencyModel(
        id: 'VAL-4971-08',
        category: ValencyGovernanceCategory.prepositionalAdjectiveGovernance,
        rection: GovernedCaseOrPreposition.gegenPlusAccusative,
        domain: CommunicativeDomain.materialScience,
        governingLexeme: 'resistent gegen (+ Akkusativ)',
        fullGermanSentence:
            'Die keramikbeschichtete Turbinenschaufel erweist sich als hochgradig resistent gegen korrosive Heißgase.',
        ungrammaticalInterferenceExample:
            '*resistent zu / vor korrosiven Heißgasen.',
        valencyRuleGerman:
            '"resistent" (sowie "beständig" / "unempfindlich") regiert "gegen + Akkusativ".',
        valencyRuleArabic:
            'الصفة (resistent) بمعنى (مقاوم لـ) تتعدى حصراً بحرف الجر (gegen + النصب).',
      ),
      // 9. Präpositional-Adjektiv: empfindlich gegenüber (+ Dativ)
      const AdjectiveNounValencyModel(
        id: 'VAL-4971-09',
        category: ValencyGovernanceCategory.prepositionalAdjectiveGovernance,
        rection: GovernedCaseOrPreposition.gegenueberPlusDative,
        domain: CommunicativeDomain.industrialRobotics,
        governingLexeme: 'empfindlich gegenüber (+ Dativ)',
        fullGermanSentence:
            'Optische Drehgeber hoher Auflösung reagieren extrem empfindlich gegenüber mechanischen Axialstößen.',
        ungrammaticalInterferenceExample:
            '*empfindlich für / auf mechanische Axialstöße.',
        valencyRuleGerman:
            '"empfindlich gegenüber + Dativ" drückt physische oder sensorische Störanfälligkeit aus.',
        valencyRuleArabic:
            'الصفة (empfindlich gegenüber + الجر) تعبر بدقة عن حساسية المستشعرات الضوئية للصدمات المحورية.',
      ),
      // 10. Attributives Dativ-Komplement voranstellen
      const AdjectiveNounValencyModel(
        id: 'VAL-4971-10',
        category: ValencyGovernanceCategory.attributiveDativeAdjunctFronting,
        rection: GovernedCaseOrPreposition.pureDative,
        domain: CommunicativeDomain.aerospaceAndAviation,
        governingLexeme: 'ein [dem Vorgänger] ebenbürtiges Konzept',
        fullGermanSentence:
            'Das Entwicklungsteam präsentierte ein dem etablierten Vorgängermodell in jeder Hinsicht überlegenes Antriebskonzept.',
        ungrammaticalInterferenceExample:
            '*ein überlegenes dem Vorgängermodell Antriebskonzept (falsche Wortstellung im Attribut).',
        valencyRuleGerman:
            'Bei attributiver Verwendung vor dem Nomen steht das regierte Dativkomplement ("dem etablierten Vorgängermodell") LINKS vom Adjektiv.',
        valencyRuleArabic:
            'عند مجيء الصفة نعتاً متقدماً، يجب تقديم المفعول المجرور بالداتيف يسار الصفة: (ein [dem Modell] überlegenes Konzept).',
        isAttributivePosition: true,
      ),
      // 11. Präpositional-Adjektiv: angewiesen auf (+ Akkusativ)
      const AdjectiveNounValencyModel(
        id: 'VAL-4971-11',
        category: ValencyGovernanceCategory.prepositionalAdjectiveGovernance,
        rection: GovernedCaseOrPreposition.aufPlusAccusative,
        domain: CommunicativeDomain.maritimeLogistics,
        governingLexeme: 'angewiesen auf (+ Akkusativ)',
        fullGermanSentence:
            'Tiefwasserhäfen sind für den reibungslosen Containerumschlag zwingend auf automatisierte Hinterland-Bahnterminals angewiesen.',
        ungrammaticalInterferenceExample:
            '*sind auf automatisierten Bahnterminals angewiesen (Dativ statt Akkusativ nach "auf").',
        valencyRuleGerman:
            '"angewiesen sein auf" regiert bei abstrakter Abhängigkeit zwingend den Akkusativ.',
        valencyRuleArabic:
            'الصفة (angewiesen auf) بمعنى (معتمد كلياً على) تفرض حالة النصب بعد حرف الجر (auf).',
      ),
      // 12. Substantiv-Rektion: Hinweis auf (+ Akkusativ)
      const AdjectiveNounValencyModel(
        id: 'VAL-4971-12',
        category: ValencyGovernanceCategory.deverbalNounPrepositionalGovernance,
        rection: GovernedCaseOrPreposition.aufPlusAccusative,
        domain: CommunicativeDomain.civilInfrastructure,
        governingLexeme: 'der Hinweis auf (+ Akkusativ)',
        fullGermanSentence:
            'Die Ultraschallprüfung lieferte keinen Hinweis auf eine fortschreitende Rissbildung in der Brückenplatte.',
        ungrammaticalInterferenceExample:
            '*lieferte keinen Hinweis über / für eine Rissbildung.',
        valencyRuleGerman:
            'Abgeleitet von "hinweisen auf + Akk", verlangt auch das Substantiv "Hinweis" "auf + Akkusativ".',
        valencyRuleArabic:
            'الاسم (Hinweis) يحتفظ بحرف الجر (auf + النصب) للدلالة على الإشارة إلى وجود شروخ أو غيابها.',
      ),
      // 13. Präpositional-Adjektiv: reich an (+ Dativ)
      const AdjectiveNounValencyModel(
        id: 'VAL-4971-13',
        category: ValencyGovernanceCategory.prepositionalAdjectiveGovernance,
        rection: GovernedCaseOrPreposition.anPlusDative,
        domain: CommunicativeDomain.materialScience,
        governingLexeme: 'reich an (+ Dativ)',
        fullGermanSentence:
            'Die entwickelte Superlegierung ist besonders reich an hochschmelzenden Übergangsmetallen wie Wolfram und Rhenium.',
        ungrammaticalInterferenceExample:
            '*ist reich mit / von Übergangsmetallen.',
        valencyRuleGerman:
            '"reich an" und das Antonym "arm an" regieren strikt "an + Dativ".',
        valencyRuleArabic:
            'الصفة (reich an + الجر) وعكسها (arm an) تقترنان حصراً بحرف الجر (an) متبوعاً بحالة الجر.',
      ),
      // 14. Genitiv-Adjektiv: mächtig (+ Genitiv)
      const AdjectiveNounValencyModel(
        id: 'VAL-4971-14',
        category: ValencyGovernanceCategory.genitiveGoverningAdjective,
        rection: GovernedCaseOrPreposition.pureGenitive,
        domain: CommunicativeDomain.industrialRobotics,
        governingLexeme: 'mächtig (+ Genitiv)',
        fullGermanSentence:
            'Nur ein der Echtzeit-Kinematik mächtiger Systemintegrator darf die Sicherheitssteuerung umprogrammieren.',
        ungrammaticalInterferenceExample:
            '*ein der Echtzeit-Kinematik mächtiger... falsch? Nein, korrekt! Fehlerhaft wäre: *ein mit der Kinematik mächtiger.',
        valencyRuleGerman:
            'Das gehobene Adjektiv "mächtig" (= beherrschend) regiert im Genitiv ("der Echtzeit-Kinematik").',
        valencyRuleArabic:
            'الصفة (mächtig) بمعنى (متقن ومتمكن من) تحكم المضاف إليه في البناء النعتي المتقدم.',
        isAttributivePosition: true,
      ),
      // 15. Dativ-Adjektiv: zugänglich (+ Dativ)
      const AdjectiveNounValencyModel(
        id: 'VAL-4971-15',
        category: ValencyGovernanceCategory.dativeGoverningAdjective,
        rection: GovernedCaseOrPreposition.pureDative,
        domain: CommunicativeDomain.renewableEnergyGrid,
        governingLexeme: 'zugänglich (+ Dativ)',
        fullGermanSentence:
            'Die Wartungsklemmen des Transformators müssen dem Fachpersonal jederzeit barrierefrei zugänglich sein.',
        ungrammaticalInterferenceExample:
            '*müssen für dem Fachpersonal zugänglich sein.',
        valencyRuleGerman:
            '"zugänglich" regiert primär den reinen Dativ ("dem Fachpersonal").',
        valencyRuleArabic:
            'الصفة (zugänglich) بمعنى (متاح لـ / يمكن الوصول إليه من قبل) تتعدى مباشرة للمجرور بالداتيف.',
      ),
      // 16. Attributives Präpositional-Komplement voranstellen
      const AdjectiveNounValencyModel(
        id: 'VAL-4971-16',
        category: ValencyGovernanceCategory.attributiveDativeAdjunctFronting,
        rection: GovernedCaseOrPreposition.fuerPlusAccusative,
        domain: CommunicativeDomain.aerospaceAndAviation,
        governingLexeme: 'eine [für extreme Lasten] geeignete Konstruktion',
        fullGermanSentence:
            'Die Konstrukteure wählten eine für extreme aerodynamische Querkräfte geeignete Leichtbaustruktur.',
        ungrammaticalInterferenceExample:
            '*eine geeignete für extreme Querkräfte Leichtbaustruktur.',
        valencyRuleGerman:
            'Im erweiterten Adjektivattribut steht die präpositionale Ergänzung ("für extreme Querkräfte") zwingend VOR dem Partizip/Adjektiv ("geeignete").',
        valencyRuleArabic:
            'في النعت الموسع: تسبق العبارة المجرورة (für extreme Querkräfte) الصفة الموصوفة (geeignete) وجوباً.',
        isAttributivePosition: true,
      ),
    ]);
  }

  List<AdjectiveNounValencyModel> getByCategory(ValencyGovernanceCategory cat) =>
      _catalog.where((v) => v.category == cat).toList();

  List<AdjectiveNounValencyModel> getByRection(GovernedCaseOrPreposition rek) =>
      _catalog.where((v) => v.rection == rek).toList();

  List<AdjectiveNounValencyModel> getByDomain(CommunicativeDomain domain) =>
      _catalog.where((v) => v.domain == domain).toList();

  /// Validates adjective/noun valency rection and attributive fronting.
  ValencyValidationResult validateValencyStructure({
    required ValencyGovernanceCategory category,
    required GovernedCaseOrPreposition expectedRection,
    required bool matchesExpectedCaseAndPreposition,
    required bool isComplementFrontedBeforeAttributiveAdjective,
  }) {
    final List<String> issues = [];
    final List<String> notes = [];

    if (!matchesExpectedCaseAndPreposition) {
      issues.add(
          'Rektionsfehler: Das regierende Adjektiv oder Nomen verlangt zwingend ${expectedRection.de}. Englische Interferenzen (z. B. *"Bedarf für" statt "Bedarf an", *"überlegen als" statt Dativ) sind ungrammatisch.');
    } else {
      notes.add('Rektion normgerecht: ${expectedRection.de} exakt eingehalten.');
    }

    if (category == ValencyGovernanceCategory.attributiveDativeAdjunctFronting &&
        !isComplementFrontedBeforeAttributiveAdjective) {
      issues.add(
          'Wortstellungsfehler im Attribut: In einer attributiven Nominalphrase muss das Dativ- oder Präpositionalkomplement zwingend LINKS vor dem Adjektiv stehen (z. B. "ein [dem Standard] überlegenes Konzept").');
    } else if (category == ValencyGovernanceCategory.attributiveDativeAdjunctFronting) {
      notes.add('Topologisch normgerecht: Attributives Komplement korrekt links vorangestellt.');
    }

    return ValencyValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      syntacticNotes: notes,
    );
  }

  Map<String, dynamic> generateTelemetrySnapshot() {
    return {
      'totalExemplars': _catalog.length,
      'categoryDistribution': {
        for (var c in ValencyGovernanceCategory.values)
          c.name: _catalog.where((v) => v.category == c).length,
      },
      'rectionDistribution': {
        for (var r in GovernedCaseOrPreposition.values)
          r.name: _catalog.where((v) => v.rection == r).length,
      },
      'domainDistribution': {
        for (var d in CommunicativeDomain.values)
          d.name: _catalog.where((v) => v.domain == d).length,
      },
      'attributiveCount': _catalog.where((v) => v.isAttributivePosition).length,
      'cefrLevel': 'CEFR C1-C2 Masterclass Adjective & Noun Valency Governance',
      'engineVersion': '1.0.0+subsystem1805',
    };
  }
}
