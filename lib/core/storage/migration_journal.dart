class MigrationRecord {
  final String migrationId;
  final int timestampEpoch;
  const MigrationRecord(this.migrationId, this.timestampEpoch);
}

class MigrationJournal {
  final List<MigrationRecord> _records = [];

  /// Records a migration by its stable id. Recording the same id twice is a
  /// no-op: the journal must stay idempotent so a replayed migration (e.g.
  /// after a process death mid-upgrade) never double-applies.
  void recordMigration(String id) {
    if (hasMigrated(id)) {
      return;
    }
    final epoch = DateTime.now().millisecondsSinceEpoch;
    _records.add(MigrationRecord(id, epoch));
  }

  bool hasMigrated(String id) => _records.any((r) => r.migrationId == id);
  List<MigrationRecord> get history => List.unmodifiable(_records);
}
