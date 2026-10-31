class BlePeerLearner {
  final String peerId;
  final String displayName;
  final int rssiSignalStrength;
  final int levelRank;

  const BlePeerLearner({
    required this.peerId,
    required this.displayName,
    required this.rssiSignalStrength,
    required this.levelRank,
  });
}

class BluetoothMatchmaker {
  static const String serviceUuid = '0000FD69-0000-1000-8000-00805F9B34FB';
  final List<BlePeerLearner> _discoveredPeers = [];

  BluetoothMatchmaker();

  List<BlePeerLearner> get discoveredPeers => List.unmodifiable(_discoveredPeers);

  void registerDiscoveredPeer(BlePeerLearner peer) {
    _discoveredPeers.removeWhere((p) => p.peerId == peer.peerId);
    _discoveredPeers.add(peer);
  }

  BlePeerLearner? selectOptimalDuelOpponent() {
    if (_discoveredPeers.isEmpty) return null;
    _discoveredPeers.sort((a, b) => b.rssiSignalStrength.compareTo(a.rssiSignalStrength));
    return _discoveredPeers.first;
  }
}
