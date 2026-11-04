class P2pChunkRetransmissionArbiter {
  final Set<int> missingChunks = {};
  void markLost(int idx) => missingChunks.add(idx);
  void markReceived(int idx) => missingChunks.remove(idx);
}
