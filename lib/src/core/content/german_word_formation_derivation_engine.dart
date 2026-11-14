import 'dart:collection';
import 'dart:math';

/// مجالات الهندسة والتقنية المعتمدة في المنهج (خالية من المخاطر القانونية والطبية)
enum DerivationEngineeringDomain {
  renewableEnergyGrid('Erneuerbare Energien & Netztechnik', 'الطاقة المتجددة وهندسة الشبكات'),
  aerospaceAndAviation('Luft- & Raumfahrttechnik', 'هندسة الطيران واستكشاف الفضاء'),
  industrialRobotics('Industrierobotik & Mechatronik', 'الروبوتات الصناعية والميكاترونكس'),
  civilInfrastructure('Bauingenieurwesen & Statik', 'الهندسة المدنية والمنشآت'),
  materialScience('Materialwissenschaft & Nanotechnologie', 'علم المواد والتراكيب النانوية'),
  maritimeLogistics('Maritime Schifffahrt & Hafenumschlag', 'الملاحة البحرية والشحن الدولي');

  final String de;
  final String ar;
  const DerivationEngineeringDomain(this.de, this.ar);
}

/// تصنيف قواعد الاشتقاق الصرفي وتكوين الكلمات في الألمانية (C1–C2)
enum WordFormationCategory {
  infinitiveVsUngNominalization,  // التمييز بين المصدر المؤسم (das Messen) واسم الحدث (-ung: die Messung)
  beTransitivizingPrefix,         // البادئة be- المحولة للفعل اللازم أو المجرور إلى متعدٍ مباشر
  entErVerZerSemanticPrefixes,    // دلالات البوادئ غير المنفصلة (ent- للإزالة، er- للإنجاز، ver- للتحول، zer- للتفكك)
  losVsFreiAdjectiveContrast,     // التمييز الدلالي بين -los (انعدام محايد) و -frei (خلو مرغوب من العيوب)
  passiveCapabilityBarSuffix,     // اللاحقة -bar الدالة على القابلية للمبني للمجهول (schweißbar, messbar)
  nisAndKeitGenderPluralRules,    // قواعد الجنس والجمع في -nis (das Ergebnis -> Ergebnisse) و -keit/-heit (مؤنث دائماً)
}

/// نموذج تطبيقي للاشتقاق الصرفي وتكوين المصطلحات التقنية
class WordFormationExemplar {
  final String id;
  final DerivationEngineeringDomain domain;
  final WordFormationCategory category;
  final String cefrLevel;
  final String morphemePattern;
  final String germanSentence;
  final String commonErrorTrap;
  final String arabicExplanation;
  final String derivedNounGender; // 'das', 'die', 'der', 'Verb/Adjektiv'

  const WordFormationExemplar({
    required this.id,
    required this.domain,
    required this.category,
    required this.cefrLevel,
    required this.morphemePattern,
    required this.germanSentence,
    required this.commonErrorTrap,
    required this.arabicExplanation,
    required this.derivedNounGender,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'domain': domain.name,
        'category': category.name,
        'cefrLevel': cefrLevel,
        'morphemePattern': morphemePattern,
        'germanSentence': germanSentence,
        'commonErrorTrap': commonErrorTrap,
        'arabicExplanation': arabicExplanation,
        'derivedNounGender': derivedNounGender,
      };
}

/// نتيجة الفحص الآلي لصحة الاشتقاق الصرفي
class WordFormationValidationResult {
  final bool isValid;
  final String diagnosedRule;
  final String arabicFeedback;
  final String correctedSuggestion;

  const WordFormationValidationResult({
    required this.isValid,
    required this.diagnosedRule,
    required this.arabicFeedback,
    required this.correctedSuggestion,
  });
}

/// بيانات قياس الأداء والإحصاءات الداخلية للمحرك
class WordFormationTelemetry {
  final int totalExemplars;
  final int validationRuns;
  final int caughtGenderSuffixErrors;
  final int caughtNisPluralErrors;
  final int caughtPrefixValencyErrors;

  const WordFormationTelemetry({
    required this.totalExemplars,
    required this.validationRuns,
    required this.caughtGenderSuffixErrors,
    required this.caughtNisPluralErrors,
    required this.caughtPrefixValencyErrors,
  });
}

/// المحرك الأساسي لتدريب وضبط الاشتقاق الصرفي وتكوين الكلمات (C1–C2)
class GermanWordFormationDerivationEngine {
  int _validationRuns = 0;
  int _caughtGenderSuffixErrors = 0;
  int _caughtNisPluralErrors = 0;
  int _caughtPrefixValencyErrors = 0;

  static const List<WordFormationExemplar> _exemplars = [
    WordFormationExemplar(
      id: 'wform_01',
      domain: DerivationEngineeringDomain.renewableEnergyGrid,
      category: WordFormationCategory.infinitiveVsUngNominalization,
      cefrLevel: 'C1',
      morphemePattern: 'das [Infinitiv] (Prozess) vs. die [Stamm + -ung] (Resultat/Einzelakt)',
      germanSentence:
          'Das kontinuierliche Überwachen der Netzfrequenz verhindert eine plötzliche Überlastung des Transformators.',
      commonErrorTrap: 'Die kontinuierliche Überwachen / Der Überlastung',
      arabicExplanation:
          'كل مصدر مؤسم (das Überwachen) يكون محايداً دائماً (das) ويدل على استمرار العملية، بينما الأسماء المنتهية بـ (-ung) مثل Überlastung تكون مؤنثة دائماً (die).',
      derivedNounGender: 'das',
    ),
    WordFormationExemplar(
      id: 'wform_02',
      domain: DerivationEngineeringDomain.aerospaceAndAviation,
      category: WordFormationCategory.infinitiveVsUngNominalization,
      cefrLevel: 'C1',
      morphemePattern: 'die [Verb + -ung] (immer feminin)',
      germanSentence:
          'Die präzise Kalibrierung des Höhenmessers dauerte im Hangar rund dreißig Minuten.',
      commonErrorTrap: 'Der Kalibrierung / Das Kalibrierung',
      arabicExplanation:
          'جميع الأسماء المشتقة باللاحقة (-ung) مؤنثة بلا استثناء (die Kalibrierung) وتُجمع بإضافة (-en).',
      derivedNounGender: 'die',
    ),
    WordFormationExemplar(
      id: 'wform_03',
      domain: DerivationEngineeringDomain.industrialRobotics,
      category: WordFormationCategory.beTransitivizingPrefix,
      cefrLevel: 'C1',
      morphemePattern: 'be- + Verbstamm -> direktes Akkusativobjekt (ohne Präposition)',
      germanSentence:
          'Die Ingenieure besprechen die neuen Sicherheitsabstände vor dem Probelauf.',
      commonErrorTrap: 'besprechen über die neuen Sicherheitsabstände (إبقاء حرف الجر über بعد besprechen)',
      arabicExplanation:
          'البادئة غير المنفصلة (be-) تحول الفعل المجرور (sprechen über) إلى فعل متعدٍ مباشر (besprechen + Akkusativ) دون حرف جر.',
      derivedNounGender: 'Verb/Adjektiv',
    ),
    WordFormationExemplar(
      id: 'wform_04',
      domain: DerivationEngineeringDomain.renewableEnergyGrid,
      category: WordFormationCategory.entErVerZerSemanticPrefixes,
      cefrLevel: 'C2',
      morphemePattern: 'ent- (Entfernung/Rückgängigmachen): entkoppeln, entlüften, entladen',
      germanSentence:
          'Bei einem Kurzschluss entkoppelt der Leistungsschalter das Teilnetz binnen Millisekunden.',
      commonErrorTrap: 'abkoppeln vs. entkoppeln (أسلوب تقني رفيع غير منفصل)',
      arabicExplanation:
          'البادئة (ent-) غير منفصلة وتفيد الإزالة أو الفصل أو العكس (entkoppeln = فصل، entlüften = تفريغ الهواء، entladen = تفريغ الشحنة).',
      derivedNounGender: 'Verb/Adjektiv',
    ),
    WordFormationExemplar(
      id: 'wform_05',
      domain: DerivationEngineeringDomain.materialScience,
      category: WordFormationCategory.entErVerZerSemanticPrefixes,
      cefrLevel: 'C2',
      morphemePattern: 'zer- (Zerstörung/Auflösung): zersetzen, zerkleinern, zerreißen',
      germanSentence:
          'Unter extremer UV-Strahlung zersetzt sich ungeschützter Kunststoff deutlich schneller.',
      commonErrorTrap: 'sich zersetzen (فعل غير منفصل لا يأخذ ge- في التصريف الثالث: zersetzt)',
      arabicExplanation:
          'البادئة (zer-) تدل على التفكك أو التحلل أو التلف، وهي غير منفصلة دائماً ولا تقبل البادئة ge- في التصريف الثالث.',
      derivedNounGender: 'Verb/Adjektiv',
    ),
    WordFormationExemplar(
      id: 'wform_06',
      domain: DerivationEngineeringDomain.civilInfrastructure,
      category: WordFormationCategory.entErVerZerSemanticPrefixes,
      cefrLevel: 'C1',
      morphemePattern: 'er- (Erreichen eines Ziels/Zustands): ermitteln, erproben, errichten',
      germanSentence:
          'Das Vermessungsbüro ermittelt die exakte Bodenbeschaffenheit entlang der Brückenachse.',
      commonErrorTrap: 'geermittelt (إضافة ge- قبل البادئة غير المنفصلة er-)',
      arabicExplanation:
          'البادئة (er-) غير منفصلة وتدل على التوصل إلى نتيجة أو إتمام إجراء (ermitteln = يستقصي/يحدد، erproben = يختبر عملياً).',
      derivedNounGender: 'Verb/Adjektiv',
    ),
    WordFormationExemplar(
      id: 'wform_07',
      domain: DerivationEngineeringDomain.aerospaceAndAviation,
      category: WordFormationCategory.losVsFreiAdjectiveContrast,
      cefrLevel: 'C2',
      morphemePattern: '-frei (frei von Störgrößen/Mängeln) vs. -los (ohne)',
      germanSentence:
          'Die Datenübertragung zwischen Satellit und Bodenstation verlief völlig störungsfrei.',
      commonErrorTrap: 'störungslos (استخدام -los مع العيوب والمشكلات بدلاً من -frei)',
      arabicExplanation:
          'نستخدم اللاحقة (-frei) عندما نشير إلى الخلو الإيجابي المرغوب من الأعطال أو الشوائب (störungsfrei, fehlerfrei, emissionsfrei)، بينما تفيد (-los) الغياب المحايد (drahtlos).',
      derivedNounGender: 'Verb/Adjektiv',
    ),
    WordFormationExemplar(
      id: 'wform_08',
      domain: DerivationEngineeringDomain.industrialRobotics,
      category: WordFormationCategory.losVsFreiAdjectiveContrast,
      cefrLevel: 'C1',
      morphemePattern: '-los (neutrales Fehlen eines Merkmals): berührungslos, nahtlos, drahtlos',
      germanSentence:
          'Der optische Laserscanner erfasst die Bauteilkontur berührungslos und in Echtzeit.',
      commonErrorTrap: 'berührungsfrei (أكثر ندرة من berührungslos في توصيف آلية عمل الحساسات)',
      arabicExplanation:
          'تصف اللاحقة (-los) غياب خاصية فيزيائية أو وسيط تقني بشكل محايد (berührungslos = دون تلامس، drahtlos = لاسلكي).',
      derivedNounGender: 'Verb/Adjektiv',
    ),
    WordFormationExemplar(
      id: 'wform_09',
      domain: DerivationEngineeringDomain.materialScience,
      category: WordFormationCategory.passiveCapabilityBarSuffix,
      cefrLevel: 'C1',
      morphemePattern: 'Verbstamm + -bar (= kann ge-...-t werden): schweißbar, recycelbar, messbar',
      germanSentence:
          'Die neue Aluminiumlegierung ist hervorragend schweißbar und vollständig recycelbar.',
      commonErrorTrap: 'الخلط بين الصفة النشطة والصفة المشتقة بـ -bar ذات المعنى المجهول',
      arabicExplanation:
          'اللاحقة (-bar) المتصلة بجذر الفعل تعادل إمكانية المبني للمجهول (schweißbar = قابل للحام، messbar = قابل للقياس).',
      derivedNounGender: 'Verb/Adjektiv',
    ),
    WordFormationExemplar(
      id: 'wform_10',
      domain: DerivationEngineeringDomain.maritimeLogistics,
      category: WordFormationCategory.nisAndKeitGenderPluralRules,
      cefrLevel: 'C2',
      morphemePattern: '-nis (meist Neutrum: das Ergebnis -> die Ergebnisse mit Doppel-s)',
      germanSentence:
          'Die Messergebnisse der Ultraschallprüfung bestätigen die Integrität des Schiffsrumpfs.',
      commonErrorTrap: 'Die Messergebnise / Der Messergebnis (كتابة s واحدة في الجمع أو خطأ الجنس)',
      arabicExplanation:
          'الأسماء المنتهية بـ (-nis) تكون غالباً محايدة (das Ergebnis, das Ereignis) وتُضاعف فيها السين عند الجمع: die Ergebnisse.',
      derivedNounGender: 'das',
    ),
    WordFormationExemplar(
      id: 'wform_11',
      domain: DerivationEngineeringDomain.renewableEnergyGrid,
      category: WordFormationCategory.nisAndKeitGenderPluralRules,
      cefrLevel: 'C1',
      morphemePattern: '-keit / -heit / -tät (immer feminin): die Leitfähigkeit, die Zuverlässigkeit',
      germanSentence:
          'Die hohe elektrische Leitfähigkeit von Kupfer senkt die Wärmeverluste im Kabelnetz.',
      commonErrorTrap: 'Das Leitfähigkeit / Der Zuverlässigkeit',
      arabicExplanation:
          'كل اسم ينتهي باللاحقة (-keit) أو (-heit) أو (-tät) هو اسم مؤنث قطعاً (die Leitfähigkeit, die Zuverlässigkeit).',
      derivedNounGender: 'die',
    ),
    WordFormationExemplar(
      id: 'wform_12',
      domain: DerivationEngineeringDomain.civilInfrastructure,
      category: WordFormationCategory.beTransitivizingPrefix,
      cefrLevel: 'C2',
      morphemePattern: 'be- + intransitives Verb -> Akkusativ (belasten, befahren, beachten)',
      germanSentence:
          'Schwerlasttransporte dürfen die neue Spannbetonbrücke ab sofort regulär befahren.',
      commonErrorTrap: 'auf der Brücke befahren (إدخال حرف جر بعد الفعل المتعدي بـ be-)',
      arabicExplanation:
          'الفعل befahren (يمر عبر/يسير على) متعدٍ بنفسه بفضل البادئة be-، فيأخذ المفعول به منصوباً مباشرة (die Brücke).',
      derivedNounGender: 'Verb/Adjektiv',
    ),
    WordFormationExemplar(
      id: 'wform_13',
      domain: DerivationEngineeringDomain.aerospaceAndAviation,
      category: WordFormationCategory.entErVerZerSemanticPrefixes,
      cefrLevel: 'C2',
      morphemePattern: 'ver- (Veränderung/Fehlentwicklung/Verbrauch): verformen, verbrauchen',
      germanSentence:
          'Die Tragflächenspitzen verformen sich unter aerodynamischer Last kontrolliert nach oben.',
      commonErrorTrap: 'verformt sich ge- (إدخال ge- مع البادئة ver-)',
      arabicExplanation:
          'البادئة (ver-) غير منفصلة وتفيد التحول البنيوي (verformen = يتشوه/يتغير شكله) أو الاستهلاك (verbrauchen).',
      derivedNounGender: 'Verb/Adjektiv',
    ),
    WordFormationExemplar(
      id: 'wform_14',
      domain: DerivationEngineeringDomain.maritimeLogistics,
      category: WordFormationCategory.nisAndKeitGenderPluralRules,
      cefrLevel: 'C2',
      morphemePattern: 'Ausnahme feminin bei -nis: die Kenntnis -> die Kenntnisse, die Erlaubnis',
      germanSentence:
          'Die genaue Kenntnis der Strömungsverhältnisse erleichtert das Anlegen im Tiefwasserhafen.',
      commonErrorTrap: 'Das Kenntnis (قياس Kenntnis على المحايد مثل Ergebnis)',
      arabicExplanation:
          'من الاستثناءات المهمة في (-nis) كلمات مؤنثة مثل (die Kenntnis, die Erlaubnis, die Finsternis)، وتُضاعف فيها السين بالجمع أيضاً (Kenntnisse).',
      derivedNounGender: 'die',
    ),
    WordFormationExemplar(
      id: 'wform_15',
      domain: DerivationEngineeringDomain.industrialRobotics,
      category: WordFormationCategory.infinitiveVsUngNominalization,
      cefrLevel: 'C1',
      morphemePattern: 'Nominalisierter Infinitiv nach Präposition (beim / zum / durch das)',
      germanSentence:
          'Beim Hochfahren der Fertigungszelle prüft die Sicherheits-SPS sämtliche Lichtschranken.',
      commonErrorTrap: 'beim hochfahren (كتابة المصدر المؤسم بحرف صغير بعد beim)',
      arabicExplanation:
          'المصدر المسبوق بأداة تعريف مدمجة (beim = bei dem, zum = zu dem) يُعد اسماً محايداً ويُكتب دائماً بحرف كبير: beim Hochfahren.',
      derivedNounGender: 'das',
    ),
    WordFormationExemplar(
      id: 'wform_16',
      domain: DerivationEngineeringDomain.materialScience,
      category: WordFormationCategory.passiveCapabilityBarSuffix,
      cefrLevel: 'C2',
      morphemePattern: 'un- + Verbstamm + -bar (Verneinung der Passiv-Möglichkeit)',
      germanSentence:
          'Die Mikrostruktur dieser Keramik bleibt selbst bei 1.400 Grad Celsius unverformbar.',
      commonErrorTrap: 'nicht verformlich',
      arabicExplanation:
          'للدلالة على عدم قابلية المادة للتشكيل أو التشوه نضيف السابقة النافية un- مع اللاحقة -bar: unverformbar.',
      derivedNounGender: 'Verb/Adjektiv',
    ),
  ];

  List<WordFormationExemplar> get allExemplars => List.unmodifiable(_exemplars);

  /// Unified immutable catalog getter matching Volume 116 Masterclass contract.
  List<WordFormationExemplar> get catalog => UnmodifiableListView(_exemplars);

  List<WordFormationExemplar> getByDomain(DerivationEngineeringDomain domain) {
    return _exemplars.where((e) => e.domain == domain).toList(growable: false);
  }

  List<WordFormationExemplar> getByCategory(WordFormationCategory category) {
    return _exemplars.where((e) => e.category == category).toList(growable: false);
  }

  WordFormationExemplar pickExemplarForDrill({
    DerivationEngineeringDomain? domain,
    int seed = 4983,
  }) {
    final pool = domain == null ? _exemplars : getByDomain(domain);
    if (pool.isEmpty) {
      return _exemplars.first;
    }
    final rng = Random(seed);
    return pool[rng.nextInt(pool.length)];
  }

  /// التحقق الذكي من قواعد الاشتقاق الصرفي وتكوين الكلمات
  WordFormationValidationResult validateWordFormation(String sentence) {
    _validationRuns++;
    final normalized = sentence.trim();
    final lower = normalized.toLowerCase();

    // 1. كشف خطأ الجنس مع الأسماء المنتهية بـ -ung أو -keit / -heit
    if (RegExp(r'\b(der|des|dem|den|das|ein|eines|einem|einen)\s+[a-zäöüß]+(ung|keit|heit|tät)\b',
            caseSensitive: false)
        .hasMatch(lower)) {
      _caughtGenderSuffixErrors++;
      return const WordFormationValidationResult(
        isValid: false,
        diagnosedRule: 'Suffix-Genusregel: -ung / -keit / -heit / -tät sind immer feminin (die)',
        arabicFeedback:
            'الأسماء المنتهية بـ (-ung / -keit / -heit / -tät) مؤنثة دائماً (die / einer)، ولا تأتي أبداً مذكرة أو محايدة.',
        correctedSuggestion: 'die / eine / einer [Nomen auf -ung/-keit/-heit/-tät]',
      );
    }

    // 2. كشف خطأ جمع -nis بـ s واحدة (Ergebnise / Ereignise / Kenntnise)
    if (RegExp(r'\b[a-zäöüß]+nise\b', caseSensitive: false).hasMatch(lower)) {
      _caughtNisPluralErrors++;
      return const WordFormationValidationResult(
        isValid: false,
        diagnosedRule: 'Pluralbildung auf -nisse (Doppel-s bei Nomen auf -nis)',
        arabicFeedback:
            'عند جمع الأسماء المنتهية بـ (-nis) يجب مضاعفة حرف s لتصبح (-nisse) مثل Ergebnisse و Kenntnisse.',
        correctedSuggestion: '[Stamm]nisse (z. B. Ergebnisse, Kenntnisse)',
      );
    }

    // 3. كشف خطأ إبقاء حرف الجر über بعد الفعل المتعدي besprechen
    if (RegExp(r'\bbespr(ech|ich)[a-zäöüß]*\s+über\b', caseSensitive: false).hasMatch(lower)) {
      _caughtPrefixValencyErrors++;
      return const WordFormationValidationResult(
        isValid: false,
        diagnosedRule: 'Transitivierung durch Präfix be- (besprechen + Akkusativ ohne "über")',
        arabicFeedback:
            'البادئة be- تحول الفعل إلى متعدٍ مباشر؛ لذا يأخذ besprechen المفعول به منصوباً مباشرة دون حرف الجر über.',
        correctedSuggestion: 'besprechen + [Akkusativobjekt]',
      );
    }

    return const WordFormationValidationResult(
      isValid: true,
      diagnosedRule: 'Korrekte C1/C2-Wortbildung und Derivationsmorphologie',
      arabicFeedback: 'الاشتقاق الصرفي وتحديد الجنس والجمع وتكافؤ البادئة سليم تماماً.',
      correctedSuggestion: '',
    );
  }

  WordFormationTelemetry get telemetry => WordFormationTelemetry(
        totalExemplars: _exemplars.length,
        validationRuns: _validationRuns,
        caughtGenderSuffixErrors: _caughtGenderSuffixErrors,
        caughtNisPluralErrors: _caughtNisPluralErrors,
        caughtPrefixValencyErrors: _caughtPrefixValencyErrors,
      );

  /// Unified telemetry snapshot across all Volume 116 engines.
  Map<String, dynamic> generateTelemetrySnapshot() {
    return {
      'totalExemplars': _exemplars.length,
      'categoryDistribution': {
        for (final c in WordFormationCategory.values)
          c.name: _exemplars.where((e) => e.category == c).length,
      },
      'domainDistribution': {
        for (final d in DerivationEngineeringDomain.values)
          d.name: _exemplars.where((e) => e.domain == d).length,
      },
      'validationRuns': _validationRuns,
      'cefrLevel': 'CEFR C1-C2 Masterclass Word-Formation & Derivational Morphology',
      'engineVersion': '1.1.0+subsystem1817',
    };
  }
}
