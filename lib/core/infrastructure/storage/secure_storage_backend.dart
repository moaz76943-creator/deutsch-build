abstract interface class SecureStorageBackend {
  Future<StorageRecord?> readRecord(String key);
  Future<void> writeRecord(String key, StorageRecord record);
  Future<void> deleteRecord(String key);
  Future<void> dispose();
}

final class StorageRecord {
  const StorageRecord({
    required this.primaryPayload,
    required this.primaryDigest,
    this.backupPayload,
    this.backupDigest,
  });

  final String primaryPayload;
  final String primaryDigest;
  final String? backupPayload;
  final String? backupDigest;

  StorageRecord copyWith({
    String? primaryPayload,
    String? primaryDigest,
    String? backupPayload,
    String? backupDigest,
  }) {
    return StorageRecord(
      primaryPayload: primaryPayload ?? this.primaryPayload,
      primaryDigest: primaryDigest ?? this.primaryDigest,
      backupPayload: backupPayload ?? this.backupPayload,
      backupDigest: backupDigest ?? this.backupDigest,
    );
  }
}

final class SecureStorageBackendException implements Exception {
  const SecureStorageBackendException(this.code);

  final String code;

  @override
  String toString() => 'SecureStorageBackendException($code)';
}
