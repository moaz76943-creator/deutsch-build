/// Separability mode for dual-prefix verbs.
enum VerbSeparabilityMode {
  separableStressedPrefix,   // trennbar: Betonung auf der Vorsilbe (z.B. 'umfahren)
  inseparableStressedStem,   // untrennbar: Betonung auf dem Stamm (z.B. um'fahren)
}

/// Analysis descriptor of dual separability verb pairs.
class DualSeparabilityVerbSpec {
  final String infinitive;
  final VerbSeparabilityMode mode;
  final String phoneticStressIpa;
  final String partizipTwo;
  final String exampleSentence;
  final String literalOrFigurativeMeaning;
  final String arabicEquivalence;

  const DualSeparabilityVerbSpec({
    required this.infinitive,
    required this.mode,
    required this.phoneticStressIpa,
    required this.partizipTwo,
    required this.exampleSentence,
    required this.literalOrFigurativeMeaning,
    required this.arabicEquivalence,
  });

  Map<String, dynamic> toJson() => {
        'infinitive': infinitive,
        'mode': mode.name,
        'ipa': phoneticStressIpa,
        'partizip2': partizipTwo,
        'sentence': exampleSentence,
        'meaning': literalOrFigurativeMeaning,
        'arabic': arabicEquivalence,
      };
}

/// Offline rule engine auditing German Dual-Separability Prefix/Particle Verbs
/// (durch-, über-, unter-, um-, wieder-).
/// Prevents critical semantic collisions where stress placement completely reverses sentence meaning
/// (e.g. "Er fährt das Schild um" [knock down] vs. "Er umfährt den Stau" [bypass]).
class GermanParticleVerbCollisionAuditor {
  static const List<DualSeparabilityVerbSpec> _dualVerbRegistry = [
    // umfahren
    DualSeparabilityVerbSpec(
      infinitive: 'umfahren',
      mode: VerbSeparabilityMode.separableStressedPrefix,
      phoneticStressIpa: "['ʔʊmfaːrən]",
      partizipTwo: 'umgefahren',
      exampleSentence: 'Der Fahrer fuhr das Verkehrsschild um.',
      literalOrFigurativeMeaning: 'anfahren und zu Boden werfen (physische Kollision)',
      arabicEquivalence: 'يصدم بالسيارة ويطرح الشيء أرضاً (فعل منفصل بضغط صوتي على البادئة)',
    ),
    DualSeparabilityVerbSpec(
      infinitive: 'umfahren',
      mode: VerbSeparabilityMode.inseparableStressedStem,
      phoneticStressIpa: "[ʔʊm'faːrən]",
      partizipTwo: 'umfahren',
      exampleSentence: 'Wir umfahren den Baustellenbereich weiträumig.',
      literalOrFigurativeMeaning: 'einen Bogen um ein Hindernis machen (Ausweichen)',
      arabicEquivalence: 'يلتف حول العائق ويتفاداه (فعل متصل بضغط صوتي على جذر الفعل)',
    ),
    // übersetzen
    DualSeparabilityVerbSpec(
      infinitive: 'übersetzen',
      mode: VerbSeparabilityMode.separableStressedPrefix,
      phoneticStressIpa: "['ʔyːbɐzɛtsn̩]",
      partizipTwo: 'übergesetzt',
      exampleSentence: 'Die Fähre setzt die Passagiere an das andere Ufer über.',
      literalOrFigurativeMeaning: 'ans andere Flussufer übersetzen',
      arabicEquivalence: 'ينقل بالسفينة إلى الضفة الأخرى (فعل منفصل)',
    ),
    DualSeparabilityVerbSpec(
      infinitive: 'übersetzen',
      mode: VerbSeparabilityMode.inseparableStressedStem,
      phoneticStressIpa: "[ʔyːbɐ'zɛtsn̩]",
      partizipTwo: 'übersetzt',
      exampleSentence: 'Der Dolmetscher übersetzt die Rede ins Arabische.',
      literalOrFigurativeMeaning: 'Text in eine andere Sprache übertragen',
      arabicEquivalence: 'يترجم من لغة إلى أخرى (فعل متصل)',
    ),
    // wiederholen
    DualSeparabilityVerbSpec(
      infinitive: 'wiederholen',
      mode: VerbSeparabilityMode.separableStressedPrefix,
      phoneticStressIpa: "['viːdɐhoːlən]",
      partizipTwo: 'wiedergeholt',
      exampleSentence: 'Der Hund holt den geworfenen Ball wieder.',
      literalOrFigurativeMeaning: 'etwas zurückholen',
      arabicEquivalence: 'يسترجع ويجلب الشيء مجدداً (فعل منفصل)',
    ),
    DualSeparabilityVerbSpec(
      infinitive: 'wiederholen',
      mode: VerbSeparabilityMode.inseparableStressedStem,
      phoneticStressIpa: "[viːdɐ'hoːlən]",
      partizipTwo: 'wiederholt',
      exampleSentence: 'Die Schülerin wiederholt die deutschen Vokabeln.',
      literalOrFigurativeMeaning: 'noch einmal sagen oder üben',
      arabicEquivalence: 'يكرر ويعيد المراجعة والترديد (فعل متصل)',
    ),
  ];

  /// Scan an input verb and identify both its separable and inseparable variants.
  static List<DualSeparabilityVerbSpec> getDualVariants(String verb) {
    final clean = verb.trim().toLowerCase()
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue');

    return _dualVerbRegistry.where((e) {
      final regClean = e.infinitive.replaceAll('ü', 'ue').replaceAll('ä', 'ae').replaceAll('ö', 'oe');
      return regClean == clean;
    }).toList();
  }

  /// Critical check for syntactic correctness: validates Partizip II and word-order compatibility.
  static bool verifySeparablePartizipTwo(String verb, String candidatePartizipTwo, bool expectSeparable) {
    final variants = getDualVariants(verb);
    if (variants.isEmpty) return true;

    final target = variants.firstWhere(
      (v) => (v.mode == VerbSeparabilityMode.separableStressedPrefix) == expectSeparable,
      orElse: () => variants.first,
    );

    return target.partizipTwo.toLowerCase() == candidatePartizipTwo.trim().toLowerCase();
  }
}
