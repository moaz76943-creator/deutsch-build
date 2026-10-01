import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'database_migration_helper.dart';

class MilestoneBadge {
  final String id;
  final String title;
  final String description;
  final int requiredStreak;

  const MilestoneBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredStreak,
  });
}

class StreakMilestonesEngine {
  static const String _tableName = 'streak_milestones';
  static const String _columnId = 'id';
  static const String _columnUnlockedAt = 'unlocked_at';

  static final StreakMilestonesEngine instance = StreakMilestonesEngine._init();
  static StreakMilestonesEngine getInstance() => instance;
  static Database? _database;

  static const List<MilestoneBadge> availableBadges = [
    MilestoneBadge(
      id: 'streak_3',
      title: 'بداية موفقة',
      description: 'دراسة لمدة 3 أيام متتالية',
      requiredStreak: 3,
    ),
    MilestoneBadge(
      id: 'streak_7',
      title: 'أسبوع من الالتزام',
      description: 'دراسة لمدة 7 أيام متتالية',
      requiredStreak: 7,
    ),
    MilestoneBadge(
      id: 'streak_30',
      title: 'شهر كامل',
      description: 'دراسة لمدة 30 يوم متتالية',
      requiredStreak: 30,
    ),
    MilestoneBadge(
      id: 'streak_100',
      title: 'مئة يوم من النجاح',
      description: 'دراسة لمدة 100 يوم متتالية',
      requiredStreak: 100,
    ),
    MilestoneBadge(
      id: 'streak_365',
      title: 'سنة من التفوق',
      description: 'دراسة لمدة 365 يوم متتالية',
      requiredStreak: 365,
    ),
  ];

  StreakMilestonesEngine._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('milestones.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await DatabaseMigrationHelper.open(
      path: path,
      version: 1,
      onCreate: _createDB,
      migrationScripts: {},
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $_columnId TEXT PRIMARY KEY,
        $_columnUnlockedAt TEXT NOT NULL
      )
    ''');
  }

  Future<List<String>> checkAndUnlockMilestones(int currentStreak) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();
    List<String> newlyUnlocked = [];

    await DatabaseMigrationHelper.executeAtomic(db, (txn) async {
      for (final badge in availableBadges) {
        if (currentStreak >= badge.requiredStreak) {
          final maps = await txn.query(
            _tableName,
            where: '$_columnId = ?',
            whereArgs: [badge.id],
          );

          if (maps.isEmpty) {
            await txn.insert(_tableName, {
              _columnId: badge.id,
              _columnUnlockedAt: now,
            });
            newlyUnlocked.add(badge.id);
          }
        }
      }
    });

    return newlyUnlocked;
  }

  Future<Set<String>> getUnlockedMilestones() async {
    final db = await instance.database;
    final maps = await db.query(_tableName);

    return maps.map((map) => map[_columnId] as String).toSet();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
