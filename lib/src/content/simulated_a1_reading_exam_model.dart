/// A question item in a simulated reading exam mock.
class ReadingQuestionItem {
  final int questionNumber;
  final String promptText;
  final List<String> options;
  final int correctOptionIndex;
  final String explanationAr;

  const ReadingQuestionItem({
    required this.questionNumber,
    required this.promptText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanationAr,
  });
}

/// A simulated A1 Reading section mimicking standard CEFR format without copying copyrighted material.
class SimulatedA1ReadingExamModel {
  static const String stimulusText =
      'Stadtbibliothek Mitteilung:\n'
      'Liebe Leserinnen und Leser,\n'
      'unsere Bibliothek bleibt am kommenden Freitag wegen Renovierungsarbeiten geschlossen.\n'
      'Ab Samstag um 10:00 Uhr sind wir wieder wie gewohnt für Sie da.\n'
      'Die Leihfrist aller ausgeliehenen Bücher wird automatisch um eine Woche verlängert.';

  static const List<ReadingQuestionItem> questions = [
    ReadingQuestionItem(
      questionNumber: 1,
      promptText: 'Wann ist die Stadtbibliothek am kommenden Freitag geöffnet?',
      options: ['Von 10:00 bis 18:00 Uhr', 'Sie ist den ganzen Tag geschlossen', 'Nur vormittags'],
      correctOptionIndex: 1,
      explanationAr: 'الإعلان يوضح صراحة أن المكتبة مغلقة يوم الجمعة لأعمال الصيانة (bleibt geschlossen).',
    ),
    ReadingQuestionItem(
      questionNumber: 2,
      promptText: 'Was passiert mit der Leihfrist der Bücher?',
      options: ['Sie wird um eine Woche verlängert', 'Man muss eine Strafe zahlen', 'Bücher müssen sofort zurück'],
      correctOptionIndex: 0,
      explanationAr: 'تم تمديد فترة الإعارة تلقائياً لمدة أسبوع كامل (automatisch um eine Woche verlängert).',
    ),
  ];

  /// Evaluates learner responses and returns score percentage.
  Map<String, dynamic> scoreExam(List<int> learnerAnswers) {
    if (learnerAnswers.length != questions.length) {
      return {'isComplete': false, 'score': 0.0};
    }

    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      if (learnerAnswers[i] == questions[i].correctOptionIndex) {
        correct++;
      }
    }

    final percent = (correct / questions.length) * 100.0;
    return {
      'isComplete': true,
      'correctCount': correct,
      'totalQuestions': questions.length,
      'scorePercentage': percent,
      'isPassed': percent >= 60.0,
    };
  }
}
