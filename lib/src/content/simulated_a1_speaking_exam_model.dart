/// A cue card used in simulated A1 speaking exams (Teil 2 & Teil 3).
class SpeakingCueCard {
  final String theme; // e.g., 'Einkaufen', 'Freizeit', 'Wohnen'
  final String keyword; // e.g., 'Obst', 'Wochenende', 'Uhrzeit'
  final String expectedQuestionDe;
  final String expectedResponseDe;
  final String pedagogicalExplanationAr;

  const SpeakingCueCard({
    required this.theme,
    required this.keyword,
    required this.expectedQuestionDe,
    required this.expectedResponseDe,
    required this.pedagogicalExplanationAr,
  });
}

/// Simulated A1 Speaking module covering Self-Introduction, Asking Questions, and Polite Requests.
class SimulatedA1SpeakingExamModel {
  static const List<String> selfIntroductionPoints = [
    'Name: Ich heiße...',
    'Alter: Ich bin ... Jahre alt.',
    'Land: Ich komme aus...',
    'Wohnort: Ich wohne in...',
    'Sprachen: Ich spreche Arabisch und lerne Deutsch.',
    'Beruf: Ich bin von Beruf...',
    'Hobby: Mein Hobby ist Lesen und Sport.',
  ];

  static const List<SpeakingCueCard> cueCards = [
    SpeakingCueCard(
      theme: 'Einkaufen',
      keyword: 'Äpfel',
      expectedQuestionDe: 'Wie viel kosten diese frischen Äpfel?',
      expectedResponseDe: 'Zwei Euro pro Kilo.',
      pedagogicalExplanationAr: 'السؤال عن السعر باستخدام أداة الاستفهام Wie viel kosten...؟',
    ),
    SpeakingCueCard(
      theme: 'Freizeit',
      keyword: 'Sport',
      expectedQuestionDe: 'Treibst du am Wochenende gerne Sport?',
      expectedResponseDe: 'Ja, ich gehe samstags gerne schwimmen.',
      pedagogicalExplanationAr: 'سؤال نعم/لا (Ja/Nein-Frage) يبدأ بالفعل مباشرة Treibst du...؟',
    ),
    SpeakingCueCard(
      theme: 'Alltag',
      keyword: 'Wasser',
      expectedQuestionDe: 'Könnten Sie mir bitte ein Glas Wasser geben?',
      expectedResponseDe: 'Ja, sehr gerne. Bitte schön!',
      pedagogicalExplanationAr: 'صياغة رجاء مهذب وطلب خدمة باستخدام Könnten Sie bitte...؟',
    ),
  ];
}
