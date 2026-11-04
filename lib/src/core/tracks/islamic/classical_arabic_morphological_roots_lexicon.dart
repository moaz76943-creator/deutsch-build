class ClassicalArabicMorphologicalRootsLexicon {
  final Map<String, List<String>> derivations = {
    'ع-ل-م': ['عَلِمَ', 'عَلَّمَ', 'تَعَلَّمَ', 'اسْتَعْلَمَ', 'عِلْم', 'عَالِم'],
    'ك-ت-ب': ['كَتَبَ', 'كَاتَبَ', 'اكْتَتَبَ', 'كِتَاب', 'كَاتِب', 'مَكْتَبَة'],
  };
  List<String> getFamily(String root) => derivations[root] ?? [];
}
