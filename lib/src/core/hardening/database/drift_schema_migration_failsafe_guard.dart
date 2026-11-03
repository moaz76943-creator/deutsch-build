/// Task 1022: Safe schema migration fallback & rollback guard
class DriftMigrationFailsafe {
  int currentVersion = 1;
  bool verifyMigration(int target) => target >= currentVersion;
  void recordSuccess(int version) => currentVersion = version;
}
