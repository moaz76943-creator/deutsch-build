import 'a1_german_arabic_bitext_corpus.dart';

/// Curated parallel C1 academic corpus exploring history of science and cross-cultural epistemic transmission.
class C1GermanArabicBitextCorpus {
  static const String corpusTitleDe = 'Wissenschaftstransfer und das goldene Zeitalter der Gelehrsamkeit';
  static const String corpusTitleAr = 'انتقال المعارف العلمية والعصر الذهبي للحضارة الإنسانية';

  static const List<AlignedBitextPair> c1Paragraphs = [
    AlignedBitextPair(
      pairId: 1,
      sentenceDe: 'Die bahnbrechenden optischen Abhandlungen von Ibn al-Haitham begründeten die moderne experimentelle Physik und beeinflussten Gelehrte der europäischen Renaissance maßgeblich.',
      sentenceAr: 'أسست أبحاث ابن الهيثم الرائدة في علم البصريات للفيزياء التجريبية الحديثة، وتركت أثراً بالغ العمق في علماء عصر النهضة الأوروبية.',
      iPlusOneNovelWords: ['bahnbrechend', 'begründen', 'maßgeblich beeinflussen'],
      grammarFocus: 'Präteritum im gehobenen akademischen Schriftstil',
    ),
    AlignedBitextPair(
      pairId: 2,
      sentenceDe: 'Historische Dokumente belegen, dass das "Haus der Weisheit" in Bagdad als kosmopolitisches Zentrum der Wissensvermittlung und Übersetzung antiker Werke fungierte.',
      sentenceAr: 'وتثبت الوثائق التاريخية أن "بيت الحكمة" في بغداد كان صرحاً حضارياً عالمياً لنقل العلوم والمعارف وترجمة المخطوطات القديمة بدقة منهجية.',
      iPlusOneNovelWords: ['das Dokument', 'kosmopolitisch', 'fungieren als'],
      grammarFocus: 'Indirekte Rede und Konjunktiv I in historischen Abhandlungen',
    ),
    AlignedBitextPair(
      pairId: 3,
      sentenceDe: 'Es entspricht einer unbestrittenen historischen Tatsache, dass das abendländische Denken durch diesen universalen Wissensstrom eine tiefgreifende Bereicherung erfuhr.',
      sentenceAr: 'ومن الحقائق التاريخية الثابتة التي لا خلاف فيها أن الفكر الغربي شهد إثراءً عميقاً عبر هذا الرافد العلمي الإنساني الشامل.',
      iPlusOneNovelWords: ['unbestritten', 'abendländisch', 'tiefgreifende Bereicherung'],
      grammarFocus: 'Nominalstil mit Funktionsverbgefügen (eine Bereicherung erfahren)',
    ),
  ];
}
