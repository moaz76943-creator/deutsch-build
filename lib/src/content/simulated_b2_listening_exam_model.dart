import 'simulated_a1_reading_exam_model.dart';
import 'simulated_a1_listening_exam_model.dart';

/// Simulated B2 Listening section covering scientific panel discussions and professional colloquiums.
class SimulatedB2ListeningExamModel {
  static const List<ListeningAudioPrompt> b2ColloquiumAudio = [
    ListeningAudioPrompt(
      audioId: 'listen_b2_01',
      spokenTranscriptDe:
          'Podiumsdiskussion zur Zukunft der Bildungsarbeit:\n'
          'Prof. Dr. Hartmann: Im Zeitalter der Digitalisierung ist nicht die Fülle an Information entscheidend, '
          'sondern die Fähigkeit zur kritischen Synthese und ethischen Einordnung. '
          'Lernende müssen befähigt werden, Algorithmen nicht blind zu vertrauen, sondern deren Quellen '
          'und Methodik eigenständig zu hinterfragen.',
      spokenTranscriptAr:
          'ندوة نقاشية حول مستقبل العمل التعليمي والتربوي:\n'
          'البروفيسور هارتمان: في عصر الرقمنة ليس المعيار وفرة المعلومات وكثرتها، بل القدرة على التركيب النقدي والتقييم الأخلاقي. '
          'يجب تمكين المتعلمين من عدم الثقة العمياء بالخوارزميات بل التمحيص المستقل لمصادرها ومنهجيتها.',
      question: ReadingQuestionItem(
        questionNumber: 1,
        promptText: 'Worauf kommt es laut Prof. Hartmann in der modernen Bildung primär an?',
        options: [
          'Auf das Auswendiglernen von Fakten',
          'Auf die kritische Synthese und ethische Einordnung von Informationen',
          'Auf die vollständige Abschaffung von Büchern',
        ],
        correctOptionIndex: 1,
        explanationAr: 'البروفيسور هارتمان يؤكد بوضوح: entscheidend ist die Fähigkeit zur kritischen Synthese und ethischen Einordnung.',
      ),
    ),
  ];

  /// Scores B2 listening.
  double scoreB2Listening(List<int> answers) {
    if (answers.isEmpty || answers.length != b2ColloquiumAudio.length) return 0.0;
    int correct = 0;
    for (int i = 0; i < b2ColloquiumAudio.length; i++) {
      if (answers[i] == b2ColloquiumAudio[i].question.correctOptionIndex) correct++;
    }
    return (correct / b2ColloquiumAudio.length) * 100.0;
  }
}
