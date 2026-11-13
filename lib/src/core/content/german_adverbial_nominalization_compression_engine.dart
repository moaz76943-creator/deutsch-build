import 'dart:collection';

/// Semantic relation between the verbal subordinate clause and the compressed nominal phrase.
enum AdverbialCompressionRelation {
  causalCompression(
    'Kausal-Komprimierung (weil/da -> wegen, aufgrund, infolge, mangels + Genitiv)',
    'التكثيف السببي (تحويل جملة التعليل إلى عبارة جر بالمضاف إليه: wegen / aufgrund / mangels)',
    'Wandelt kausale Nebensätze in kompakte Genitiv-Präpositionalphrasen um: "Weil Schmiermittel fehlten" -> "Mangels ausreichender Schmiermittel".',
  ),
  concessiveCompression(
    'Konzessiv-Komprimierung (obwohl/obgleich -> trotz, ungeachtet + Genitiv)',
    'التكثيف التنازلي (تحويل جملة الاستدراك والتنازل إلى عبارة جر: trotz / ungeachtet)',
    'Verdichtet eingeräumte Gegengründe zu nominalen Attributen: "Obwohl starke Böen auftraten" -> "Trotz starker Windböen".',
  ),
  conditionalCompression(
    'Konditional-Komprimierung (wenn/falls -> bei + Dativ / im Falle + Genitiv)',
    'التكثيف الشرطي (تحويل جملة الشرط إلى عبارة جر: bei / im Falle / ohne)',
    'Ersetzt Bedingungssätze durch präpositionale Konditionalangaben: "Wenn der Druck abfällt" -> "Bei einem Druckabfall".',
  ),
  temporalCompression(
    'Temporal-Komprimierung (während/nachdem/bevor -> während [Gen.], nach, vor [Dat.])',
    'التكثيف الزمني (تحويل الجمل الزمنية إلى ظروف اسمية: während / nach / vor)',
    'Komprimiert Zeitverhältnisse (Gleichzeitigkeit, Vorzeitigkeit, Nachzeitigkeit) in präpositionale Nominalblöcke.',
  ),
  finalCompression(
    'Final-Komprimierung (damit/um... zu -> zu/zur/zum + Dativ oder zwecks + Genitiv)',
    'التكثيف الغائي (تحويل جملة الهدف والتعليل الغائي إلى: zur / zwecks)',
    'Verdichtet Zweckangaben in technische Spezifikationsphrasen: "Um Korrosion zu verhüten" -> "Zur Korrosionsverhütung / Zwecks Korrosionsschutzes".',
  ),
  modalInstrumentalCompression(
    'Modal-Instrumentale Komprimierung (indem/dadurch dass -> durch / mittels)',
    'التكثيف الأداتي والكيفي (تحويل جملة الوسيلة والكيفية إلى: durch / mittels)',
    'Transformiert instrumentale Nebensätze in präzise Verfahrensangaben: "Indem man die Welle kühlt" -> "Durch Kühlung der Welle".',
  );

  final String deTitle;
  final String arTitle;
  final String grammaticalDefinition;
  const AdverbialCompressionRelation(this.deTitle, this.arTitle, this.grammaticalDefinition);
}

/// Case governed by the compressing preposition.
enum PrepositionGovernedCase {
  genitiveStrict('Strikter Genitiv (aufgrund, infolge, mangels, zwecks, ungeachtet, während)', 'حالة المضاف إليه الصارمة (Genitiv)'),
  dativeStrict('Strikter Dativ (bei, nach, vor, zu/zur/zum, mit)', 'حالة الجر (Dativ)'),
  accusativeStrict('Strikter Akkusativ (durch, ohne, für)', 'حالة النصب (Akkusativ)');

  final String de;
  final String ar;
  const PrepositionGovernedCase(this.de, this.ar);
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

/// Structural model of a German adverbial-to-nominal clause compression pair.
class AdverbialNominalizationModel {
  final String id;
  final AdverbialCompressionRelation relation;
  final PrepositionGovernedCase governedCase;
  final CommunicativeDomain domain;
  final String verbalSubordinateClause;
  final String compressedNominalPhrase;
  final String fullNominalizedSentence;
  final String fullVerbalizedSentence;
  final String compressionPreposition;
  final String nominalizationSuffixOrForm;
  final String syntacticTransformationRuleGerman;
  final String syntacticTransformationRuleArabic;

  const AdverbialNominalizationModel({
    required this.id,
    required this.relation,
    required this.governedCase,
    required this.domain,
    required this.verbalSubordinateClause,
    required this.compressedNominalPhrase,
    required this.fullNominalizedSentence,
    required this.fullVerbalizedSentence,
    required this.compressionPreposition,
    required this.nominalizationSuffixOrForm,
    required this.syntacticTransformationRuleGerman,
    required this.syntacticTransformationRuleArabic,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'relation': relation.name,
    'governedCase': governedCase.name,
    'domain': domain.name,
    'verbalSubordinateClause': verbalSubordinateClause,
    'compressedNominalPhrase': compressedNominalPhrase,
    'fullNominalizedSentence': fullNominalizedSentence,
    'fullVerbalizedSentence': fullVerbalizedSentence,
    'compressionPreposition': compressionPreposition,
    'nominalizationSuffixOrForm': nominalizationSuffixOrForm,
    'syntacticTransformationRuleGerman': syntacticTransformationRuleGerman,
    'syntacticTransformationRuleArabic': syntacticTransformationRuleArabic,
  };
}

/// Validation result for adverbial nominalization transformations.
class NominalizationValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<String> stylisticNotes;

  const NominalizationValidationResult({
    required this.isValid,
    required this.issues,
    required this.syntacticNotes,
  });
}

/// Core Engine managing German Adverbial-to-Nominal Clause Compression.
class GermanAdverbialNominalizationCompressionEngine {
  final List<AdverbialNominalizationModel> _catalog = [];

  GermanAdverbialNominalizationCompressionEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<AdverbialNominalizationModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    _catalog.addAll([
      // 1. Kausal (mangels + Genitiv)
      const AdverbialNominalizationModel(
        id: 'NOM-4970-01',
        relation: AdverbialCompressionRelation.causalCompression,
        governedCase: PrepositionGovernedCase.genitiveStrict,
        domain: CommunicativeDomain.industrialRobotics,
        verbalSubordinateClause: 'Weil ausreichende Schmiermittel im Getriebe fehlten',
        compressedNominalPhrase: 'Mangels ausreichender Schmiermittel im Getriebe',
        fullNominalizedSentence:
            'Mangels ausreichender Schmiermittel im Getriebe kam es zu einer Überhitzung der Planetenräder.',
        fullVerbalizedSentence:
            'Weil ausreichende Schmiermittel im Getriebe fehlten, kam es zu einer Überhitzung der Planetenräder.',
        compressionPreposition: 'mangels',
        nominalizationSuffixOrForm: 'Plural-Genitiv ohne Artikel (-er am Adjektiv)',
        syntacticTransformationRuleGerman:
            'Negierter Kausalsatz ("weil ... fehlt") wird mit der Genitivpräposition "mangels" ohne Artikel komprimiert.',
        syntacticTransformationRuleArabic:
            'تكثيف السبب المنفي (لعدم وجود كذا): تحويل جملة التعليل المنفية إلى (mangels) متبوعة بالمضاف إليه.',
      ),
      // 2. Kausal (infolge + Genitiv)
      const AdverbialNominalizationModel(
        id: 'NOM-4970-02',
        relation: AdverbialCompressionRelation.causalCompression,
        governedCase: PrepositionGovernedCase.genitiveStrict,
        domain: CommunicativeDomain.renewableEnergyGrid,
        verbalSubordinateClause: 'Weil die Netzfrequenz sprunghaft anstieg',
        compressedNominalPhrase: 'Infolge eines sprunghaften Anstiegs der Netzfrequenz',
        fullNominalizedSentence:
            'Infolge eines sprunghaften Anstiegs der Netzfrequenz trennten die Schutzrelais den Windpark automatisch vom Netz.',
        fullVerbalizedSentence:
            'Weil die Netzfrequenz sprunghaft anstieg, trennten die Schutzrelais den Windpark automatisch vom Netz.',
        compressionPreposition: 'infolge',
        nominalizationSuffixOrForm: 'Substantivierter Verbstamm (der Anstieg) + Genitivattribut',
        syntacticTransformationRuleGerman:
            'Das Subjekt des Nebensatzes ("die Netzfrequenz") wird zum Genitivattribut ("der Netzfrequenz") hinter dem Nomen "Anstieg".',
        syntacticTransformationRuleArabic:
            'يتحول الفاعل (تردد الشبكة) إلى مضاف إليه بعد الاسم المشتق من الفعل (Anstieg) مسبوقاً بـ (infolge).',
      ),
      // 3. Konzessiv (trotz + Genitiv)
      const AdverbialNominalizationModel(
        id: 'NOM-4970-03',
        relation: AdverbialCompressionRelation.concessiveCompression,
        governedCase: PrepositionGovernedCase.genitiveStrict,
        domain: CommunicativeDomain.aerospaceAndAviation,
        verbalSubordinateClause: 'Obwohl extreme Minustemperaturen in 12.000 Metern Höhe herrschten',
        compressedNominalPhrase: 'Trotz extremer Minustemperaturen in 12.000 Metern Höhe',
        fullNominalizedSentence:
            'Trotz extremer Minustemperaturen in 12.000 Metern Höhe funktionierten sämtliche Hydraulikaktoren reibungslos.',
        fullVerbalizedSentence:
            'Obwohl extreme Minustemperaturen in 12.000 Metern Höhe herrschten, funktionierten sämtliche Hydraulikaktoren reibungslos.',
        compressionPreposition: 'trotz',
        nominalizationSuffixOrForm: 'Artikelloser Plural-Genitiv ("trotz extremer Minustemperaturen")',
        syntacticTransformationRuleGerman:
            'Konzessivsatz wird durch "trotz" + Genitiv im Vorfeld des Hauptsatzes ersetzt (mit anschließender V2-Inversion).',
        syntacticTransformationRuleArabic:
            'تحويل جملة الاستدراك (obwohl) إلى عبارة جر (trotz + مضاف إليه) في الصدارة مع تأخير الفاعل بعد الفعل.',
      ),
      // 4. Konzessiv (ungeachtet + Genitiv)
      const AdverbialNominalizationModel(
        id: 'NOM-4970-04',
        relation: AdverbialCompressionRelation.concessiveCompression,
        governedCase: PrepositionGovernedCase.genitiveStrict,
        domain: CommunicativeDomain.maritimeLogistics,
        verbalSubordinateClause: 'Obgleich der Seegang stark zunahm',
        compressedNominalPhrase: 'Ungeachtet des stark zunehmenden Seegangs',
        fullNominalizedSentence:
            'Ungeachtet des stark zunehmenden Seegangs hielt das Containerschiff seinen präzisen Kurs durch das Verkehrstrennungsgebiet.',
        fullVerbalizedSentence:
            'Obgleich der Seegang stark zunahm, hielt das Containerschiff seinen präzisen Kurs durch das Verkehrstrennungsgebiet.',
        compressionPreposition: 'ungeachtet',
        nominalizationSuffixOrForm: 'Partizip-I-Attribut im Genitiv ("des zunehmenden Seegangs")',
        syntacticTransformationRuleGerman:
            'Verwendung des gehobenen Konzessivmarkers "ungeachtet" + Genitiv mit Partizipialattribut.',
        syntacticTransformationRuleArabic:
            'أسلوب تنازل رفيع بـ (ungeachtet) المتبوعة باسم الفاعل المجرور بالإضافة للتعبير عن مواصلة الإبحار.',
      ),
      // 5. Konditional (bei + Dativ)
      const AdverbialNominalizationModel(
        id: 'NOM-4970-05',
        relation: AdverbialCompressionRelation.conditionalCompression,
        governedCase: PrepositionGovernedCase.dativeStrict,
        domain: CommunicativeDomain.civilInfrastructure,
        verbalSubordinateClause: 'Wenn der Grundwasserspiegel unzulässig ansteigt',
        compressedNominalPhrase: 'Bei einem unzulässigen Anstieg des Grundwasserspiegels',
        fullNominalizedSentence:
            'Bei einem unzulässigen Anstieg des Grundwasserspiegels schalten sich die redundanten Tauchpumpen selbsttätig ein.',
        fullVerbalizedSentence:
            'Wenn der Grundwasserspiegel unzulässig ansteigt, schalten sich die redundanten Tauchpumpen selbsttätig ein.',
        compressionPreposition: 'bei',
        nominalizationSuffixOrForm: 'Präposition "bei" + Dativ ("einem Anstieg")',
        syntacticTransformationRuleGerman:
            'Konditionales "wenn" wird standardmäßig in der technischen Betriebsanleitung durch "bei + Dativ" komprimiert.',
        syntacticTransformationRuleArabic:
            'تحويل جملة الشرط إلى عبارة ظرفية (bei + Dativ) وهو الأسلوب القياسي في كتيبات التشغيل الهندسية.',
      ),
      // 6. Konditional negativ (ohne + Akkusativ)
      const AdverbialNominalizationModel(
        id: 'NOM-4970-06',
        relation: AdverbialCompressionRelation.conditionalCompression,
        governedCase: PrepositionGovernedCase.accusativeStrict,
        domain: CommunicativeDomain.aerospaceAndAviation,
        verbalSubordinateClause: 'Wenn die Brennkammer nicht aktiv gekühlt wird',
        compressedNominalPhrase: 'Ohne aktive Kühlung der Brennkammer',
        fullNominalizedSentence:
            'Ohne aktive Kühlung der Brennkammer würden die Turbinenleitschaufeln innerhalb weniger Sekunden schmelzen.',
        fullVerbalizedSentence:
            'Wenn die Brennkammer nicht aktiv gekühlt würde, würden die Turbinenleitschaufeln innerhalb weniger Sekunden schmelzen.',
        compressionPreposition: 'ohne',
        nominalizationSuffixOrForm: 'Nominalisierung auf -ung ("Kühlung") im Akkusativ',
        syntacticTransformationRuleGerman:
            'Negierter Konditionalsatz ("wenn ... nicht") wird elegant durch "ohne" + Akkusativ ("Ohne aktive Kühlung") ersetzt.',
        syntacticTransformationRuleArabic:
            'تحويل الشرط المنفي إلى عبارة (ohne + Akkusativ) باستخدام الاسم المشتق (-ung) للدلالة على حتمية التبريد.',
      ),
      // 7. Temporal Gleichzeitigkeit (während + Genitiv)
      const AdverbialNominalizationModel(
        id: 'NOM-4970-07',
        relation: AdverbialCompressionRelation.temporalCompression,
        governedCase: PrepositionGovernedCase.genitiveStrict,
        domain: CommunicativeDomain.materialScience,
        verbalSubordinateClause: 'Während der Probekörper im Vakuumofen langsam abkühlt',
        compressedNominalPhrase: 'Während der langsamen Abkühlung des Probekörpers im Vakuumofen',
        fullNominalizedSentence:
            'Während der langsamen Abkühlung des Probekörpers im Vakuumofen darf die Schutzgaszufuhr keinesfalls unterbrochen werden.',
        fullVerbalizedSentence:
            'Während der Probekörper im Vakuumofen langsam abkühlt, darf die Schutzgaszufuhr keinesfalls unterbrochen werden.',
        compressionPreposition: 'während',
        nominalizationSuffixOrForm: 'Substantivierung auf -ung im Genitiv ("der Abkühlung")',
        syntacticTransformationRuleGerman:
            'Die Subjunktion "während" wird zur Genitiv-Präposition "während"; das Adverb "langsam" wird zum attributiven Adjektiv ("der langsamen").',
        syntacticTransformationRuleArabic:
            'تحويل أداة التزامن إلى حرف الجر (während + Genitiv) مع تحويل الظرف (langsam) إلى صفة مجرورة.',
      ),
      // 8. Temporal Vorzeitigkeit (nach + Dativ)
      const AdverbialNominalizationModel(
        id: 'NOM-4970-08',
        relation: AdverbialCompressionRelation.temporalCompression,
        governedCase: PrepositionGovernedCase.dativeStrict,
        domain: CommunicativeDomain.renewableEnergyGrid,
        verbalSubordinateClause: 'Nachdem die Gasisolation erfolgreich auf Dichtigkeit geprüft worden war',
        compressedNominalPhrase: 'Nach erfolgreicher Dichtigkeitsprüfung der Gasisolation',
        fullNominalizedSentence:
            'Nach erfolgreicher Dichtigkeitsprüfung der Gasisolation erfolgte die schrittweise Freigabe der 380-kV-Schaltanlage.',
        fullVerbalizedSentence:
            'Nachdem die Gasisolation erfolgreich auf Dichtigkeit geprüft worden war, erfolgte die schrittweise Freigabe der 380-kV-Schaltanlage.',
        compressionPreposition: 'nach',
        nominalizationSuffixOrForm: 'Kompositum auf -ung im Dativ ("Dichtigkeitsprüfung")',
        syntacticTransformationRuleGerman:
            'Vorzeitiges "nachdem" verwandelt sich in "nach + Dativ" mit hochkomprimiertem Fachkompositum.',
        syntacticTransformationRuleArabic:
            'تحويل أسبقية (nachdem) إلى عبارة زمنية مكثفة بـ (nach + Dativ) ومركب اسمي تقني.',
      ),
      // 9. Temporal Nachzeitigkeit (vor + Dativ)
      const AdverbialNominalizationModel(
        id: 'NOM-4970-09',
        relation: AdverbialCompressionRelation.temporalCompression,
        governedCase: PrepositionGovernedCase.dativeStrict,
        domain: CommunicativeDomain.industrialRobotics,
        verbalSubordinateClause: 'Bevor der sechsachsige Schweißroboter wieder angefahren wird',
        compressedNominalPhrase: 'Vor dem Wiederanfahren des sechsachsigen Schweißroboters',
        fullNominalizedSentence:
            'Vor dem Wiederanfahren des sechsachsigen Schweißroboters muss der Sicherheitslichtvorhang quittiert werden.',
        fullVerbalizedSentence:
            'Bevor der sechsachsige Schweißroboter wieder angefahren wird, muss der Sicherheitslichtvorhang quittiert werden.',
        compressionPreposition: 'vor',
        nominalizationSuffixOrForm: 'Substantivierter Infinitiv ("das Wiederanfahren") im Dativ',
        syntacticTransformationRuleGerman:
            'Nachzeitiges "bevor" wird durch "vor + Dativ" mit substantiviertem Infinitiv ersetzt.',
        syntacticTransformationRuleArabic:
            'تحويل اللاحقية (bevor) إلى (vor + Dativ) مقترناً بالمصدر المعرف (das Wiederanfahren).',
      ),
      // 10. Final (zur + Dativ)
      const AdverbialNominalizationModel(
        id: 'NOM-4970-10',
        relation: AdverbialCompressionRelation.finalCompression,
        governedCase: PrepositionGovernedCase.dativeStrict,
        domain: CommunicativeDomain.civilInfrastructure,
        verbalSubordinateClause: 'Um die Schwingungsresonanz der Hängebrücke zu dämpfen',
        compressedNominalPhrase: 'Zur Dämpfung der Schwingungsresonanz der Hängebrücke',
        fullNominalizedSentence:
            'Zur Dämpfung der Schwingungsresonanz der Hängebrücke installierten die Ingenieure abgestimmte Tilgermassen im Brückendeck.',
        fullVerbalizedSentence:
            'Um die Schwingungsresonanz der Hängebrücke zu dämpfen, installierten die Ingenieure abgestimmte Tilgermassen im Brückendeck.',
        compressionPreposition: 'zur (zu + der)',
        nominalizationSuffixOrForm: 'Femininum auf -ung ("die Dämpfung") im Dativ',
        syntacticTransformationRuleGerman:
            'Finaler Infinitivsatz ("um... zu") wird in der Fachsprache kompakt durch "zur + Nomen + Genitivattribut" ersetzt.',
        syntacticTransformationRuleArabic:
            'تحويل جملة الغاية (um... zu) إلى تركيب غائي موجز بـ (zur + اسم مشتق -ung) لتخميد الرنين.',
      ),
      // 11. Final (zwecks + Genitiv)
      const AdverbialNominalizationModel(
        id: 'NOM-4970-11',
        relation: AdverbialCompressionRelation.finalCompression,
        governedCase: PrepositionGovernedCase.genitiveStrict,
        domain: CommunicativeDomain.materialScience,
        verbalSubordinateClause: 'Damit die Korngrenzenkorrosion dauerhaft unterbunden wird',
        compressedNominalPhrase: 'Zwecks dauerhafter Unterbindung der Korngrenzenkorrosion',
        fullNominalizedSentence:
            'Zwecks dauerhafter Unterbindung der Korngrenzenkorrosion wird der Edelstahllegierung stabilisierendes Niob zulegiert.',
        fullVerbalizedSentence:
            'Damit die Korngrenzenkorrosion dauerhaft unterbunden wird, wird der Edelstahllegierung stabilisierendes Niob zulegiert.',
        compressionPreposition: 'zwecks',
        nominalizationSuffixOrForm: 'Genitivphrase ohne Artikel ("zwecks dauerhafter Unterbindung")',
        syntacticTransformationRuleGerman:
            'Amtssprachlich-technische Zweckpräposition "zwecks" verlangt zwingend den Genitiv.',
        syntacticTransformationRuleArabic:
            'أداة الغاية الرسمية (zwecks) المتبوعة بالمضاف إليه لبيان الغرض المعدني من إضافة عنصر النيوبيوم.',
      ),
      // 12. Modal-Instrumental (durch + Akkusativ)
      const AdverbialNominalizationModel(
        id: 'NOM-4970-12',
        relation: AdverbialCompressionRelation.modalInstrumentalCompression,
        governedCase: PrepositionGovernedCase.accusativeStrict,
        domain: CommunicativeDomain.renewableEnergyGrid,
        verbalSubordinateClause: 'Indem man den Anstellwinkel der Rotorblätter kontinuierlich anpasst',
        compressedNominalPhrase: 'Durch kontinuierliche Anpassung des Anstellwinkels der Rotorblätter',
        fullNominalizedSentence:
            'Durch kontinuierliche Anpassung des Anstellwinkels der Rotorblätter lässt sich die Nennleistung auch bei Sturm konstant halten.',
        fullVerbalizedSentence:
            'Indem man den Anstellwinkel der Rotorblätter kontinuierlich anpasst, lässt sich die Nennleistung auch bei Sturm konstant halten.',
        compressionPreposition: 'durch',
        nominalizationSuffixOrForm: 'Akkusativ ohne Artikel ("durch kontinuierliche Anpassung")',
        syntacticTransformationRuleGerman:
            'Modales "indem" komprimiert zu "durch + Akkusativ"; der Akkusativ-Gegenstand ("den Anstellwinkel") wird zum Genitivattribut.',
        syntacticTransformationRuleArabic:
            'تحويل أداة الوسيلة (indem) إلى (durch + Akkusativ) مع نقل المفعول به إلى مضاف إليه (زاوية الشفرات).',
      ),
      // 13. Modal-Instrumental (mittels + Genitiv)
      const AdverbialNominalizationModel(
        id: 'NOM-4970-13',
        relation: AdverbialCompressionRelation.modalInstrumentalCompression,
        governedCase: PrepositionGovernedCase.genitiveStrict,
        domain: CommunicativeDomain.aerospaceAndAviation,
        verbalSubordinateClause: 'Dadurch dass man einen Laser-Doppler-Vibrometer einsetzt',
        compressedNominalPhrase: 'Mittels des Einsatzes eines Laser-Doppler-Vibrometers',
        fullNominalizedSentence:
            'Mittels hochauflösender Laser-Doppler-Vibrometrie werden Strukturvibrationen berührungslos im Windkanal erfasst.',
        fullVerbalizedSentence:
            'Dadurch dass man hochauflösende Laser-Doppler-Vibrometrie einsetzt, werden Strukturvibrationen berührungslos erfasst.',
        compressionPreposition: 'mittels',
        nominalizationSuffixOrForm: 'Genitiv-Präposition ("mittels" + Genitiv)',
        syntacticTransformationRuleGerman:
            'Instrumentale Nebensätze mit "dadurch, dass" verdichten sich über "mittels + Genitiv".',
        syntacticTransformationRuleArabic:
            'استخدام حرف الجر الأداتي (mittels + Genitiv) لتكثيف آلية القياس الليزري دون تلامس.',
      ),
      // 14. Kausal (aufgrund + Genitiv)
      const AdverbialNominalizationModel(
        id: 'NOM-4970-14',
        relation: AdverbialCompressionRelation.causalCompression,
        governedCase: PrepositionGovernedCase.genitiveStrict,
        domain: CommunicativeDomain.maritimeLogistics,
        verbalSubordinateClause: 'Da der Tiefgang des Großcontainerschiffs zugenommen hat',
        compressedNominalPhrase: 'Aufgrund des zugenommenen Tiefgangs des Großcontainerschiffs',
        fullNominalizedSentence:
            'Aufgrund des größeren Tiefgangs des Großcontainerschiffs musste die Fahrrinne der Elbe ausgebaggert werden.',
        fullVerbalizedSentence:
            'Da der Tiefgang des Großcontainerschiffs größer geworden ist, musste die Fahrrinne der Elbe ausgebaggert werden.',
        compressionPreposition: 'aufgrund',
        nominalizationSuffixOrForm: 'Genitiv ("aufgrund des größeren Tiefgangs")',
        syntacticTransformationRuleGerman:
            'Kausale "da"-Sätze im Vorfeld werden normgerecht mit "aufgrund + Genitiv" in Fachtexten komprimiert.',
        syntacticTransformationRuleArabic:
            'تكثيف جملة السبب المعروف مسبقاً (da) إلى (aufgrund + Genitiv) لتوضيح سبب تعميق المجرى الملاحي.',
      ),
      // 15. Konditional (im Falle + Genitiv)
      const AdverbialNominalizationModel(
        id: 'NOM-4970-15',
        relation: AdverbialCompressionRelation.conditionalCompression,
        governedCase: PrepositionGovernedCase.genitiveStrict,
        domain: CommunicativeDomain.industrialRobotics,
        verbalSubordinateClause: 'Falls der Feldbus spontan ausfallen sollte',
        compressedNominalPhrase: 'Im Falle eines spontanen Ausfalls des Feldbusses',
        fullNominalizedSentence:
            'Im Falle eines spontanen Ausfalls des Feldbusses verharren alle Servoachsen sicher in ihrer mechanischen Haltebremse.',
        fullVerbalizedSentence:
            'Falls der Feldbus spontan ausfallen sollte, verharren alle Servoachsen sicher in ihrer mechanischen Haltebremse.',
        compressionPreposition: 'im Falle',
        nominalizationSuffixOrForm: 'Komplexe Präpositionalphrase "im Falle + Genitiv"',
        syntacticTransformationRuleGerman:
            'Eventual-Konditionalsätze ("falls ... sollte") werden in Notfallhandbüchern zu "im Falle + Genitiv" verdichtet.',
        syntacticTransformationRuleArabic:
            'صياغة طوارئ قياسية: تحويل الشرط الاحتمالي (falls) إلى (im Falle + Genitiv) لوصف إيقاف المحاور الآمن.',
      ),
      // 16. Modal (unter + Dativ: unter Anwendung von)
      const AdverbialNominalizationModel(
        id: 'NOM-4970-16',
        relation: AdverbialCompressionRelation.modalInstrumentalCompression,
        governedCase: PrepositionGovernedCase.dativeStrict,
        domain: CommunicativeDomain.civilInfrastructure,
        verbalSubordinateClause: 'Indem man ein hochauflösendes Georadar anwendet',
        compressedNominalPhrase: 'Unter Anwendung eines hochauflösenden Georadars',
        fullNominalizedSentence:
            'Unter Anwendung eines hochauflösenden Georadars kartierten die Geotechniker Hohlräume unter der Trasse.',
        fullVerbalizedSentence:
            'Indem sie ein hochauflösendes Georadar anwandten, kartierten die Geotechniker Hohlräume unter der Trasse.',
        compressionPreposition: 'unter Anwendung',
        nominalizationSuffixOrForm: 'Präpositionalphrase "unter + Dativ" + Genitivattribut',
        syntacticTransformationRuleGerman:
            'Verfahrensangabe: "unter Anwendung + Genitiv" ersetzt modale "indem"-Konstruktionen.',
        syntacticTransformationRuleArabic:
            'تعبير إجرائي مهني (تحت تطبيق/باستخدام رادار الاختراق الأرضي) يختزل الجملة الكيفية في صيغة اسمية دقيقة.',
      ),
    ]);
  }

  List<AdverbialNominalizationModel> getByRelation(AdverbialCompressionRelation relation) =>
      _catalog.where((m) => m.relation == relation).toList();

  List<AdverbialNominalizationModel> getByCase(PrepositionGovernedCase governedCase) =>
      _catalog.where((m) => m.governedCase == governedCase).toList();

  List<AdverbialNominalizationModel> getByDomain(CommunicativeDomain domain) =>
      _catalog.where((m) => m.domain == domain).toList();

  /// Validates case governance, Genitiv-vs-Dativ usage, and V2 inversion after fronted PP.
  NominalizationValidationResult validateCompression({
    required PrepositionGovernedCase expectedCase,
    required bool isNounPhraseInExpectedCase,
    required bool isMainClauseVerbSecondInverted,
    required bool retainsAllSemanticArguments,
  }) {
    final List<String> issues = [];
    final List<String> notes = [];

    if (!isNounPhraseInExpectedCase) {
      issues.add(
          'Rektionsfehler: Die komprimierte Präpositionalphrase verlangt zwingend ${expectedCase.de}. Umgangssprachliches Ausweichen (z. B. Dativ nach "wegen/trotz" in Fachtexten) ist nicht normgerecht.');
    } else {
      notes.add('Rektion normgerecht: ${expectedCase.de} präzise eingehalten.');
    }

    if (!isMainClauseVerbSecondInverted) {
      issues.add(
          'Topologie-Fehler: Rückt die komprimierte Präpositionalphrase ins Vorfeld, muss das finite Verb im Hauptsatz zwingend an Position II (Inversion vor das Subjekt) stehen.');
    } else {
      notes.add('Topologisch normgerecht: V2-Inversion nach Vorfeld-Präpositionalphrase gesichert.');
    }

    if (!retainsAllSemanticArguments) {
      issues.add(
          'Informationsverlust: Bei der Nominalisierung müssen alle Aktanten (z. B. Subjekt als Genitivattribut) vollständig erhalten bleiben.');
    } else {
      notes.add('Semantisch äquivalent: Vollständiger Erhalt aller logischen Argumente.');
    }

    return NominalizationValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      syntacticNotes: notes,
    );
  }

  Map<String, dynamic> generateTelemetrySnapshot() {
    return {
      'totalExemplars': _catalog.length,
      'relationDistribution': {
        for (var r in AdverbialCompressionRelation.values)
          r.name: _catalog.where((m) => m.relation == r).length,
      },
      'caseDistribution': {
        for (var c in PrepositionGovernedCase.values)
          c.name: _catalog.where((m) => m.governedCase == c).length,
      },
      'domainDistribution': {
        for (var d in CommunicativeDomain.values)
          d.name: _catalog.where((m) => m.domain == d).length,
      },
      'cefrLevel': 'CEFR C1-C2 Masterclass Adverbial-to-Nominal Compression',
      'engineVersion': '1.0.0+subsystem1804',
    };
  }
}
