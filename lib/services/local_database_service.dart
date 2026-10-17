import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._init();
<<<<<<< HEAD
  static Database? _database;
=======
>>>>>>> pr-179

  LocalDatabaseService._init();

  // Compatibility alias for existing screens that load the German default.
  Future<Database> get database => DatabaseService.instance.contentDb;

<<<<<<< HEAD
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }
=======
  // Delegate language-specific content and progress to the canonical service.
  Future<Database> get contentDb => DatabaseService.instance.contentDb;
>>>>>>> pr-179

  Future<Database> getContentDb([String? languageCode]) =>
      DatabaseService.instance.getContentDb(languageCode);

  Future<Database> get progressDb => DatabaseService.instance.progressDb;
}
