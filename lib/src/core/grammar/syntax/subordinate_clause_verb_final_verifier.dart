/// Task 1304: German Nebensatz verb-final word order verifier
class SubordinateClauseVerifier {
  bool isVerbFinal(List<String> tokens, int verbIndex) => verbIndex == tokens.length - 1;
}
