import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._init();

  LocalDatabaseService._init();

  Future<Database> get database => DatabaseService.instance.contentDb;
}
