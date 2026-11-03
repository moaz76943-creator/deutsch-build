class VowelHarmonyVocalicShiftEngine {
  final Set<String> backVowels = {'a', 'ı', 'o', 'u'};
  final Set<String> frontVowels = {'e', 'i', 'ö', 'ü'};
  bool isBackVowel(String v) => backVowels.contains(v.toLowerCase());
}
