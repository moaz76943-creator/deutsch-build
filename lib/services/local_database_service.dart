import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._init();

  LocalDatabaseService._init();

  // Compatibility alias for existing screens that load the German default.
  Future<Database> get database => DatabaseService.instance.contentDb;

  // Delegate language-specific content and progress to the canonical service.
  Future<Database> get contentDb => DatabaseService.instance.contentDb;

  Future<Database> getContentDb([String? languageCode]) =>
      DatabaseService.instance.getContentDb(languageCode);

  Future<Database> get progressDb => DatabaseService.instance.progressDb;
}
