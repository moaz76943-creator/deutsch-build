import 'a1_german_arabic_bitext_corpus.dart';

/// Curated parallel C1 academic corpus exploring sustainable urban planning, bioclimatic architecture, and civic spaces.
class C1UrbanArchitectureBitextCorpus {
  static const String corpusTitleDe = 'Bioklimatische Architektur und urbane Transformation';
  static const String corpusTitleAr = 'العمارة المناخية الحيوية والتحول المعماري الحضري المستدام';

  static const List<AlignedBitextPair> architectureParagraphs = [
    AlignedBitextPair(
      pairId: 1,
      sentenceDe: 'Die Integration bioklimatischer Prinzipien in den modernen Städtebau zielt darauf ab, den Energiebedarf durch passive thermische Regulierung zu minimieren.',
      sentenceAr: 'يهدف إدماج مبادئ التصميم المناخي الحيوي في التخطيط العمراني المعاصر إلى خفض استهلاك الطاقة عبر التنظيم الحراري الطبيعي السلبي للمباني.',
      iPlusOneNovelWords: ['bioklimatisch', 'der Städtebau', 'thermische Regulierung'],
      grammarFocus: 'Funktionsverbgefüge (darauf abzielen) & Gerundivformen',
    ),
    AlignedBitextPair(
      pairId: 2,
      sentenceDe: 'Indem traditionelle bauliche Elemente wie schattenspendende Innenhöfe und natürliche Luftströmungskanäle adaptiert werden, gelingt eine harmonische Symbiose aus Tradition und Moderne.',
      sentenceAr: 'ومن خلال توظيف العناصر المعمارية التراثية كالأفنية المظللة وقنوات التهوية الطبيعية، يتحقق تناغم بديع يجمع بين أصالة التراث ودقة المعاصرة.',
      iPlusOneNovelWords: ['der Innenhof', 'Luftströmungskanäle', 'die Symbiose'],
      grammarFocus: 'Modalsatz mit "indem" & Passivkonstruktion im Präsens',
    ),
    AlignedBitextPair(
      pairId: 3,
      sentenceDe: 'Weitblickende Stadtplaner plädieren folglich für die Schaffung zusammenhängender Grünzüge, welche nicht nur das Mikroklima kühlen, sondern den sozialen Zusammenhalt festigen.',
      sentenceAr: 'لذلك يدعو مخططو المدن أصحاب الرؤى المستقبلية إلى إنشاء مساحات خضراء متصلة لا تلطف المناخ المصغر فحسب، بل تعزز التماسك والترابط المجتمعي.',
      iPlusOneNovelWords: ['weitblickend', 'plädieren für', 'zusammenhängende Grünzüge'],
      grammarFocus: 'Doppelkonjunktion (nicht nur... sondern auch) im Relativsatz mit "welche"',
    ),
  ];
}
