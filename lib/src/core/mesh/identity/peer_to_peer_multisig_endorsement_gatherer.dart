/// Task 1553: m-of-n multisignature aggregator for verified content
class MultisigEndorsementGatherer {
  final Map<String, List<String>> _signatures = {};
  void addSig(String contentHash, String sig) => _signatures.putIfAbsent(contentHash, () => []).add(sig);
  bool hasQuorum(String contentHash, int threshold) => (_signatures[contentHash]?.length ?? 0) >= threshold;
}
