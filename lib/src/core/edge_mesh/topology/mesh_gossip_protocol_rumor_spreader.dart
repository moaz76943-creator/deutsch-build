/// Task 2012: Anti-entropy epidemic gossip protocol disseminating learner milestones
class MeshGossipRumorSpreader {
  final Map<String, int> _seenDigests = {};
  void spreadRumor(String digest, int epoch) => _seenDigests[digest] = epoch;
}
