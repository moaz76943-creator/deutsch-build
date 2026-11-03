/// Task 1028: RAM-to-disk spillover buffer preventing SQLite memory pressure
class TransientCacheSpillover {
  int ramEntries = 0;
  int diskSpillEntries = 0;
  void pushEntry(bool toDisk) => toDisk ? diskSpillEntries++ : ramEntries++;
}
