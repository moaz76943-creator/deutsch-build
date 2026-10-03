import '../../../core/infrastructure/storage/local_storage_repository.dart';
import '../domain/sync_models.dart';
import '../domain/sync_services.dart';

final class LocalSyncRepository implements SyncRepository {
  LocalSyncRepository(this._storage);

  final LocalStorageRepository _storage;
  Future<void> _writeTail = Future<void>.value();

  @override
  Future<void> enqueue(SyncQueueItem item) {
    return _serialize(() async {
      final state = await _readState();
      final byEntity = <String, SyncQueueItem>{
        for (final existing in state.queue) existing.entityKey: existing,
      };
      final previous = byEntity[item.entityKey];
      if (previous == null ||
          !item.updatedAtUtc.isBefore(previous.updatedAtUtc)) {
        byEntity[item.entityKey] = item;
      }
      final queue = byEntity.values.toList(growable: false)
        ..sort((a, b) {
          final time = a.updatedAtUtc.compareTo(b.updatedAtUtc);
          return time != 0 ? time : a.id.compareTo(b.id);
        });
      await _writeState(_StoredSyncState(queue: queue, snapshot: state.snapshot));
    });
  }

  @override
  Future<List<SyncQueueItem>> pendingMutations() async {
    final state = await _readAfterWrites();
    return List<SyncQueueItem>.unmodifiable(state.queue);
  }

  @override
  Future<void> acknowledge(Set<String> ids) {
    if (ids.isEmpty) return Future<void>.value();
    return _serialize(() async {
      final state = await _readState();
      final queue = state.queue
          .where((item) => !ids.contains(item.id))
          .toList(growable: false);
      await _writeState(_StoredSyncState(queue: queue, snapshot: state.snapshot));
    });
  }

  @override
  Future<SyncProgressSnapshot?> loadSnapshot() async =>
      (await _readAfterWrites()).snapshot;

  @override
  Future<void> saveSnapshot(SyncProgressSnapshot snapshot) {
    return _serialize(() async {
      final state = await _readState();
      await _writeState(_StoredSyncState(queue: state.queue, snapshot: snapshot));
    });
  }

  Future<T> _serialize<T>(Future<T> Function() action) {
    final next = _writeTail.then((_) => action());
    _writeTail = next.then<void>((_) {}).catchError((_) {});
    return next;
  }

  Future<_StoredSyncState> _readAfterWrites() async {
    await _writeTail;
    return _readState();
  }

  Future<_StoredSyncState> _readState() async {
    final raw = await _storage.load(StorageBucket.syncPendingMutations);
    if (raw == null) return const _StoredSyncState();

    final queue = <SyncQueueItem>[];
    final rawQueue = raw['queue'];
    if (rawQueue is List) {
      for (final entry in rawQueue.whereType<Map>()) {
        final json = <String, Object?>{
          for (final item in entry.entries)
            if (item.key is String) item.key as String: item.value,
        };
        try {
          queue.add(SyncQueueItem.fromJson(json));
        } on FormatException {
          continue;
        } on ArgumentError {
          continue;
        }
      }
    }

    SyncProgressSnapshot? snapshot;
    final rawSnapshot = raw['snapshot'];
    if (rawSnapshot is Map) {
      final json = <String, Object?>{
        for (final entry in rawSnapshot.entries)
          if (entry.key is String) entry.key as String: entry.value,
      };
      try {
        snapshot = SyncProgressSnapshot.fromJson(json);
      } on FormatException {
        snapshot = null;
      } on ArgumentError {
        snapshot = null;
      }
    }
    return _StoredSyncState(queue: queue, snapshot: snapshot);
  }

  Future<void> _writeState(_StoredSyncState state) {
    return _storage.save(
      StorageBucket.syncPendingMutations,
      <String, Object?>{
        'queue': state.queue.map((item) => item.toJson()).toList(growable: false),
        if (state.snapshot != null) 'snapshot': state.snapshot!.toJson(),
      },
    );
  }
}

final class _StoredSyncState {
  const _StoredSyncState({
    this.queue = const <SyncQueueItem>[],
    this.snapshot,
  });

  final List<SyncQueueItem> queue;
  final SyncProgressSnapshot? snapshot;
}
