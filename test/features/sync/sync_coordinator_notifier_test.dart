import 'dart:async';

import 'package:deutsch_bilarabi/features/sync/application/sync_coordinator_notifier.dart';
import 'package:deutsch_bilarabi/features/sync/domain/sync_models.dart';
import 'package:deutsch_bilarabi/features/sync/domain/sync_services.dart';
import 'package:flutter_test/flutter_test.dart';

final class _MemorySyncRepository implements SyncRepository {
  final List<SyncQueueItem> queue = <SyncQueueItem>[];
  SyncProgressSnapshot? snapshot;

  @override
  Future<void> enqueue(SyncQueueItem item) async {
    queue.removeWhere((existing) => existing.entityKey == item.entityKey);
    queue.add(item);
  }

  @override
  Future<List<SyncQueueItem>> pendingMutations() async =>
      List<SyncQueueItem>.unmodifiable(queue);

  @override
  Future<void> acknowledge(Set<String> ids) async =>
      queue.removeWhere((item) => ids.contains(item.id));

  @override
  Future<SyncProgressSnapshot?> loadSnapshot() async => snapshot;

  @override
  Future<void> saveSnapshot(SyncProgressSnapshot value) async {
    snapshot = value;
  }
}

final class _FakeCloud implements CloudStorageService {
  SyncProgressSnapshot? remote;
  int pushes = 0;

  @override
  Future<SyncProgressSnapshot?> fetchSnapshot(String syncKey) async => remote;

  @override
  Future<CloudPushResult> pushSnapshot({
    required String syncKey,
    required SyncProgressSnapshot snapshot,
    required List<SyncQueueItem> mutations,
    String? expectedRevision,
  }) async {
    pushes += 1;
    remote = snapshot.copyWith(revision: 'cloud-$pushes');
    return CloudPushResult.applied(remote!);
  }
}

final class _Connectivity implements ConnectivityService {
  _Connectivity(this.online);

  bool online;
  final StreamController<bool> controller = StreamController<bool>.broadcast(sync: true);

  @override
  Future<bool> isOnline() async => online;

  @override
  Stream<bool> get changes => controller.stream;

  void setOnline(bool value) {
    online = value;
    controller.add(value);
  }
}

SyncProgressSnapshot snapshot(String revision, DateTime at) =>
    SyncProgressSnapshot(
      revision: revision,
      updatedAtUtc: at,
      currentStreak: 3,
      longestStreak: 5,
      totalXp: 100,
      srs: const <String, SyncSrsRecord>{},
      achievementIds: const <String>{},
    );

void main() {
  test('offline mutations remain queued and status stays offline', () async {
    final repository = _MemorySyncRepository()
      ..snapshot = snapshot('local-1', DateTime.utc(2026, 10, 3, 8));
    final cloud = _FakeCloud();
    final connectivity = _Connectivity(false);
    final coordinator = SyncCoordinatorNotifier(
      syncKey: 'learner-1',
      repository: repository,
      cloud: cloud,
      connectivity: connectivity,
    );
    addTearDown(() async {
      coordinator.dispose();
      await connectivity.controller.close();
    });

    await coordinator.start();
    await coordinator.enqueueMutation(
      SyncQueueItem(
        id: 'm1',
        entityKey: 'learner.progress',
        updatedAtUtc: DateTime.utc(2026, 10, 3, 9),
        payload: const <String, Object?>{'xp': 120},
      ),
    );

    expect(coordinator.state.status, SyncStatus.offline);
    expect(await repository.pendingMutations(), hasLength(1));
    expect(cloud.pushes, 0);
  });

  test('queued mutations flush automatically when connectivity returns', () async {
    final repository = _MemorySyncRepository()
      ..snapshot = snapshot('local-1', DateTime.utc(2026, 10, 3, 8));
    final cloud = _FakeCloud();
    final connectivity = _Connectivity(false);
    final coordinator = SyncCoordinatorNotifier(
      syncKey: 'learner-1',
      repository: repository,
      cloud: cloud,
      connectivity: connectivity,
    );
    addTearDown(() async {
      coordinator.dispose();
      await connectivity.controller.close();
    });

    await coordinator.start();
    await coordinator.enqueueMutation(
      SyncQueueItem(
        id: 'm1',
        entityKey: 'learner.progress',
        updatedAtUtc: DateTime.utc(2026, 10, 3, 9),
        payload: const <String, Object?>{'xp': 120},
      ),
    );

    connectivity.setOnline(true);
    await coordinator.settle();

    expect(cloud.pushes, 1);
    expect(await repository.pendingMutations(), isEmpty);
    expect(coordinator.state.status, SyncStatus.upToDate);
  });

  test('ambiguous equal-time conflict pauses for explicit resolution', () async {
    final at = DateTime.utc(2026, 10, 3, 9);
    final repository = _MemorySyncRepository()
      ..snapshot = snapshot('local', at);
    final cloud = _FakeCloud()..remote = snapshot('remote', at);
    final connectivity = _Connectivity(true);
    final coordinator = SyncCoordinatorNotifier(
      syncKey: 'learner-1',
      repository: repository,
      cloud: cloud,
      connectivity: connectivity,
    );
    addTearDown(() async {
      coordinator.dispose();
      await connectivity.controller.close();
    });

    await coordinator.start();
    await coordinator.syncNow();

    expect(coordinator.state.status, SyncStatus.conflictDetected);
    expect(coordinator.state.conflict, isNotNull);

    await coordinator.resolveConflict(
      SyncConflictResolutionStrategy.mergeProgress,
    );

    expect(coordinator.state.status, SyncStatus.upToDate);
    expect(coordinator.state.conflict, isNull);
  });

  test('never acknowledges queued mutations when local snapshot is missing', () async {
    final repository = _MemorySyncRepository();
    final queued = SyncQueueItem(
      id: 'm1',
      entityKey: 'learner.progress',
      updatedAtUtc: DateTime.utc(2026, 10, 3, 9),
      payload: const <String, Object?>{'xp': 120},
    );
    repository.queue.add(queued);

    final cloud = _FakeCloud()
      ..remote = snapshot('remote', DateTime.utc(2026, 10, 3, 8));
    final connectivity = _Connectivity(true);
    final coordinator = SyncCoordinatorNotifier(
      syncKey: 'learner-1',
      repository: repository,
      cloud: cloud,
      connectivity: connectivity,
    );
    addTearDown(() async {
      coordinator.dispose();
      await connectivity.controller.close();
    });

    await coordinator.start();

    expect(await repository.pendingMutations(), hasLength(1));
    expect(repository.snapshot, isNull);
    expect(coordinator.state.status, SyncStatus.offline);
    expect(
      coordinator.state.message,
      'sync_unavailable_queue_preserved',
    );
  });
}
