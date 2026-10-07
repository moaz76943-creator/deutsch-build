class VerbConjugationRule {
  const VerbConjugationRule({
    required this.tense,
    required this.pronounSuffixes,
  });

  final String tense;
  final Map<String, String> pronounSuffixes;

  Map<String, dynamic> toJson() => {
        'tense': tense,
        'pronounSuffixes': pronounSuffixes,
      };
}

class LanguageIntelligenceContract {
  static List<VerbConjugationRule> getStandardConjugations(String languageCode) {
    switch (languageCode) {
      case 'de':
        return [
          const VerbConjugationRule(
            tense: 'Present',
            pronounSuffixes: {'ich': '-e', 'du': '-st', 'er/sie/es': '-t'},
          ),
        ];
      case 'ar':
        return [
          const VerbConjugationRule(
            tense: 'Past',
            pronounSuffixes: {'هو': 'َ', 'هي': 'َت', 'أنا': 'ْتُ'},
          ),
        ];
      default:
        return [];
    }
  }
}
