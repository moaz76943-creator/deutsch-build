import 'dart:collection';

/// Classification of temporal relations in German technical subordination.
enum TemporalRelationType {
  anteriorityVorzeitigkeit(
    'Vorzeitigkeit (nachdem, sobald, sowie)',
    'الأسبقية الزمنية (الحدث في الجملة الفرعية وقع وانتهى قبل حدث الجملة الرئيسية)',
    'Erzwingt strenge Consecutio Temporum: Plusquamperfekt im Nebensatz bei Präteritum im Hauptsatz; Perfekt im Nebensatz bei Präsens/Futur im Hauptsatz.',
  ),
  simultaneityGleichzeitigkeit(
    'Gleichzeitigkeit (während, solange, indem)',
    'التزامن والمقارنة الزمنية (وقوع الحدثين معاً في نفس الحقبة الزمنية)',
    'Erfordert Tempusidentität: Beide Teilsätze stehen im selben Tempus (Präteritum/Präteritum oder Präsens/Präsens).',
  ),
  posteriorityNachzeitigkeit(
    'Nachzeitigkeit (bevor, ehe)',
    'اللاحقية الزمنية (الحدث في الجملة الفرعية يقع بعد إنجاز الجملة الرئيسية)',
    'Der Hauptsatz vollzieht sich zeitlich vor dem Nebensatz. Im Deutschen steht der Nebensatz meist im Präsens oder Präteritum.',
  ),
  terminalBoundaryLimit(
    'Endpunkt-Terminierung (bis)',
    'الغاية والحد الزمني النهائي (استمرار الحدث الرئيسي حتى نقطة التوقف)',
    'Markiert die exakte zeitliche Abbruchgrenze eines kontinuierlichen Prozesses.',
  ),
  durationalConditionWindow(
    'Dauer-Konditionierung (solange)',
    'النافذة الزمنية المستمرة والشرطية (استمرار الفعل طالما استمر الظرف)',
    'Koppelt die Aufrechterhaltung des Hauptsatzgeschehens an die kontinuierliche Gültigkeit des Nebensatzes.',
  );

  final String deTitle;
  final String arTitle;
  final String grammaticalRules;
  const TemporalRelationType(this.deTitle, this.arTitle, this.grammaticalRules);
}

/// Permissible Consecutio Temporum (Zeitenfolge) tense combinations in German.
enum ConsecutioTemporumPair {
  pastAnteriority(
    'Vergangenheit Vorzeitigkeit (Plusquamperfekt + Präteritum)',
    'أسبقية ماضية صارمة (ماض تام في الفرعية + ماض بسيط في الرئيسية)',
  ),
  presentFutureAnteriority(
    'Gegenwart/Zukunft Vorzeitigkeit (Perfekt + Präsens/Futur)',
    'أسبقية حاضرة/مستقبلية (مضارع تام في الفرعية + مضارع/مستقبل في الرئيسية)',
  ),
  pastSimultaneity(
    'Vergangenheit Gleichzeitigkeit (Präteritum + Präteritum)',
    'تزامن ماضٍ متطابق (ماض بسيط في الفرعية + ماض بسيط في الرئيسية)',
  ),
  presentSimultaneity(
    'Gegenwart Gleichzeitigkeit (Präsens + Präsens)',
    'تزامن حاضر متطابق (مضارع في الفرعية + مضارع في الرئيسية)',
  ),
  posteriorityPresent(
    'Nachzeitigkeit Gegenwart (Präsens + Präsens/Imperativ)',
    'لاحقية حاضرة/أمرية (مضارع في الفرعية قبل الإجراء الرئيسي)',
  ),
  posteriorityPast(
    'Nachzeitigkeit Vergangenheit (Präteritum + Präteritum)',
    'لاحقية ماضية موثقة (ماض بسيط في الفرعية بعد إنجاز الإجراء)',
  );

  final String de;
  final String ar;
  const ConsecutioTemporumPair(this.de, this.ar);
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

/// Structural model of a German complex temporal subordination sentence.
class TemporalSubordinationModel {
  final String id;
  final TemporalRelationType temporalRelation;
  final ConsecutioTemporumPair consecutioPair;
  final String subordinator;
  final CommunicativeDomain domain;
  final String fullGermanSentence;
  final String subordinateClause;
  final String mainClause;
  final String aspectualAnchoringExplanationGerman;
  final String aspectualAnchoringExplanationArabic;
  final String safetySequenceRelevance;

  const TemporalSubordinationModel({
    required this.id,
    required this.temporalRelation,
    required this.consecutioPair,
    required this.subordinator,
    required this.domain,
    required this.fullGermanSentence,
    required this.subordinateClause,
    required this.mainClause,
    required this.aspectualAnchoringExplanationGerman,
    required this.aspectualAnchoringExplanationArabic,
    required this.safetySequenceRelevance,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'temporalRelation': temporalRelation.name,
    'consecutioPair': consecutioPair.name,
    'subordinator': subordinator,
    'domain': domain.name,
    'fullGermanSentence': fullGermanSentence,
    'subordinateClause': subordinateClause,
    'mainClause': mainClause,
    'aspectualAnchoringExplanationGerman': aspectualAnchoringExplanationGerman,
    'aspectualAnchoringExplanationArabic': aspectualAnchoringExplanationArabic,
    'safetySequenceRelevance': safetySequenceRelevance,
  };
}

/// Validation result for temporal sequence compliance.
class TemporalValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<String> grammarNotes;

  const TemporalValidationResult({
    required this.isValid,
    required this.issues,
    required this.grammarNotes,
  });
}

/// Core Engine managing German Temporal Subordination & Consecutio Temporum.
class GermanTemporalSubordinationAspectEngine {
  final List<TemporalSubordinationModel> _catalog = [];

  GermanTemporalSubordinationAspectEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<TemporalSubordinationModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    _catalog.addAll([
      // 1. nachdem (Past Anteriority: Plusquamperfekt + Präteritum)
      const TemporalSubordinationModel(
        id: 'TEMP-4960-01',
        temporalRelation: TemporalRelationType.anteriorityVorzeitigkeit,
        consecutioPair: ConsecutioTemporumPair.pastAnteriority,
        subordinator: 'nachdem',
        domain: CommunicativeDomain.renewableEnergyGrid,
        fullGermanSentence:
            'Nachdem der Primärtransformator redundant vom Hochspannungsnetz getrennt worden war, öffnete der Wartungsleiter die Erdungsschalter.',
        subordinateClause: 'Nachdem der Primärtransformator redundant vom Hochspannungsnetz getrennt worden war',
        mainClause: 'öffnete der Wartungsleiter die Erdungsschalter',
        aspectualAnchoringExplanationGerman:
            'Klassische Vorzeitigkeit in der Vergangenheit: Die Netzabschaltung muss vollendet sein (Plusquamperfekt Passiv), bevor die Erdung mechanisch schließt (Präteritum).',
        aspectualAnchoringExplanationArabic:
            'أسبقية ماضية ملزمة: يجب اكتمال عزل المحول عن شبكة الجهد العالي (ماض تام مبني للمجهول) قبل أن يفتح المشرف قواطع التأريض (ماض بسيط).',
        safetySequenceRelevance: 'Verhindert lebensgefährliche Lichtbögen durch strikte Einhaltung der 5 Sicherheitsregeln.',
      ),
      // 2. nachdem (Present/Future Anteriority: Perfekt + Präsens)
      const TemporalSubordinationModel(
        id: 'TEMP-4960-02',
        temporalRelation: TemporalRelationType.anteriorityVorzeitigkeit,
        consecutioPair: ConsecutioTemporumPair.presentFutureAnteriority,
        subordinator: 'nachdem',
        domain: CommunicativeDomain.aerospaceAndAviation,
        fullGermanSentence:
            'Nachdem die Triebwerksverschalung mit Drehmomentschlüsseln arretiert worden ist, beginnt die automatisierte Dichtigkeitsprüfung.',
        subordinateClause: 'Nachdem die Triebwerksverschalung mit Drehmomentschlüsseln arretiert worden ist',
        mainClause: 'beginnt die automatisierte Dichtigkeitsprüfung',
        aspectualAnchoringExplanationGerman:
            'Vorzeitigkeit im Präsensbereich: Vollendete Arretierung (Perfekt Passiv) als unabdingbare Voraussetzung für den Prüfstart (Präsens).',
        aspectualAnchoringExplanationArabic:
            'أسبقية في زمن الحاضر: التحقق من إحكام إغلاق غطاء المحرك بمفتاح العزم (مضارع تام) شرط انطلاق فحص التسريب الآلي (مضارع).',
        safetySequenceRelevance: 'Verhindert Druckverluste während des Prüflaufs im Flugzeughangar.',
      ),
      // 3. sobald (Instantaneous Anteriority: Perfekt + Präsens)
      const TemporalSubordinationModel(
        id: 'TEMP-4960-03',
        temporalRelation: TemporalRelationType.anteriorityVorzeitigkeit,
        consecutioPair: ConsecutioTemporumPair.presentFutureAnteriority,
        subordinator: 'sobald',
        domain: CommunicativeDomain.industrialRobotics,
        fullGermanSentence:
            'Sobald der Sensor das Erreichen der Endlage signalisiert hat, stoppt die SPS den Vorschubmotor.',
        subordinateClause: 'Sobald der Sensor das Erreichen der Endlage signalisiert hat',
        mainClause: 'stoppt die SPS den Vorschubmotor',
        aspectualAnchoringExplanationGerman:
            'Punktuelle, unmittelbare Vorzeitigkeit: Unverzügliche Reaktion der Steuerung nach Eintreffen des Sensorsignals.',
        aspectualAnchoringExplanationArabic:
            'أسبقية لحظية فورية: بمجرد تأكيد الحساس بلوغ الموضع النهائي (مضارع تام)، توقف وحدة التحكم محرك الدفع فوراً.',
        safetySequenceRelevance: 'Schützt Roboterachsen vor mechanischer Blockade und Kollision.',
      ),
      // 4. sobald (Past Instantaneous Anteriority: Plusquamperfekt + Präteritum)
      const TemporalSubordinationModel(
        id: 'TEMP-4960-04',
        temporalRelation: TemporalRelationType.anteriorityVorzeitigkeit,
        consecutioPair: ConsecutioTemporumPair.pastAnteriority,
        subordinator: 'sobald',
        domain: CommunicativeDomain.civilInfrastructure,
        fullGermanSentence:
            'Sobald der Beton die geforderte Druckfestigkeit von 35 MPa erreicht hatte, schalten die Bauarbeiter die Schalung aus.',
        subordinateClause: 'Sobald der Beton die geforderte Druckfestigkeit von 35 MPa erreicht hatte',
        mainClause: 'schalten die Bauarbeiter die Schalung aus',
        aspectualAnchoringExplanationGerman:
            'Vollendete Aushärtung (Plusquamperfekt) geht dem Ausschalen (Präteritum) im Bauablauf zwingend voraus.',
        aspectualAnchoringExplanationArabic:
            'اكتمال التصلد الخرساني وبلوغ قوة الضغط المطلوبة (ماض تام) يسبق بالضرورة فك القوالب الخشبية (ماض بسيط).',
        safetySequenceRelevance: 'Verhindert vorzeitiges Einstürzen oder unzulässige Rissbildung im Tragwerk.',
      ),
      // 5. während (Past Simultaneity: Präteritum + Präteritum)
      const TemporalSubordinationModel(
        id: 'TEMP-4960-05',
        temporalRelation: TemporalRelationType.simultaneityGleichzeitigkeit,
        consecutioPair: ConsecutioTemporumPair.pastSimultaneity,
        subordinator: 'während',
        domain: CommunicativeDomain.materialScience,
        fullGermanSentence:
            'Während die Vakuumpumpe das Prüfvolumen evakuierte, maß das Massenspektrometer kontinuierlich die Restgaszusammensetzung.',
        subordinateClause: 'Während die Vakuumpumpe das Prüfvolumen evakuierte',
        mainClause: 'maß das Massenspektrometer kontinuierlich die Restgaszusammensetzung',
        aspectualAnchoringExplanationGerman:
            'Absolute Gleichzeitigkeit zweier kontinuierlicher Prozessabläufe im selben Tempus (Präteritum/Präteritum).',
        aspectualAnchoringExplanationArabic:
            'تزامن تام وتطابق زمني بين عملية تفريغ الهواء وقياس مطياف الكتلة المستمر لمكونات الغاز المتبقي.',
        safetySequenceRelevance: 'Gewährleistet die Reinheit der Dünnschichtbeschichtung im Nanobereich.',
      ),
      // 6. während (Present Simultaneity: Präsens + Präsens)
      const TemporalSubordinationModel(
        id: 'TEMP-4960-06',
        temporalRelation: TemporalRelationType.simultaneityGleichzeitigkeit,
        consecutioPair: ConsecutioTemporumPair.presentSimultaneity,
        subordinator: 'während',
        domain: CommunicativeDomain.maritimeLogistics,
        fullGermanSentence:
            'Während das Containerschiff am Kai festmacht, erfassen automatisierte OCR-Kameras die Containernummern.',
        subordinateClause: 'Während das Containerschiff am Kai festmacht',
        mainClause: 'erfassen automatisierte OCR-Kameras die Containernummern',
        aspectualAnchoringExplanationGerman:
            'Parallele Prozessabwicklung in Echtzeit im Präsens.',
        aspectualAnchoringExplanationArabic:
            'تزامن لوجستي فوري بالزمن المضارع بين رسو سفينة الحاويات ومسح الكاميرات الضوئية الذكية لأرقام الحاويات.',
        safetySequenceRelevance: 'Verhindert Liegezeitverzögerungen und Fehlladungen im Hafenterminal.',
      ),
      // 7. bevor (Present Posteriority: Präsens + Präsens)
      const TemporalSubordinationModel(
        id: 'TEMP-4960-07',
        temporalRelation: TemporalRelationType.posteriorityNachzeitigkeit,
        consecutioPair: ConsecutioTemporumPair.posteriorityPresent,
        subordinator: 'bevor',
        domain: CommunicativeDomain.renewableEnergyGrid,
        fullGermanSentence:
            'Bevor der Windpark ans Übertragungsnetz synchronisiert wird, führen die Ingenieure eine Frequenzprüfung durch.',
        subordinateClause: 'Bevor der Windpark ans Übertragungsnetz synchronisiert wird',
        mainClause: 'führen die Ingenieure eine Frequenzprüfung durch',
        aspectualAnchoringExplanationGerman:
            'Nachzeitigkeit des Nebensatzes: Die Frequenzprüfung (Hauptsatz) muss VOR der Synchronisation (Nebensatz) stattfinden.',
        aspectualAnchoringExplanationArabic:
            'لاحقية زمنية: يجب إجراء فحص التردد مسبقاً قبل ربط وتزامن مزرعة الرياح مع شبكة نقل الكهرباء.',
        safetySequenceRelevance: 'Verhindert Netzstörungen und unkontrollierte Phasensprünge.',
      ),
      // 8. bevor (Past Posteriority: Präteritum + Präteritum)
      const TemporalSubordinationModel(
        id: 'TEMP-4960-08',
        temporalRelation: TemporalRelationType.posteriorityNachzeitigkeit,
        consecutioPair: ConsecutioTemporumPair.posteriorityPast,
        subordinator: 'bevor',
        domain: CommunicativeDomain.aerospaceAndAviation,
        fullGermanSentence:
            'Bevor der Testpilot das Triebwerk auf maximale Nachbrennerleistung schaltete, überprüfte er die Turbineneinlasstemperatur.',
        subordinateClause: 'Bevor der Testpilot das Triebwerk auf maximale Nachbrennerleistung schaltete',
        mainClause: 'überprüfte er die Turbineneinlasstemperatur',
        aspectualAnchoringExplanationGerman:
            'Vergangenheitsdokumentation einer sicherheitsrelevanten Sequenz im Präteritum.',
        aspectualAnchoringExplanationArabic:
            'توثيق تسلسل تشغيلي في الماضي: فحص درجة حرارة مدخل التوربين قبل تفعيل الحارق اللاحق الأقصى.',
        safetySequenceRelevance: 'Vermeidet thermische Zerstörung der Turbinenschaufeln.',
      ),
      // 9. ehe (Formal Posteriority: Präsens + Präsens)
      const TemporalSubordinationModel(
        id: 'TEMP-4960-09',
        temporalRelation: TemporalRelationType.posteriorityNachzeitigkeit,
        consecutioPair: ConsecutioTemporumPair.posteriorityPresent,
        subordinator: 'ehe',
        domain: CommunicativeDomain.industrialRobotics,
        fullGermanSentence:
            'Ehe das Bedienpersonal die Roboterzelle betritt, muss der Zustimmtaster betätigt werden.',
        subordinateClause: 'Ehe das Bedienpersonal die Roboterzelle betritt',
        mainClause: 'muss der Zustimmtaster betätigt werden',
        aspectualAnchoringExplanationGerman:
            'Stilistisch gehobenes "ehe" als Synonym zu "bevor" in offiziellen Betriebsanweisungen.',
        aspectualAnchoringExplanationArabic:
            'أداة لاحقية رفيعة المستوى (ehe) تلزم تفعيل زر التمكين قبل أن يخطو الفني داخل خلية الروبوت.',
        safetySequenceRelevance: 'Zwingende Unfallverhütungsvorschrift (UVV) nach EN ISO 10218.',
      ),
      // 10. bis (Terminal Boundary: Präsens + Präsens)
      const TemporalSubordinationModel(
        id: 'TEMP-4960-10',
        temporalRelation: TemporalRelationType.terminalBoundaryLimit,
        consecutioPair: ConsecutioTemporumPair.presentSimultaneity,
        subordinator: 'bis',
        domain: CommunicativeDomain.materialScience,
        fullGermanSentence:
            'Die thermische Behandlung im Vakuumofen dauert an, bis das Werkstück eine homogene Kerntemperatur von 950 Grad aufweist.',
        subordinateClause: 'bis das Werkstück eine homogene Kerntemperatur von 950 Grad aufweist',
        mainClause: 'Die thermische Behandlung im Vakuumofen dauert an',
        aspectualAnchoringExplanationGerman:
            'Endpunktspezifikation: Die Dauerhandlung im Hauptsatz stoppt genau in dem Moment, in dem der Grenzwert erreicht ist.',
        aspectualAnchoringExplanationArabic:
            'تحديد غائي نهائي: تستمر المعالجة الحرارية في فرن التفريغ إلى أن تبلغ حرارة لب القطعة 950 درجة مئوية.',
        safetySequenceRelevance: 'Verhindert unvollständige Gefügeumwandlung im Metall.',
      ),
      // 11. bis (Past Terminal Boundary: Präteritum + Präteritum)
      const TemporalSubordinationModel(
        id: 'TEMP-4960-11',
        temporalRelation: TemporalRelationType.terminalBoundaryLimit,
        consecutioPair: ConsecutioTemporumPair.pastSimultaneity,
        subordinator: 'bis',
        domain: CommunicativeDomain.civilInfrastructure,
        fullGermanSentence:
            'Die Entwässerungspumpen liefen auf Volllast, bis der Pegel im Baugrubenbereich unter die kritische Marke sank.',
        subordinateClause: 'bis der Pegel im Baugrubenbereich unter die kritische Marke sank',
        mainClause: 'Die Entwässerungspumpen liefen auf Volllast',
        aspectualAnchoringExplanationGerman:
            'Präteritaler Endpunkt: Pumpbetrieb bis zur Absenkung des Grundwasserspiegels.',
        aspectualAnchoringExplanationArabic:
            'حد نهائي في الماضي: استمرار عمل مضخات النزح بكامل طاقتها حتى هبط منسوب المياه أسفل الخط الحرج.',
        safetySequenceRelevance: 'Schutz vor Grundbruch und Flutung der Baugrube.',
      ),
      // 12. solange (Durational Condition: Präsens + Präsens)
      const TemporalSubordinationModel(
        id: 'TEMP-4960-12',
        temporalRelation: TemporalRelationType.durationalConditionWindow,
        consecutioPair: ConsecutioTemporumPair.presentSimultaneity,
        subordinator: 'solange',
        domain: CommunicativeDomain.renewableEnergyGrid,
        fullGermanSentence:
            'Solange die Schmiermitteltemperatur im Getriebe unter 75 Grad bleibt, ist der Volllastbetrieb der Windturbine unbedenklich.',
        subordinateClause: 'Solange die Schmiermitteltemperatur im Getriebe unter 75 Grad bleibt',
        mainClause: 'ist der Volllastbetrieb der Windturbine unbedenklich',
        aspectualAnchoringExplanationGerman:
            'Kopplung von Zeitdauer und Bedingung: Die Betriebserlaubnis gilt exakt so lange wie der Temperaturmesswert stabil bleibt.',
        aspectualAnchoringExplanationArabic:
            'نافذة زمنية شرطية: تشغيل التوربين بكامل طاقته آمن حصراً طالما بقيت حرارة زيت التروس دون 75 درجة.',
        safetySequenceRelevance: 'Schützt das Großgetriebe vor thermischem Fressen und Zahnradschäden.',
      ),
      // 13. solange (Past Durational Condition: Präteritum + Präteritum)
      const TemporalSubordinationModel(
        id: 'TEMP-4960-13',
        temporalRelation: TemporalRelationType.durationalConditionWindow,
        consecutioPair: ConsecutioTemporumPair.pastSimultaneity,
        subordinator: 'solange',
        domain: CommunicativeDomain.maritimeLogistics,
        fullGermanSentence:
            'Solange die Windgeschwindigkeit unter 8 Beaufort lag, setzte der Terminalkran die Containerlöschung fort.',
        subordinateClause: 'Solange die Windgeschwindigkeit unter 8 Beaufort lag',
        mainClause: 'setzte der Terminalkran die Containerlöschung fort',
        aspectualAnchoringExplanationGerman:
            'Vergangene Dauerbedingung: Fortsetzung des Umschlagbetriebs unterhalb der Sturmgrenze.',
        aspectualAnchoringExplanationArabic:
            'استمرار تفريغ الحاويات في الميناء طالما لم تتجاوز سرعة الرياح العاصفة 8 درجات بوفورت.',
        safetySequenceRelevance: 'Verhütung von Kranabstürzen und Containerschäden bei Starkwind.',
      ),
      // 14. nachdem (Passive Past Anteriority)
      const TemporalSubordinationModel(
        id: 'TEMP-4960-14',
        temporalRelation: TemporalRelationType.anteriorityVorzeitigkeit,
        consecutioPair: ConsecutioTemporumPair.pastAnteriority,
        subordinator: 'nachdem',
        domain: CommunicativeDomain.materialScience,
        fullGermanSentence:
            'Nachdem die Probekörper 500 Stunden lang im Salzsprühnebel getestet worden waren, analysierten die Werkstoffprüfer die Korrosionstiefe.',
        subordinateClause: 'Nachdem die Probekörper 500 Stunden lang im Salzsprühnebel getestet worden waren',
        mainClause: 'analysierten die Werkstoffprüfer die Korrosionstiefe',
        aspectualAnchoringExplanationGerman:
            'Abgeschlossener Korrosionstest (Plusquamperfekt Passiv) vor Beginn der metallographischen Befundung (Präteritum).',
        aspectualAnchoringExplanationArabic:
            'اكتمال فحص رذاذ الملح لمدة 500 ساعة (ماض تام للمجهول) قبل قياس عمق التآكل مجهرياً (ماض بسيط).',
        safetySequenceRelevance: 'Exakte Einhaltung der Prüfvorschriften nach DIN EN ISO 9227.',
      ),
      // 15. sobald (Future Anteriority with Futur I in Main Clause)
      const TemporalSubordinationModel(
        id: 'TEMP-4960-15',
        temporalRelation: TemporalRelationType.anteriorityVorzeitigkeit,
        consecutioPair: ConsecutioTemporumPair.presentFutureAnteriority,
        subordinator: 'sobald',
        domain: CommunicativeDomain.aerospaceAndAviation,
        fullGermanSentence:
            'Sobald die Satellitenverbindung hergestellt ist, wird der Autopilot die aktualisierten Wegpunkte einlesen.',
        subordinateClause: 'Sobald die Satellitenverbindung hergestellt ist',
        mainClause: 'wird der Autopilot die aktualisierten Wegpunkte einlesen',
        aspectualAnchoringExplanationGerman:
            'Zukunftszugewandte Vorzeitigkeit: Perfekt/Zustandspassiv im Nebensatz, Futur I im Hauptsatz.',
        aspectualAnchoringExplanationArabic:
            'أسبقية مستقبلية: بمجرد ثبات الاتصال بالأقمار الصناعية (مضارع تام)، سيقوم الطيار الآلي بقراءة نقاط المسار.',
        safetySequenceRelevance: 'Gewährleistet kontinuierliche Navigationssicherheit auf Langstreckenflügen.',
      ),
      // 16. während (Adversative Simultaneity)
      const TemporalSubordinationModel(
        id: 'TEMP-4960-16',
        temporalRelation: TemporalRelationType.simultaneityGleichzeitigkeit,
        consecutioPair: ConsecutioTemporumPair.presentSimultaneity,
        subordinator: 'während',
        domain: CommunicativeDomain.industrialRobotics,
        fullGermanSentence:
            'Während Sensor A die Vibrationen im Niederfrequenzbereich überwacht, detektiert Sensor B Ultraschallimpulse im Getriebe.',
        subordinateClause: 'Während Sensor A die Vibrationen im Niederfrequenzbereich überwacht',
        mainClause: 'detektiert Sensor B Ultraschallimpulse im Getriebe',
        aspectualAnchoringExplanationGerman:
            'Gleichzeitigkeit mit semantischer Kontrastierung (Adversativ-Aspekt) zweier komplementärer Diagnosesensoren.',
        aspectualAnchoringExplanationArabic:
            'تزامن تبايني تقني: بينما يرصد الحساس (أ) الاهتزازات منخفضة التردد، يلتقط الحساس (ب) نبضات الموجات فوق الصوتية.',
        safetySequenceRelevance: 'Redundante und diversitäre Fehlerfrüherkennung nach VDI 3834.',
      ),
    ]);
  }

  List<TemporalSubordinationModel> getByRelation(TemporalRelationType relation) =>
      _catalog.where((t) => t.temporalRelation == relation).toList();

  List<TemporalSubordinationModel> getByConsecutio(ConsecutioTemporumPair consecutio) =>
      _catalog.where((t) => t.consecutioPair == consecutio).toList();

  List<TemporalSubordinationModel> getByDomain(CommunicativeDomain domain) =>
      _catalog.where((t) => t.domain == domain).toList();

  /// Validates Consecutio Temporum compliance for temporal complex sentences.
  TemporalValidationResult validateConsecutioTemporum({
    required String subordinator,
    required String subordinateTense, // 'plusquamperfekt', 'perfekt', 'praeteritum', 'praesens'
    required String mainTense,        // 'praeteritum', 'praesens', 'futur'
  }) {
    final List<String> issues = [];
    final List<String> notes = [];

    final sub = subordinator.toLowerCase();
    final subT = subordinateTense.toLowerCase();
    final mainT = mainTense.toLowerCase();

    if (sub == 'nachdem' || sub == 'sobald') {
      if (mainT == 'praeteritum') {
        if (subT != 'plusquamperfekt') {
          issues.add(
              'Zeitenfolge-Verstoß (Consecutio Temporum): Bei Hauptsatz im Präteritum MUSS der mit "$sub" eingeleitete vorzeitige Nebensatz im Plusquamperfekt stehen (nicht im $subT).');
        } else {
          notes.add('Zeitenfolge normgerecht: Plusquamperfekt im Nebensatz zu Präteritum im Hauptsatz.');
        }
      } else if (mainT == 'praesens' || mainT == 'futur') {
        if (subT != 'perfekt') {
          issues.add(
              'Zeitenfolge-Verstoß: Bei Hauptsatz im Präsens/Futur MUSS der vorzeitige Nebensatz mit "$sub" im Perfekt (oder Futur II) stehen.');
        } else {
          notes.add('Zeitenfolge normgerecht: Perfekt im Nebensatz zu Präsens/Futur im Hauptsatz.');
        }
      }
    } else if (sub == 'während' || sub == 'solange') {
      if ((subT == 'praeteritum' && mainT != 'praeteritum') ||
          (subT == 'praesens' && mainT != 'praesens')) {
        issues.add(
            'Gleichzeitigkeits-Fehler: "$sub" verlangt Tempusidentität zwischen Neben- und Hauptsatz ($subT vs. $mainT).');
      } else {
        notes.add('Gleichzeitigkeit normgerecht: Tempusidentität gewahrt.');
      }
    } else if (sub == 'bevor' || sub == 'ehe') {
      if (subT == 'plusquamperfekt') {
        issues.add(
            'Nachzeitigkeits-Fehler: "$sub" darf NIEMALS mit dem Plusquamperfekt stehen, da der Nebensatz dem Hauptsatz zeitlich nachfolgt.');
      } else {
        notes.add('Nachzeitigkeit normgerecht formuliert.');
      }
    }

    return TemporalValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      grammarNotes: notes,
    );
  }

  Map<String, dynamic> generateTelemetrySnapshot() {
    return {
      'totalExemplars': _catalog.length,
      'relationDistribution': {
        for (var r in TemporalRelationType.values)
          r.name: _catalog.where((t) => t.temporalRelation == r).length,
      },
      'consecutioDistribution': {
        for (var c in ConsecutioTemporumPair.values)
          c.name: _catalog.where((t) => t.consecutioPair == c).length,
      },
      'domainDistribution': {
        for (var d in CommunicativeDomain.values)
          d.name: _catalog.where((t) => t.domain == d).length,
      },
      'cefrLevel': 'CEFR C1-C2 Masterclass Temporal Consecutio Temporum',
      'engineVersion': '1.0.0+subsystem1794',
    };
  }
}
