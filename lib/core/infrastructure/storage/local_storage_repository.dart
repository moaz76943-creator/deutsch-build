import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'secure_storage_backend.dart';

enum StorageBucket {
  learnerProgress('learner_progress_v1'),
  srsIntervals('srs_intervals_v1'),
  errorBank('error_bank_v1'),
  gamification('gamification_v1'),
  syncPendingMutations('sync_pending_mutations_v1'),
  notificationPreferences('notification_preferences_v1'),
  lexiconUserData('lexicon_user_data_v1');

  const StorageBucket(this.storageKey);

  final String storageKey;
}

enum LocalStorageFailureCode {
  invalidPayload,
  readFailed,
  writeFailed,
  disposed,
}

final class LocalStorageFailure implements Exception {
  const LocalStorageFailure(this.code);

  final LocalStorageFailureCode code;

  @override
  String toString() => 'LocalStorageFailure($code)';
}

abstract interface class LocalStorageRepository {
  Future<void> save(StorageBucket bucket, Map<String, Object?> payload);
  Future<Map<String, Object?>?> load(StorageBucket bucket);
  Future<void> delete(StorageBucket bucket);
  Future<void> dispose();
}

final class ResilientLocalStorageRepository implements LocalStorageRepository {
  ResilientLocalStorageRepository(
    this._backend, {
    HashAlgorithm? hashAlgorithm,
  }) : _hashAlgorithm = hashAlgorithm ?? Sha256();

  final SecureStorageBackend _backend;
  final HashAlgorithm _hashAlgorithm;
  bool _disposed = false;

  @override
  Future<void> save(
    StorageBucket bucket,
    Map<String, Object?> payload,
  ) async {
    _ensureActive();

    late final String encoded;
    try {
      encoded = jsonEncode(payload);
    } on Object {
      throw const LocalStorageFailure(LocalStorageFailureCode.invalidPayload);
    }

    try {
      final digest = await _digest(encoded);
      final previous = await _backend.readRecord(bucket.storageKey);

      String? backupPayload;
      String? backupDigest;
      if (previous != null) {
        if (await _decodeValid(
              previous.primaryPayload,
              previous.primaryDigest,
            ) !=
            null) {
          backupPayload = previous.primaryPayload;
          backupDigest = previous.primaryDigest;
        } else if (previous.backupPayload != null &&
            previous.backupDigest != null &&
            await _decodeValid(
                  previous.backupPayload!,
                  previous.backupDigest!,
                ) !=
                null) {
          backupPayload = previous.backupPayload;
          backupDigest = previous.backupDigest;
        }
      }

      await _backend.writeRecord(
        bucket.storageKey,
        StorageRecord(
          primaryPayload: encoded,
          primaryDigest: digest,
          backupPayload: backupPayload,
          backupDigest: backupDigest,
        ),
      );
    } on LocalStorageFailure {
      rethrow;
    } on Object {
      throw const LocalStorageFailure(LocalStorageFailureCode.writeFailed);
    }
  }

  @override
  Future<Map<String, Object?>?> load(StorageBucket bucket) async {
    _ensureActive();

    StorageRecord? record;
    try {
      record = await _backend.readRecord(bucket.storageKey);
    } on Object {
      throw const LocalStorageFailure(LocalStorageFailureCode.readFailed);
    }
    if (record == null) return null;

    final primary = await _decodeValid(
      record.primaryPayload,
      record.primaryDigest,
    );
    if (primary != null) return primary;

    final backupPayload = record.backupPayload;
    final backupDigest = record.backupDigest;
    if (backupPayload != null && backupDigest != null) {
      final backup = await _decodeValid(backupPayload, backupDigest);
      if (backup != null) {
        try {
          await _backend.writeRecord(
            bucket.storageKey,
            StorageRecord(
              primaryPayload: backupPayload,
              primaryDigest: backupDigest,
              backupPayload: backupPayload,
              backupDigest: backupDigest,
            ),
          );
        } on Object {
          // The recovered in-memory value is still safe to return. A later
          // write can repair the physical row if this best-effort repair fails.
        }
        return backup;
      }
    }

    try {
      await _backend.deleteRecord(bucket.storageKey);
    } on Object {
      // A corrupt row is treated as unavailable even if cleanup is deferred.
    }
    return null;
  }

  @override
  Future<void> delete(StorageBucket bucket) async {
    _ensureActive();
    try {
      await _backend.deleteRecord(bucket.storageKey);
    } on Object {
      throw const LocalStorageFailure(LocalStorageFailureCode.writeFailed);
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _backend.dispose();
  }

  Future<String> _digest(String payload) async {
    final digest = await _hashAlgorithm.hash(utf8.encode(payload));
    return base64UrlEncode(digest.bytes);
  }

  Future<Map<String, Object?>?> _decodeValid(
    String payload,
    String expectedDigest,
  ) async {
    if (await _digest(payload) != expectedDigest) return null;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) return null;
      return <String, Object?>{
        for (final entry in decoded.entries)
          if (entry.key is String) (entry.key as String): entry.value,
      };
    } on Object {
      return null;
    }
  }

  void _ensureActive() {
    if (_disposed) {
      throw const LocalStorageFailure(LocalStorageFailureCode.disposed);
    }
  }
}
