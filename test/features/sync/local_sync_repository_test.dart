import 'package:deutsch_bilarabi/core/infrastructure/storage/local_storage_repository.dart';
import 'package:deutsch_bilarabi/features/sync/data/local_sync_repository.dart';
import 'package:deutsch_bilarabi/features/sync/domain/sync_models.dart';
import 'package:flutter_test/flutter_test.dart';

final class _MemoryStorage implements LocalStorageRepository {
  final Map<StorageBucket, Map<String, Object?>> values =
      <StorageBucket, Map<String, Object?>>{};

  @override
  Future<void> save(StorageBucket bucket, Map<String, Object?> payload) async {
    values[bucket] = Map<String, Object?>.from(payload);
  }

  @override
  Future<Map<String, Object?>?> load(StorageBucket bucket) async =>
      values[bucket] == null
          ? null
          : Map<String, Object?>.from(values[bucket]!);

  @override
  Future<void> delete(StorageBucket bucket) async => values.remove(bucket);

  @override
  Future<void> dispose() async {}
}

void main() {
  test('pending queue survives repository recreation and deduplicates entity mutations', () async {
    final storage = _MemoryStorage();
    var repository = LocalSyncRepository(storage);

    await repository.enqueue(
      SyncQueueItem(
        id: 'm1',
        entityKey: 'learner.progress',
        updatedAtUtc: DateTime.utc(2026, 10, 3, 8),
        payload: const <String, Object?>{'xp': 100},
      ),
    );
    await repository.enqueue(
      SyncQueueItem(
        id: 'm2',
        entityKey: 'learner.progress',
        updatedAtUtc: DateTime.utc(2026, 10, 3, 9),
        payload: const <String, Object?>{'xp': 150},
      ),
    );

    repository = LocalSyncRepository(storage);
    final pending = await repository.pendingMutations();

    expect(pending, hasLength(1));
    expect(pending.single.id, 'm2');
    expect(pending.single.payload['xp'], 150);
  });

  test('acknowledge removes only uploaded ids and never duplicates remaining data', () async {
    final storage = _MemoryStorage();
    final repository = LocalSyncRepository(storage);

    for (final item in <SyncQueueItem>[
      SyncQueueItem(
        id: 'm1',
        entityKey: 'srs:a',
        updatedAtUtc: DateTime.utc(2026, 10, 3, 8),
        payload: const <String, Object?>{'v': 1},
      ),
      SyncQueueItem(
        id: 'm2',
        entityKey: 'srs:b',
        updatedAtUtc: DateTime.utc(2026, 10, 3, 8),
        payload: const <String, Object?>{'v': 2},
      ),
    ]) {
      await repository.enqueue(item);
    }

    await repository.acknowledge(<String>{'m1'});
    final pending = await repository.pendingMutations();

    expect(pending.map((item) => item.id), <String>['m2']);
  });
}
