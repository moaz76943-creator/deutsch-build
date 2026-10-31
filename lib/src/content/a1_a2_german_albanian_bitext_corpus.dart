/// Aligned bilingual sentence pair between German and Albanian.
class GermanAlbanianPair {
  final int pairId;
  final String sentenceDe;
  final String sentenceSq;
  final String communicativeContextAr;

  const GermanAlbanianPair({
    required this.pairId,
    required this.sentenceDe,
    required this.sentenceSq,
    required this.communicativeContextAr,
  });
}

/// Curated sovereign parallel corpus pairing German with Albanian (sq) for Southeast European learners.
class A1A2GermanAlbanianBitextCorpus {
  static const List<GermanAlbanianPair> albanianEntries = [
    GermanAlbanianPair(
      pairId: 1,
      sentenceDe: 'Guten Tag! Ein ehrliches Wort ist mehr wert als Gold.',
      sentenceSq: 'Mirëdita! Një fjalë e sinqertë vlen më shumë se ari.',
      communicativeContextAr: 'الصدق في القول والتعامل الإنساني النبيل.',
    ),
    GermanAlbanianPair(
      pairId: 2,
      sentenceDe: 'Gemeinsames Lernen stärkt den Geist und verbindet die Menschen.',
      sentenceSq: 'Mësimi i përbashkët forcon mendjen dhe bashkon njerëzit.',
      communicativeContextAr: 'التعلم الجماعي ينمي الفكر ويبني أواصر الأخوة بين البشر.',
    ),
    GermanAlbanianPair(
      pairId: 3,
      sentenceDe: 'Die Gesundheit der Familie ist das größte Gut im Leben.',
      sentenceSq: 'Shëndeti i familjes është pasuria më e madhe në jetë.',
      communicativeContextAr: 'صحة الأسرة وسلامتها هي أعظم نعم الحياة.',
    ),
  ];
}
