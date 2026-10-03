import 'package:sqflite_common/sqlite_api.dart';

import '../../../../services/sqlite_policy.dart';

import '../models/milestone_badge.dart';

class StreakMilestonesEngine {
  static const String _milestonesTable = 'streak_milestones';
  static const String _columnId = 'id';
  static const String _columnTitle = 'title';
  static const String _columnDescription = 'description';
  static const String _columnRequiredDays = 'required_days';
  static const String _columnUnlockedAt = 'unlocked_at';

  static const String _studyDaysTable = 'study_days';
  static const String _columnDate = 'date';

  static final StreakMilestonesEngine instance = StreakMilestonesEngine._init();
  static Database? _database;
  static const AppSqlitePolicy _sqlitePolicy = AppSqlitePolicy();

  StreakMilestonesEngine._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('streak_tracking.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final path = await _sqlitePolicy.resolvePath(fileName: filePath);
    return _sqlitePolicy.openWritable(
      path: path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_milestonesTable (
        $_columnId TEXT PRIMARY KEY,
        $_columnTitle TEXT NOT NULL,
        $_columnDescription TEXT NOT NULL,
        $_columnRequiredDays INTEGER NOT NULL,
        $_columnUnlockedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_studyDaysTable (
        $_columnDate TEXT PRIMARY KEY
      )
    ''');
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> logStudyDay(DateTime date) async {
    final db = await database;
    final dateString = _formatDate(date);

    await db.insert(
        _studyDaysTable,
        {
          _columnDate: dateString,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);

    final streak = await calculateCurrentStreak();
    await checkAndUnlockMilestones(streak);
  }

  Future<int> calculateCurrentStreak() async {
    final db = await database;
    final maps = await db.query(_studyDaysTable, orderBy: '$_columnDate DESC');

    if (maps.isEmpty) return 0;

    int streak = 0;
    DateTime? expectedDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    for (final map in maps) {
      final loggedDateStr = map[_columnDate] as String;

      if (streak == 0 && loggedDateStr == _formatDate(today)) {
        streak++;
        expectedDate = yesterday;
      } else if (streak == 0 && loggedDateStr == _formatDate(yesterday)) {
        streak++;
        expectedDate = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day - 1,
        );
      } else if (expectedDate != null &&
          loggedDateStr == _formatDate(expectedDate)) {
        streak++;
        expectedDate = DateTime(
          expectedDate.year,
          expectedDate.month,
          expectedDate.day - 1,
        );
      } else {
        break;
      }
    }

    return streak;
  }

  Future<List<MilestoneBadge>> getUnlockedBadges() async {
    final db = await database;
    final maps = await db.query(
      _milestonesTable,
      orderBy: '$_columnRequiredDays ASC',
    );

    return maps
        .map(
          (map) => MilestoneBadge(
            id: map[_columnId] as String,
            title: map[_columnTitle] as String,
            description: map[_columnDescription] as String,
            requiredStreakDays: map[_columnRequiredDays] as int,
            unlockedAt: DateTime.parse(map[_columnUnlockedAt] as String),
          ),
        )
        .toList();
  }

  Future<void> checkAndUnlockMilestones(int currentStreakDays) async {
    final db = await database;

    final milestonesToUnlock = _getAvailableMilestones()
        .where((m) => m.requiredStreakDays <= currentStreakDays)
        .toList();

    await db.transaction((txn) async {
      for (final milestone in milestonesToUnlock) {
        final existing = await txn.query(
          _milestonesTable,
          where: '$_columnId = ?',
          whereArgs: [milestone.id],
        );

        if (existing.isEmpty) {
          await txn.insert(_milestonesTable, {
            _columnId: milestone.id,
            _columnTitle: milestone.title,
            _columnDescription: milestone.description,
            _columnRequiredDays: milestone.requiredStreakDays,
            _columnUnlockedAt: DateTime.now().toIso8601String(),
          });
        }
      }
    });
  }

  List<MilestoneBadge> _getAvailableMilestones() {
    final now = DateTime.now();
    return [
      MilestoneBadge(
        id: 'streak_3',
        title: 'البداية الجيدة',
        description: 'دراسة لمدة 3 أيام متتالية',
        requiredStreakDays: 3,
        unlockedAt: now,
      ),
      MilestoneBadge(
        id: 'streak_7',
        title: 'مواظب أسبوعي',
        description: 'دراسة لمدة 7 أيام متتالية',
        requiredStreakDays: 7,
        unlockedAt: now,
      ),
      MilestoneBadge(
        id: 'streak_14',
        title: 'عزيمة حديدية',
        description: 'دراسة لمدة 14 يوم متتالية',
        requiredStreakDays: 14,
        unlockedAt: now,
      ),
      MilestoneBadge(
        id: 'streak_30',
        title: 'بطل الشهر',
        description: 'دراسة لمدة 30 يوم متتالية',
        requiredStreakDays: 30,
        unlockedAt: now,
      ),
    ];
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
