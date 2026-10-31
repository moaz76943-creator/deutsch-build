import 'a1_german_arabic_bitext_corpus.dart';

/// Graded interactive story corpus demonstrating scientific manuscript restoration and cultural heritage conservation.
class ManuscriptPreservationStoryCorpus {
  static const String storyTitleDe = 'Die Bewahrung des Wissens: Restaurierung historischer Handschriften';
  static const String storyTitleAr = 'حراسة المعرفة الإنسانية: ترميم وصون المخطوطات التاريخية النادرة';

  static const List<AlignedBitextPair> restorationChapters = [
    AlignedBitextPair(
      pairId: 1,
      sentenceDe: 'Im traditionsreichen Institut für Bestandserhaltung untersuchten erfahrene Philologen jahrhundertealte Pergamentkodizes unter UV-Lumineszenz.',
      sentenceAr: 'في المعهد العريق لصون المقتنيات النادرة، عكف باحثون فلهولوجيون متمرسون على فحص مخطوطات رقّية أثرية تعود لقرون خلت باستخدام تقنية الفلورة فوق البنفسجية.',
      iPlusOneNovelWords: ['die Bestandserhaltung', 'der Pergamentkodex', 'die UV-Lumineszenz'],
      grammarFocus: 'Komposita im gehobenen akademischen Sprachgebrauch & Dativ-Attribute',
    ),
    AlignedBitextPair(
      pairId: 2,
      sentenceDe: 'Mittels schonender chemischer Entsäuerungsverfahren und mikrochirurgischer Faserfestigung gelang es den Experten, die brüchigen Schriftzeugnisse vor dem Zerfall zu bewahren.',
      sentenceAr: 'وعبر استخدام تقنيات لطيفة لإزالة الحموضة وتثبيت ألياف الورق جراحياً بدقة ميكرونية، نجح الخبراء في إنقاذ هذه الشواهد الخطية الهشة من التلف والاندثار.',
      iPlusOneNovelWords: ['die Entsäuerung', 'die Schriftzeugnisse', 'vor dem Zerfall bewahren'],
      grammarFocus: 'Präposition "mittels" mit Genitiv & Infinitivkonstruktion mit "gelingen"',
    ),
    AlignedBitextPair(
      pairId: 3,
      sentenceDe: 'Die hochauflösende digitale Erfassung ermöglicht es der weltweiten Forschungsgemeinschaft nunmehr, uneingeschränkt auf diesen geistigen Schatz zuzugreifen.',
      sentenceAr: 'وباتت الرقمنة فائقة الدقة تتيح لمجتمع الباحثين حول العالم بأسره الوصول الحر وغير المقيد إلى هذا الكنز الفكري الإنساني الثمين.',
      iPlusOneNovelWords: ['die Erfassung', 'uneingeschränkt', 'der geistige Schatz'],
      grammarFocus: 'Infinitivsatz als Objektergänzung & modale Adverbien (nunmehr, uneingeschränkt)',
    ),
  ];
}
