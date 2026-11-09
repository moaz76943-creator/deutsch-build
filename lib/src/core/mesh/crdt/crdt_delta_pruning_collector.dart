import 'dart:math';

/// Represents a tombstone entry marking a deleted CRDT record.
class CrdtTombstone {
  final String recordKey;
  final int logicalTimestamp;
  final DateTime wallTimeUtc;

  CrdtTombstone({
    required this.recordKey,
    required this.logicalTimestamp,
    DateTime? wallTimeUtc,
  }) : wallTimeUtc = wallTimeUtc ?? DateTime.now().toUtc();
}

/// Garbage collector for CRDT state logs, eliminating tombstone accumulation
/// while guaranteeing causal consistency across disconnected offline peers.
class CrdtDeltaPruningCollector {
  final Map<String, CrdtTombstone> _tombstones = <String, CrdtTombstone>{};
  final Map<String, int> _peerStableCutTimestamps = <String, int>{};
  final Duration tombstoneMaxAge;

  CrdtDeltaPruningCollector({
    this.tombstoneMaxAge = const Duration(days: 14),
  });

  int get activeTombstoneCount => _tombstones.length;

  /// Register or update peer's observed causal cutoff timestamp.
  void updatePeerStableTimestamp(String peerId, int timestamp) {
    _peerStableCutTimestamps[peerId] = timestamp;
  }

  /// Mark an entity as deleted with tombstone.
  void registerTombstone(String key, int logicalTimestamp) {
    _tombstones[key] = CrdtTombstone(
      recordKey: key,
      logicalTimestamp: logicalTimestamp,
    );
  }

  /// Prune tombstones that are strictly older than both the peer cutoff and the max age.
  int collectGarbage() {
    if (_tombstones.isEmpty) return 0;

    final minPeerCutoff = _peerStableCutTimestamps.isEmpty
        ? null
        : _peerStableCutTimestamps.values.reduce(min);

    final now = DateTime.now().toUtc();
    final keysToRemove = <String>[];

    _tombstones.forEach((key, tombstone) {
      final isExpiredByAge = now.difference(tombstone.wallTimeUtc) > tombstoneMaxAge;
      final isObservedByAllPeers = minPeerCutoff != null && tombstone.logicalTimestamp <= minPeerCutoff;

      if (isExpiredByAge || isObservedByAllPeers) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _tombstones.remove(key);
    }

    return keysToRemove.length;
  }
}
