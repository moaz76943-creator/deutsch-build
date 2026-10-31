/// Aligned bilingual sentence pair between German and Classical Syriac (Aramaic heritage).
class GermanSyriacPair {
  final int pairId;
  final String sentenceDe;
  final String sentenceSyc;
  final String historicalNoteAr;

  const GermanSyriacPair({
    required this.pairId,
    required this.sentenceDe,
    required this.sentenceSyc,
    required this.historicalNoteAr,
  });
}

/// Sovereign parallel corpus pairing German with Classical Syriac (syc).
class A1A2GermanSyriacBitextCorpus {
  static const List<GermanSyriacPair> syriacEntries = [
    GermanSyriacPair(
      pairId: 1,
      sentenceDe: 'Friede sei mit diesem Hause und allen, die darin wohnen.',
      sentenceSyc: 'ܫܠܡܐ ܥܠ ܒܝܬܐ ܗܢܐ ܘܥܠ ܟܠ ܕܥܡܪܝܢ ܒܗ.',
      historicalNoteAr: 'تحية السلام السامية العريقة: "شلومو / شلاما" التي تقابل السلام العربي وFriede الألماني.',
    ),
    GermanSyriacPair(
      pairId: 2,
      sentenceDe: 'Der verlässliche Freund ist wie ein starker Fels im Sturm.',
      sentenceSyc: 'ܪܚܡܐ ܡܗܝܡܢܐ ܐܝܟ ܫܘܥܐ ܗܘ ܥܫܝܢܐ ܒܥܠܥܠܐ.',
      historicalNoteAr: 'الصديق الوفي: "رحمو مهايمنو" ومقابله الألماني der verlässliche Freund.',
    ),
    GermanSyriacPair(
      pairId: 3,
      sentenceDe: 'Wahre Weisheit beginnt mit dem Streben nach Wahrheit und Gerechtigkeit.',
      sentenceSyc: 'ܚܟܡܬܐ ܫܪܝܪܬܐ ܡܫܪܝܐ ܒܒܥܬܐ ܕܫܪܪܐ ܘܕܟܐܢܘܬܐ.',
      historicalNoteAr: 'الحكمة والعدل: "حكمثو شاريرثو" ومقابلها die wahre Weisheit.',
    ),
  ];
}
