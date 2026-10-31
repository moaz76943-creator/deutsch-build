import 'simulated_a1_reading_exam_model.dart';
import 'simulated_a1_listening_exam_model.dart';

/// Simulated B1 Listening exam module covering radio interviews, scientific reports, and presentations.
class SimulatedB1ListeningExamModel {
  static const List<ListeningAudioPrompt> b1BroadcastAudio = [
    ListeningAudioPrompt(
      audioId: 'listen_b1_01',
      spokenTranscriptDe:
          'Radiosendung "Wissenschaft am Nachmittag":\n'
          'Moderator: Herzlich willkommen. Heute sprechen wir mit Dr. Klein über die Vorteile des Lesens vor dem Einschlafen.\n'
          'Dr. Klein: Wer abends vor dem Schlafen dreißig Minuten in einem gedruckten Buch liest, senkt den Stresspegel messbar '
          'und schläft wesentlich tiefer als Personen, die auf Bildschirme oder Smartphones blicken.',
      spokenTranscriptAr:
          'برنامج إذاعي "العلم في الظهيرة":\n'
          'المذيع: أهلاً بكم. نتحدث اليوم مع الدكتور كلاين حول فوائد القراءة قبل النوم.\n'
          'د. كلاين: من يقرأ مساءً لمدة 30 دقيقة في كتاب ورقي مطبوع يخفض مستوى التوتر لديه بشكل ملحوظ وينام بعمق أكبر مقارنة بمن يحدق في الشاشات أو الهواتف.',
      question: ReadingQuestionItem(
        questionNumber: 1,
        promptText: 'Welchen Effekt hat das abendliche Lesen in einem gedruckten Buch laut Dr. Klein?',
        options: [
          'Es macht nervös',
          'Es senkt den Stresspegel und verbessert den Schlaf',
          'Es hat keinen messbaren Einfluss',
        ],
        correctOptionIndex: 1,
        explanationAr: 'الدكتور كلاين يؤكد صراحة: senkt den Stresspegel messbar und schläft wesentlich tiefer.',
      ),
    ),
  ];

  /// Scores B1 listening broadcast.
  double scoreB1Listening(List<int> answers) {
    if (answers.isEmpty || answers.length != b1BroadcastAudio.length) return 0.0;
    int correct = 0;
    for (int i = 0; i < b1BroadcastAudio.length; i++) {
      if (answers[i] == b1BroadcastAudio[i].question.correctOptionIndex) correct++;
    }
    return (correct / b1BroadcastAudio.length) * 100.0;
  }
}
