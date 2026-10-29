import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/sync_models.dart';
import '../domain/sync_services.dart';
import 'sync_conflict_resolver.dart';

final class SyncCoordinatorState {
  const SyncCoordinatorState({
    this.status = SyncStatus.offline,
    this.pendingCount = 0,
    this.conflict,
    this.lastSyncedAtUtc,
    this.message,
  });

  final SyncStatus status;
  final int pendingCount;
  final SyncConflict? conflict;
  final DateTime? lastSyncedAtUtc;
  final String? message;

  SyncCoordinatorState copyWith({
    SyncStatus? status,
    int? pendingCount,
    SyncConflict? conflict,
    bool clearConflict = false,
    DateTime? lastSyncedAtUtc,
    String? message,
    bool clearMessage = false,
  }) {
    return SyncCoordinatorState(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      conflict: clearConflict ? null : conflict ?? this.conflict,
      lastSyncedAtUtc: lastSyncedAtUtc ?? this.lastSyncedAtUtc,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}

final class SyncCoordinatorNotifier extends ChangeNotifier {
  SyncCoordinatorNotifier({
    required this.syncKey,
    required SyncRepository repository,
    required CloudStorageService cloud,
    required ConnectivityService connectivity,
    SyncConflictResolver resolver = const SyncConflictResolver(),
  })  : _repository = repository,
        _cloud = cloud,
        _connectivity = connectivity,
        _resolver = resolver {
    if (syncKey.trim().isEmpty || syncKey.length > 160) {
      throw ArgumentError.value(syncKey, 'syncKey', 'invalid sync key');
    }
  }

  final String syncKey;
  final SyncRepository _repository;
  final CloudStorageService _cloud;
  final ConnectivityService _connectivity;
  final SyncConflictResolver _resolver;

  SyncCoordinatorState _state = const SyncCoordinatorState();
  StreamSubscription<bool>? _connectivitySubscription;
  Future<void> _serial = Future<void>.value();
  bool _disposed = false;

  SyncCoordinatorState get state => _state;

  Future<void> start() async {
    if (_disposed) return;
    await _connectivitySubscription?.cancel();
    final pending = await _repository.pendingMutations();
    final online = await _connectivity.isOnline();
    _state = _state.copyWith(
      status: online ? SyncStatus.upToDate : SyncStatus.offline,
      pendingCount: pending.length,
      clearMessage: true,
    );
    notifyListeners();

    _connectivitySubscription = _connectivity.changes.distinct().listen(
      _onConnectivityChanged,
    );

    if (online) {
      await syncNow();
    }
  }

  Future<void> enqueueMutation(SyncQueueItem item) async {
    await _repository.enqueue(item);
    final pending = await _repository.pendingMutations();
    _state = _state.copyWith(pendingCount: pending.length);
    notifyListeners();

    if (await _connectivity.isOnline()) {
      await syncNow();
    } else {
      _setStatus(SyncStatus.offline);
    }
  }

  Future<void> saveLocalSnapshot(
    SyncProgressSnapshot snapshot, {
    SyncQueueItem? mutation,
  }) async {
    await _repository.saveSnapshot(snapshot);
    if (mutation != null) {
      await _repository.enqueue(mutation);
    }
    final pending = await _repository.pendingMutations();
    _state = _state.copyWith(pendingCount: pending.length);
    notifyListeners();
  }

  Future<void> syncNow() => _serialize(_syncNowInternal);

  Future<void> settle() => _serial;

  Future<void> resolveConflict(
    SyncConflictResolutionStrategy strategy,
  ) {
    return _serialize(() async {
      final conflict = _state.conflict;
      if (conflict == null) return;
      if (!await _connectivity.isOnline()) {
        _setStatus(SyncStatus.offline);
        return;
      }

      _setStatus(SyncStatus.syncing);
      final resolved = _resolver.resolve(
        local: conflict.local,
        remote: conflict.remote,
        strategy: strategy,
      );
      await _repository.saveSnapshot(resolved);
      final pending = await _repository.pendingMutations();
      final result = await _cloud.pushSnapshot(
        syncKey: syncKey,
        snapshot: resolved,
        mutations: pending,
        expectedRevision: conflict.remote.revision,
      );
      await _applyPushResult(result, pending);
    });
  }

  Future<void> _syncNowInternal() async {
    if (_disposed) return;
    if (_state.status == SyncStatus.conflictDetected &&
        _state.conflict != null) {
      return;
    }
    if (!await _connectivity.isOnline()) {
      _setStatus(SyncStatus.offline);
      return;
    }

    _setStatus(SyncStatus.syncing);
    try {
      final pending = await _repository.pendingMutations();
      final local = await _repository.loadSnapshot();
      final remote = await _cloud.fetchSnapshot(syncKey);

      if (local == null && pending.isNotEmpty) {
        throw StateError('Pending mutations require a local snapshot.');
      }

      if (local == null && remote == null) {
        _state = _state.copyWith(
          status: SyncStatus.upToDate,
          pendingCount: 0,
          lastSyncedAtUtc: DateTime.now().toUtc(),
          clearConflict: true,
          clearMessage: true,
        );
        notifyListeners();
        return;
      }

      if (local == null && remote != null) {
        await _repository.saveSnapshot(remote);
        _state = _state.copyWith(
          status: SyncStatus.upToDate,
          pendingCount: 0,
          lastSyncedAtUtc: DateTime.now().toUtc(),
          clearConflict: true,
          clearMessage: true,
        );
        notifyListeners();
        return;
      }

      if (local != null && remote == null) {
        final result = await _cloud.pushSnapshot(
          syncKey: syncKey,
          snapshot: local,
          mutations: pending,
        );
        await _applyPushResult(result, pending);
        return;
      }

      final safeLocal = local!;
      final safeRemote = remote!;
      if (_resolver.requiresUserResolution(
        local: safeLocal,
        remote: safeRemote,
      )) {
        _state = _state.copyWith(
          status: SyncStatus.conflictDetected,
          pendingCount: pending.length,
          conflict: SyncConflict(local: safeLocal, remote: safeRemote),
          message: 'sync_conflict_requires_confirmation',
        );
        notifyListeners();
        return;
      }

      final resolved = _resolver.resolve(
        local: safeLocal,
        remote: safeRemote,
        strategy:
            SyncConflictResolutionStrategy.lastWriteWinsProtectHigherStreak,
      );
      await _repository.saveSnapshot(resolved);
      final result = await _cloud.pushSnapshot(
        syncKey: syncKey,
        snapshot: resolved,
        mutations: pending,
        expectedRevision: safeRemote.revision,
      );
      await _applyPushResult(result, pending);
    } on Object {
      final pending = await _repository.pendingMutations();
      _state = _state.copyWith(
        status: SyncStatus.offline,
        pendingCount: pending.length,
        message: 'sync_unavailable_queue_preserved',
      );
      notifyListeners();
    }
  }

  Future<void> _applyPushResult(
    CloudPushResult result,
    List<SyncQueueItem> pending,
  ) async {
    if (!result.applied) {
      final local = await _repository.loadSnapshot();
      final remote = result.conflict;
      if (local != null && remote != null) {
        _state = _state.copyWith(
          status: SyncStatus.conflictDetected,
          pendingCount: pending.length,
          conflict: SyncConflict(local: local, remote: remote),
          message: 'sync_conflict_requires_confirmation',
        );
        notifyListeners();
        return;
      }
      throw StateError('Cloud conflict did not include a remote snapshot.');
    }

    final applied = result.snapshot;
    if (applied == null) {
      throw StateError('Applied cloud result requires a snapshot.');
    }

    await _repository.saveSnapshot(applied);
    await _repository.acknowledge(
      pending.map((item) => item.id).toSet(),
    );
    final remaining = await _repository.pendingMutations();
    _state = _state.copyWith(
      status: SyncStatus.upToDate,
      pendingCount: remaining.length,
      lastSyncedAtUtc: DateTime.now().toUtc(),
      clearConflict: true,
      clearMessage: true,
    );
    notifyListeners();
  }

  void _onConnectivityChanged(bool online) {
    if (_disposed) return;
    if (!online) {
      _setStatus(SyncStatus.offline);
      return;
    }
    unawaited(syncNow());
  }

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    _serial = _serial.then((_) async {
      try {
        completer.complete(await operation());
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  void _setStatus(SyncStatus status) {
    if (_disposed) return;
    _state = _state.copyWith(status: status);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_connectivitySubscription?.cancel());
    super.dispose();
  }
}
