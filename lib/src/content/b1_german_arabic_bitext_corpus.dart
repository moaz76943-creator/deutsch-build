import 'a1_german_arabic_bitext_corpus.dart';

/// Curated parallel B1 corpus covering community service, technological innovation, and civic responsibility.
class B1GermanArabicBitextCorpus {
  static const String storyTitleDe = 'Ehrenamtliche Initiative: Brücken zwischen Generationen';
  static const String storyTitleAr = 'مبادرة تطوعية: جسور المحبة بين الأجيال';

  static const List<AlignedBitextPair> b1StoryParagraphs = [
    AlignedBitextPair(
      pairId: 1,
      sentenceDe: 'In einer dynamischen Großstadt gründeten engagierte Jugendliche eine ehrenamtliche Initiative zur Unterstützung älterer Nachbarn.',
      sentenceAr: 'في مدينة كبرى نابضة بالحياة، أسس شباب مخلصون ومبادرون مبادرة تطوعية لدعم ومساعدة الجيران من كبار السن.',
      iPlusOneNovelWords: ['das Ehrenamt', 'engagiert', 'die Initiative'],
      grammarFocus: 'Partizip I und II als Adjektive (engagierte Jugendliche)',
    ),
    AlignedBitextPair(
      pairId: 2,
      sentenceDe: 'Sie halfen beim wöchentlichen Lebensmitteleinkauf und erklärten geduldig die Bedienung moderner Kommunikationsmittel.',
      sentenceAr: 'ساعدوهم في شراء مستلزماتهم الغذائية الأسبوعية، وشرحوا لهم بصبر وأناة كيفية استخدام وسائل التواصل الحديثة.',
      iPlusOneNovelWords: ['die Bedienung', 'geduldig', 'die Kommunikationsmittel'],
      grammarFocus: 'Präteritum narrativer Stil & Dativ-Verben (helfen)',
    ),
    AlignedBitextPair(
      pairId: 3,
      sentenceDe: 'Durch diese herzliche Begegnung entstand ein wertvoller Dialog, von dem beide Generationen nachhaltig profitierten.',
      sentenceAr: 'ومن خلال هذا اللقاء القلبي الدافئ، نشأ حوار إنساني بنّاء وقيّم، عادت ثماره بالنفع المستدام على كلا الجيلين.',
      iPlusOneNovelWords: ['die Begegnung', 'nachhaltig', 'profitieren von'],
      grammarFocus: 'Relativsätze mit Präpositionen (von dem beide profitierten)',
    ),
  ];
}
