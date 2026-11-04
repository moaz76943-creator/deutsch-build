/// Task 1351: Guards against illegal Deppenapostroph (Anna's -> Annas)
class GenitiveApostropheGuard {
  bool hasGreengrocersApostrophe(String word) => word.endsWith('\'s');
}
