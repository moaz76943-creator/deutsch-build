import 'dart:math';

/// State descriptor for an active mesh peer.
class MeshPeerNode {
  final String peerId;
  final String ipAddress;
  final int port;
  int heartbeatSequence;
  DateTime lastSeenUtc;
  bool isAlive;

  MeshPeerNode({
    required this.peerId,
    required this.ipAddress,
    required this.port,
    this.heartbeatSequence = 0,
    DateTime? lastSeenUtc,
    this.isAlive = true,
  }) : lastSeenUtc = lastSeenUtc ?? DateTime.now().toUtc();
}

/// Decentralized anti-entropy gossip routing table.
/// Enforces bounded neighbor capacity (max 32 nodes) to prevent memory exhaustion on mobile.
class DecentralizedGossipDiscoveryProtocol {
  final String localNodeId;
  final int maxNeighbors;
  final Duration peerTimeout;
  final Map<String, MeshPeerNode> _routingTable = <String, MeshPeerNode>{};

  DecentralizedGossipDiscoveryProtocol({
    required this.localNodeId,
    this.maxNeighbors = 32,
    this.peerTimeout = const Duration(seconds: 45),
  });

  int get activePeerCount => _routingTable.values.where((p) => p.isAlive).length;
  int get totalTableSize => _routingTable.length;

  /// Register or refresh peer heartbeat.
  bool recordHeartbeat(String peerId, String ip, int port, int sequence) {
    if (peerId == localNodeId) return false;

    if (_routingTable.containsKey(peerId)) {
      final peer = _routingTable[peerId]!;
      if (sequence > peer.heartbeatSequence) {
        peer.heartbeatSequence = sequence;
        peer.lastSeenUtc = DateTime.now().toUtc();
        peer.isAlive = true;
        return true;
      }
      return false;
    }

    // Bounded table check
    if (_routingTable.length >= maxNeighbors) {
      evictStalePeers();
      if (_routingTable.length >= maxNeighbors) {
        return false; // Table full, drop new peer until space frees
      }
    }

    _routingTable[peerId] = MeshPeerNode(
      peerId: peerId,
      ipAddress: ip,
      port: port,
      heartbeatSequence: sequence,
    );
    return true;
  }

  /// Mark and remove stale peers that exceeded timeout.
  int evictStalePeers() {
    final now = DateTime.now().toUtc();
    final staleKeys = <String>[];

    _routingTable.forEach((key, peer) {
      if (now.difference(peer.lastSeenUtc) > peerTimeout) {
        staleKeys.add(key);
      }
    });

    for (final key in staleKeys) {
      _routingTable.remove(key);
    }

    return staleKeys.length;
  }

  /// Select random gossip target peers for anti-entropy broadcast.
  List<MeshPeerNode> selectGossipTargets({int fanout = 3}) {
    final alivePeers = _routingTable.values.where((p) => p.isAlive).toList();
    if (alivePeers.length <= fanout) {
      return alivePeers;
    }

    alivePeers.shuffle(Random());
    return alivePeers.take(fanout).toList();
  }
}
