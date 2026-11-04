/// Task 1855: Storage quota arbiter managing offline language pack limits and LRU caching
class PackStorageQuotaArbiter {
  bool canFitPack(int packSizeMb, int availableDiskMb) => availableDiskMb > (packSizeMb + 200);
}
