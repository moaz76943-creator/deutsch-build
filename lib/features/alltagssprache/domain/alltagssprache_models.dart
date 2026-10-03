enum AlltagTopic {
  neighborhood,
  shopping,
  punctuality,
  politePhrases,
}

extension AlltagTopicLabels on AlltagTopic {
  String get labelDe => switch (this) {
        AlltagTopic.neighborhood => 'Nachbarschaft',
        AlltagTopic.shopping => 'Einkaufen',
        AlltagTopic.punctuality => 'Pünktlichkeit',
        AlltagTopic.politePhrases => 'Höfliche Wendungen',
      };

  String get labelAr => switch (this) {
        AlltagTopic.neighborhood => 'الجيرة وآداب السكن',
        AlltagTopic.shopping => 'التسوق',
        AlltagTopic.punctuality => 'المواعيد',
        AlltagTopic.politePhrases => 'عبارات يومية مهذبة',
      };
}

class AlltagScenario {
  const AlltagScenario({
    required this.id,
    required this.topic,
    required this.phraseDe,
    required this.meaningAr,
    required this.contextDe,
    required this.etiquetteAr,
    required this.promptAr,
    required this.optionsDe,
    required this.correctIndex,
    required this.feedbackAr,
  }) : assert(optionsDe.length >= 2),
       assert(correctIndex >= 0),
       assert(correctIndex < optionsDe.length);

  final String id;
  final AlltagTopic topic;
  final String phraseDe;
  final String meaningAr;
  final String contextDe;
  final String etiquetteAr;
  final String promptAr;
  final List<String> optionsDe;
  final int correctIndex;
  final String feedbackAr;

  String get correctAnswer => optionsDe[correctIndex];
}
