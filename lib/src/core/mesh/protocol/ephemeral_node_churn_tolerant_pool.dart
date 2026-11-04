/// Task 1507: Peer pool tracking active vs stale nodes
class PeerNodePool {
  final Map<String, int> _nodes = {};
  void updateHeartbeat(String nodeId, int timestamp) => _nodes[nodeId] = timestamp;
  bool isAlive(String nodeId, int now) => (now - (_nodes[nodeId] ?? 0)) < 30000;
}
