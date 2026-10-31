/// Aligned bilingual parallel sentence pair.
class AlignedBitextPair {
  final int pairId;
  final String sentenceDe;
  final String sentenceAr;
  final List<String> iPlusOneNovelWords;
  final String grammarFocus;

  const AlignedBitextPair({
    required this.pairId,
    required this.sentenceDe,
    required this.sentenceAr,
    required this.iPlusOneNovelWords,
    required this.grammarFocus,
  });
}

/// Curated parallel A1 corpus providing Krashen i+1 comprehensible reading input.
class A1GermanArabicBitextCorpus {
  static const String storyTitleDe = 'Tariqs erster Tag in der Sprachschule';
  static const String storyTitleAr = 'يوم طارق الأول في مدرسة تعليم اللغات';

  static const List<AlignedBitextPair> storyParagraphs = [
    AlignedBitextPair(
      pairId: 1,
      sentenceDe: 'Tariq steht früh am Morgen auf und frühstückt mit seiner Familie.',
      sentenceAr: 'يستيقظ طارق في الصباح الباكر ويتناول وجبة الإفطار مع عائلته.',
      iPlusOneNovelWords: ['frühstücken', 'aufstehen'],
      grammarFocus: 'Trennbare Verben im Präsens (الأفعال المنفصلة)',
    ),
    AlignedBitextPair(
      pairId: 2,
      sentenceDe: 'Er nimmt seine Tasche, in der ein neues deutsches Buch liegt.',
      sentenceAr: 'يأخذ حقيبته التي يوجد فيها كتاب ألماني جديد.',
      iPlusOneNovelWords: ['die Tasche', 'liegen'],
      grammarFocus: 'Lokale Präpositionen mit Dativ (حروف الجر المكانية)',
    ),
    AlignedBitextPair(
      pairId: 3,
      sentenceDe: 'An der Haltestelle wartet er ruhig auf den Bus zur Sprachschule.',
      sentenceAr: 'ينتظر الحافلة المتجهة إلى مدرسة اللغات بهدوء عند موقف الحافلات.',
      iPlusOneNovelWords: ['warten auf', 'die Haltestelle'],
      grammarFocus: 'Feste Verb-Präposition-Verbindung (warten auf + Akk)',
    ),
    AlignedBitextPair(
      pairId: 4,
      sentenceDe: 'Im Klassenzimmer begrüßt die freundliche Lehrerin alle neuen Schüler mit einem Lächeln.',
      sentenceAr: 'في قاعة الدرس، ترحب المعلمة اللطيفة بجميع الطلاب الجدد بابتسامة طيبة.',
      iPlusOneNovelWords: ['begrüßen', 'das Lächeln'],
      grammarFocus: 'Adjektivdeklination nach bestimmtem Artikel (إعراب الصفات)',
    ),
  ];
}
