/// Task 1598: Monitors local download speed, peer count, and swarm health
class MeshStoreTelemetryBeacon {
  int activePeers = 0;
  double downloadKbps = 0.0;
  void updateSwarm(int peers, double speed) { activePeers = peers; downloadKbps = speed; }
}
