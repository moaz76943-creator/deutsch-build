/// Task 1034: Foreign key violation cleanup & dangling record repair
class OrphanRelationCleaner {
  int cleanedOrphans = 0;
  void recordCleaned(int count) => cleanedOrphans += count;
}
