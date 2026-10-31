import 'simulated_a1_reading_exam_model.dart';
import 'simulated_a1_listening_exam_model.dart';

/// Simulated A2 Listening exam module covering multi-turn phone dialogues and scheduling.
class SimulatedA2ListeningExamModel {
  static const List<ListeningAudioPrompt> a2AudioDialogues = [
    ListeningAudioPrompt(
      audioId: 'listen_a2_01',
      spokenTranscriptDe:
          'Gespräch am Kundenservice:\n'
          '- Guten Tag, mein Name ist Weber. Ich rufe wegen meiner Buchbestellung an.\n'
          '- Guten Tag Herr Weber. Ihr Lehrbuch ist gestern im Lager eingetroffen und kann ab heute '
          'Nachmittag um 15:00 Uhr in der Filiale abgeholt werden.',
      spokenTranscriptAr:
          'محادثة خدمة العملاء: نهاركم سعيد، اسمي فيبر. أتصل بخصوص طلبيتي للكتب.\n'
          '- نهاركم سعيد سيد فيبر. كتابكم التعليمي وصل أمس للمستودع ويمكنكم استلامه بدءاً من بعد ظهر اليوم في الساعة الثالثة.',
      question: ReadingQuestionItem(
        questionNumber: 1,
        promptText: 'Wann kann Herr Weber sein Buch in der Filiale abholen?',
        options: ['Gestern', 'Heute ab 15:00 Uhr', 'Erst nächste Woche'],
        correctOptionIndex: 1,
        explanationAr: 'الموظف يؤكد: ab heute Nachmittag um 15:00 Uhr (اليوم بدءاً من الساعة الثالثة).',
      ),
    ),
    ListeningAudioPrompt(
      audioId: 'listen_a2_02',
      spokenTranscriptDe:
          'Verabredung unter Kollegen:\n'
          '- Hallo Sara, wollen wir am Freitag zusammen in der Mensa essen?\n'
          '- Am Freitag habe ich leider um 12 Uhr eine Präsentation. Passt es dir stattdessen am Donnerstag?',
      spokenTranscriptAr:
          'اتفاق بين زميلين: مرحباً سارة، هل نتناول الغداء معاً يوم الجمعة في مطعم الجامعة؟\n'
          '- يوم الجمعة لدي للأسف عرض تقديمي عند الساعة الثانية عشرة. هل يناسبك يوم الخميس بدلاً منه؟',
      question: ReadingQuestionItem(
        questionNumber: 2,
        promptText: 'Warum kann Sara am Freitag nicht in der Mensa essen?',
        options: ['Sie ist krank', 'Sie hat eine Präsentation', 'Sie ist nicht an der Universität'],
        correctOptionIndex: 1,
        explanationAr: 'سارة توضح سبب اعتذارها: habe um 12 Uhr eine Präsentation (لدي عرض تقديمي).',
      ),
    ),
  ];

  /// Scores A2 listening comprehension.
  double scoreA2Listening(List<int> answers) {
    if (answers.length != a2AudioDialogues.length) return 0.0;
    int correct = 0;
    for (int i = 0; i < a2AudioDialogues.length; i++) {
      if (answers[i] == a2AudioDialogues[i].question.correctOptionIndex) correct++;
    }
    return (correct / a2AudioDialogues.length) * 100.0;
  }
}
