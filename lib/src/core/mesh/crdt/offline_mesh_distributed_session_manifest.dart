/// Task 1538: Lightweight manifest summarizing node CRDT state vector
class DistributedSessionManifest {
  String generateManifest(String nodeId, int clock) => '{"node":"$nodeId","clock":$clock}';
}
