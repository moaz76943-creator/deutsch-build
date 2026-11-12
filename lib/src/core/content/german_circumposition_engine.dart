import 'dart:collection';

/// Grammatical cases governed by circumpositions, postpositions, and ambipositions.
enum GermanCase {
  genitive('Genitiv', 'حالة الإضافة'),
  dative('Dativ', 'حالة الجر بالداتيف'),
  accusative('Akkusativ', 'حالة النصب بالأكوزاتيف');

  final String germanLabel;
  final String arabicLabel;
  const GermanCase(this.germanLabel, this.arabicLabel);
}

/// Structural category of the adposition.
enum PositionalType {
  circumposition(
    'Zirkumposition / Rahmenpräposition',
    'حرف جر تأطيري ثنائي (يحيط بالاسم من الأمام والخلف)',
    'Umgibt das Bezugswort: um ... willen, von ... an, an ... vorbei',
  ),
  postposition(
    'Postposition (nachgestellte Präposition)',
    'شبه حرف الجر المؤخر (يأتي بعد الاسم المجرور)',
    'Steht hinter dem Nomen: dem Fluss entlang, meiner Ansicht nach, der Sache wegen',
  ),
  ambiposition(
    'Ambiposition (vor- oder nachgestellt)',
    'حرف جر مزدوج الموضع (يقبل التقدم والتأخر مع اختلاف الإعراب غالباً)',
    'Kann vor oder hinter dem Nomen stehen: entlang des Pfades vs. den Pfad entlang',
  );

  final String germanTitle;
  final String arabicTitle;
  final String syntaxPattern;
  const PositionalType(this.germanTitle, this.arabicTitle, this.syntaxPattern);
}

/// Communicative domain strictly compliant with professional and non-liability ethics.
enum CommunicativeDomain {
  engineeringAndTech('Ingenieurwesen & Technologie', 'الهندسة والتقنية'),
  logisticsAndTransport('Logistik & Güterverkehr', 'اللوجستيات والنقل والشحن'),
  aviationAndNavigation('Luftfahrt & Schifffahrt', 'الملاحة والطيران'),
  meteorologyAndNature('Meteorologie & Umweltwissenschaft', 'الأرصاد وعلوم البيئة'),
  commerceAndTrade('Handel & Betriebswirtschaft', 'التجارة والأعمال التجارية'),
  everydayLife('Alltag & Praktische Wegbeschreibung', 'الحياة اليومية والإرشاد المكاني');

  final String de;
  final String ar;
  const CommunicativeDomain(this.de, this.ar);
}

/// Data model representing a circumpositional or postpositional construction.
class CircumpositionModel {
  final String id;
  final String leadComponent; // e.g. "um", "von", or empty if pure postposition
  final String coreNoun; // e.g. "des Projekterfolgs", "morgen", "dem Fluss"
  final String tailComponent; // e.g. "willen", "an", "entlang"
  final PositionalType positionalType;
  final GermanCase governedCase;
  final CommunicativeDomain domain;
  final String fullSentence;
  final String arabicTranslation;
  final String grammaticalAnalysisArabic;
  final String grammaticalAnalysisGerman;
  final String morphologicalSpecialNote;

  const CircumpositionModel({
    required this.id,
    required this.leadComponent,
    required this.coreNoun,
    required this.tailComponent,
    required this.positionalType,
    required this.governedCase,
    required this.domain,
    required this.fullSentence,
    required this.arabicTranslation,
    required this.grammaticalAnalysisArabic,
    required this.grammaticalAnalysisGerman,
    required this.morphologicalSpecialNote,
  });

  String get completePhrase => leadComponent.isEmpty
      ? '$coreNoun $tailComponent'
      : '$leadComponent $coreNoun $tailComponent';

  Map<String, dynamic> toJson() => {
    'id': id,
    'leadComponent': leadComponent,
    'coreNoun': coreNoun,
    'tailComponent': tailComponent,
    'completePhrase': completePhrase,
    'positionalType': positionalType.name,
    'governedCase': governedCase.name,
    'domain': domain.name,
    'fullSentence': fullSentence,
    'arabicTranslation': arabicTranslation,
    'grammaticalAnalysisArabic': grammaticalAnalysisArabic,
    'grammaticalAnalysisGerman': grammaticalAnalysisGerman,
    'morphologicalSpecialNote': morphologicalSpecialNote,
  };
}

/// Validation report for adposition position and case agreement.
class CircumpositionValidationReport {
  final bool isValid;
  final bool correctCaseSelected;
  final bool correctWordOrder;
  final List<String> issues;
  final List<String> syntacticCorrections;
  final String arabicSummary;

  const CircumpositionValidationReport({
    required this.isValid,
    required this.correctCaseSelected,
    required this.correctWordOrder,
    required this.issues,
    required this.syntacticCorrections,
    required this.arabicSummary,
  });
}

/// Comprehensive engine governing German Circumpositions and Postpositions.
class GermanCircumpositionEngine {
  final List<CircumpositionModel> _catalog = [];

  GermanCircumpositionEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<CircumpositionModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    // 1. Circumposition: um ... willen (Genitiv) - Engineering Project Safety
    _catalog.add(
      const CircumpositionModel(
        id: 'CIRC-UM-WILLEN-01',
        leadComponent: 'um',
        coreNoun: 'der baulichen Sicherheit',
        tailComponent: 'willen',
        positionalType: PositionalType.circumposition,
        governedCase: GermanCase.genitive,
        domain: CommunicativeDomain.engineeringAndTech,
        fullSentence:
            'Um der baulichen Sicherheit willen wurden die tragenden Stahlträger doppelt verstärkt.',
        arabicTranslation:
            'حرصاً على السلامة الإنشائية ومراعاةً لها، تم تدعيم العوارض الفولاذية الحاملة بمقدار الضعف.',
        grammaticalAnalysisArabic:
            'حرف جر تأطيري (Zirkumposition): يحيط الاسم بـ "um" في الصدر و"willen" في العجز، ويجر الاسم بينهما بالإضافة (Genitiv) وجوباً.',
        grammaticalAnalysisGerman:
            'Klassische Zirkumposition "um ... willen" regiert obligatorisch den Genitiv ("der baulichen Sicherheit").',
        morphologicalSpecialNote:
            'Bei Personalpronomen erfolgt Verschmelzung mit Einschub von -t-: meinetwillen, deinetwillen, seinetwillen, ihretwillen.',
      ),
    );

    // 2. Circumposition: um meinetwillen (Pronominal fusion) - Daily Life & Cooperation
    _catalog.add(
      const CircumpositionModel(
        id: 'CIRC-UM-PRONOM-02',
        leadComponent: 'um',
        coreNoun: 'meinet',
        tailComponent: 'willen',
        positionalType: PositionalType.circumposition,
        governedCase: GermanCase.genitive,
        domain: CommunicativeDomain.everydayLife,
        fullSentence:
            'Du brauchst deinen gut durchdachten Zeitplan nicht um meinetwillen zu ändern.',
        arabicTranslation:
            'لست بحاجة إلى تغيير جدول مواعيدك المحكم من أجلي أو بسببي.',
        grammaticalAnalysisArabic:
            'صيغة دمج ضمير الملكية مع أداة التأطير مع إقحام صوت التاء الفاصل (Epenthese): mein + t + willen.',
        grammaticalAnalysisGerman:
            'Verschmolzene Pronominalform: Possessivstamm "mein" + Fugenelement "-t-" + "willen". Funktional ein erstarrter Genitiv.',
        morphologicalSpecialNote:
            'Historisch entstanden aus "um meines Willen"; das Fugen-t verhindert Hiatus und erleichtert die Aussprache.',
      ),
    );

    // 3. Postposition / Ambiposition: entlang (Postposed: Akkusativ) - Navigation & Transport
    _catalog.add(
      const CircumpositionModel(
        id: 'CIRC-ENTLANG-POST-03',
        leadComponent: '',
        coreNoun: 'den Fluss',
        tailComponent: 'entlang',
        positionalType: PositionalType.postposition,
        governedCase: GermanCase.accusative,
        domain: CommunicativeDomain.aviationAndNavigation,
        fullSentence:
            'Das Frachtschiff navigierte den Fluss entlang bis zur Mündung in das Hafenbecken.',
        arabicTranslation:
            'أبحرت سفينة الشحن بمحاذاة النهر حتى وصلت إلى مصبه في حوض الميناء.',
        grammaticalAnalysisArabic:
            'شبه حرف جر مؤخر (Postposition): عندما تأتي "entlang" بعد الاسم، يتعين نصب الاسم (Akkusativ: den Fluss).',
        grammaticalAnalysisGerman:
            'Nachgestelltes "entlang" verlangt den Akkusativ ("den Fluss entlang"). Dies drückt eine gerichtete Längsbewegung aus.',
        morphologicalSpecialNote:
            'Gegenüberstellung: Vorangestellt verlangt "entlang" standardsprachlich den Genitiv (entlang des Flusses) oder Dativ.',
      ),
    );

    // 4. Ambiposition: entlang (Preposed: Genitiv) - Environmental Science
    _catalog.add(
      const CircumpositionModel(
        id: 'CIRC-ENTLANG-PRE-04',
        leadComponent: 'entlang',
        coreNoun: 'des Waldrandes',
        tailComponent: '',
        positionalType: PositionalType.ambiposition,
        governedCase: GermanCase.genitive,
        domain: CommunicativeDomain.meteorologyAndNature,
        fullSentence:
            'Entlang des Waldrandes installierten die Forscher hochpräzise Wetterstationen.',
        arabicTranslation:
            'على طول حافة الغابة وبمحاذاتها، ثبّت الباحثون محطات رصد جوي فائقة الدقة.',
        grammaticalAnalysisArabic:
            'حرف جر مقدم (Präposition): عند تقدم "entlang" على الاسم، يكون الإعراب الفصيح هو الإضافة (Genitiv: des Waldrandes).',
        grammaticalAnalysisGerman:
            'Vorangestelltes "entlang" regiert in der gehobenen Standardsprache vorzugsweise den Genitiv.',
        morphologicalSpecialNote:
            'Umgangssprachlich tritt mitunter der Dativ auf (entlang dem Waldrand), in der Schriftsprache gilt der Genitiv als makellos.',
      ),
    );

    // 5. Circumposition: von ... an (Dativ) - Logistics & Time Measurement
    _catalog.add(
      const CircumpositionModel(
        id: 'CIRC-VON-AN-05',
        leadComponent: 'von',
        coreNoun: 'dem kommenden Montag',
        tailComponent: 'an',
        positionalType: PositionalType.circumposition,
        governedCase: GermanCase.dative,
        domain: CommunicativeDomain.logisticsAndTransport,
        fullSentence:
            'Von dem kommenden Montag an werden sämtliche Lieferketten digital überwacht.',
        arabicTranslation:
            'اعتباراً من يوم الاثنين القادم فصاعداً، ستتم مراقبة كافة سلاسل التوريد رقمياً.',
        grammaticalAnalysisArabic:
            'حرف جر تأطيري زماني (von ... an): يبدأ بـ von ويختم بـ an، ويجر الاسم بالداتيف (dem kommenden Montag).',
        grammaticalAnalysisGerman:
            'Temporale Zirkumposition "von ... an" zur Markierung des Anfangszeitpunkts mit regiertem Dativ.',
        morphologicalSpecialNote:
            'Wird "an" weggelassen, fehlt die prospektive Kontinuitätsbetonung (ab / von ... an).',
      ),
    );

    // 6. Circumposition: von ... aus (Dativ) - Engineering & Spatial Point of Origin
    _catalog.add(
      const CircumpositionModel(
        id: 'CIRC-VON-AUS-06',
        leadComponent: 'von',
        coreNoun: 'der zentralen Steuerungszentrale',
        tailComponent: 'aus',
        positionalType: PositionalType.circumposition,
        governedCase: GermanCase.dative,
        domain: CommunicativeDomain.engineeringAndTech,
        fullSentence:
            'Von der zentralen Steuerungszentrale aus lässt sich die gesamte Turbinenleistung modulieren.',
        arabicTranslation:
            'انطلاقاً من مركز التحكم المركزي، يمكن ضبط وموالفة أداء التوربينات بالكامل.',
        grammaticalAnalysisArabic:
            'حرف جر تأطيري مكاني يفيد نقطة الانطلاق والمصدرية (von ... aus)، والاسم مجرور بالداتيف المؤنث (der Zentrale).',
        grammaticalAnalysisGerman:
            'Lokale Zirkumposition "von ... aus" kennzeichnet den Ausgangspunkt einer Handlung oder Steuerung.',
        morphologicalSpecialNote:
            '"Aus" fungiert hier als Raumrichtungspartikel, die die Wirkung nach außen betont.',
      ),
    );

    // 7. Postposition: nach (Dativ) - Expressing Opinion / Viewpoint in Commerce
    _catalog.add(
      const CircumpositionModel(
        id: 'CIRC-NACH-OPINION-07',
        leadComponent: '',
        coreNoun: 'unserer fachlichen Einschätzung',
        tailComponent: 'nach',
        positionalType: PositionalType.postposition,
        governedCase: GermanCase.dative,
        domain: CommunicativeDomain.commerceAndTrade,
        fullSentence:
            'Unserer fachlichen Einschätzung nach bietet dieses Marktsegment stabiles Wachstumspotenzial.',
        arabicTranslation:
            'وفقاً لتقديرنا التخصصي وبحسب رأينا، يتيح هذا القطاع السوقي فرص نمو مستقرة.',
        grammaticalAnalysisArabic:
            'شبه حرف جر مؤخر (Postposition): عند التعبير عن الرأي والتقدير (Einschätzung / Meinung / Ansicht)، تأتي "nach" مؤخرة وتجر بالداتيف.',
        grammaticalAnalysisGerman:
            'Postpositionales "nach" bei Urteils- und Referenzsubstantiven; regiert strikt den Dativ.',
        morphologicalSpecialNote:
            'Vorangestellt ("nach unserer Einschätzung") ebenfalls korrekt; nachgestellt wirkt stilistisch gewichtiger.',
      ),
    );

    // 8. Circumposition: an ... vorbei (Dativ) - Logistics & Spatial Bypass
    _catalog.add(
      const CircumpositionModel(
        id: 'CIRC-AN-VORBEI-08',
        leadComponent: 'an',
        coreNoun: 'den verengten Baustellenabschnitten',
        tailComponent: 'vorbei',
        positionalType: PositionalType.circumposition,
        governedCase: GermanCase.dative,
        domain: CommunicativeDomain.logisticsAndTransport,
        fullSentence:
            'Die Schwerlasttransporte wurden sicher an den verengten Baustellenabschnitten vorbei geleitet.',
        arabicTranslation:
            'تم توجيه قوافل النقل الثقيل بأمان متجاوزةً مقاطع الورش الضيقة ومحاذيةً لها دون عوائق.',
        grammaticalAnalysisArabic:
            'حرف جر تأطيري مساري يفيد التجاوز والمرور بجانب الشيء (an + Dativ ... vorbei).',
        grammaticalAnalysisGerman:
            'Lokale Zirkumposition "an ... vorbei" zur Beschreibung einer Passierbewegung unter Wahrung von Abstand.',
        morphologicalSpecialNote:
            'Das Bezugssubstantiv steht im Dativ Plural mit der Flexionsendung -n (Abschnitten).',
      ),
    );

    // 9. Postposition: wegen (Genitiv / Dativ) - Trade & Commercial Cause
    _catalog.add(
      const CircumpositionModel(
        id: 'CIRC-WEGEN-POST-09',
        leadComponent: '',
        coreNoun: 'der gestiegenen Rohstoffpreise',
        tailComponent: 'wegen',
        positionalType: PositionalType.postposition,
        governedCase: GermanCase.genitive,
        domain: CommunicativeDomain.commerceAndTrade,
        fullSentence:
            'Der gestiegenen Rohstoffpreise wegen mussten die Produktionskapazitäten neu kalkuliert werden.',
        arabicTranslation:
            'نظراً لارتفاع أسعار المواد الخام وبسببها، كان لزاماً إعادة حساب وتخطيط الطاقات الإنتاجية.',
        grammaticalAnalysisArabic:
            'حرف جر سببي مؤخر (wegen nachgestellt): عند تأخره في النثر الفصيح الراقي، يتقدم الاسم المجرور بالإضافة (Genitiv).',
        grammaticalAnalysisGerman:
            'Nachgestelltes "wegen" mit Genitiv gilt als besonders formell und rhetorisch pointiert.',
        morphologicalSpecialNote:
            'Ebenso wie bei "um ... willen" gibt es bei Pronomina die Formen "meinetwegen", "deinetwegen", "unsretwegen".',
      ),
    );

    // 10. Circumposition: auf ... zu (Akkusativ) - Aviation & Directional Approach
    _catalog.add(
      const CircumpositionModel(
        id: 'CIRC-AUF-ZU-10',
        leadComponent: 'auf',
        coreNoun: 'die beleuchtete Landebahn',
        tailComponent: 'zu',
        positionalType: PositionalType.circumposition,
        governedCase: GermanCase.accusative,
        domain: CommunicativeDomain.aviationAndNavigation,
        fullSentence:
            'Das Frachtflugzeug steuerte im Sinkflug präzise auf die beleuchtete Landebahn zu.',
        arabicTranslation:
            'اتجهت طائرة الشحن أثناء هبوطها بدقة متناهية صوب مدرج الهبوط المضاء.',
        grammaticalAnalysisArabic:
            'حرف جر تأطيري حركي يفيد التوجه صوب الهدف (auf + Akkusativ ... zu)، يليه الفعل التواصلي (zusteuern auf).',
        grammaticalAnalysisGerman:
            'Direktionale Zirkumposition "auf ... zu" mit Akkusativ zur Bezeichnung einer Zielannäherung.',
        morphologicalSpecialNote:
            '"Zu" bildet häufig mit dem Verb eine verbale Einheit (auf etw. zusteuern / zugehen).',
      ),
    );

    // 11. Circumposition: von ... her (Dativ) - Meteorology & Wind Direction
    _catalog.add(
      const CircumpositionModel(
        id: 'CIRC-VON-HER-11',
        leadComponent: 'von',
        coreNoun: 'dem Gebirgsmassiv',
        tailComponent: 'her',
        positionalType: PositionalType.circumposition,
        governedCase: GermanCase.dative,
        domain: CommunicativeDomain.meteorologyAndNature,
        fullSentence:
            'Von dem Gebirgsmassiv her wehte ein trockener, warmer Fallwind in das Tal.',
        arabicTranslation:
            'هبت من ناحية السلسلة الجبلية رياح هابطة جافة ودافئة باتجاه الوادي.',
        grammaticalAnalysisArabic:
            'حرف جر تأطيري يفيد القدوم والاتجاه من المصدر نحونا (von ... her)، والاسم مجرور بالداتيف المحايد.',
        grammaticalAnalysisGerman:
            'Lokale Zirkumposition "von ... her" markiert die Herkunftsrichtung bezogen auf den Sprecherstandort.',
        morphologicalSpecialNote:
            'Der deiktische Partikel "her" indiziert eine Bewegung auf den Bezugspunkt zu.',
      ),
    );

    // 12. Postposition: zufolge (Dativ / Genitiv) - Weather Forecast Verification
    _catalog.add(
      const CircumpositionModel(
        id: 'CIRC-ZUFOLGE-POST-12',
        leadComponent: '',
        coreNoun: 'den neuesten Satellitendaten',
        tailComponent: 'zufolge',
        positionalType: PositionalType.postposition,
        governedCase: GermanCase.dative,
        domain: CommunicativeDomain.meteorologyAndNature,
        fullSentence:
            'Den neuesten Satellitendaten zufolge erreicht die Kaltfront die Küstenregion heute Abend.',
        arabicTranslation:
            'وفقاً لأحدث بيانات الأقمار الاصطناعية وبحسبها، ستصل الجبهة الهوائية الباردة إلى المنطقة الساحلية مساء اليوم.',
        grammaticalAnalysisArabic:
            'حرف جر إسنادي مؤخر (zufolge nachgestellt): يسبقه الاسم المجرور بالداتيف حصراً (Den neuesten Daten).',
        grammaticalAnalysisGerman:
            'Postpositionales "zufolge" verlangt zwingend den Dativ ("den Satellitendaten zufolge").',
        morphologicalSpecialNote:
            'Steht "zufolge" ausnahmsweise voran, regiert es den Genitiv: "zufolge neuester Satellitendaten".',
      ),
    );
  }

  /// Evaluates an adpositional phrase against positional grammar constraints.
  CircumpositionValidationReport validatePhrase({
    required String leadWord,
    required String tailWord,
    required GermanCase appliedCase,
    required PositionalType expectedType,
  }) {
    final issues = <String>[];
    final corrections = <String>[];
    bool correctCase = true;
    bool correctOrder = true;

    if (expectedType == PositionalType.circumposition) {
      if (leadWord.isEmpty || tailWord.isEmpty) {
        correctOrder = false;
        issues.add('Unvollständige Zirkumposition: Beide Rahmenkomponenten (Vor- und Nachglied) müssen gesetzt sein.');
        corrections.add('Stellen Sie das Nomen zwischen beide Komponenten (z. B. um ... willen).');
      }
      if (leadWord.toLowerCase() == 'um' && tailWord.toLowerCase() == 'willen') {
        if (appliedCase != GermanCase.genitive) {
          correctCase = false;
          issues.add('Kasusfehler: "um ... willen" verlangt ausnahmslos den Genitiv.');
          corrections.add('Verwenden Sie die Genitivform des Nomens (z. B. um des Friedens willen).');
        }
      }
    } else if (expectedType == PositionalType.postposition) {
      if (leadWord.isNotEmpty) {
        correctOrder = false;
        issues.add('Falsche Platzierung: Die Postposition muss hinter dem Bezugsnomen stehen.');
        corrections.add('Setzen Sie die Präposition an das Ende der Nominalphrase.');
      }
      if (tailWord.toLowerCase() == 'entlang') {
        if (appliedCase != GermanCase.accusative) {
          correctCase = false;
          issues.add('Kasusdiskrepanz: Nachgestelltes "entlang" verlangt den Akkusativ.');
          corrections.add('Ändern Sie den Kasus zu Akkusativ (z. B. den Fluss entlang).');
        }
      } else if (tailWord.toLowerCase() == 'zufolge') {
        if (appliedCase != GermanCase.dative) {
          correctCase = false;
          issues.add('Kasusdiskrepanz: Nachgestelltes "zufolge" regiert obligatorisch den Dativ.');
          corrections.add('Setzen Sie das Nomen in den Dativ (z. B. den Berichten zufolge).');
        }
      }
    }

    final isValid = issues.isEmpty;
    final arabicSummary = isValid
        ? 'التركيب النحوي لحرف الجر التأطيري/المؤخر سليم تماماً ومتطابق مع قواعد اللغة الألمانية الفصيحة.'
        : 'تم رصد خلل في الترتيب الموقعي أو الحالة الإعرابية لحرف الجر المركب.';

    return CircumpositionValidationReport(
      isValid: isValid,
      correctCaseSelected: correctCase,
      correctWordOrder: correctOrder,
      issues: issues,
      syntacticCorrections: corrections,
      arabicSummary: arabicSummary,
    );
  }

  List<CircumpositionModel> filterByType(PositionalType type) {
    return _catalog.where((item) => item.positionalType == type).toList();
  }

  List<CircumpositionModel> filterByDomain(CommunicativeDomain domain) {
    return _catalog.where((item) => item.domain == domain).toList();
  }
}
