/// Task 2075: Synthesizes pronominal adverbs (dafür, worauf, daran) with euphony 'r'
class PronominalAdverbSynthesizer {
  String buildDaCompound(String prep) => ['a', 'e', 'i', 'o', 'u', 'ä', 'ö', 'ü'].contains(prep[0]) ? 'dar$prep' : 'da$prep';
}
