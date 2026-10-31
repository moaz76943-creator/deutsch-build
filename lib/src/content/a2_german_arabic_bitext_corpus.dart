import 'a1_german_arabic_bitext_corpus.dart';

/// Curated parallel A2 corpus expanding narrative depth and sentence subordinate clauses (weil, dass).
class A2GermanArabicBitextCorpus {
  static const String storyTitleDe = 'Ein Ausflug in den Schwarzwald';
  static const String storyTitleAr = 'رحلة استكشافية إلى الغابة السوداء';

  static const List<AlignedBitextPair> a2StoryParagraphs = [
    AlignedBitextPair(
      pairId: 1,
      sentenceDe: 'Letztes Wochenende fuhren die Studenten gemeinsam in den Schwarzwald, um die Natur zu genießen.',
      sentenceAr: 'في نهاية الأسبوع الماضي، سافر الطلاب معاً إلى الغابة السوداء للاستمتاع بالطبيعة الخلابة.',
      iPlusOneNovelWords: ['der Ausflug', 'genießen', 'Schwarzwald'],
      grammarFocus: 'Präteritum von starken Verben & Infinitiv mit um...zu',
    ),
    AlignedBitextPair(
      pairId: 2,
      sentenceDe: 'Sie wanderten auf sicheren Wegen durch den dichten Wald, weil die frische Bergluft sehr gesund ist.',
      sentenceAr: 'ساروا في مسارات ممهدة آمنة عبر الغابة الكثيفة، لأن هواء الجبال النقي مفيد جداً للصحة.',
      iPlusOneNovelWords: ['wandern', 'der Pfad', 'die Bergluft'],
      grammarFocus: 'Kausale Nebensätze mit "weil" (Verb am Satzende)',
    ),
    AlignedBitextPair(
      pairId: 3,
      sentenceDe: 'An einem klaren Gebirgsbach machten sie Rast und tranken kühles, erfrischendes Quellwasser.',
      sentenceAr: 'وعند جدول ماء جبلي رقراق وصافٍ، أخذوا استراحة وشربوا ماء ينبوع بارداً ومنعشاً.',
      iPlusOneNovelWords: ['der Gebirgsbach', 'die Rast', 'das Quellwasser'],
      grammarFocus: 'Adjektivdeklination ohne Artikel im Akkusativ',
    ),
  ];
}
