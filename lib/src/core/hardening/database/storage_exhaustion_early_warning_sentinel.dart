/// Task 1035: Low-disk space sentinel preventing incomplete write transactions
class StorageExhaustionSentinel {
  bool isStorageSufficient(int freeBytes) => freeBytes > (50 * 1024 * 1024);
}
