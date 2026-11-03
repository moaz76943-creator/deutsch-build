class LocalPeerReputationScoringEngine {
  final Map<String, int> _scores = {};
  void reward(String peer) => _scores[peer] = (_scores[peer] ?? 100) + 5;
  void penalize(String peer) => _scores[peer] = (_scores[peer] ?? 100) - 20;
  bool isTrusted(String peer) => (_scores[peer] ?? 100) >= 60;
}
