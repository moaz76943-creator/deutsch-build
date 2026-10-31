class HesitationFiller {
  final String text;
  final String meaning;
  final int timeBonus;

  const HesitationFiller({
    required this.text,
    required this.meaning,
    required this.timeBonus,
  });
}

class AnaphoraTask {
  final String sentence1;
  final String antecedent;
  final String sentence2;
  final List<String> pronounOptions;
  final String correctPronoun;

  const AnaphoraTask({
    required this.sentence1,
    required this.antecedent,
    required this.sentence2,
    required this.pronounOptions,
    required this.correctPronoun,
  });
}

class EnrichmentLevel {
  final int level;
  final String verb;
  final String nuance;

  const EnrichmentLevel({
    required this.level,
    required this.verb,
    required this.nuance,
  });
}
