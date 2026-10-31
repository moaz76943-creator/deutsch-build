/// Aligned bilingual sentence pair between German and Persian (Farsi).
class GermanPersianPair {
  final int pairId;
  final String sentenceDe;
  final String sentenceFa;
  final String communicativeContextAr;

  const GermanPersianPair({
    required this.pairId,
    required this.sentenceDe,
    required this.sentenceFa,
    required this.communicativeContextAr,
  });
}

/// Curated sovereign parallel corpus pairing German with Persian (fa) for Middle Eastern learners.
class A1A2GermanPersianBitextCorpus {
  static const List<GermanPersianPair> persianEntries = [
    GermanPersianPair(
      pairId: 1,
      sentenceDe: 'Guten Tag! Es ist mir eine große Freude, Sie kennenzulernen.',
      sentenceFa: 'روز بخیر! از آشنایی با شما بسیار خوشبختم.',
      communicativeContextAr: 'صيغة التعارف والترحيب المهذبة الودية بين المتعلمين.',
    ),
    GermanPersianPair(
      pairId: 2,
      sentenceDe: 'Wissen und Bildung erhellen den Geist wie das Licht am Morgen.',
      sentenceFa: 'دانش و آموزش مانند روشنایی صبحگاه، ذهن را روشن می‌سازند.',
      communicativeContextAr: 'الحث على قيمة العلم والمعرفة في إثراء الفكر والروح.',
    ),
    GermanPersianPair(
      pairId: 3,
      sentenceDe: 'Wir trinken gemeinsam warmen Tee und unterhalten uns über Sprachen.',
      sentenceFa: 'ما با هم چای گرم می‌نوشیم و درباره زبان‌ها گفتگو می‌کنیم.',
      communicativeContextAr: 'المحادثة اللطيفة وجلسات التعلم الأخوية الهادئة.',
    ),
  ];
}
