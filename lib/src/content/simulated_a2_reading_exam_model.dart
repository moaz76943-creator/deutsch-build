import 'simulated_a1_reading_exam_model.dart';

/// Simulated A2 Reading mock covering multi-paragraph news, notices, and matching.
class SimulatedA2ReadingExamModel {
  static const String newsArticle =
      'Neuer Stadtpark in Heidelberg eröffnet:\n'
      'Gestern wurde der neue generationenübergreifende Bürgerpark feierlich eröffnet.\n'
      'Der Park bietet weitläufige Grünflächen, einen modernen Spielplatz für Kinder '
      'sowie einen schattigen Lesegarten mit kostenlosem Büchertauschschrank.\n'
      'Hunde sind an der Leine willkommen, und das Grillen ist zum Schutz der Natur '
      'ausschließlich auf den speziell gekennzeichneten Grillplätzen gestattet.';

  static const List<ReadingQuestionItem> a2Questions = [
    ReadingQuestionItem(
      questionNumber: 1,
      promptText: 'Was bietet der neue Park für lesebegeisterte Bürger?',
      options: ['Eine Buchhandlung', 'Einen Lesegarten mit Büchertauschschrank', 'Nur Zeitungsverkauf'],
      correctOptionIndex: 1,
      explanationAr: 'النص يوضح وجود حديقة قراءة مظللة مع خزانة مجانية لتبادل الكتب (schattigen Lesegarten mit Büchertauschschrank).',
    ),
    ReadingQuestionItem(
      questionNumber: 2,
      promptText: 'Wo darf im Park gegrillt werden?',
      options: ['Überall auf der Wiese', 'Gar nicht', 'Nur auf den gekennzeichneten Plätzen'],
      correctOptionIndex: 2,
      explanationAr: 'الشواء مسموح فقط في الأماكن المخصصة والمحددة بعلامات (auf den gekennzeichneten Grillplätzen).',
    ),
  ];

  /// Evaluates A2 reading comprehension score.
  Map<String, dynamic> evaluateA2Reading(List<int> answers) {
    if (answers.length != a2Questions.length) return {'isComplete': false, 'score': 0.0};
    int correct = 0;
    for (int i = 0; i < a2Questions.length; i++) {
      if (answers[i] == a2Questions[i].correctOptionIndex) correct++;
    }
    final pct = (correct / a2Questions.length) * 100.0;
    return {
      'isComplete': true,
      'scorePercentage': pct,
      'isPassed': pct >= 60.0,
    };
  }
}
