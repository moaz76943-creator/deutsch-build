/// Aligned bilingual sentence pair between German and Urdu.
class GermanUrduPair {
  final int pairId;
  final String sentenceDe;
  final String sentenceUr;
  final String communicativeContextAr;

  const GermanUrduPair({
    required this.pairId,
    required this.sentenceDe,
    required this.sentenceUr,
    required this.communicativeContextAr,
  });
}

/// Curated sovereign parallel corpus pairing German with Urdu (ur) for South Asian multilingual learners.
class A1A2GermanUrduBitextCorpus {
  static const List<GermanUrduPair> urduEntries = [
    GermanUrduPair(
      pairId: 1,
      sentenceDe: 'Guten Tag! Friede und Segen seien mit Ihnen.',
      sentenceUr: 'السلام علیکم! آپ پر سلامتی اور برکت ہو۔',
      communicativeContextAr: 'تحية السلام والبركة النبيلة في اللقاء.',
    ),
    GermanUrduPair(
      pairId: 2,
      sentenceDe: 'Ehrliche Arbeit und Fleiß bringen wahren Erfolg im Leben.',
      sentenceUr: 'ایماندارانہ محنت اور لگن ہی زندگی میں حقیقی کامیابی لاتی ہے۔',
      communicativeContextAr: 'العمل النزيه والاجتهاد الدؤوب طريق النجاح الحقيقي.',
    ),
    GermanUrduPair(
      pairId: 3,
      sentenceDe: 'Die Familie ist die Quelle von Liebe, Geborgenheit und Stärke.',
      sentenceUr: 'خاندان محبت، تحفظ اور طاقت کا سرچشمہ ہے۔',
      communicativeContextAr: 'الأسرة هي مهد المحبة والأمان والقوة في المجتمع.',
    ),
  ];
}
