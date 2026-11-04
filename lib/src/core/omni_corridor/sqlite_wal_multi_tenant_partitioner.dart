/// Task 1905: Multi-tenant SQLite partitioner isolating 100 language schemas
class SqliteMultiTenantPartitioner {
  String getPartitionPath(String base, String lang) => '$base/partition_$lang.db';
}
