import 'dart:math';

/// مجالات الهندسة والتقنية المعتمدة في المنهج (خالية من المخاطر القانونية والطبية)
enum PrepositionEngineeringDomain {
  renewableEnergyGrid,
  aerospaceAndAviation,
  industrialRobotics,
  civilInfrastructure,
  materialScience,
  maritimeLogistics,
}

/// تصنيف دلالات حروف الجر وإعرابها في الألمانية المتقدمة (C1–C2)
enum PrepositionalSemanticsCategory {
  abstractWechselpraepositionAufIn,  // حروف الجر ذات الوجهين في المعاني المجردة (beruhen auf + Dat vs. verweisen auf + Akk)
  abstractUeberVorAnValency,        // أفعال مقترنة بـ über (+ Akk دائماً) و an/vor (+ Dat في الحالة المجردة)
  temporalPrecisionSeitVorBinnen,   // الدقة الزمنية: seit (مستمر بالحاضر) مقابل vor (منقضٍ) و binnen (مهلة)
  genitivePrepWithVonFallback,      // حروف الجر المضافة وإلزامية التعويض بـ von + Dativ عند غياب الأداة في الجمع
  dankMittelsAnhandGovernance,      // إدارة الحالات مع dank و mittels و anhand في النصوص التقنية
  directionalVsStaticOperational,   // التمييز التشغيلي بين السكون (in Betrieb sein) والحركة (in Betrieb nehmen)
}

/// نموذج تطبيقي لدلالات حروف الجر وإعرابها
class PrepositionalSemanticsExemplar {
  final String id;
  final PrepositionEngineeringDomain domain;
  final PrepositionalSemanticsCategory category;
  final String cefrLevel;
  final String prepositionPattern;
  final String germanSentence;
  final String commonErrorTrap;
  final String arabicExplanation;
  final String governedCase; // 'Dativ', 'Akkusativ', 'Genitiv', 'Dativ (von-Ersatz)'

  const PrepositionalSemanticsExemplar({
    required this.id,
    required this.domain,
    required this.category,
    required this.cefrLevel,
    required this.prepositionPattern,
    required this.germanSentence,
    required this.commonErrorTrap,
    required this.arabicExplanation,
    required this.governedCase,
  });
}

/// نتيجة الفحص الآلي لصحة حرف الجر والحالة الإعرابية
class PrepositionValidationResult {
  final bool isValid;
  final String diagnosedRule;
  final String arabicFeedback;
  final String correctedSuggestion;

  const PrepositionValidationResult({
    required this.isValid,
    required this.diagnosedRule,
    required this.arabicFeedback,
    required this.correctedSuggestion,
  });
}

/// بيانات قياس الأداء والإحصاءات الداخلية للمحرك
class PrepositionalSemanticsTelemetry {
  final int totalExemplars;
  final int validationRuns;
  final int caughtAbstractWechselErrors;
  final int caughtGenitiveFallbackErrors;
  final int caughtSeitTenseErrors;

  const PrepositionalSemanticsTelemetry({
    required this.totalExemplars,
    required this.validationRuns,
    required this.caughtAbstractWechselErrors,
    required this.caughtGenitiveFallbackErrors,
    required this.caughtSeitTenseErrors,
  });
}

/// المحرك الأساسي لضبط دلالات حروف الجر والحالات الإعرابية المجردة (C1–C2)
class PrepositionalSemanticsEngine {
  int _validationRuns = 0;
  int _caughtAbstractWechselErrors = 0;
  int _caughtGenitiveFallbackErrors = 0;
  int _caughtSeitTenseErrors = 0;

  static const List<PrepositionalSemanticsExemplar> _exemplars = [
    PrepositionalSemanticsExemplar(
      id: 'prep_01',
      domain: PrepositionEngineeringDomain.renewableEnergyGrid,
      category: PrepositionalSemanticsCategory.abstractWechselpraepositionAufIn,
      cefrLevel: 'C1',
      prepositionPattern: 'beruhen / basieren auf + [Dativ] vs. verweisen / reagieren auf + [Akkusativ]',
      germanSentence:
          'Die Netzprognose basiert auf einer hochauflösenden Zeitreihe der letzten zwölf Monate.',
      commonErrorTrap: 'basiert auf eine hochauflösende Zeitreihe (استخدام Akkusativ مع basieren/beruhen)',
      arabicExplanation:
          'الأفعال الدالة على الارتكاز الثابت (basieren auf, beruhen auf) تحكم المجرور (Dativ)، أما أفعال التوجيه والاستجابة (verweisen auf, reagieren auf) فتحكم المنصوب (Akkusativ).',
      governedCase: 'Dativ',
    ),
    PrepositionalSemanticsExemplar(
      id: 'prep_02',
      domain: PrepositionEngineeringDomain.aerospaceAndAviation,
      category: PrepositionalSemanticsCategory.abstractWechselpraepositionAufIn,
      cefrLevel: 'C1',
      prepositionPattern: 'sich stützen / zurückgreifen auf + [Akkusativ]',
      germanSentence:
          'Das Avioniksystem greift bei einem Primärausfall sofort auf den redundanten Datenbus zurück.',
      commonErrorTrap: 'greift auf dem redundanten Datenbus zurück',
      arabicExplanation:
          'الفعل zurückgreifen auf يفيد التوجه واللجوء إلى مصدر بديل، لذا يفرض حالة النصب (Akkusativ: auf den redundanten Datenbus).',
      governedCase: 'Akkusativ',
    ),
    PrepositionalSemanticsExemplar(
      id: 'prep_03',
      domain: PrepositionEngineeringDomain.industrialRobotics,
      category: PrepositionalSemanticsCategory.abstractUeberVorAnValency,
      cefrLevel: 'C1',
      prepositionPattern: 'verfügen über / diskutieren über + [Akkusativ]',
      germanSentence:
          'Der neue Knickarmroboter verfügt über einen integrierten Drehmomentsensor in jeder Achse.',
      commonErrorTrap: 'verfügt über einem integrierten Drehmomentsensor (وضع Dativ بعد über المجردة)',
      arabicExplanation:
          'في المعاني المجردة والمرتبطة بتكافؤ الأفعال (verfügen über, berichten über, nachdenken über)، يفرض حرف الجر über حالة النصب (Akkusativ) دائماً.',
      governedCase: 'Akkusativ',
    ),
    PrepositionalSemanticsExemplar(
      id: 'prep_04',
      domain: PrepositionEngineeringDomain.civilInfrastructure,
      category: PrepositionalSemanticsCategory.abstractUeberVorAnValency,
      cefrLevel: 'C2',
      prepositionPattern: 'zweifeln an / leiden an / arbeiten an + [Dativ]',
      germanSentence:
          'Kein Prüfingenieur zweifelt an der Tragfähigkeit der vorgespannten Brückensegmente.',
      commonErrorTrap: 'zweifelt an die Tragfähigkeit',
      arabicExplanation:
          'الفعل zweifeln an (يشك في) يأخذ دائماً حالة الجر (Dativ: an der Tragfähigkeit)، على عكس denken an الذي يأخذ Akkusativ.',
      governedCase: 'Dativ',
    ),
    PrepositionalSemanticsExemplar(
      id: 'prep_05',
      domain: PrepositionEngineeringDomain.materialScience,
      category: PrepositionalSemanticsCategory.temporalPrecisionSeitVorBinnen,
      cefrLevel: 'C1',
      prepositionPattern: 'seit + [Dativ] + [Präsens] (andauernder Zustand)',
      germanSentence:
          'Seit drei Wochen läuft der Dauertest der Keramikbeschichtung ohne Unterbrechung.',
      commonErrorTrap: 'Seit drei Wochen lief der Dauertest... (استخدام الماضي مع حدث مستمر حتى الآن)',
      arabicExplanation:
          'حرف الجر seit يدل على حدث بدأ في الماضي ولا يزال مستمراً في الحاضر، لذا يتطلب زمن المضارع (Präsens: läuft) وليس الماضي.',
      governedCase: 'Dativ',
    ),
    PrepositionalSemanticsExemplar(
      id: 'prep_06',
      domain: PrepositionEngineeringDomain.maritimeLogistics,
      category: PrepositionalSemanticsCategory.temporalPrecisionSeitVorBinnen,
      cefrLevel: 'C2',
      prepositionPattern: 'binnen + [Genitiv / Dativ] (enge Frist) vs. innerhalb von + [Dativ]',
      germanSentence:
          'Die Entladung des Massengutfrachters erfolgte binnen eines einzigen Arbeitstages.',
      commonErrorTrap: 'binnen einen einzigen Arbeitstag (استخدام Akkusativ مع binnen)',
      arabicExplanation:
          'حرف الجر الزمني binnen (خلال مهلة وجيزة) يحكم المضاف إليه (Genitiv: binnen eines Arbeitstages) أو المجرور في الجمع غير المعرف.',
      governedCase: 'Genitiv',
    ),
    PrepositionalSemanticsExemplar(
      id: 'prep_07',
      domain: PrepositionEngineeringDomain.renewableEnergyGrid,
      category: PrepositionalSemanticsCategory.genitivePrepWithVonFallback,
      cefrLevel: 'C2',
      prepositionPattern: 'aufgrund / wegen + [von + Dativ] bei artikellosem Plural',
      germanSentence:
          'Aufgrund von Netzengpässen mussten zwei Windparks vorübergehend abgeregelt werden.',
      commonErrorTrap: 'Aufgrund Netzengpässen (إسقاط von أمام اسم جمع مجرد لا تظهر عليه علامة المضاف إليه)',
      arabicExplanation:
          'عندما يلي حرف الجر المضاف (aufgrund / wegen / trotz / innerhalb) اسم جمع خالٍ من الأداة والصفة (Netzengpässen)، يلزم التعويض بـ von + Dativ.',
      governedCase: 'Dativ (von-Ersatz)',
    ),
    PrepositionalSemanticsExemplar(
      id: 'prep_08',
      domain: PrepositionEngineeringDomain.aerospaceAndAviation,
      category: PrepositionalSemanticsCategory.genitivePrepWithVonFallback,
      cefrLevel: 'C2',
      prepositionPattern: 'innerhalb von + [Dativ] bei Zahlwort + Nomen ohne Artikel',
      germanSentence:
          'Die Notfalltelemetrie synchronisiert sich innerhalb von fünf Millisekunden.',
      commonErrorTrap: 'innerhalb fünf Millisekunden (حذف von أو إهمال Genitiv)',
      arabicExplanation:
          'مع الأعداد غير المسبوقة بأداة (fünf Millisekunden) والتي لا تظهر فيها علامة المضاف إليه بوضوح، نستخدم الصيغة القياسية (innerhalb von + Dativ).',
      governedCase: 'Dativ (von-Ersatz)',
    ),
    PrepositionalSemanticsExemplar(
      id: 'prep_09',
      domain: PrepositionEngineeringDomain.industrialRobotics,
      category: PrepositionalSemanticsCategory.dankMittelsAnhandGovernance,
      cefrLevel: 'C1',
      prepositionPattern: 'anhand + [Genitiv] (auf Basis von Dokumenten/Daten)',
      germanSentence:
          'Anhand der präzisen Laserprotokolle ließ sich der Kalibrierungsfehler exakt lokalisieren.',
      commonErrorTrap: 'Anhand den präzisen Laserprotokollen',
      arabicExplanation:
          'حرف الجر anhand (استناداً إلى) يحكم المضاف إليه (Genitiv: anhand der Laserprotokolle)، ولا يُستخدم بالجر إلا مع von في الجمع المجرد.',
      governedCase: 'Genitiv',
    ),
    PrepositionalSemanticsExemplar(
      id: 'prep_10',
      domain: PrepositionEngineeringDomain.civilInfrastructure,
      category: PrepositionalSemanticsCategory.dankMittelsAnhandGovernance,
      cefrLevel: 'C2',
      prepositionPattern: 'dank + [Genitiv oder Dativ]',
      germanSentence:
          'Dank des innovativen Dämpfungssystems überstand das Viadukt die Böen schadlos.',
      commonErrorTrap: 'Dank das innovative Dämpfungssystem (استخدام Akkusativ مع dank)',
      arabicExplanation:
          'حرف الجر dank (بفضل) يحكم المضاف إليه في الأسلوب الرسمي (dank des Systems) أو المجرور (dank dem System)، لكنه لا يأخذ Akkusativ أبداً.',
      governedCase: 'Genitiv',
    ),
    PrepositionalSemanticsExemplar(
      id: 'prep_11',
      domain: PrepositionEngineeringDomain.materialScience,
      category: PrepositionalSemanticsCategory.dankMittelsAnhandGovernance,
      cefrLevel: 'C2',
      prepositionPattern: 'mittels + [Genitiv] (ohne von bei Singular mit Artikel/Adjektiv)',
      germanSentence:
          'Mittels eines Elektronenmikroskops wurde die Rissausbreitung im Mikrometerbereich vermessen.',
      commonErrorTrap: 'Mittels einem Elektronenmikroskop',
      arabicExplanation:
          'حرف الجر mittels (بواسطة أداة/وسيلة) يحكم المضاف إليه (Genitiv: mittels eines Elektronenmikroskops) في اللغة الفصحى.',
      governedCase: 'Genitiv',
    ),
    PrepositionalSemanticsExemplar(
      id: 'prep_12',
      domain: PrepositionEngineeringDomain.maritimeLogistics,
      category: PrepositionalSemanticsCategory.directionalVsStaticOperational,
      cefrLevel: 'C1',
      prepositionPattern: 'in Betrieb nehmen [Akkusativ-Richtung] vs. in Betrieb sein [Dativ-Zustand]',
      germanSentence:
          'Die neue Schleusenkammer wird morgen feierlich in den Vollbetrieb genommen.',
      commonErrorTrap: 'in dem Vollbetrieb genommen (الخلط بين الحالة الساكنة والإدخال في الخدمة)',
      arabicExplanation:
          'التعبير in [den] Betrieb nehmen يدل على الانتقال إلى حالة التشغيل (حركة -> Akkusativ)، بينما in [dem] Betrieb sein يدل على البقاء في الخدمة (سكون -> Dativ).',
      governedCase: 'Akkusativ',
    ),
    PrepositionalSemanticsExemplar(
      id: 'prep_13',
      domain: PrepositionEngineeringDomain.renewableEnergyGrid,
      category: PrepositionalSemanticsCategory.directionalVsStaticOperational,
      cefrLevel: 'C1',
      prepositionPattern: 'auf dem Prüfstand stehen [Dativ] vs. auf den Prüfstand stellen [Akkusativ]',
      germanSentence:
          'Der Prototyp des Hochspannungsschalters steht derzeit auf dem Prüfstand.',
      commonErrorTrap: 'steht auf den Prüfstand',
      arabicExplanation:
          'الفعل stehen يدل على الموضع الثابت (أين؟) لذا يأخذ Dativ: auf dem Prüfstand.',
      governedCase: 'Dativ',
    ),
    PrepositionalSemanticsExemplar(
      id: 'prep_14',
      domain: PrepositionEngineeringDomain.aerospaceAndAviation,
      category: PrepositionalSemanticsCategory.abstractUeberVorAnValency,
      cefrLevel: 'C2',
      prepositionPattern: 'warnen vor / schützen vor + [Dativ]',
      germanSentence:
          'Die Bordelektronik warnt frühzeitig vor einem möglichen Druckabfall in der Kabine.',
      commonErrorTrap: 'warnt vor einen möglichen Druckabfall',
      arabicExplanation:
          'الأفعال warnen vor و schützen vor تحكم دائماً حالة المجرور (Dativ: vor einem möglichen Druckabfall).',
      governedCase: 'Dativ',
    ),
    PrepositionalSemanticsExemplar(
      id: 'prep_15',
      domain: PrepositionEngineeringDomain.industrialRobotics,
      category: PrepositionalSemanticsCategory.temporalPrecisionSeitVorBinnen,
      cefrLevel: 'C1',
      prepositionPattern: 'vor + [Dativ] + [Präteritum/Perfekt] (abgeschlossener Zeitpunkt)',
      germanSentence:
          'Vor genau zwei Stunden wurde die neue Steuerungssoftware aufgespielt.',
      commonErrorTrap: 'Seit zwei Stunden wurde die Software aufgespielt (الخلط بين حدث منتهٍ منذ ساعتين وحدث مستمر)',
      arabicExplanation:
          'عند الحديث عن نقطة زمنية منتهية في الماضي (منذ ساعتين تم التثبيت)، نستخدم vor + Dativ مع زمن الماضي وليس seit.',
      governedCase: 'Dativ',
    ),
    PrepositionalSemanticsExemplar(
      id: 'prep_16',
      domain: PrepositionEngineeringDomain.civilInfrastructure,
      category: PrepositionalSemanticsCategory.genitivePrepWithVonFallback,
      cefrLevel: 'C2',
      prepositionPattern: 'angesichts + [Genitiv] (ohne Artikel: angesichts zunehmender Belastung)',
      germanSentence:
          'Angesichts des steigenden Verkehrsaufkommens wird die Fahrbahnverbreiterung vorgezogen.',
      commonErrorTrap: 'Angesichts dem steigenden Verkehrsaufkommen',
      arabicExplanation:
          'حرف الجر angesichts (في ضوء / إزاء) يحكم المضاف إليه (Genitiv) دائماً في النصوص الهندسية والإدارية.',
      governedCase: 'Genitiv',
    ),
  ];

  List<PrepositionalSemanticsExemplar> get allExemplars => List.unmodifiable(_exemplars);

  List<PrepositionalSemanticsExemplar> getByDomain(PrepositionEngineeringDomain domain) {
    return _exemplars.where((e) => e.domain == domain).toList(growable: false);
  }

  List<PrepositionalSemanticsExemplar> getByCategory(PrepositionalSemanticsCategory category) {
    return _exemplars.where((e) => e.category == category).toList(growable: false);
  }

  PrepositionalSemanticsExemplar pickExemplarForDrill({
    PrepositionEngineeringDomain? domain,
    int seed = 4979,
  }) {
    final pool = domain == null ? _exemplars : getByDomain(domain);
    if (pool.isEmpty) {
      return _exemplars.first;
    }
    final rng = Random(seed);
    return pool[rng.nextInt(pool.length)];
  }

  /// التحقق الذكي من صحة حروف الجر والحالات الإعرابية المجردة
  PrepositionValidationResult validatePrepositionalPhrase(String sentence) {
    _validationRuns++;
    final normalized = sentence.trim();
    final lower = normalized.toLowerCase();

    // 1. كشف استخدام Akkusativ مع basieren / beruhen auf أو Dativ مع verfügen über
    if (RegExp(r'\b(basiert|basieren|beruht|beruhen)\s+auf\s+(eine|einen|die|den|das)\b',
            caseSensitive: false)
        .hasMatch(lower)) {
      _caughtAbstractWechselErrors++;
      return const PrepositionValidationResult(
        isValid: false,
        diagnosedRule: 'basieren / beruhen auf + Dativ (nicht Akkusativ)',
        arabicFeedback:
            'الفعلان (basieren auf / beruhen auf) يتطلبان حالة المجرور (Dativ: auf einer / auf dem / auf den) وليس النصب.',
        correctedSuggestion: 'basiert / beruht auf [einer/einem/dem/der/den]',
      );
    }

    if (RegExp(r'\b(verfügt|verfügen)\s+über\s+(einem|einer|dem|der)\b',
            caseSensitive: false)
        .hasMatch(lower)) {
      _caughtAbstractWechselErrors++;
      return const PrepositionValidationResult(
        isValid: false,
        diagnosedRule: 'verfügen über + Akkusativ (abstrakte Rektion)',
        arabicFeedback:
            'حرف الجر über في المعنى المجرد مع verfügen يحكم حالة النصب (Akkusativ: über einen / eine / ein) وليس المجرور.',
        correctedSuggestion: 'verfügt über [einen/eine/ein/die/den/das]',
      );
    }

    // 2. كشف سقوط von قبل اسم جمع مجرد بعد aufgrund / wegen
    if (RegExp(r'\b(aufgrund|wegen)\s+[A-ZÄÖÜ][a-zäöüß]+en\b')
        .hasMatch(normalized)) {
      _caughtGenitiveFallbackErrors++;
      return const PrepositionValidationResult(
        isValid: false,
        diagnosedRule: 'von-Ersatz bei artikellosem Plural nach aufgrund / wegen',
        arabicFeedback:
            'عند مجيء اسم جمع خالٍ من الأداة بعد (aufgrund / wegen)، يجب إدراج von لتعويض المضاف إليه: aufgrund von ...',
        correctedSuggestion: 'aufgrund von / wegen [von] + [Plural-Dativ]',
      );
    }

    // 3. كشف استخدام الماضي wurde مع seit لحدث لم يكتمل أو الخلط الزمني
    if (RegExp(r'^seit\s+.+\s+wurde\b', caseSensitive: false).hasMatch(lower)) {
      _caughtSeitTenseErrors++;
      return const PrepositionValidationResult(
        isValid: false,
        diagnosedRule: 'seit + Präsens (andauernd) vs. vor + Präteritum/Perfekt (abgeschlossen)',
        arabicFeedback:
            'لحدث منتهٍ في نقطة زمنية ماضية مع (wurde)، نستخدم vor بدلاً من seit؛ أما seit فتتطلب زمن المضارع للاستمرار.',
        correctedSuggestion: 'Vor [Zeitraum] wurde ... (abgeschlossen) / Seit [Zeitraum] läuft ... (andauernd)',
      );
    }

    return const PrepositionValidationResult(
      isValid: true,
      diagnosedRule: 'Korrekte C1/C2-Präpositionsrektion und Zeitsemantik',
      arabicFeedback: 'حرف الجر والحالة الإعرابية والدلالة الزمنية سليمة تماماً.',
      correctedSuggestion: '',
    );
  }

  PrepositionalSemanticsTelemetry get telemetry => PrepositionalSemanticsTelemetry(
        totalExemplars: _exemplars.length,
        validationRuns: _validationRuns,
        caughtAbstractWechselErrors: _caughtAbstractWechselErrors,
        caughtGenitiveFallbackErrors: _caughtGenitiveFallbackErrors,
        caughtSeitTenseErrors: _caughtSeitTenseErrors,
      );
}
