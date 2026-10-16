import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'sqlite_maintenance_service.dart';

class StorageMaintenanceService {
  final SqliteMaintenanceService _sqliteMaintenanceService;

  StorageMaintenanceService({SqliteMaintenanceService? sqliteMaintenanceService})
      : _sqliteMaintenanceService = sqliteMaintenanceService ?? SqliteMaintenanceService();

  Future<void> runMaintenance(Database db) async {
    await _sqliteMaintenanceService.performMaintenance(db);
  }

  Future<void> cleanupTemporaryFiles() async {
    try {
      final dbPath = await getDatabasesPath();
      final directory = Directory(dbPath);
      if (!await directory.exists()) {
        return;
      }

      final files = directory.listSync();
      for (final file in files) {
        if (file is File) {
          final filename = file.uri.pathSegments.last;
          if (filename.endsWith('.tmp') || filename.endsWith('-journal.tmp')) {
             try {
               await file.delete();
             } on FileSystemException {
               // ignore
             }
          }
        }
      }
    } on FileSystemException {
      // ignore directory access errors
    }
  }
}
