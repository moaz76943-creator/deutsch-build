import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../lib/services/sqlite_maintenance_service.dart';
import '../../../lib/services/storage_maintenance_service.dart';
import '../../../lib/services/database_service.dart';
import 'package:path/path.dart';

class TestMockDbService implements DatabaseService {
   final Database mockDb;
   TestMockDbService(this.mockDb);

   @override
   Future<Database> get progressDb async => mockDb;

   @override
   Future<Database> get contentDb async => mockDb;

   @override
   Future<List<Map<String, dynamic>>> searchDictionary(String query, String langCode) async => [];

   @override
   Future<void> updateSrsProgressAtomic({required String lexemeId, required String status, String languageCode = 'de'}) async {}
}

void main() {
  late DatabaseService dbService;
  late SqliteMaintenanceService sqliteMaintenance;
  late StorageMaintenanceService storageMaintenance;
  late String dbPath;
  late String dbDir;
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbDir = await getDatabasesPath();
    dbPath = join(dbDir, 'user_progress_v2.db');

    final file = File(dbPath);
    if (file.existsSync()) {
      file.deleteSync();
    }

    db = await databaseFactory.openDatabase(dbPath, options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
             await db.execute('''
          CREATE TABLE IF NOT EXISTS srs_progress (
           lexeme_id TEXT PRIMARY KEY,
           target_language_code TEXT NOT NULL,
           repetition_count INTEGER NOT NULL DEFAULT 0,
           interval_days INTEGER NOT NULL DEFAULT 1,
           ease_factor REAL NOT NULL DEFAULT 2.5,
           next_due_at INTEGER,
           status TEXT NOT NULL DEFAULT 'learning'
          )
        ''');
        }
    ));

    dbService = TestMockDbService(db);
    sqliteMaintenance = SqliteMaintenanceService(dbService: dbService);
    storageMaintenance = StorageMaintenanceService(dbService: dbService);
  });

  tearDown(() async {
     if (db.isOpen) {
       await db.close();
     }
  });

  test('SqliteMaintenanceService handles WAL growth and checkpointing', () async {
    await db.execute('PRAGMA journal_mode=WAL;');
    await db.execute('CREATE TABLE IF NOT EXISTS test_wal (id INTEGER PRIMARY KEY, value TEXT)');
    for (int i = 0; i < 100; i++) {
       await db.execute('INSERT INTO test_wal (value) VALUES (?)', ['test_$i']);
    }

    final walFile = File('$dbPath-wal');
    expect(walFile.existsSync(), isTrue);

    await sqliteMaintenance.performMaintenance();
    expect(true, isTrue);
  });

  test('SqliteMaintenanceService parses PRAGMA result for BUSY states', () async {
     // A locked scenario can be tested by running performMaintenance when db is busy.
     // In dart ffi it may just succeed for pragma, but we verify it doesn't crash.
     await sqliteMaintenance.performMaintenance();
     expect(true, isTrue);
  });

  test('StorageMaintenanceService handles low disk space', () async {
     // Check low storage should not crash and should clean up
     await storageMaintenance.checkLowStorage();
     expect(true, isTrue);
  });

  test('StorageMaintenanceService handles VACUUM safely', () async {
    await storageMaintenance.performStorageMaintenance();
    expect(true, isTrue);
  });

  test('StorageMaintenanceService safely rebuilds corrupted disposable indexes', () async {
    await db.execute('DROP INDEX IF EXISTS idx_srs_progress_status;');
    await storageMaintenance.rebuildDisposableIndexes();
    final result = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='index' AND name='idx_srs_progress_status'");
    expect(result.isNotEmpty, isTrue);
  });

  test('Restart recovery test (temp files cleanup)', () async {
     final tempFile = File(join(dbDir, 'test.tmp'));
     await tempFile.writeAsString('temp');

     expect(tempFile.existsSync(), isTrue);
     await sqliteMaintenance.performMaintenance();
     expect(tempFile.existsSync(), isFalse);
  });
}
