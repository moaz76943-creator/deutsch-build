class PeerVerifiedDecentralizedConsensusOracle {
  bool verifyPeerConsensus(int yesVotes, int totalPeers) => (yesVotes / totalPeers) >= 0.66;
}
