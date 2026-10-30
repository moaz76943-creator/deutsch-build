import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._init();
  static Database? _database;

  LocalDatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('polyglot_content_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lexemes (
        lexeme_id TEXT PRIMARY KEY, language_code TEXT, article TEXT, lemma TEXT, plural TEXT, concept_id TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE examples (
        concept_id TEXT, language_code TEXT, translation_ar TEXT, sentence TEXT
      )
    ''');
  }
}
