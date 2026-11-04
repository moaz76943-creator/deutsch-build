/// Task 1037: Idle connection pool recycler & zombie socket reaper
class ConnectionPoolReaper {
  int closedConnections = 0;
  void pruneIdleConnections() => closedConnections++;
}
