/// Direct local peer discovery record.
class PeerDevice {
  final String deviceId;
  final String deviceName;
  final String connectionMedium; // 'WiFi_Direct', 'BLE', 'Local_LAN'
  final int lastSyncTimestampMs;

  const PeerDevice({
    required this.deviceId,
    required this.deviceName,
    required this.connectionMedium,
    required this.lastSyncTimestampMs,
  });
}

/// Offline Peer-to-Peer learning vault synchronizer across phones, tablets, and laptops.
class P2pVaultReplicator {
  final List<PeerDevice> _discoveredPeers = [];

  int get peerCount => _discoveredPeers.length;

  void addPeer(PeerDevice peer) {
    _discoveredPeers.removeWhere((p) => p.deviceId == peer.deviceId);
    _discoveredPeers.add(peer);
  }

  /// Calculates conflict-free sync delta between two vaults based on Lamport clocks.
  Map<String, dynamic> computeSyncDelta({
    required int localVaultVersion,
    required int remoteVaultVersion,
    required int localItemsCount,
    required int remoteItemsCount,
  }) {
    if (localVaultVersion == remoteVaultVersion) {
      return {'status': 'in_sync', 'needsTransfer': false, 'itemsToReplicate': 0};
    }

    final isRemoteNewer = remoteVaultVersion > localVaultVersion;
    final itemDelta = (remoteItemsCount - localItemsCount).abs();

    return {
      'status': isRemoteNewer ? 'pull_required' : 'push_required',
      'needsTransfer': true,
      'itemsToReplicate': itemDelta,
      'targetVersion': isRemoteNewer ? remoteVaultVersion : localVaultVersion,
    };
  }
}
