import 'dart:math';

/// A versioned key-value record in the multi-master edge database.
class VersionedRecord {
  final String key;
  final String value;
  final int version;
  final int physicalTimestampUtc;
  final String originNodeId;

  VersionedRecord({
    required this.key,
    required this.value,
    required this.version,
    required this.physicalTimestampUtc,
    required this.originNodeId,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'val': value,
        'ver': version,
        'ts': physicalTimestampUtc,
        'origin': originNodeId,
      };
}

/// Anti-Entropy protocol reconciling states between multi-master edge nodes.
/// Uses Last-Write-Wins (LWW) with deterministic node ID tie-breaking.
class AntiEntropyReconciliationProtocol {
  final String localNodeId;
  final Map<String, VersionedRecord> _localStore = <String, VersionedRecord>{};

  AntiEntropyReconciliationProtocol({required this.localNodeId});

  int get localRecordCount => _localStore.length;

  /// Put or update a local record.
  void putLocal(String key, String value) {
    final prev = _localStore[key];
    final nextVersion = (prev?.version ?? 0) + 1;
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    _localStore[key] = VersionedRecord(
      key: key,
      value: value,
      version: nextVersion,
      physicalTimestampUtc: now,
      originNodeId: localNodeId,
    );
  }

  /// Get local version vector / catalog.
  Map<String, int> getVersionCatalog() {
    return _localStore.map((key, record) => MapEntry(key, record.version));
  }

  /// Reconcile remote incoming record. Returns true if local store was updated.
  bool reconcileRemoteRecord(VersionedRecord remote) {
    final local = _localStore[remote.key];

    if (local == null) {
      _localStore[remote.key] = remote;
      return true;
    }

    if (remote.version > local.version) {
      _localStore[remote.key] = remote;
      return true;
    } else if (remote.version == local.version) {
      // Tie-break: Higher physical timestamp wins
      if (remote.physicalTimestampUtc > local.physicalTimestampUtc) {
        _localStore[remote.key] = remote;
        return true;
      } else if (remote.physicalTimestampUtc == local.physicalTimestampUtc) {
        // Deterministic lexicographical tie-break on node ID
        if (remote.originNodeId.compareTo(local.originNodeId) > 0) {
          _localStore[remote.key] = remote;
          return true;
        }
      }
    }

    return false;
  }

  VersionedRecord? getRecord(String key) => _localStore[key];
}
