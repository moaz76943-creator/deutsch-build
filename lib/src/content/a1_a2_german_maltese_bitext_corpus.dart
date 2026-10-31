/// Aligned bilingual sentence pair between German and Maltese (Semitic-European Bridge).
class GermanMaltesePair {
  final int pairId;
  final String sentenceDe;
  final String sentenceMt;
  final String semiticRootNote;

  const GermanMaltesePair({
    required this.pairId,
    required this.sentenceDe,
    required this.sentenceMt,
    required this.semiticRootNote,
  });
}

/// Sovereign parallel corpus pairing German with Maltese (mt) to bridge Semitic and Germanic structures.
class A1A2GermanMalteseBitextCorpus {
  static const List<GermanMaltesePair> bitextEntries = [
    GermanMaltesePair(
      pairId: 1,
      sentenceDe: 'Guten Morgen! Der neue Tag beginnt mit Zuversicht und Frieden.',
      sentenceMt: 'L-għodwa t-tajba! Il-jum il-ġdid jibda bil-fiduċja u s-sliem.',
      semiticRootNote: 'Maltese "L-għodwa t-tajba" bridges Arabic "الغدوة الطيبة" and German greeting structures.',
    ),
    GermanMaltesePair(
      pairId: 2,
      sentenceDe: 'Wir trinken frisches Wasser und essen gesundes Brot.',
      sentenceMt: 'Aħna nixorbu ilma frisk u nieklu ħobż bnin.',
      semiticRootNote: 'Notice Semitic roots: nixorbu (نشرب), ilma (الماء), ħobż (الخبز).',
    ),
    GermanMaltesePair(
      pairId: 3,
      sentenceDe: 'Der Schüler liest fleißig ein nützliches Buch in der Bibliothek.',
      sentenceMt: 'L-istudent jaqra b’diliġenza ktieb utli fil-librerija.',
      semiticRootNote: 'Notice Semitic verbs: jaqra (يقرأ), ktieb (كتاب).',
    ),
  ];
}
