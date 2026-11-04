/// Task 1512: Epidemic gossip protocol with anti-entropy synchronization
class GossipPropagator {
  int selectGossipTarget(int activePeers) => activePeers > 1 ? 2 : 1;
}
