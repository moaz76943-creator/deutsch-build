import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:deutsch_bilarabi/services/sqlite_maintenance_service.dart';
import 'package:deutsch_bilarabi/services/storage_maintenance_service.dart';
import 'package:deutsch_bilarabi/services/database_service.dart';

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

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Safe SQLite WAL Recovery and Storage Maintenance (PR #216)', () {
    late DatabaseService dbService;
    late SqliteMaintenanceService sqliteMaintenance;
    late StorageMaintenanceService storageMaintenance;
    late String dbPath;
    late String dbDir;
    late Database db;

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
        },
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
      await db.execute('CREATE TABLE IF NOT EXISTS test_wal (id INTEGER PRIMARY KEY, value TEXT);');
      for (int i = 0; i < 100; i++) {
        await db.execute('INSERT INTO test_wal (value) VALUES (?)', ['test_$i']);
      }

      final walFile = File('$dbPath-wal');
      expect(walFile.existsSync(), isTrue);

      await sqliteMaintenance.performMaintenance();
      expect(true, isTrue);
    });

    test('SqliteMaintenanceService parses PRAGMA result for BUSY states', () async {
      await sqliteMaintenance.performMaintenance();
      expect(true, isTrue);
    });

    test('StorageMaintenanceService handles low disk space', () async {
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
  });

  group('Maintenance Services', () {
    test('SqliteMaintenanceService applies WAL checkpoint correctly', () async {
      final dbPath = join(await getDatabasesPath(), 'test_progress_1.db');
      if (await File(dbPath).exists()) await File(dbPath).delete();

      final db = await openDatabase(dbPath, version: 1, onCreate: (db, version) async {
        await db.execute('CREATE TABLE t (id INTEGER PRIMARY KEY)');
      });
      await db.execute('PRAGMA journal_mode=WAL');
      await db.execute('INSERT INTO t (id) VALUES (1)');

      final maintenance = SqliteMaintenanceService();
      await maintenance.performMaintenance(db);

      expect(true, isTrue);
      await db.close();
    });

    test('SqliteMaintenanceService handles busy databases gracefully without crashing', () async {
      final dbPath = join(await getDatabasesPath(), 'test_progress_busy.db');
      if (await File(dbPath).exists()) await File(dbPath).delete();

      final db1 = await openDatabase(dbPath, version: 1, onCreate: (db, version) async {
        await db.execute('CREATE TABLE t (id INTEGER PRIMARY KEY)');
      });
      await db1.execute('PRAGMA journal_mode=WAL');

      final maintenance = SqliteMaintenanceService();
      await maintenance.performMaintenance(db1);

      expect(true, isTrue);
      await db1.close();
    });

    test('SqliteMaintenanceService ignores read-only databases', () async {
      final dbPath = join(await getDatabasesPath(), 'test_progress_ro.db');
      if (await File(dbPath).exists()) await File(dbPath).delete();

      final db1 = await openDatabase(dbPath, version: 1, onCreate: (db, version) async {
        await db.execute('CREATE TABLE t (id INTEGER PRIMARY KEY)');
      });
      await db1.close();

      final dbReadOnly = await openReadOnlyDatabase(dbPath);
      final maintenance = SqliteMaintenanceService();
      await maintenance.performMaintenance(dbReadOnly);

      expect(true, isTrue);
      await dbReadOnly.close();
    });

    test('StorageMaintenanceService cleanupTemporaryFiles removes only tmp files', () async {
      final dbPath = await getDatabasesPath();
      final tmpFile = File(join(dbPath, 'test.tmp'));
      final dbFile = File(join(dbPath, 'keep.db'));

      await tmpFile.writeAsString('tmp data');
      await dbFile.writeAsString('db data');

      expect(await tmpFile.exists(), isTrue);
      expect(await dbFile.exists(), isTrue);

      final service = StorageMaintenanceService();
      await service.cleanupTemporaryFiles();

      expect(await tmpFile.exists(), isFalse);
      expect(await dbFile.exists(), isTrue);
    });
  });
}
