import 'simulated_a1_reading_exam_model.dart';

/// Simulated B1 Reading section covering blog forum discussions, opinions, and formal announcements.
class SimulatedB1ReadingExamModel {
  static const String blogPostText =
      'Forum "Zukunft des Lernens":\n'
      'Erfahrungsbericht von Thomas K.:\n'
      'Ich lerne seit sechs Monaten Sprachen mit einer vollständig lokalen, offline-fähigen Software. '
      'Der größte Vorteil für mich ist die Unabhängigkeit von ständigen Internetverbindungen und '
      'der absolute Schutz meiner persönlichen Daten. '
      'Im Vergleich zu Online-Plattformen, die oft durch Werbung ablenken, kann ich mich hier '
      'vollkommen konzentrieren. Ich lerne täglich zwanzig Minuten und habe bereits enorme Fortschritte '
      'beim freien Sprechen und Verstehen erzielt.';

  static const List<ReadingQuestionItem> b1Questions = [
    ReadingQuestionItem(
      questionNumber: 1,
      promptText: 'Welchen Hauptvorteil sieht Thomas in der Offline-Lernsoftware?',
      options: [
        'Sie ist billiger als ein Buch',
        'Unabhängigkeit vom Internet und absoluter Datenschutz',
        'Man muss keine Grammatik lernen',
      ],
      correctOptionIndex: 1,
      explanationAr: 'توماس يحدد الميزة الكبرى صراحة: Unabhängigkeit von ständigen Internetverbindungen und der absolute Schutz der Daten.',
    ),
    ReadingQuestionItem(
      questionNumber: 2,
      promptText: 'Wie viel Zeit investiert Thomas täglich in das Sprachenlernen?',
      options: ['Eine Stunde', 'Zwanzig Minuten', 'Nur am Wochenende'],
      correctOptionIndex: 1,
      explanationAr: 'النص يذكر بدقة: täglich zwanzig Minuten (عشرون دقيقة يومياً).',
    ),
  ];

  /// Evaluates B1 reading score.
  Map<String, dynamic> scoreB1Reading(List<int> answers) {
    if (answers.length != b1Questions.length) return {'isComplete': false, 'score': 0.0};
    int correct = 0;
    for (int i = 0; i < b1Questions.length; i++) {
      if (answers[i] == b1Questions[i].correctOptionIndex) correct++;
    }
    final pct = (correct / b1Questions.length) * 100.0;
    return {
      'isComplete': true,
      'scorePercentage': pct,
      'isPassed': pct >= 60.0,
    };
  }
}
