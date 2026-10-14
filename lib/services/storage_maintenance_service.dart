import 'sqlite_maintenance_service.dart';

class StorageMaintenanceService {
  final SqliteMaintenanceService _sqliteMaintenanceService;

  StorageMaintenanceService({SqliteMaintenanceService? sqliteMaintenanceService})
      : _sqliteMaintenanceService = sqliteMaintenanceService ?? SqliteMaintenanceService();

  Future<void> performStorageMaintenance() async {
    // Coordinate database maintenance. We deliberately avoid dropping
    // user_progress_v2.db or polyglot_content_v2.db to reclaim storage.
    // Instead we only compact the WAL and rebuild indices for the writable DB.
    await _sqliteMaintenanceService.performMaintenance();
  }
}
