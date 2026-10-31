import 'sync_models.dart';

abstract interface class SyncRepository {
  Future<void> enqueue(SyncQueueItem item);
  Future<List<SyncQueueItem>> pendingMutations();
  Future<void> acknowledge(Set<String> ids);
  Future<SyncProgressSnapshot?> loadSnapshot();
  Future<void> saveSnapshot(SyncProgressSnapshot snapshot);
}

abstract interface class CloudStorageService {
  Future<SyncProgressSnapshot?> fetchSnapshot(String syncKey);

  Future<CloudPushResult> pushSnapshot({
    required String syncKey,
    required SyncProgressSnapshot snapshot,
    required List<SyncQueueItem> mutations,
    String? expectedRevision,
  });
}

abstract interface class ConnectivityService {
  Future<bool> isOnline();
  Stream<bool> get changes;
}
