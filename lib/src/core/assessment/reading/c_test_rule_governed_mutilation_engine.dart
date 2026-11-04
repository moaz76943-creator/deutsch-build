/// Task 1472: Standard C-Test generator (cuts second half of every 2nd word)
class CTestMutilationEngine {
  String mutilateWord(String word) => word.length > 2 ? word.substring(0, (word.length / 2).ceil()) + '___' : word;
}
