import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class ProgressDatabaseService {
  static Database? _progressDb;

  /// تهيئة قاعدة بيانات تقدم المستخدم المستقلة مع تفعيل WAL Mode
  static Future<Database> getDatabase() async {
    if (_progressDb != null) return _progressDb!;

    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = join(docsDir.path, 'user_progress.sqlite');

    _progressDb = await openDatabase(
      dbPath,
      version: 1,
      onConfigure: (db) async {
        // تفعيل وضع الكتابة المسبقة لتسريع التزامن ومنع الإقفال
        await db.rawQuery('PRAGMA journal_mode = WAL;');
        await db.execute('PRAGMA busy_timeout = 5000;');
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS user_progress (
            concept_id TEXT PRIMARY KEY,
            box_level INTEGER DEFAULT 0,
            ease_factor REAL DEFAULT 2.5,
            interval_days INTEGER DEFAULT 0,
            repetitions INTEGER DEFAULT 0,
            last_reviewed_at INTEGER,
            next_review_at INTEGER
          );
        ''');
      },
    );

    return _progressDb!;
  }

  /// تسجيل نتيجة المراجعة وفق خوارزمية SM-2
  static Future<void> recordProgress({
    required String conceptId,
    required bool isCorrect,
  }) async {
    final db = await getDatabase();
    final now = DateTime.now().millisecondsSinceEpoch;

    final records = await db.query(
      'user_progress',
      where: 'concept_id = ?',
      whereArgs: [conceptId],
    );

    int repetitions = 0;
    int boxLevel = 0;
    double easeFactor = 2.5;
    int intervalDays = 1;

    if (records.isNotEmpty) {
      final row = records.first;
      repetitions = (row['repetitions'] as int? ?? 0);
      boxLevel = (row['box_level'] as int? ?? 0);
      easeFactor = (row['ease_factor'] as num? ?? 2.5).toDouble();
      intervalDays = (row['interval_days'] as int? ?? 1);
    }

    if (isCorrect) {
      repetitions += 1;
      boxLevel += 1;
      intervalDays = (repetitions == 1) ? 1 : ((repetitions == 2) ? 6 : (intervalDays * easeFactor).round());
      easeFactor = (easeFactor + 0.1).clamp(1.3, 3.0);
    } else {
      repetitions = 0;
      boxLevel = 0;
      intervalDays = 1;
      easeFactor = (easeFactor - 0.2).clamp(1.3, 3.0);
    }

    final nextReview = now + (intervalDays * 24 * 60 * 60 * 1000);

    await db.transaction((txn) async {
      await txn.insert(
        'user_progress',
        {
          'concept_id': conceptId,
          'box_level': boxLevel,
          'ease_factor': easeFactor,
          'interval_days': intervalDays,
          'repetitions': repetitions,
          'last_reviewed_at': now,
          'next_review_at': nextReview,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  /// جلب مستويات الحفظ لجميع المفاهيم
  static Future<Map<String, int>> getAllBoxLevels() async {
    final db = await getDatabase();
    final rows = await db.query('user_progress', columns: ['concept_id', 'box_level']);
    return {for (var r in rows) r['concept_id'] as String: r['box_level'] as int? ?? 0};
  }
}
