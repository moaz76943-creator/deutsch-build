class MigrationRecord {
  final String migrationId;
  final int timestampEpoch;
  const MigrationRecord(this.migrationId, this.timestampEpoch);
}

class MigrationJournal {
  final List<MigrationRecord> _records = [];

  void recordMigration(String id) {
    if (!hasMigrated(id)) {
<<<<<<< HEAD
      _records.add(MigrationRecord(
          DateTime.now().millisecondsSinceEpoch.toString(),
          DateTime.now().millisecondsSinceEpoch));
=======
      _records.add(MigrationRecord(DateTime.now().millisecondsSinceEpoch.toString(), DateTime.now().millisecondsSinceEpoch));
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    }
  }

  bool hasMigrated(String id) => _records.any((r) => r.migrationId == id);
  List<MigrationRecord> get history => List.unmodifiable(_records);
}
