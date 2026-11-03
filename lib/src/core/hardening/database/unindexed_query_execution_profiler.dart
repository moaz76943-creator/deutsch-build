/// Task 1026: Query plan analyzer catching slow full-table scans
class QueryExecutionProfiler {
  final List<String> slowQueries = [];
  void logSlowQuery(String sql) => slowQueries.add(sql);
  int get slowQueryCount => slowQueries.length;
}
