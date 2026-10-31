/// Model simulating B1 Speaking exam (Teil 2: Ein Thema präsentieren & Feedback).
class PresentationSlidePrompt {
  final int slideNumber;
  final String titleDe;
  final String titleAr;
  final List<String> keyPhrasesDe;

  const PresentationSlidePrompt({
    required this.slideNumber,
    required this.titleDe,
    required this.titleAr,
    required this.keyPhrasesDe,
  });
}

/// Simulated B1 Presentation module covering the official 5-part CEFR presentation structure.
class SimulatedB1SpeakingExamModel {
  static const String topicTitleDe = 'Ernährung mit gesunden Bio-Lebensmitteln';
  static const String topicTitleAr = 'التغذية الصحية بالأطعمة العضوية الطبيعية';

  static const List<PresentationSlidePrompt> presentationParts = [
    PresentationSlidePrompt(
      slideNumber: 1,
      titleDe: 'Thema & Struktur vorstellen',
      titleAr: 'تقديم عنوان الموضوع وهيكل العرض التقديمي',
      keyPhrasesDe: [
        'Das Thema meiner heutigen Präsentation lautet...',
        'Meine Präsentation gliedert sich in folgende Teile...',
      ],
    ),
    PresentationSlidePrompt(
      slideNumber: 2,
      titleDe: 'Eigene persönliche Erfahrung',
      titleAr: 'التجربة الشخصية الذاتية',
      keyPhrasesDe: [
        'Ich persönlich bevorzuge frisches Obst und Gemüse vom Wochenmarkt...',
        'In meinem Alltag achte ich sehr auf natürliche Zutaten...',
      ],
    ),
    PresentationSlidePrompt(
      slideNumber: 3,
      titleDe: 'Situation im Heimatland',
      titleAr: 'واقع الأمر في الوطن الأم',
      keyPhrasesDe: [
        'In meinem Heimatland kaufen die meisten Menschen frische Lebensmittel direkt beim Bauern...',
        'Traditionelle Wochenmärkte spielen dort eine zentrale Rolle...',
      ],
    ),
    PresentationSlidePrompt(
      slideNumber: 4,
      titleDe: 'Vor- und Nachteile abwägen',
      titleAr: 'مقارنة المزايا والسلبيات',
      keyPhrasesDe: [
        'Ein großer Vorteil von Bio-Produkten ist der Verzicht auf schädliche Chemikalien...',
        'Ein möglicher Nachteil besteht in den etwas höheren Kosten...',
      ],
    ),
    PresentationSlidePrompt(
      slideNumber: 5,
      titleDe: 'Eigene Meinung & Abschluss',
      titleAr: 'الرأي الشخصي والختام واستقبال الأسئلة',
      keyPhrasesDe: [
        'Zusammenfassend bin ich der Überzeugung, dass Gesundheit die beste Investition ist...',
        'Ich bedanke mich herzlich für Ihre Aufmerksamkeit. Haben Sie noch Fragen?',
      ],
    ),
  ];
}
