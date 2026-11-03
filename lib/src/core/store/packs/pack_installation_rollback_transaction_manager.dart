class PackInstallationRollbackTransactionManager {
  bool isCommitted = false;
  void begin() => isCommitted = false;
  void commit() => isCommitted = true;
  void rollback() => isCommitted = false;
}
