import 'dart:math';

/// مجالات الهندسة والتقنية المعتمدة في المنهج (خالية من المخاطر القانونية والطبية)
enum PronominalEngineeringDomain {
  renewableEnergyGrid,
  aerospaceAndAviation,
  industrialRobotics,
  civilInfrastructure,
  materialScience,
  maritimeLogistics,
}

/// تصنيف أنماط الضمائر الانعكاسية والتبادلية والظروف الضميرية (C1–C2)
enum ReflexivePronominalCategory {
  dativeReflexiveWithAkkObject,   // الضمير الانعكاسي في حالة Dativ لوجود مفعول به منصوب
  accusativeReflexiveMandatory,   // الأفعال الانعكاسية الإلزامية في حالة Akkusativ
  reciprocalEinanderVsSich,       // التمييز بين التبادلية (einander) والانعكاس الذاتي (sich)
  fusedPrepositionEinander,       // دمج حرف الجر مع einander (aufeinander, miteinander)
  inanimatePronominalDaR,         // الظروف الضميرية (da(r)-) للأشياء والمفاهيم المجردة
  animatePrepPersonalPronoun,     // حرف الجر + ضمير شخصي للأشخاص والفرق الهندسية (منع da(r)-)
}

/// نموذج تطبيقي للضمائر الانعكاسية والتبادلية والظروف الضميرية
class ReflexivePronominalExemplar {
  final String id;
  final PronominalEngineeringDomain domain;
  final ReflexivePronominalCategory category;
  final String cefrLevel;
  final String targetStructure;
  final String germanSentence;
  final String commonErrorTrap;
  final String arabicExplanation;
  final bool requiresDativeReflexive;
  final bool refersToAnimateEntity;

  const ReflexivePronominalExemplar({
    required this.id,
    required this.domain,
    required this.category,
    required this.cefrLevel,
    required this.targetStructure,
    required this.germanSentence,
    required this.commonErrorTrap,
    required this.arabicExplanation,
    required this.requiresDativeReflexive,
    required this.refersToAnimateEntity,
  });
}

/// نتيجة التحقق الذكي من صحة الضمائر الانعكاسية والظروف الضميرية
class PronominalValidationResult {
  final bool isValid;
  final String diagnosedRule;
  final String arabicFeedback;
  final String correctedSuggestion;

  const PronominalValidationResult({
    required this.isValid,
    required this.diagnosedRule,
    required this.arabicFeedback,
    required this.correctedSuggestion,
  });
}

/// بيانات قياس الأداء والإحصاءات الداخلية للمحرك
class ReflexivePronominalTelemetry {
  final int totalExemplars;
  final int validationRuns;
  final int caughtReflexiveCaseErrors;
  final int caughtReciprocalAmbiguities;
  final int caughtAnimacyPronominalErrors;

  const ReflexivePronominalTelemetry({
    required this.totalExemplars,
    required this.validationRuns,
    required this.caughtReflexiveCaseErrors,
    required this.caughtReciprocalAmbiguities,
    required this.caughtAnimacyPronominalErrors,
  });
}

/// المحرك الأساسي لضبط الضمائر الانعكاسية والتبادلية والظروف الضميرية (C1–C2)
class ReflexiveReciprocalPronominalEngine {
  int _validationRuns = 0;
  int _caughtReflexiveCaseErrors = 0;
  int _caughtReciprocalAmbiguities = 0;
  int _caughtAnimacyPronominalErrors = 0;

  static const List<ReflexivePronominalExemplar> _exemplars = [
    ReflexivePronominalExemplar(
      id: 'pron_01',
      domain: PronominalEngineeringDomain.renewableEnergyGrid,
      category: ReflexivePronominalCategory.dativeReflexiveWithAkkObject,
      cefrLevel: 'C1',
      targetStructure: 'sich [Dativ: mir/dir] + [Akkusativobjekt] + merken / ansehen',
      germanSentence:
          'Ich schaue mir das Schaltbild des Umspannwerks genau an, bevor ich den Trennschalter freigebe.',
      commonErrorTrap: 'Ich schaue mich das Schaltbild an (استخدام Akkusativ رغم وجود مفعول به منصوب)',
      arabicExplanation:
          'عند وجود مفعول به منصوب صريح (das Schaltbild)، يتحول الضمير الانعكاسي إلى حالة المجرور غير المباشر (Dativ: mir / dir).',
      requiresDativeReflexive: true,
      refersToAnimateEntity: false,
    ),
    ReflexivePronominalExemplar(
      id: 'pron_02',
      domain: PronominalEngineeringDomain.aerospaceAndAviation,
      category: ReflexivePronominalCategory.dativeReflexiveWithAkkObject,
      cefrLevel: 'C1',
      targetStructure: 'Du musst dir [Dativ] + [Akkusativobjekt] + merken / einprägen',
      germanSentence:
          'Du musst dir die exakten Toleranzgrenzen der Turbinenwelle für die Abnahmeprüfung merken.',
      commonErrorTrap: 'Du musst dich die Grenzen merken (الخلط بين sich merken و sich erinnern)',
      arabicExplanation:
          'الفعل sich merken يأخذ مفعولاً به منصوباً (die Grenzen)، لذا يأتي الضمير الانعكاسي دائماً في حالة Dativ (dir)، بخلاف sich erinnern an (dich).',
      requiresDativeReflexive: true,
      refersToAnimateEntity: false,
    ),
    ReflexivePronominalExemplar(
      id: 'pron_03',
      domain: PronominalEngineeringDomain.industrialRobotics,
      category: ReflexivePronominalCategory.accusativeReflexiveMandatory,
      cefrLevel: 'C1',
      targetStructure: 'sich [Akkusativ: mich/dich] + verlassen auf / konzentrieren auf',
      germanSentence:
          'Ich verlasse mich während der Nachtschicht vollständig auf die redundante Kollisionserkennung.',
      commonErrorTrap: 'Ich verlasse mir auf die Erkennung',
      arabicExplanation:
          'الأفعال الانعكاسية المقترنة بحرف جر (sich verlassen auf / sich konzentrieren auf) تأخذ الضمير الانعكاسي في حالة Akkusativ دائماً (mich / dich).',
      requiresDativeReflexive: false,
      refersToAnimateEntity: false,
    ),
    ReflexivePronominalExemplar(
      id: 'pron_04',
      domain: PronominalEngineeringDomain.civilInfrastructure,
      category: ReflexivePronominalCategory.reciprocalEinanderVsSich,
      cefrLevel: 'C2',
      targetStructure: '[Subjekt Plural] + [Verb] + einander / sich gegenseitig',
      germanSentence:
          'Die beiden Brückensegmente stützen einander im Scheitelpunkt ohne zusätzliche Zuganker.',
      commonErrorTrap: 'Die Segmente stützen sich (غموض بين أن كل جزء يدعم نفسه أو يدعم الآخر)',
      arabicExplanation:
          'في النصوص الهندسية الدقيقة، نستخدم einander أو sich gegenseitig لرفع اللبس بين الفعل الانعكاسي الفردي والفعل التبادلي المتبادل.',
      requiresDativeReflexive: false,
      refersToAnimateEntity: false,
    ),
    ReflexivePronominalExemplar(
      id: 'pron_05',
      domain: PronominalEngineeringDomain.materialScience,
      category: ReflexivePronominalCategory.fusedPrepositionEinander,
      cefrLevel: 'C2',
      targetStructure: '[Präposition + einander zusammengeschrieben] (aufeinander, miteinander, voneinander)',
      germanSentence:
          'Die beiden Keramikschichten sind thermisch optimal aufeinander abgestimmt.',
      commonErrorTrap: 'auf einander / auf sich abgestimmt (فصل حرف الجر إملائياً أو استخدام auf sich)',
      arabicExplanation:
          'عند دخول حرف الجر على einander يُكتب التركيب كلمة واحدة متصلة (aufeinander, miteinander, voneinander) ولا يصح استبداله بـ auf sich للمعنى التبادلي.',
      requiresDativeReflexive: false,
      refersToAnimateEntity: false,
    ),
    ReflexivePronominalExemplar(
      id: 'pron_06',
      domain: PronominalEngineeringDomain.maritimeLogistics,
      category: ReflexivePronominalCategory.fusedPrepositionEinander,
      cefrLevel: 'C2',
      targetStructure: 'voneinander abweichen / miteinander kommunizieren',
      germanSentence:
          'Die Messwerte der beiden Echolote weichen um weniger als zwei Millimeter voneinander ab.',
      commonErrorTrap: 'von sich abweichen',
      arabicExplanation:
          'يعبر التركيب المدمج voneinander عن التباعد أو الاختلاف المتبادل بين طرفين أو جهازين، ويُكتب متصلاً دائماً.',
      requiresDativeReflexive: false,
      refersToAnimateEntity: false,
    ),
    ReflexivePronominalExemplar(
      id: 'pron_07',
      domain: PronominalEngineeringDomain.renewableEnergyGrid,
      category: ReflexivePronominalCategory.inanimatePronominalDaR,
      cefrLevel: 'C1',
      targetStructure: 'da(r)- + [Präposition] für unbelebte Dinge / Prozesse',
      germanSentence:
          'Der Energiespeicher ist betriebsbereit; wir rechnen fest damit, dass er die Lastspitze abfängt.',
      commonErrorTrap: 'wir rechnen fest mit ihm (استخدام ضمير شخصي لغير العاقل بعد حرف جر)',
      arabicExplanation:
          'عند الإحالة إلى شيء غير عاقل أو عملية تقنية (Energiespeicher) بعد حرف جر، نستخدم الظرف الضميري المركب (damit / darauf / daran) بدلاً من الضمير الشخصي.',
      requiresDativeReflexive: false,
      refersToAnimateEntity: false,
    ),
    ReflexivePronominalExemplar(
      id: 'pron_08',
      domain: PronominalEngineeringDomain.aerospaceAndAviation,
      category: ReflexivePronominalCategory.animatePrepPersonalPronoun,
      cefrLevel: 'C1',
      targetStructure: '[Präposition] + [Personalpronomen] für Personen / Teams',
      germanSentence:
          'Die leitende Prüfingenieurin hat die Simulation freigegeben; wir stimmen uns direkt mit ihr ab.',
      commonErrorTrap: 'wir stimmen uns direkt damit ab (استخدام damit للإشارة إلى شخص عاقل)',
      arabicExplanation:
          'يُحظر استخدام الظروف الضميرية (damit, darauf, davon) للإشارة إلى الأشخاص؛ بل يجب استخدام حرف الجر متبوعاً بالضمير الشخصي (mit ihr / auf ihn / von ihnen).',
      requiresDativeReflexive: false,
      refersToAnimateEntity: true,
    ),
    ReflexivePronominalExemplar(
      id: 'pron_09',
      domain: PronominalEngineeringDomain.industrialRobotics,
      category: ReflexivePronominalCategory.inanimatePronominalDaR,
      cefrLevel: 'C2',
      targetStructure: 'Kataphorisches da(r)- + dass-Satz / zu-Infinitiv',
      germanSentence:
          'Die Steuerung achtet penibel darauf, den Schwenkbereich des Arms nicht zu überschreiten.',
      commonErrorTrap: 'Die Steuerung achtet penibel auf, den Schwenkbereich... (حذف dar- قبل الجملة المصدرية)',
      arabicExplanation:
          'الفعل achten auf يتطلب وجود الظرف الضميري التمهيدي (darauf) قبل جملة المصدر أو جملة dass في الأسلوب الدقيق.',
      requiresDativeReflexive: false,
      refersToAnimateEntity: false,
    ),
    ReflexivePronominalExemplar(
      id: 'pron_10',
      domain: PronominalEngineeringDomain.civilInfrastructure,
      category: ReflexivePronominalCategory.dativeReflexiveWithAkkObject,
      cefrLevel: 'C2',
      targetStructure: 'sich [Dativ] + [Akkusativobjekt] + vorstellen / zunutze machen',
      germanSentence:
          'Das Planungsteam machte sich die geologischen Bohrdaten für die Tunneltrasse zunutze.',
      commonErrorTrap: 'machte sich [falscher Kasus bei 1./2. Person: mich] die Daten zunutze',
      arabicExplanation:
          'التعبير الثابت sich [Dativ] etwas zunutze machen يضع الضمير الانعكاسي في حالة Dativ دائماً (mir / dir / sich) لوجود مفعول به منصوب (die Bohrdaten).',
      requiresDativeReflexive: true,
      refersToAnimateEntity: false,
    ),
    ReflexivePronominalExemplar(
      id: 'pron_11',
      domain: PronominalEngineeringDomain.materialScience,
      category: ReflexivePronominalCategory.animatePrepPersonalPronoun,
      cefrLevel: 'C1',
      targetStructure: 'sich verlassen auf + [Personalpronomen für Fachpersonal]',
      germanSentence:
          'Die Werkstoffprüfer liefern präzise Messreihen; die Konstruktionsabteilung verlässt sich auf sie.',
      commonErrorTrap: 'verlässt sich darauf (عندما يكون المرجع فريق المهندسين أنفسهم وليس القياسات)',
      arabicExplanation:
          'بما أن المرجع هم الأشخاص (die Werkstoffprüfer)، نستخدم حرف الجر مع الضمير الشخصي (auf sie) وليس الظرف الضميري (darauf).',
      requiresDativeReflexive: false,
      refersToAnimateEntity: true,
    ),
    ReflexivePronominalExemplar(
      id: 'pron_12',
      domain: PronominalEngineeringDomain.maritimeLogistics,
      category: ReflexivePronominalCategory.reciprocalEinanderVsSich,
      cefrLevel: 'C2',
      targetStructure: 'aneinander koppeln / ineinandergreifen',
      germanSentence:
          'Die automatischen Verriegelungsbolzen greifen nahtlos ineinander, sobald der Container aufsetzt.',
      commonErrorTrap: 'greifen in sich / in einander',
      arabicExplanation:
          'الأفعال التبادلية المركبة مع حرف جر مثل ineinandergreifen و aneinanderkoppeln تستخدم einander مدمجاً للدلالة على التداخل المتبادل.',
      requiresDativeReflexive: false,
      refersToAnimateEntity: false,
    ),
    ReflexivePronominalExemplar(
      id: 'pron_13',
      domain: PronominalEngineeringDomain.renewableEnergyGrid,
      category: ReflexivePronominalCategory.dativeReflexiveWithAkkObject,
      cefrLevel: 'C1',
      targetStructure: 'sich [Dativ: mir] + etwas verbitten / vornehmen / leisten',
      germanSentence:
          'Ich nehme mir heute die vollständige Auswertung der Blindleistungskompensation vor.',
      commonErrorTrap: 'Ich nehme mich die Auswertung vor',
      arabicExplanation:
          'الفعل sich etwas vornehmen يتطلب حالة Dativ للضمير الانعكاسي (mir / dir / uns) لأن النشاط المخطط له هو المفعول به المباشر.',
      requiresDativeReflexive: true,
      refersToAnimateEntity: false,
    ),
    ReflexivePronominalExemplar(
      id: 'pron_14',
      domain: PronominalEngineeringDomain.aerospaceAndAviation,
      category: ReflexivePronominalCategory.accusativeReflexiveMandatory,
      cefrLevel: 'C1',
      targetStructure: 'sich [Akkusativ: mich/dich] + eignen für / auswirken auf',
      germanSentence:
          'Du kannst dich direkt an den Bordrechner wenden, um das Fehlerprotokoll auszulesen.',
      commonErrorTrap: 'Du kannst dir an den Bordrechner wenden',
      arabicExplanation:
          'الفعل sich wenden an يفرض حالة النصب (Akkusativ: mich / dich) على الضمير الانعكاسي دائماً.',
      requiresDativeReflexive: false,
      refersToAnimateEntity: false,
    ),
    ReflexivePronominalExemplar(
      id: 'pron_15',
      domain: PronominalEngineeringDomain.industrialRobotics,
      category: ReflexivePronominalCategory.inanimatePronominalDaR,
      cefrLevel: 'C2',
      targetStructure: 'darin bestehen, dass / zu-Infinitiv',
      germanSentence:
          'Der Hauptvorteil dieses Achsantriebs besteht darin, dass kein Getriebespiel mehr auftritt.',
      commonErrorTrap: 'besteht in dem, dass...',
      arabicExplanation:
          'الفعل bestehen in بمعنى "يكمن في" يرتبط وجوباً بالظرف الضميري darin عند التمهيد لجملة dass.',
      requiresDativeReflexive: false,
      refersToAnimateEntity: false,
    ),
    ReflexivePronominalExemplar(
      id: 'pron_16',
      domain: PronominalEngineeringDomain.civilInfrastructure,
      category: ReflexivePronominalCategory.fusedPrepositionEinander,
      cefrLevel: 'C2',
      targetStructure: 'gegeneinander verspannen / nebeneinander verlaufen',
      germanSentence:
          'Die beiden Versorgungstunnel verlaufen parallel nebeneinander durch das Kalkgestein.',
      commonErrorTrap: 'neben einander (الكتابة المنفصلة المحظورة إملائياً)',
      arabicExplanation:
          'تُكتب كافة تراكيب حروف الجر مع einander متصلة كلمة واحدة (nebeneinander, gegeneinander, untereinander).',
      requiresDativeReflexive: false,
      refersToAnimateEntity: false,
    ),
  ];

  List<ReflexivePronominalExemplar> get allExemplars => List.unmodifiable(_exemplars);

  List<ReflexivePronominalExemplar> getByDomain(PronominalEngineeringDomain domain) {
    return _exemplars.where((e) => e.domain == domain).toList(growable: false);
  }

  List<ReflexivePronominalExemplar> getByCategory(ReflexivePronominalCategory category) {
    return _exemplars.where((e) => e.category == category).toList(growable: false);
  }

  ReflexivePronominalExemplar pickExemplarForDrill({
    PronominalEngineeringDomain? domain,
    int seed = 4976,
  }) {
    final pool = domain == null ? _exemplars : getByDomain(domain);
    if (pool.isEmpty) {
      return _exemplars.first;
    }
    final rng = Random(seed);
    return pool[rng.nextInt(pool.length)];
  }

  /// التحقق الذكي من الضمائر الانعكاسية والتبادلية والظروف الضميرية
  PronominalValidationResult validatePronominalUsage(
    String sentence, {
    required bool refersToPersonOrTeam,
  }) {
    _validationRuns++;
    final normalized = sentence.trim();
    final lower = normalized.toLowerCase();

    // 1. كشف استخدام Akkusativ (mich/dich) مع أفعال تأخذ Dativ لوجود مفعول به منصوب
    final dativeReflexiveVerbTrap = RegExp(
      r'\b(schaue|sehe|merke|nehme|kaufe|stelle)\s+(mich|dich)\s+(das|den|die|ein|eine|einen)\b',
      caseSensitive: false,
    );
    if (dativeReflexiveVerbTrap.hasMatch(lower)) {
      _caughtReflexiveCaseErrors++;
      final fixed = normalized
          .replaceAll(RegExp(r'\bmich\b', caseSensitive: false), 'mir')
          .replaceAll(RegExp(r'\bdich\b', caseSensitive: false), 'dir');
      return PronominalValidationResult(
        isValid: false,
        diagnosedRule: 'Dativ-Reflexivpronomen (mir/dir) bei vorhandenem Akkusativobjekt',
        arabicFeedback:
            'بما أن الجملة تحتوي على مفعول به منصوب صريح، يجب وضع الضمير الانعكاسي في حالة Dativ (mir / dir) وليس (mich / dich).',
        correctedSuggestion: fixed,
      );
    }

    // 2. كشف الفصل الإملائي الخاطئ لـ auf einander / mit einander / von einander
    final splitEinanderRegex = RegExp(
      r'\b(auf|mit|von|an|in|gegen|neben|unter|über|nach)\s+einander\b',
      caseSensitive: false,
    );
    if (splitEinanderRegex.hasMatch(lower)) {
      _caughtReciprocalAmbiguities++;
      final fixed = normalized.replaceAllMapped(
        splitEinanderRegex,
        (m) => '${m.group(1)}einander',
      );
      return PronominalValidationResult(
        isValid: false,
        diagnosedRule: 'Zusammenschreibung von Präposition + einander',
        arabicFeedback:
            'تُكتب حروف الجر المتصلة بـ einander دائماً كلمة واحدة متصلة (مثل: aufeinander, miteinander, voneinander).',
        correctedSuggestion: fixed,
      );
    }

    // 3. كشف استخدام da(r)- للإشارة إلى أشخاص عاقلين
    final darCompoundRegex = RegExp(
      r'\b(damit|darauf|daran|davon|dazu|darüber|darin|dagegen|danach)\b',
      caseSensitive: false,
    );
    if (refersToPersonOrTeam && darCompoundRegex.hasMatch(lower)) {
      _caughtAnimacyPronominalErrors++;
      return const PronominalValidationResult(
        isValid: false,
        diagnosedRule: 'Präposition + Personalpronomen statt da(r)- bei Personen',
        arabicFeedback:
            'لا يجوز استخدام الظروف الضميرية (damit / darauf / daran) للإشارة إلى الأشخاص؛ استخدم حرف الجر مع الضمير الشخصي (مثل: mit ihr / auf ihn / mit ihnen).',
        correctedSuggestion: '[Präposition + Personalpronomen (ihn/ihr/ihnen)]',
      );
    }

    return const PronominalValidationResult(
      isValid: true,
      diagnosedRule: 'Korrekte C1/C2-Reflexiv-, Reziprok- und Pronominalstruktur',
      arabicFeedback: 'استخدام الضمير الانعكاسي والتبادلي والظرف الضميري سليم تماماً.',
      correctedSuggestion: '',
    );
  }

  ReflexivePronominalTelemetry get telemetry => ReflexivePronominalTelemetry(
        totalExemplars: _exemplars.length,
        validationRuns: _validationRuns,
        caughtReflexiveCaseErrors: _caughtReflexiveCaseErrors,
        caughtReciprocalAmbiguities: _caughtReciprocalAmbiguities,
        caughtAnimacyPronominalErrors: _caughtAnimacyPronominalErrors,
      );
}
