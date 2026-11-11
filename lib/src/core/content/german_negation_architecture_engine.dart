/// Scope of the negation.
enum NegationScope {
  sentenceNegation, // Satznegation (نفي الجملة بالكامل)
  constituentNegation, // Sondernegation (نفي عنصر محدد)
}

/// Category of negation word utilized.
enum NegationWordType {
  indefiniteNounKein, // kein-
  particleNicht,      // nicht
  intensifiedGarNicht,// gar nicht / überhaupt nicht
  categoricalAdverb,  // keineswegs / auf keinen Fall
}

/// Analysis descriptor of an engineered negative sentence structure.
class NegationSentenceStructure {
  final NegationScope scope;
  final NegationWordType wordType;
  final String negatedElement;
  final String generatedSentence;
  final String placementRuleExplanation;
  final String arabicTranslation;

  NegationSentenceStructure({
    required this.scope,
    required this.wordType,
    required this.negatedElement,
    required this.generatedSentence,
    required this.placementRuleExplanation,
    required this.arabicTranslation,
  });

  Map<String, dynamic> toJson() => {
        'scope': scope.name,
        'type': wordType.name,
        'negated': negatedElement,
        'sentence': generatedSentence,
        'rule': placementRuleExplanation,
        'arabic': arabicTranslation,
      };
}

/// Offline rule engine constructing and validating German Negation Architecture (Negationsstrukturen).
/// Enforces precise placement rules for "nicht" (Satznegation am Satzende vs. Sondernegation vor dem Element)
/// and inflects "kein-" across grammatical cases.
class GermanNegationArchitectureEngine {
  /// Negate a noun phrase with "kein-".
  static NegationSentenceStructure negateNoun({
    required String subject,
    required String verb,
    required String nounStem,
    required String gender, // 'maskulin', 'feminin', 'neutral', 'plural'
    required String gramCase, // 'nominativ', 'akkusativ', 'dativ'
  }) {
    String suffix = '';

    if (gramCase == 'akkusativ') {
      if (gender == 'maskulin') suffix = 'en';
      else if (gender == 'feminin' || gender == 'plural') suffix = 'e';
    } else if (gramCase == 'dativ') {
      if (gender == 'feminin') suffix = 'er';
      else if (gender == 'plural') suffix = 'en';
      else suffix = 'em';
    } else {
      // Nominativ
      if (gender == 'feminin' || gender == 'plural') suffix = 'e';
    }

    final keinForm = 'kein$suffix';
    final sentence = '$subject $verb $keinForm $nounStem.'.replaceAll(RegExp(r'\s+'), ' ');

    return NegationSentenceStructure(
      scope: NegationScope.sentenceNegation,
      wordType: NegationWordType.indefiniteNounKein,
      negatedElement: nounStem,
      generatedSentence: sentence,
      placementRuleExplanation: 'تستخدم أداة النفي (kein) لنفي الأسماء المنكرة أو غير المسبوقة بأداة',
      arabicTranslation: 'نفي اسمي مباشر',
    );
  }

  /// Negate with "nicht" using calculated positioning (Satznegation vs Sondernegation).
  static NegationSentenceStructure negateWithNicht({
    required String subject,
    required String verb,
    required NegationScope scope,
    String directObjectOrElement = '',
    String prepositionalPhrase = '',
    String separablePrefixOrParticiple = '',
    bool isIntensified = false,
  }) {
    final negationParticle = isIntensified ? 'überhaupt nicht' : 'nicht';
    String sentence = '';
    String rule = '';

    if (scope == NegationScope.sentenceNegation) {
      // Satznegation: "nicht" comes before separable prefix, participle, or prepositional phrase, otherwise at the end.
      if (prepositionalPhrase.isNotEmpty) {
        final objStr = directObjectOrElement.isNotEmpty ? ' $directObjectOrElement' : '';
        sentence = '$subject $verb$objStr $negationParticle $prepositionalPhrase.';
        rule = 'في نفي الجملة، تأتي nicht قبل شبه الجملة المجرورة بحرف جر مباشرة';
      } else if (separablePrefixOrParticiple.isNotEmpty) {
        final objStr = directObjectOrElement.isNotEmpty ? ' $directObjectOrElement' : '';
        sentence = '$subject $verb$objStr $negationParticle $separablePrefixOrParticiple.';
        rule = 'في نفي الجملة، تأتي nicht قبل سابقة الفعل المنفصل أو اسم المفعول في نهاية الجملة';
      } else if (directObjectOrElement.isNotEmpty) {
        // Defined direct object: "nicht" comes after defined accusative object
        sentence = '$subject $verb $directObjectOrElement $negationParticle.';
        rule = 'في نفي الجملة، تأتي nicht بعد المفعول به المعرف بأداة تعريف';
      } else {
        sentence = '$subject $verb $negationParticle.';
        rule = 'في نفي الجملة المجردة، تأتي nicht في نهاية الجملة تماماً';
      }
    } else {
      // Sondernegation: "nicht" placed directly before the negated constituent
      sentence = '$subject $verb $negationParticle $directObjectOrElement.'.trim();
      rule = 'في النفي الجزئي (Sondernegation)، تسبق nicht العنصر المراد نفيه حصراً';
    }

    sentence = sentence.replaceAll(RegExp(r'\s+'), ' ');

    return NegationSentenceStructure(
      scope: scope,
      wordType: isIntensified ? NegationWordType.intensifiedGarNicht : NegationWordType.particleNicht,
      negatedElement: directObjectOrElement,
      generatedSentence: sentence,
      placementRuleExplanation: rule,
      arabicTranslation: 'نفي تركيبي باستخدام nicht',
    );
  }
}
