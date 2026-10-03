import 'package:deutsch_bilarabi/core/infrastructure/storage/local_storage_repository.dart';
import 'package:deutsch_bilarabi/core/infrastructure/storage/secure_storage_backend.dart';
import 'package:flutter_test/flutter_test.dart';

final class _MemoryBackend implements SecureStorageBackend {
  final Map<String, StorageRecord> records = <String, StorageRecord>{};
  bool failWrites = false;
  bool disposed = false;

  @override
  Future<StorageRecord?> readRecord(String key) async => records[key];

  @override
  Future<void> writeRecord(String key, StorageRecord record) async {
    if (failWrites) throw StateError('write_failed');
    records[key] = record;
  }

  @override
  Future<void> deleteRecord(String key) async {
    records.remove(key);
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  test('stores and restores learner progress, SRS and error-bank payloads',
      () async {
    final backend = _MemoryBackend();
    final repository = ResilientLocalStorageRepository(backend);

    await repository.save(
      StorageBucket.learnerProgress,
      <String, Object?>{'xp': 120, 'streak': 4},
    );
    await repository.save(
      StorageBucket.srsIntervals,
      <String, Object?>{'haus': 7, 'gehen': 3},
    );
    await repository.save(
      StorageBucket.errorBank,
      <String, Object?>{
        'items': <Object?>[
          <String, Object?>{'id': 'haus', 'failures': 2},
        ],
      },
    );

    expect(
      await repository.load(StorageBucket.learnerProgress),
      <String, Object?>{'xp': 120, 'streak': 4},
    );
    expect(
      await repository.load(StorageBucket.srsIntervals),
      <String, Object?>{'haus': 7, 'gehen': 3},
    );
    expect(
      await repository.load(StorageBucket.errorBank),
      <String, Object?>{
        'items': <Object?>[
          <String, Object?>{'id': 'haus', 'failures': 2},
        ],
      },
    );
  });

  test('recovers the last valid backup when current payload is corrupt',
      () async {
    final backend = _MemoryBackend();
    final repository = ResilientLocalStorageRepository(backend);

    await repository.save(
      StorageBucket.learnerProgress,
      <String, Object?>{'xp': 10},
    );
    await repository.save(
      StorageBucket.learnerProgress,
      <String, Object?>{'xp': 20},
    );

    final key = StorageBucket.learnerProgress.storageKey;
    final current = backend.records[key]!;
    backend.records[key] = current.copyWith(primaryPayload: '{"xp":999}');

    expect(
      await repository.load(StorageBucket.learnerProgress),
      <String, Object?>{'xp': 10},
    );

    final repaired = backend.records[key]!;
    expect(repaired.primaryPayload, repaired.backupPayload);
  });

  test('surfaces typed write failures without leaking backend exceptions',
      () async {
    final backend = _MemoryBackend()..failWrites = true;
    final repository = ResilientLocalStorageRepository(backend);

    await expectLater(
      repository.save(
        StorageBucket.learnerProgress,
        <String, Object?>{'xp': 1},
      ),
      throwsA(
        isA<LocalStorageFailure>().having(
          (failure) => failure.code,
          'code',
          LocalStorageFailureCode.writeFailed,
        ),
      ),
    );
  });

  test('dispose releases the storage backend', () async {
    final backend = _MemoryBackend();
    final repository = ResilientLocalStorageRepository(backend);

    await repository.dispose();

    expect(backend.disposed, isTrue);
  });
}
