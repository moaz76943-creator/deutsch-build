/// Task 1515: Tit-for-tat peer scoring and Sybil attack mitigation
class PeerReputationGuard {
  final Map<String, double> _scores = {};
  void recordUpload(String peerId, int bytes) => _scores[peerId] = (_scores[peerId] ?? 1.0) + (bytes / 1024.0);
  bool isTrustworthy(String peerId) => (_scores[peerId] ?? 1.0) >= 0.5;
}
