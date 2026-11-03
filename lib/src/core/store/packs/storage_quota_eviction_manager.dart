class StorageQuotaEvictionManager {
  final int maxStorageBytes;
  const StorageQuotaEvictionManager({this.maxStorageBytes = 1024 * 1024 * 1024}); // 1GB
  bool hasSpace(int currentUsed, int packSize) => (currentUsed + packSize) <= maxStorageBytes;
}
