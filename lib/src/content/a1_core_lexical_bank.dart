/// A high-frequency lexical entry with Arabic gloss, grammatical metadata, and example.
class LexicalEntry {
  final String germanWord;
  final String arabicMeaning;
  final String partOfSpeech; // verb, noun, pronoun, particle
  final String cefrLevel;
  final String exampleSentenceDe;
  final String exampleSentenceAr;

  const LexicalEntry({
    required this.germanWord,
    required this.arabicMeaning,
    required this.partOfSpeech,
    required this.cefrLevel,
    required this.exampleSentenceDe,
    required this.exampleSentenceAr,
  });
}

/// Curated foundational A1 vocabulary bank adhering strictly to ethical and moral purity.
class A1CoreLexicalBank {
  static const List<LexicalEntry> coreVocabulary = [
    LexicalEntry(
      germanWord: 'sein',
      arabicMeaning: 'يكون (فعل الكينونة الأساسي)',
      partOfSpeech: 'verb',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Ich bin Student in Berlin.',
      exampleSentenceAr: 'أنا طالب في برلين.',
    ),
    LexicalEntry(
      germanWord: 'haben',
      arabicMeaning: 'يملك / لديه',
      partOfSpeech: 'verb',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Wir haben heute viel Zeit zum Lernen.',
      exampleSentenceAr: 'لدينا اليوم وقت كافٍ للتعلم.',
    ),
    LexicalEntry(
      germanWord: 'lernen',
      arabicMeaning: 'يتعلم',
      partOfSpeech: 'verb',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Er lernt fleißig Deutsch.',
      exampleSentenceAr: 'هو يتعلم الألمانية بجد واجتهاد.',
    ),
    LexicalEntry(
      germanWord: 'arbeiten',
      arabicMeaning: 'يعمل',
      partOfSpeech: 'verb',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Mein Vater arbeitet als Ingenieur.',
      exampleSentenceAr: 'يعمل والدي مهندساً.',
    ),
    LexicalEntry(
      germanWord: 'helfen',
      arabicMeaning: 'يساعد (يأخذ حالة المجرور Dativ)',
      partOfSpeech: 'verb',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Ich helfe meinem Nachbarn gerne.',
      exampleSentenceAr: 'أساعد جاري بكل سرور.',
    ),
    LexicalEntry(
      germanWord: 'Guten Tag',
      arabicMeaning: 'نهاركم سعيد / تحية طيبة',
      partOfSpeech: 'particle',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Guten Tag! Wie geht es Ihnen?',
      exampleSentenceAr: 'نهاركم سعيد! كيف حالكم؟',
    ),
  ];

  /// Finds entry by German word lemma.
  LexicalEntry? findByWord(String word) {
    final lower = word.trim().toLowerCase();
    for (final entry in coreVocabulary) {
      if (entry.germanWord.toLowerCase() == lower) return entry;
    }
    return null;
  }
}
