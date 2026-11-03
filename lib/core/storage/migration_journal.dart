class MigrationRecord {
  final String migrationId;
  final int timestampEpoch;
  const MigrationRecord(this.migrationId, this.timestampEpoch);
}

class MigrationJournal {
  final List<MigrationRecord> _records = [];

  void recordMigration(String id) {
    if (!hasMigrated(id)) {
      _records.add(MigrationRecord(
          id,
          DateTime.now().millisecondsSinceEpoch));
    }
  }

  bool hasMigrated(String id) => _records.any((r) => r.migrationId == id);
  List<MigrationRecord> get history => List.unmodifiable(_records);
}
