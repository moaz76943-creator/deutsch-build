import 'package:sqflite/sqflite.dart';

class LanguageMigrationHelper {
  static Future<void> upgradeToMultiLanguage(Database db) async {
    await db.execute('''
      ALTER TABLE spaced_repetition
      ADD COLUMN target_language TEXT DEFAULT 'de';
    ''');

    await db.execute('''
      ALTER TABLE dialogue_scenarios
      ADD COLUMN target_language TEXT DEFAULT 'de';
    ''');

    await db.execute('''
      ALTER TABLE user_vocab_custom
      ADD COLUMN target_language TEXT DEFAULT 'de';
    ''');
  }
}
