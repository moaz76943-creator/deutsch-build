/// Pedagogical barrier descriptor for Indonesian learners.
class IndonesianGrammarBridge {
  final String featureName;
  final String indonesianReality;
  final String germanChallenge;
  final String strategyTipId;

  const IndonesianGrammarBridge({
    required this.featureName,
    required this.indonesianReality,
    required this.germanChallenge,
    required this.strategyTipId,
  });
}

/// Deep localization profile for native Indonesian (Bahasa Indonesia) speakers.
class IndonesianDeepLocalizationProfile {
  static const String localeCode = 'id';
  static const String languageName = 'Bahasa Indonesia';
  static const bool isRtl = false;
  static const String defaultWordOrder = 'SVO';

  static const List<IndonesianGrammarBridge> pedagogicalBridges = [
    IndonesianGrammarBridge(
      featureName: 'Grammatical Gender (Genus)',
      indonesianReality: 'Bahasa Indonesia tidak memiliki gender gramatikal (semua kata benda netral).',
      germanChallenge: 'Bahasa Jerman memiliki 3 artikel definit: der (maskulin), die (feminin), das (netral).',
      strategyTipId: 'Selalu hafalkan kata benda Jerman bersama artikelnya (contoh: "das Buch", bukan hanya "Buch").',
    ),
    IndonesianGrammarBridge(
      featureName: 'Verb Conjugation & Tenses',
      indonesianReality: 'Kata kerja tidak berubah bentuk (hanya ditambah kata keterangan: "sudah", "sedang", "akan").',
      germanChallenge: 'Kata kerja Jerman berkonjugasi sesuai subjek (ich lerne, du lernst, er lernt).',
      strategyTipId: 'Gunakan tabel akhiran konjugasi teratur (-e, -st, -t, -en, -t, -en) sebagai pola dasar.',
    ),
  ];
}
