class ConversationTurn {
  final String id, promptGerman, promptArabic, skill;
  final List<String> expected, keywords;
  const ConversationTurn({
    required this.id,
    required this.promptGerman,
    required this.promptArabic,
    required this.expected,
    required this.keywords,
    this.skill = 'production',
  });
}

class ConversationScenario {
  final String id, title, situation;
  final List<ConversationTurn> turns;
  const ConversationScenario({
    required this.id,
    required this.title,
    required this.situation,
    required this.turns,
  });
}

class ConversationScore {
  final int value;
  final bool correct;
  final List<String> matchedKeywords, missingKeywords;
  const ConversationScore({
    required this.value,
    required this.correct,
    required this.matchedKeywords,
    required this.missingKeywords,
  });
}
