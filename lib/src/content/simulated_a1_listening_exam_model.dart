import 'simulated_a1_reading_exam_model.dart';

/// Audio transcript item for simulated listening comprehension.
class ListeningAudioPrompt {
  final String audioId;
  final String spokenTranscriptDe;
  final String spokenTranscriptAr;
  final ReadingQuestionItem question;

  const ListeningAudioPrompt({
    required this.audioId,
    required this.spokenTranscriptDe,
    required this.spokenTranscriptAr,
    required this.question,
  });
}

/// Simulated A1 Listening exam section mimicking public announcements and phone messages.
class SimulatedA1ListeningExamModel {
  static const List<ListeningAudioPrompt> listeningExercises = [
    ListeningAudioPrompt(
      audioId: 'listen_a1_01',
      spokenTranscriptDe:
          'Gleisdurchsage: Achtung am Gleis 3! Der Regionalexpress nach Leipzig hat heute zehn Minuten Verspätung. '
          'Bitte achten Sie auf die Durchsagen.',
      spokenTranscriptAr:
          'إعلان المحطة الصوتي: انتباه على الرصيف 3! القطار الإقليمي المتجه إلى لايبزيغ متأخر اليوم عشر دقائق. يُرجى الانتباه للإعلانات.',
      question: ReadingQuestionItem(
        questionNumber: 1,
        promptText: 'Wie viel Verspätung hat der Zug nach Leipzig?',
        options: ['Fünf Minuten', 'Zehn Minuten', 'Er fällt heute aus'],
        correctOptionIndex: 1,
        explanationAr: 'الإعلان يذكر بوضوح: zehn Minuten Verspätung (عشر دقائق تأخير).',
      ),
    ),
    ListeningAudioPrompt(
      audioId: 'listen_a1_02',
      spokenTranscriptDe:
          'Anrufbeantworter Praxis Dr. Meyer: Guten Tag! Unsere Praxis ist am Mittwoch ab 14:00 Uhr wieder telefonisch erreichbar. '
          'In dringenden Notfällen wenden Sie sich bitte an den ärztlichen Bereitschaftsdienst.',
      spokenTranscriptAr:
          'الرد الآلي لعيادة الدكتور ماير: نهاركم سعيد! عيادتنا تستقبل اتصالاتكم يوم الأربعاء بدءاً من الساعة الثانية ظهراً. في حالات الطوارئ يرجى الاتصال بطوارئ الأطباء.',
      question: ReadingQuestionItem(
        questionNumber: 2,
        promptText: 'Wann ist die Arztpraxis am Mittwoch wieder erreichbar?',
        options: ['Ab 08:00 Uhr morgens', 'Ab 14:00 Uhr', 'Gar nicht'],
        correctOptionIndex: 1,
        explanationAr: 'التسجيل يحدد الموعد: ab 14:00 Uhr (بدءاً من الساعة الثانية ظهراً).',
      ),
    ),
  ];

  /// Evaluates listening score.
  double evaluateScore(List<int> answers) {
    if (answers.length != listeningExercises.length) return 0.0;
    int correct = 0;
    for (int i = 0; i < listeningExercises.length; i++) {
      if (answers[i] == listeningExercises[i].question.correctOptionIndex) {
        correct++;
      }
    }
    return (correct / listeningExercises.length) * 100.0;
  }
}
