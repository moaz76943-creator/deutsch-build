/// Task 2001: Zero-configuration mDNS local peer discovery for offline classroom mesh
class LocalPeerMdnsDiscovery {
  final List<String> _discoveredPeers = [];
  void addPeer(String ip) => _discoveredPeers.add(ip);
  List<String> getPeers() => List.unmodifiable(_discoveredPeers);
}
