/// Aligned bilingual sentence pair between German and Bosnian.
class GermanBosnianPair {
  final int pairId;
  final String sentenceDe;
  final String sentenceBs;
  final String communicativeContextAr;

  const GermanBosnianPair({
    required this.pairId,
    required this.sentenceDe,
    required this.sentenceBs,
    required this.communicativeContextAr,
  });
}

/// Curated sovereign parallel corpus pairing German with Bosnian (bs) for Balkan multilingual learners.
class A1A2GermanBosnianBitextCorpus {
  static const List<GermanBosnianPair> bosnianEntries = [
    GermanBosnianPair(
      pairId: 1,
      sentenceDe: 'Guten Tag! Es ist wichtig, den Nachbarn mit Freundlichkeit zu begegnen.',
      sentenceBs: 'Dobar dan! Važno je komšijama prilaziti s ljubaznošću.',
      communicativeContextAr: 'حسن التعامل واللطف مع الجيران في الحياة اليومية.',
    ),
    GermanBosnianPair(
      pairId: 2,
      sentenceDe: 'Wissen und Fleiß öffnen Türen zu neuen Horizonten.',
      sentenceBs: 'Znanje i marljivost otvaraju vrata novim vidicima.',
      communicativeContextAr: 'قيمة العلم والاجتهاد في فتح آفاق المستقبل.',
    ),
    GermanBosnianPair(
      pairId: 3,
      sentenceDe: 'Wir schätzen die Ruhe der Natur und bewahren die Umwelt.',
      sentenceBs: 'Cijenimo mir prirode i čuvamo životnu sredinu.',
      communicativeContextAr: 'تقدير سكينة الطبيعة وصون البيئة والمحيط الحيوي.',
    ),
  ];
}
