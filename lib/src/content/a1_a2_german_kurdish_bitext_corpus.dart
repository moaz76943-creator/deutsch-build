/// Aligned bilingual sentence pair between German and Kurdish (Sorani).
class GermanKurdishPair {
  final int pairId;
  final String sentenceDe;
  final String sentenceCkb;
  final String communicativeContextAr;

  const GermanKurdishPair({
    required this.pairId,
    required this.sentenceDe,
    required this.sentenceCkb,
    required this.communicativeContextAr,
  });
}

/// Sovereign parallel corpus pairing German with Kurdish (ckb) for Middle Eastern multilingual learners.
class A1A2GermanKurdishBitextCorpus {
  static const List<GermanKurdishPair> kurdishEntries = [
    GermanKurdishPair(
      pairId: 1,
      sentenceDe: 'Guten Tag! Willkommen in unserer Gemeinschaft.',
      sentenceCkb: 'ڕۆژتان باش! بەخێربێن بۆ ناو کۆمەڵگەکەمان.',
      communicativeContextAr: 'الترحيب الودود بالأعضاء الجدد في المجتمع.',
    ),
    GermanKurdishPair(
      pairId: 2,
      sentenceDe: 'Bildung ist das stärkste Fundament für eine friedliche Zukunft.',
      sentenceCkb: 'پەروەردە و فێرکردن بەهێزترین بنچینەیە بۆ داهاتوویەکی ئاشتیانە.',
      communicativeContextAr: 'التعليم هو الأساس المتين لمستقبل يسوده السلام والأمان.',
    ),
    GermanKurdishPair(
      pairId: 3,
      sentenceDe: 'Wir unterstützen einander mit Respekt und Aufrichtigkeit.',
      sentenceCkb: 'ئێمە بە ڕێز و دڵسۆزییەوە پشتیوانی لە یەکتر دەکەین.',
      communicativeContextAr: 'التضامن والتآزر القائم على الاحترام والإخلاص المتبادل.',
    ),
  ];
}
