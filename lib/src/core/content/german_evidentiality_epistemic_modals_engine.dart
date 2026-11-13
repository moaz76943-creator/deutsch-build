import 'dart:collection';

/// Evidential source category and speaker epistemological stance.
enum EvidentialityType {
  hearsayAttribution(
    'Fremdaussage & Gerücht (sollen)',
    'النقل عن الغير / السماع الموثق أو المتداول (sollen)',
    'Der Sprecher distanziert sich von der Information und verweist auf Berichte Dritter: "Das Bauteil soll zertifiziert sein."',
  ),
  subjectClaim(
    'Behauptung des Subjekts mit Sprecherskepsis (wollen)',
    'ادعاء الفاعل لنفسه مع تشكيك المتحدث أو تحفظه (wollen)',
    'Das Subjekt behauptet eine Tatsache über sich selbst; der Sprecher zweifelt daran: "Der Lieferant will die Toleranzen eingehalten haben."',
  ),
  inferentialDeduction(
    'Logische Schlussfolgerung & Evidenz (müssen / dürfte / könnte)',
    'الاستنتاج المنطقي المبرهن بالأدلة والقرائن التقنية (müssen / dürfte)',
    'Aufgrund messbarer Parameter schließt der Ingenieur mit hoher Wahrscheinlichkeit: "Die Druckleitung muss geborsten sein."',
  ),
  imminentHazardRisk(
    'Drohende Gefahr & Systemversagen (drohen zu + Infinitiv)',
    'الخطر المحدق والإنذار بانهيار المنظومة (drohen zu + Infinitiv)',
    'Kündigt eine unmittelbar bevorstehende negative technische Entwicklung an: "Der Transformator droht zu überhitzen."',
  ),
  auspiciousPromise(
    'Günstige Prognose & Effizienzversprechen (versprechen zu + Infinitiv)',
    'المؤشرات الإيجابية الواعدة بالارتقاء بالأداء (versprechen zu + Infinitiv)',
    'Objektive Messdaten oder Simulationen deuten auf signifikante Verbesserungen hin: "Die Beschichtung verspricht den Verschleiß zu halbieren."',
  ),
  observationalAppearance(
    'Sensorische Evidenz & visueller Befund (scheinen zu + Infinitiv)',
    'المشاهدة الظاهرية المستندة للرصد الميداني أو الحسي (scheinen zu + Infinitiv)',
    'Drückt eine begründete Vermutung auf Basis unmittelbarer Wahrnehmung aus: "Die Naht scheint dem Schweißdruck zu genügen."',
  );

  final String deTitle;
  final String arTitle;
  final String grammaticalDescription;
  const EvidentialityType(this.deTitle, this.arTitle, this.grammaticalDescription);
}

/// Temporal aspect of the epistemic complement.
enum EpistemicInfinitiveAspect {
  infinitiveIActive('Infinitiv I Aktiv (Gegenwart / Zukunft)', 'مصدر أول بسيط مبني للمعلوم'),
  infinitiveIPassive('Infinitiv I Passiv (Gegenwart Vorgang)', 'مصدر أول للمجهول'),
  infinitiveIIActive('Infinitiv II Aktiv (Vergangenheit)', 'مصدر مركب ماض مبني للمعلوم'),
  infinitiveIIPassive('Infinitiv II Passiv (Vergangenheit Vorgang)', 'مصدر مركب ماض للمجهول');

  final String de;
  final String ar;
  const EpistemicInfinitiveAspect(this.de, this.ar);
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

/// Structural model of an evidential epistemic construction.
class EvidentialityEpistemicModel {
  final String id;
  final String governingSemiAuxiliary;
  final EvidentialityType evidentialityType;
  final EpistemicInfinitiveAspect infinitiveAspect;
  final CommunicativeDomain domain;
  final String fullGermanSentence;
  final String epistemicCarrierPhrase;
  final String nonEpistemicParaphrase;
  final String speakerStanceGerman;
  final String speakerStanceArabic;
  final double speakerConfidenceDegree; // 0.0 (extreme skepticism) to 1.0 (certainty)
  final String technicalEvidenceBasis;

  const EvidentialityEpistemicModel({
    required this.id,
    required this.governingSemiAuxiliary,
    required this.evidentialityType,
    required this.infinitiveAspect,
    required this.domain,
    required this.fullGermanSentence,
    required this.epistemicCarrierPhrase,
    required this.nonEpistemicParaphrase,
    required this.speakerStanceGerman,
    required this.speakerStanceArabic,
    required this.speakerConfidenceDegree,
    required this.technicalEvidenceBasis,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'governingSemiAuxiliary': governingSemiAuxiliary,
    'evidentialityType': evidentialityType.name,
    'infinitiveAspect': infinitiveAspect.name,
    'domain': domain.name,
    'fullGermanSentence': fullGermanSentence,
    'epistemicCarrierPhrase': epistemicCarrierPhrase,
    'nonEpistemicParaphrase': nonEpistemicParaphrase,
    'speakerStanceGerman': speakerStanceGerman,
    'speakerStanceArabic': speakerStanceArabic,
    'speakerConfidenceDegree': speakerConfidenceDegree,
    'technicalEvidenceBasis': technicalEvidenceBasis,
  };
}

/// Validation result for evidential structures.
class EvidentialValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<String> normativeNotes;

  const EvidentialValidationResult({
    required this.isValid,
    required this.issues,
    required this.normativeNotes,
  });
}

/// Core Engine managing German Evidentiality & Epistemic Modals.
class GermanEvidentialityEpistemicModalsEngine {
  final List<EvidentialityEpistemicModel> _catalog = [];

  GermanEvidentialityEpistemicModalsEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<EvidentialityEpistemicModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    _catalog.addAll([
      const EvidentialityEpistemicModel(
        id: 'EVID-4956-01',
        governingSemiAuxiliary: 'sollen',
        evidentialityType: EvidentialityType.hearsayAttribution,
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIIActive,
        domain: CommunicativeDomain.aerospaceAndAviation,
        fullGermanSentence:
            'Das Hilfstriebwerk soll vor dem transatlantischen Start eine Druckanomalie aufgewiesen haben.',
        epistemicCarrierPhrase: 'soll ... aufgewiesen haben',
        nonEpistemicParaphrase:
            'Man berichtet / Es heißt, dass das Hilfstriebwerk eine Druckanomalie aufwies (der Sprecher distanziert sich).',
        speakerStanceGerman:
            'Distanzierte Wiedergabe eines Wartungsberichts ohne persönliche Bürgschaft für dessen Richtigkeit.',
        speakerStanceArabic:
            'نقل لتقرير فني خارجي عن حدوث خلل ضغط في المحرك المساعد مع تجريد المتحدث من مسؤولية الجزم بصحته.',
        speakerConfidenceDegree: 0.50,
        technicalEvidenceBasis: 'Mündlicher Zwischenbericht der Bodenabfertigung am Zielflughafen.',
      ),
      const EvidentialityEpistemicModel(
        id: 'EVID-4956-02',
        governingSemiAuxiliary: 'wollen',
        evidentialityType: EvidentialityType.subjectClaim,
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIIActive,
        domain: CommunicativeDomain.materialScience,
        fullGermanSentence:
            'Der Werkstoffhersteller will die Verbundwerkstoffe nach ISO 9001 zertifiziert haben.',
        epistemicCarrierPhrase: 'will ... zertifiziert haben',
        nonEpistemicParaphrase:
            'Der Hersteller behauptet, dass er die Werkstoffe zertifiziert habe, was der Prüfingenieur anzweifelt.',
        speakerStanceGerman:
            'Skeptische Zurückweisung einer Eigenbehauptung des Lieferanten bis zur Vorlage der Siegel.',
        speakerStanceArabic:
            'إيراد ادعاء المصنع بحصوله على شهادة الجودة مع إبراز تشكيك المهندس المدقق بانتظار الوثائق الرسمية.',
        speakerConfidenceDegree: 0.25,
        technicalEvidenceBasis: 'Werbeprospekt des Zulieferers ohne beigefügte Prüfzertifikate.',
      ),
      const EvidentialityEpistemicModel(
        id: 'EVID-4956-03',
        governingSemiAuxiliary: 'drohen zu',
        evidentialityType: EvidentialityType.imminentHazardRisk,
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIActive,
        domain: CommunicativeDomain.renewableEnergyGrid,
        fullGermanSentence:
            'Der Wechselrichter der Solarfarm droht infolge der Netzüberspannung zu kollabieren.',
        epistemicCarrierPhrase: 'droht ... zu kollabieren',
        nonEpistemicParaphrase:
            'Es besteht die akute Gefahr, dass der Wechselrichter durch Überspannung zerstört wird.',
        speakerStanceGerman:
            'Dringliche Alarmierung vor einem unmittelbar bevorstehenden technischen Totalschaden.',
        speakerStanceArabic:
            'إنذار هندسي عاجل يحذر من الانهيار الوشيك لمحوّل مزرعة الطاقة الشمسية بفعل فرط الجهد الكهربائي.',
        speakerConfidenceDegree: 0.90,
        technicalEvidenceBasis: 'Sensordaten zeigen einen sprunghaften Temperatur- und Stromanstieg.',
      ),
      const EvidentialityEpistemicModel(
        id: 'EVID-4956-04',
        governingSemiAuxiliary: 'versprechen zu',
        evidentialityType: EvidentialityType.auspiciousPromise,
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIActive,
        domain: CommunicativeDomain.industrialRobotics,
        fullGermanSentence:
            'Die neue bürstenlose Servomotor-Generation verspricht den Energieverbrauch um 18% zu senken.',
        epistemicCarrierPhrase: 'verspricht ... zu senken',
        nonEpistemicParaphrase:
            'Alle bisherigen Laborprüfungen weisen darauf hin, dass der Energieverbrauch um 18% sinken wird.',
        speakerStanceGerman:
            'Fundierter Optimismus gestützt auf reproduzierbare Messreihen im Prototypenbau.',
        speakerStanceArabic:
            'تفاؤل علمي مدروس ومسنود بتجارب المختبر يفيد بخفض استهلاك طاقة المحركات بنسبة 18%.',
        speakerConfidenceDegree: 0.85,
        technicalEvidenceBasis: 'Prüfstandsdaten über 1000 kontinuierliche Lastzyklen.',
      ),
      const EvidentialityEpistemicModel(
        id: 'EVID-4956-05',
        governingSemiAuxiliary: 'scheinen zu',
        evidentialityType: EvidentialityType.observationalAppearance,
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIActive,
        domain: CommunicativeDomain.civilInfrastructure,
        fullGermanSentence:
            'Der Brückenpfeiler scheint den dynamischen Schwingungen des Schwerlastverkehrs standzuhalten.',
        epistemicCarrierPhrase: 'scheint ... standzuhalten',
        nonEpistemicParaphrase:
            'Dem äußeren Befund und den ersten Dehnungsstreifen nach hält der Pfeiler den Schwingungen stand.',
        speakerStanceGerman:
            'Vorsichtig positive Einschätzung basierend auf aktuellen Beobachtungen vor Ort.',
        speakerStanceArabic:
            'تقييم ظاهري حذر مدعوم بالمشاهدة الميدانية يشير إلى صمود دعامة الجسر أمام الاهتزازات الديناميكية.',
        speakerConfidenceDegree: 0.70,
        technicalEvidenceBasis: 'Visuelle Inspektion und piezoelektrische Rissüberwachung.',
      ),
      const EvidentialityEpistemicModel(
        id: 'EVID-4956-06',
        governingSemiAuxiliary: 'müssen',
        evidentialityType: EvidentialityType.inferentialDeduction,
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIIActive,
        domain: CommunicativeDomain.maritimeLogistics,
        fullGermanSentence:
            'Das Ruderblatt des Frachters muss während der Passage der Untiefe den Grund berührt haben.',
        epistemicCarrierPhrase: 'muss ... berührt haben',
        nonEpistemicParaphrase:
            'Aus den mechanischen Verformungen lässt sich zwingend folgern, dass eine Grundberührung stattfand.',
        speakerStanceGerman:
            'Nahezu zweifelsfreie Rekonstruktion eines nautischen Schadensereignisses aus Folgeschäden.',
        speakerStanceArabic:
            'استنتاج قطعي شبه يقيني بأن زعنفة التوجيه اصطدمت بالقاع البحري نظراً للتشوهات الميكانيكية الظاهرة.',
        speakerConfidenceDegree: 0.95,
        technicalEvidenceBasis: 'Tiefe Schleifspuren und Sedimentanhaftungen am Schiffsrumpf.',
      ),
      const EvidentialityEpistemicModel(
        id: 'EVID-4956-07',
        governingSemiAuxiliary: 'dürfte',
        evidentialityType: EvidentialityType.inferentialDeduction,
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIActive,
        domain: CommunicativeDomain.materialScience,
        fullGermanSentence:
            'Die Zugfestigkeit der Graphen-Matrix dürfte den Richtwert von 1200 Megapascal übertreffen.',
        epistemicCarrierPhrase: 'dürfte ... übertreffen',
        nonEpistemicParaphrase:
            'Es ist sehr wahrscheinlich, dass die Zugfestigkeit über 1200 MPa liegt.',
        speakerStanceGerman:
            'Hohe Wahrscheinlichkeit abgeleitet aus Molekulardynamik-Simulationen.',
        speakerStanceArabic:
            'ترجيح تقني واثق مبني على محاكاة الديناميكا الجزيئية بأن قوة الشد ستتجاوز 1200 ميغاباسكال.',
        speakerConfidenceDegree: 0.80,
        technicalEvidenceBasis: 'Finite-Elemente-Berechnung und thermochemische Modellierung.',
      ),
      const EvidentialityEpistemicModel(
        id: 'EVID-4956-08',
        governingSemiAuxiliary: 'sollen',
        evidentialityType: EvidentialityType.hearsayAttribution,
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIIPassive,
        domain: CommunicativeDomain.civilInfrastructure,
        fullGermanSentence:
            'Die Spannbetonträger sollen vor dem Einbau auf Mikrorisse ultraschallgeprüft worden sein.',
        epistemicCarrierPhrase: 'sollen ... geprüft worden sein',
        nonEpistemicParaphrase:
            'Es wird behauptet/vorgegeben, dass die Träger ultraschallgeprüft wurden.',
        speakerStanceGerman:
            'Wiedergabe von Lieferantenprotokollen im Passiv Perfekt ohne eigene Endabnahme.',
        speakerStanceArabic:
            'نقل مبني للمجهول لما ورد في أوراق المقاول بأن كتل الخرسانة خضعت لفحص الموجات فوق الصوتية.',
        speakerConfidenceDegree: 0.50,
        technicalEvidenceBasis: 'Lieferscheinvermerk des Subunternehmens.',
      ),
      const EvidentialityEpistemicModel(
        id: 'EVID-4956-09',
        governingSemiAuxiliary: 'drohen zu',
        evidentialityType: EvidentialityType.imminentHazardRisk,
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIActive,
        domain: CommunicativeDomain.aerospaceAndAviation,
        fullGermanSentence:
            'Die Leitschaufel der Niederdruckturbine droht durch Schwingungsrisskorrosion abzureißen.',
        epistemicCarrierPhrase: 'droht ... abzureißen',
        nonEpistemicParaphrase:
            'Es besteht unmittelbare Abreißgefahr der Turbinenschaufel durch Korrosion.',
        speakerStanceGerman:
            'Höchste Dringlichkeitsstufe: Notwendigkeit eines sofortigen Triebwerkstopps.',
        speakerStanceArabic:
            'تحذير من الدرجة القصوى: خطر انفصال شفرة التوربين نتيجة التآكل الاهتزازي مما يستوجب إيقاف المحرك.',
        speakerConfidenceDegree: 0.92,
        technicalEvidenceBasis: 'Endoskopische Triebwerksinspektion offenbart Mikroriss am Schaufelfuß.',
      ),
      const EvidentialityEpistemicModel(
        id: 'EVID-4956-10',
        governingSemiAuxiliary: 'wollen',
        evidentialityType: EvidentialityType.subjectClaim,
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIActive,
        domain: CommunicativeDomain.industrialRobotics,
        fullGermanSentence:
            'Der Softwareentwickler will den Fehler in der Kinematik-Schleife bereits behoben haben.',
        epistemicCarrierPhrase: 'will ... behoben haben',
        nonEpistemicParaphrase:
            'Der Programmierer behauptet, den Fehler beseitigt zu haben, was im Integrationstest noch scheitert.',
        speakerStanceGerman:
            'Kritische Skepsis gegenüber der Aussage des Entwicklers angesichts fortbestehender Ausreißer.',
        speakerStanceArabic:
            'تحفظ نقدي على زعم مطور البرمجيات بإصلاح خطأ الحركية في ظل استمرار تعثر الاختبارات العملية.',
        speakerConfidenceDegree: 0.20,
        technicalEvidenceBasis: 'Automatisierte CI/CD-Pipelines weisen nach wie vor Abweichungen auf.',
      ),
      const EvidentialityEpistemicModel(
        id: 'EVID-4956-11',
        governingSemiAuxiliary: 'versprechen zu',
        evidentialityType: EvidentialityType.auspiciousPromise,
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIActive,
        domain: CommunicativeDomain.renewableEnergyGrid,
        fullGermanSentence:
            'Die neuartige Festkörperbatterie verspricht die Zyklenfestigkeit von Heimspeichern zu verdreifachen.',
        epistemicCarrierPhrase: 'verspricht ... zu verdreifachen',
        nonEpistemicParaphrase:
            'Die Daten weisen darauf hin, dass die Zyklenfestigkeit sich verdreifachen wird.',
        speakerStanceGerman:
            'Prognose gestützt auf elektrochemische Impedanzspektroskopie.',
        speakerStanceArabic:
            'توقع علمي رصين مبني على قياسات المقاومة الكهروكيميائية بمضاعفة عمر البطاريات الصلبة 3 مرات.',
        speakerConfidenceDegree: 0.88,
        technicalEvidenceBasis: 'Verifizierte Laborergebnisse renommierter Materialprüfanstalten.',
      ),
      const EvidentialityEpistemicModel(
        id: 'EVID-4956-12',
        governingSemiAuxiliary: 'könnte',
        evidentialityType: EvidentialityType.inferentialDeduction,
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIIActive,
        domain: CommunicativeDomain.maritimeLogistics,
        fullGermanSentence:
            'Das Schmieröl der Hauptantriebswelle könnte durch Kondenswasser kontaminiert worden sein.',
        epistemicCarrierPhrase: 'könnte ... kontaminiert worden sein',
        nonEpistemicParaphrase:
            'Es ist möglich, dass Kondenswasser das Schmieröl verunreinigt hat.',
        speakerStanceGerman:
            'Hypothetische Ursachenanalyse im Rahmen einer Fehlerbaumanalyse.',
        speakerStanceArabic:
            'فرضية تشغيلية محتملة ضمن شجرة استكشاف الأعطال تفيد بتلوث زيت العمود المرفقي بماء التكثف.',
        speakerConfidenceDegree: 0.45,
        technicalEvidenceBasis: 'Trübung des Öls im Schauglas der Hauptmaschine.',
      ),
      const EvidentialityEpistemicModel(
        id: 'EVID-4956-13',
        governingSemiAuxiliary: 'scheinen zu',
        evidentialityType: EvidentialityType.observationalAppearance,
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIIPassive,
        domain: CommunicativeDomain.aerospaceAndAviation,
        fullGermanSentence:
            'Die Avionik-Module scheinen während des Transports erschütterungsgeschützt verpackt worden zu sein.',
        epistemicCarrierPhrase: 'scheinen ... verpackt worden zu sein',
        nonEpistemicParaphrase:
            'Der unversehrte Zustand der Plomben lässt darauf schließen, dass die Verpackung vorschriftsmäßig war.',
        speakerStanceGerman:
            'Befundbasierte Schlussfolgerung nach Begutachtung der Wareneingangsbehälter.',
        speakerStanceArabic:
            'استنتاج مبني على سلامة الأختام يفيد بأن وحدات الملاحة الجوية غُلفت بطريقة ماصة للصدمات.',
        speakerConfidenceDegree: 0.75,
        technicalEvidenceBasis: 'Schockindikatoren an den Versandkisten blieben unberührt.',
      ),
      const EvidentialityEpistemicModel(
        id: 'EVID-4956-14',
        governingSemiAuxiliary: 'sollen',
        evidentialityType: EvidentialityType.hearsayAttribution,
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIActive,
        domain: CommunicativeDomain.renewableEnergyGrid,
        fullGermanSentence:
            'Die Geothermie-Tiefenbohrung soll im kommenden Quartal die Heißwasserschicht in 4000 m Tiefe erreichen.',
        epistemicCarrierPhrase: 'soll ... erreichen',
        nonEpistemicParaphrase:
            'Laut Projektplan und Konsortialberichten wird erwartet, dass die Schicht erreicht wird.',
        speakerStanceGerman:
            'Mitteilung eines geplanten Meilensteins ohne persönliche Haftung für geologische Überraschungen.',
        speakerStanceArabic:
            'نقل لجدول أعمال مشروع الطاقة الحرارية الأرضية بالوصول لطبقة المياه الساخنة دون ضمان المفاجآت الصخرية.',
        speakerConfidenceDegree: 0.60,
        technicalEvidenceBasis: 'Offizieller Quartalsbericht des Bohrkonsortiums.',
      ),
      const EvidentialityEpistemicModel(
        id: 'EVID-4956-15',
        governingSemiAuxiliary: 'wollen',
        evidentialityType: EvidentialityType.subjectClaim,
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIIActive,
        domain: CommunicativeDomain.civilInfrastructure,
        fullGermanSentence:
            'Die Rohbau-Firma will den Aushubplan zentimetergenau eingehalten haben.',
        epistemicCarrierPhrase: 'will ... eingehalten haben',
        nonEpistemicParaphrase:
            'Die Firma versichert, der Plan sei exakt befolgt worden; die Tachymetermessung zeigt Abweichungen.',
        speakerStanceGerman:
            'Widerspruch zwischen der Behauptung des Bauleiters und den lasergestützten Vermessungsdaten.',
        speakerStanceArabic:
            'إبراز التناقض بين زعم مقاول الحفريات بالدقة المطلقة ونتائج المسح الليزري التي تفضح التجاوزات.',
        speakerConfidenceDegree: 0.15,
        technicalEvidenceBasis: 'Tachymetrisches 3D-Geländemodell belegt 15 cm Abweichung.',
      ),
      const EvidentialityEpistemicModel(
        id: 'EVID-4956-16',
        governingSemiAuxiliary: 'drohen zu',
        evidentialityType: EvidentialityType.imminentHazardRisk,
        infinitiveAspect: EpistemicInfinitiveAspect.infinitiveIActive,
        domain: CommunicativeDomain.materialScience,
        fullGermanSentence:
            'Die nanostrukturierte Passivierungsschicht droht unter salzhaltiger Heißdampfatmosphäre abzublättern.',
        epistemicCarrierPhrase: 'droht ... abzublättern',
        nonEpistemicParaphrase:
            'Es droht akuter Schichtverlust durch feucht-chemische Korrosion.',
        speakerStanceGerman:
            'Vorwarnung vor Materialermüdung und Funktionsverlust der Schutzschicht.',
        speakerStanceArabic:
            'تحذير من تفتت طبقة الخمول النانوية الواقية تحت تأثير بخار الماء الحار المشبع بالأملاح.',
        speakerConfidenceDegree: 0.89,
        technicalEvidenceBasis: 'Salzsprühnebeltest nach DIN EN ISO 9227.',
      ),
    ]);
  }

  List<EvidentialityEpistemicModel> getByType(EvidentialityType type) =>
      _catalog.where((e) => e.evidentialityType == type).toList();

  List<EvidentialityEpistemicModel> getByDomain(CommunicativeDomain domain) =>
      _catalog.where((e) => e.domain == domain).toList();

  List<EvidentialityEpistemicModel> getBySemiAuxiliary(String auxiliary) =>
      _catalog.where((e) => e.governingSemiAuxiliary.toLowerCase() == auxiliary.toLowerCase()).toList();

  /// Validates evidential grammar and topological syntax.
  EvidentialValidationResult validateEvidentialConstruction({
    required String governingAuxiliary,
    required EpistemicInfinitiveAspect infinitiveAspect,
    required bool containsZuParticle,
    required bool isThirdPartySubject,
  }) {
    final List<String> issues = [];
    final List<String> notes = [];

    final aux = governingAuxiliary.toLowerCase();

    // Rule 1: Modal verbs (sollen, wollen, müssen, dürfen, können) NEVER take "zu"
    final modalVerbs = ['sollen', 'wollen', 'müssen', 'dürfen', 'können', 'dürfte', 'könnte'];
    if (modalVerbs.contains(aux)) {
      if (containsZuParticle) {
        issues.add('Grammatikfehler: Das Modalverb "$aux" verlangt den reinen Infinitiv ohne "zu".');
      } else {
        notes.add('Normkonform: Reiner Infinitiv beim Modalverb "$aux".');
      }
    }

    // Rule 2: Semi-auxiliaries (scheinen, drohen, versprechen) OBLIGATORILY require "zu"
    final semiAuxiliaries = ['scheinen', 'scheinen zu', 'drohen', 'drohen zu', 'versprechen', 'versprechen zu'];
    if (semiAuxiliaries.any((s) => aux.contains(s))) {
      if (!containsZuParticle) {
        issues.add('Grammatikfehler: Das Halbmodalverb "$aux" erfordert zwingend den Infinitiv mit "zu".');
      } else {
        notes.add('Normkonform: Infinitiv mit "zu" beim Halbmodalverb "$aux".');
      }
    }

    // Rule 3: Subjectivity rules for "wollen" vs "sollen"
    if (aux == 'wollen' && isThirdPartySubject) {
      notes.add('Pragmatische Eigenheit: Subjektives "wollen" drückt aus, dass das Subjekt selbst die Behauptung aufstellt ("Er will es getan haben").');
    }

    return EvidentialValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      normativeNotes: notes,
    );
  }

  Map<String, dynamic> generateTelemetrySnapshot() {
    return {
      'totalExemplars': _catalog.length,
      'typeDistribution': {
        for (var t in EvidentialityType.values)
          t.name: _catalog.where((e) => e.evidentialityType == t).length,
      },
      'domainDistribution': {
        for (var d in CommunicativeDomain.values)
          d.name: _catalog.where((e) => e.domain == d).length,
      },
      'infinitiveAspectsCount': {
        for (var a in EpistemicInfinitiveAspect.values)
          a.name: _catalog.where((e) => e.infinitiveAspect == a).length,
      },
      'averageConfidenceDegree':
          _catalog.map((e) => e.speakerConfidenceDegree).reduce((a, b) => a + b) / _catalog.length,
      'cefrLevel': 'CEFR C1-C2 Masterclass Evidentiality',
      'engineVersion': '1.0.0+subsystem1790',
    };
  }
}
