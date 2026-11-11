/// Type of phonological rule applied.
enum PhonologicalRuleType {
  auslautverhaertungDevoicing, // b->p, d->t, g->k am Silbenende
  glottalStopKnacklaut,        // [ʔ] vor vokalisch anlautenden Silben
  nasalAssimilation,           // -en zu [m̩] oder [ŋ]
}

/// Analysis descriptor of a word's phonetic transcription and phonological audit.
class PhonologicalAuditAnalysis {
  final String orthographicWord;
  final String phoneticIpaTranscription;
  final List<PhonologicalRuleType> appliedRules;
  final bool hasTerminalDevoicing;
  final bool hasGlottalStop;
  final String arabicPronunciationGuidance;

  PhonologicalAuditAnalysis({
    required this.orthographicWord,
    required this.phoneticIpaTranscription,
    required this.appliedRules,
    required this.hasTerminalDevoicing,
    required this.hasGlottalStop,
    required this.arabicPronunciationGuidance,
  });

  Map<String, dynamic> toJson() => {
        'word': orthographicWord,
        'ipa': phoneticIpaTranscription,
        'rules': appliedRules.map((r) => r.name).toList(),
        'devoicing': hasTerminalDevoicing,
        'glottal_stop': hasGlottalStop,
        'guidance': arabicPronunciationGuidance,
      };
}

/// Offline rule engine modeling German phonology and phonetic assimilation rules:
/// 1. Auslautverhärtung: Voiced plosives/fricatives (b, d, g, s) become voiceless ([p], [t], [k], [s]) word-finally.
/// 2. Knacklaut (Glottal Stop [ʔ]): Inserted before morpheme-initial vowels (e.g. [ʔ]Apfel, be[ʔ]achten).
class GermanPhonologicalAuditorEngine {
  static const Set<String> _vowels = {'a', 'e', 'i', 'o', 'u', 'ä', 'ö', 'ü'};

  /// Analyze German word for final devoicing and glottal stop requirements.
  static PhonologicalAuditAnalysis auditPronunciation(String word) {
    final clean = word.trim().toLowerCase();
    final rules = <PhonologicalRuleType>[];
    bool hasDevoicing = false;
    bool hasGlottal = false;
    String ipa = clean;
    String guidance = '';

    // 1. Check Glottal Stop (Knacklaut) at word start
    if (clean.isNotEmpty && _vowels.contains(clean[0])) {
      hasGlottal = true;
      rules.add(PhonologicalRuleType.glottalStopKnacklaut);
      ipa = 'ʔ$ipa';
      guidance += 'همزة قطع واضحة (Knacklaut) في بداية الكلمة قبل الحرف الصوتي. ';
    }

    // 2. Check Auslautverhärtung (Terminal Devoicing at end of word)
    if (clean.endsWith('d')) {
      hasDevoicing = true;
      rules.add(PhonologicalRuleType.auslautverhaertungDevoicing);
      ipa = '${ipa.substring(0, ipa.length - 1)}t';
      guidance += 'تحول صوت (d) في نهاية الكلمة إلى (t) مهموس وجازم (Auslautverhärtung). ';
    } else if (clean.endsWith('g')) {
      hasDevoicing = true;
      rules.add(PhonologicalRuleType.auslautverhaertungDevoicing);
      ipa = '${ipa.substring(0, ipa.length - 1)}k';
      guidance += 'تحول صوت (g) في نهاية الكلمة إلى (k) مهموس (Auslautverhärtung). ';
    } else if (clean.endsWith('b')) {
      hasDevoicing = true;
      rules.add(PhonologicalRuleType.auslautverhaertungDevoicing);
      ipa = '${ipa.substring(0, ipa.length - 1)}p';
      guidance += 'تحول صوت (b) في نهاية الكلمة إلى (p) مهموس (Auslautverhärtung). ';
    }

    if (guidance.isEmpty) {
      guidance = 'نطق قياسي مطابق للمخرج الصوتي المباشر.';
    }

    return PhonologicalAuditAnalysis(
      orthographicWord: word,
      phoneticIpaTranscription: '[$ipa]',
      appliedRules: rules,
      hasTerminalDevoicing: hasDevoicing,
      hasGlottalStop: hasGlottal,
      arabicPronunciationGuidance: guidance.trim(),
    );
  }
}
