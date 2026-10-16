class InfoGapTask {
  final String title;
  final String contextDescription;
  final List<String> requiredFacts;
  final Map<String, String> answers;

  InfoGapTask({
    required this.title,
    required this.contextDescription,
    required this.requiredFacts,
    required this.answers,
  });
}

class PragmaticScenario {
  final String situation;
  final String politeOption;
  final String directOption;
  final String explanation;

  PragmaticScenario({
    required this.situation,
    required this.politeOption,
    required this.directOption,
    required this.explanation,
  });
}
