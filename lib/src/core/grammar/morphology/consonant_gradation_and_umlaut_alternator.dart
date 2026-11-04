/// Task 1324: Ablaut/Umlaut vowel gradation alternator
class VowelGradationAlternator {
  String applyAblaut(String root, String tense) => tense == 'prateritum' ? root.replaceAll('a', 'u') : root;
}
