/// Task 1584: Local storage manager auto-evicting stale pack caches
class StorageQuotaEvictionManager {
  bool shouldEvict(int currentBytes, int maxBytes) => currentBytes > maxBytes;
}
