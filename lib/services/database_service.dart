import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _contentDb;
  static Database? _progressDb;

  DatabaseService._init();

  // 1. قاعدة المحتوى (اللغات، الكلمات، الأمثلة)
  Future<Database> get contentDb async {
    if (_contentDb != null) return _contentDb!;
    _contentDb = await _initContentDb('polyglot_content_v2.db');
    return _contentDb!;
  }

  // 2. قاعدة تقدم المستخدم (SRS Progress) - مفصولة لحماية البيانات
  Future<Database> get progressDb async {
    if (_progressDb != null) return _progressDb!;
    _progressDb = await _initProgressDb('user_progress_v2.db');
    return _progressDb!;
  }

  Future<Database> _initContentDb(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createContentDbSchema(db);
        // زرع بيانات مبدئية لكي يعمل المعجم فوراً
        await _seedInitialData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Create missing tables if they don't exist (e.g., if legacy LocalDatabaseService created db)
          await _createContentDbSchema(db);

          // Add missing columns to lexemes and examples if they were created by LocalDatabaseService
          try {
            await db.execute("ALTER TABLE lexemes ADD COLUMN display_text TEXT NOT NULL DEFAULT ''");
          } catch (_) {}

          try {
            await db.execute("ALTER TABLE lexemes ADD COLUMN gender TEXT");
          } catch (_) {}

          try {
            await db.execute("ALTER TABLE lexemes ADD COLUMN grammar_json TEXT DEFAULT '{}'");
          } catch (_) {}

          // Migrate examples table safely
          try {
            await db.execute('''
              CREATE TABLE examples_new (
               example_id TEXT PRIMARY KEY,
               concept_id TEXT NOT NULL,
               language_code TEXT NOT NULL,
               sentence TEXT NOT NULL,
               translation_ar TEXT
              )
            ''');

            await db.execute('''
              INSERT INTO examples_new (example_id, concept_id, language_code, sentence, translation_ar)
              SELECT lower(hex(randomblob(16))), concept_id, language_code, sentence, translation_ar
              FROM examples
            ''');

            await db.execute('DROP TABLE examples');
            await db.execute('ALTER TABLE examples_new RENAME TO examples');
          } catch (_) {
             // Migration might have already occurred or table was already in correct format
          }
        }
      },
    );
  }

  Future<void> _createContentDbSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS language_profiles (
       language_code TEXT PRIMARY KEY,
       name_native TEXT NOT NULL,
       name_ar TEXT NOT NULL,
       direction TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS concepts (
       concept_id TEXT PRIMARY KEY,
       category TEXT NOT NULL,
       cefr_level TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS lexemes (
       lexeme_id TEXT PRIMARY KEY,
       concept_id TEXT NOT NULL,
       language_code TEXT NOT NULL,
       lemma TEXT NOT NULL,
       display_text TEXT NOT NULL,
       article TEXT,
       plural TEXT,
       gender TEXT,
       grammar_json TEXT DEFAULT '{}'
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS examples (
       example_id TEXT PRIMARY KEY,
       concept_id TEXT NOT NULL,
       language_code TEXT NOT NULL,
       sentence TEXT NOT NULL,
       translation_ar TEXT
      )
    ''');
  }

  Future<Database> _initProgressDb(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createProgressDbSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createProgressDbSchema(db);
        }
      },
    );
  }

  Future<void> _createProgressDbSchema(Database db) async {
    // جدول التكرار المتباعد (SuperMemo-2)
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

    // Create vocabulary_items table here instead of in VocabularyRepository
    await db.execute('''
      CREATE TABLE IF NOT EXISTS vocabulary_items (
        word TEXT PRIMARY KEY,
        language_code TEXT NOT NULL DEFAULT 'de',
        article TEXT,
        meaning TEXT,
        interval INTEGER NOT NULL DEFAULT 0,
        repetitions INTEGER NOT NULL DEFAULT 0,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        json_data TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_vocab_lang ON vocabulary_items(language_code)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_vocab_interval ON vocabulary_items(interval)');
  }

  // دالة البحث في المعجم الفوري
  Future<List<Map<String, dynamic>>> searchDictionary(String query, String langCode) async {
    final db = await contentDb;
    if (query.isEmpty) {
      return await db.rawQuery('''
        SELECT l.*, e.sentence, e.translation_ar 
        FROM lexemes l
        LEFT JOIN examples e ON e.concept_id = l.concept_id AND e.language_code = l.language_code
        WHERE l.language_code = ?
        LIMIT 20
      ''', [langCode]);
    }

    return await db.rawQuery('''
      SELECT l.*, e.sentence, e.translation_ar 
      FROM lexemes l
      LEFT JOIN examples e ON e.concept_id = l.concept_id AND e.language_code = l.language_code
      WHERE l.language_code = ? AND (l.lemma LIKE ? OR l.display_text LIKE ? OR e.translation_ar LIKE ?)
      LIMIT 20
    ''', [langCode, '%$query%', '%$query%', '%$query%']);
  }

  // إدخال بيانات تجريبية (مفاهيم الحياة اليومية)
  Future<void> _seedInitialData(Database db) async {
    final batch = db.batch();
    
    // إدخال اللغات
    batch.insert('language_profiles', {'language_code': 'de', 'name_native': 'Deutsch', 'name_ar': 'الألمانية', 'direction': 'ltr'});
    batch.insert('language_profiles', {'language_code': 'ar', 'name_native': 'العربية', 'name_ar': 'العربية', 'direction': 'rtl'});

    // إدخال المفاهيم
    batch.insert('concepts', {'concept_id': 'daily.water', 'category': 'daily', 'cefr_level': 'A1'});
    batch.insert('concepts', {'concept_id': 'daily.book', 'category': 'daily', 'cefr_level': 'A1'});
    batch.insert('concepts', {'concept_id': 'daily.car', 'category': 'daily', 'cefr_level': 'A1'});

    // إدخال الكلمات (ألماني)
    batch.insert('lexemes', {'lexeme_id': 'lex.de.water', 'concept_id': 'daily.water', 'language_code': 'de', 'lemma': 'Wasser', 'display_text': 'das Wasser', 'article': 'das', 'gender': 'n'});
    batch.insert('lexemes', {'lexeme_id': 'lex.de.book', 'concept_id': 'daily.book', 'language_code': 'de', 'lemma': 'Buch', 'display_text': 'das Buch', 'article': 'das', 'plural': 'Bücher', 'gender': 'n'});
    batch.insert('lexemes', {'lexeme_id': 'lex.de.car', 'concept_id': 'daily.car', 'language_code': 'de', 'lemma': 'Auto', 'display_text': 'das Auto', 'article': 'das', 'plural': 'Autos', 'gender': 'n'});

    // إدخال الأمثلة
    batch.insert('examples', {'example_id': 'ex.de.water', 'concept_id': 'daily.water', 'language_code': 'de', 'sentence': 'Ich trinke Wasser.', 'translation_ar': 'أشرب الماء.'});
    batch.insert('examples', {'example_id': 'ex.de.book', 'concept_id': 'daily.book', 'language_code': 'de', 'sentence': 'Ich lese ein Buch.', 'translation_ar': 'أقرأ كتاباً.'});
    batch.insert('examples', {'example_id': 'ex.de.car', 'concept_id': 'daily.car', 'language_code': 'de', 'sentence': 'Das Auto ist schnell.', 'translation_ar': 'السيارة سريعة.'});

    await batch.commit(noResult: true);
  }

  Future<void> updateSrsProgressAtomic({
    required String lexemeId,
    required String status,
    String languageCode = 'de',
  }) async {
    final db = await progressDb;
    await db.transaction((txn) async {
      await txn.rawInsert('''
        INSERT OR REPLACE INTO srs_progress (lexeme_id, target_language_code, repetition_count, status)
        VALUES (?, ?,
          COALESCE((SELECT repetition_count + 1 FROM srs_progress WHERE lexeme_id = ?), 1),
          ?
        )
      ''', [lexemeId, languageCode, lexemeId, status]);
    });
  }
}
