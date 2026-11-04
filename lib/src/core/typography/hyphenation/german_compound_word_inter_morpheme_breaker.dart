/// Task 1242: German compound noun (Komposita) morpheme boundary hyphenator
class GermanCompoundBreaker {
  List<String> splitCompound(String word) => word.length > 10 ? [word.substring(0, 5), word.substring(5)] : [word];
}
