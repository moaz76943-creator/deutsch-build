import 'a1_german_arabic_bitext_corpus.dart';

/// Graded interactive story corpus demonstrating cosmic contemplation, astronomy, and night sky preservation.
class AstronomyDarkSkyStoryCorpus {
  static const String storyTitleDe = 'Das Observatorium in den Alpen: Erforschung der Gestirne und Schutz des Nachthimmels';
  static const String storyTitleAr = 'المرصد الفلكي في جبال الألب: سبر أغوار النجوم وصون بهاء السماء الليلية';

  static const List<AlignedBitextPair> cosmicChapters = [
    AlignedBitextPair(
      pairId: 1,
      sentenceDe: 'Hoch oben auf dem schneebedeckten Berggipfel richteten die Astronomen das hochauflösende Spiegelteleskop auf weit entfernte Spiralgalaxien aus.',
      sentenceAr: 'في أعالي القمة الجبلية المكسوة بالثلوج، وجّه علماء الفلك التلسكوب العاكس فائق الدقة نحو مجرات حلزونية سحيقة في أعماق الفضاء.',
      iPlusOneNovelWords: ['das Observatorium', 'schneebedeckt', 'die Spiralgalaxie'],
      grammarFocus: 'Trennbare Verben mit Richtungsangaben (ausrichten auf + Akk)',
    ),
    AlignedBitextPair(
      pairId: 2,
      sentenceDe: 'Sie engagierten sich leidenschaftlich für die Eindämmung urbaner Lichtverschmutzung, damit künftige Generationen das majestätische Band der Milchstraße mit bloßem Auge bewundern können.',
      sentenceAr: 'وكانوا يسعون بحماس صادق للحد من التلوث الضوئي في المدن، لكي تتمكن الأجيال القادمة من تأمل شريط درب التبانة المهيب بالعين المجردة.',
      iPlusOneNovelWords: ['die Lichtverschmutzung', 'majestätisch', 'die Milchstraße'],
      grammarFocus: 'Konjunktionalsatz mit "damit" (Subjektwechsel) & Modalverb im Nebensatz',
    ),
    AlignedBitextPair(
      pairId: 3,
      sentenceDe: 'Der Blick in die unendlichen Weiten des Kosmos erfüllt das forschende Gemüt mit tiefer Demut vor der erhabenen Ordnung des Universums.',
      sentenceAr: 'إن التأمل في أرجاء الكون اللامتناهية يملأ قلب الباحث تواضعاً عميقاً وإجلالاً للنظام البديع المحكم الذي يسير عليه الوجود.',
      iPlusOneNovelWords: ['die Demut', 'erhaben', 'das Universum'],
      grammarFocus: 'Präpositionalobjekt mit Genitivattribut (mit tiefer Demut vor der Ordnung)',
    ),
  ];
}
