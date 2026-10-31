/// Aligned bilingual sentence pair between German and Turkish.
class GermanTurkishPair {
  final int pairId;
  final String sentenceDe;
  final String sentenceTr;
  final String communicativeContextAr;

  const GermanTurkishPair({
    required this.pairId,
    required this.sentenceDe,
    required this.sentenceTr,
    required this.communicativeContextAr,
  });
}

/// Curated parallel corpus pairing German with Turkish (tr) for community harmony in Berlin and Ruhr area.
class A1A2GermanTurkishBitextCorpus {
  static const List<GermanTurkishPair> turkishEntries = [
    GermanTurkishPair(
      pairId: 1,
      sentenceDe: 'Guten Tag, Nachbar! Schön, Sie heute gesund und munter zu sehen.',
      sentenceTr: 'İyi günler komşum! Sizi bugün sağlıklı ve neşeli görmek çok güzel.',
      communicativeContextAr: 'تحية الجوار الطيبة وتبادل الأمنيات بالصحة والنشاط بين الجيران.',
    ),
    GermanTurkishPair(
      pairId: 2,
      sentenceDe: 'Wir kochen heute gemeinsam Gemüsesuppe mit frischen Zutaten.',
      sentenceTr: 'Bugün taze malzemelerle birlikte sebze çorbası pişiriyoruz.',
      communicativeContextAr: 'الطهي المنزلي المشترك للأطعمة الصحية الطازجة.',
    ),
    GermanTurkishPair(
      pairId: 3,
      sentenceDe: 'Pünktlichkeit und gegenseitige Hilfsbereitschaft erleichtern das Zusammenleben.',
      sentenceTr: 'Dakiklik ve karşılıklı yardımlaşma birlikte yaşamayı kolaylaştırır.',
      communicativeContextAr: 'الانضباط بالمواعيد والتعاون المتبادل يرسخان حسن التعايش السلمي في الحي.',
    ),
  ];
}
