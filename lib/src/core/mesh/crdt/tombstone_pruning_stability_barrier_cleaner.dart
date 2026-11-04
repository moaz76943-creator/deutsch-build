/// Task 1527: Garbage collects obsolete deletion tombstones
class TombstonePruner {
  void prune(Set<String> tombstones, Set<String> ackedPeers, int allPeersCount) {
    if (ackedPeers.length >= allPeersCount) tombstones.clear();
  }
}
