import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class SnapshotResult {
  final bool isSuccess;
  final String? snapshotPath;
  final String? error;

  const SnapshotResult({
    required this.isSuccess,
    this.snapshotPath,
    this.error,
  });
}

/// إدارة النسخ الاحتياطية المتسقة والحماية من انهيار قواعد البيانات - Study 36
/// يضمن مزامنة WAL Checkpoint، وتكوين لقطات ذرية (Atomic Snapshots)، وحفظ Last-Known-Good
class CrashSafeSnapshotManager {
  static const List<int> sqliteHeaderBytes = [
    0x53, 0x51, 0x4C, 0x69, 0x74, 0x65, 0x20, 0x66,
    0x6F, 0x72, 0x6D, 0x61, 0x74, 0x20, 0x33, 0x00,
  ]; // "SQLite format 3\0"

  /// إنشاء لقطة متسقة وآمنة من قاعدة البيانات
  static Future<SnapshotResult> createConsistentSnapshot({
    required String databasePath,
    required String targetSnapshotPath,
    Database? activeDatabase,
  }) async {
    final dbFile = File(databasePath);
    if (!await dbFile.exists()) {
      return const SnapshotResult(
        isSuccess: false,
        error: 'Database source file does not exist',
      );
    }

    try {
      // 1. مزامنة وتفريغ إطارات WAL إلى ملف القاعدة الرئيسي إن كانت القاعدة مفتوحة
      if (activeDatabase != null && activeDatabase.isOpen) {
        try {
          await activeDatabase.rawQuery('PRAGMA wal_checkpoint(TRUNCATE);');
        } catch (_) {
          // محاولة ثانية بـ PASSIVE إن كان TRUNCATE محظوراً
          await activeDatabase.rawQuery('PRAGMA wal_checkpoint(PASSIVE);');
        }
      }

      // 2. نسخ ذري عبر ملف مؤقت (.tmp)
      final tmpPath = '$targetSnapshotPath.tmp_${DateTime.now().millisecondsSinceEpoch}';
      final tmpFile = await dbFile.copy(tmpPath);

      // 3. التحقق من صحة ترويسة SQLite للملف المنسوخ
      final isValidHeader = await verifySqliteHeader(tmpFile);
      if (!isValidHeader) {
        if (await tmpFile.exists()) await tmpFile.delete();
        return const SnapshotResult(
          isSuccess: false,
          error: 'Snapshot failed: invalid SQLite header signature',
        );
      }

      // 4. استبدال ذري بالملف النهائي
      final targetFile = File(targetSnapshotPath);
      final targetDir = Directory(p.dirname(targetSnapshotPath));
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      await tmpFile.rename(targetFile.path);

      return SnapshotResult(
        isSuccess: true,
        snapshotPath: targetFile.path,
      );
    } catch (e) {
      return SnapshotResult(
        isSuccess: false,
        error: 'Snapshot error: $e',
      );
    }
  }

  /// التحقق من ترويسة ملف SQLite (16 بايت الأولى)
  static Future<bool> verifySqliteHeader(File file) async {
    if (!await file.exists()) return false;
    final length = await file.length();
    if (length < 16) return false;

    final raf = await file.open(mode: FileMode.read);
    try {
      final header = await raf.read(16);
      if (header.length < 16) return false;
      for (var i = 0; i < 16; i++) {
        if (header[i] != sqliteHeaderBytes[i]) return false;
      }
      return true;
    } finally {
      await raf.close();
    }
  }

  /// إنشاء نقطة استعادة (Last-Known-Good) قبل تطبيق أي هجرة بيانات خطرة
  static Future<File?> preserveLastKnownGood(String databasePath) async {
    final dbFile = File(databasePath);
    if (!await dbFile.exists()) return null;

    final lkgPath = '$databasePath.lkg';
    return await dbFile.copy(lkgPath);
  }

  /// استعادة فورية لنسخة Last-Known-Good عند فشل عملية أو هجرة
  static Future<bool> restoreLastKnownGood(String databasePath) async {
    final lkgFile = File('$databasePath.lkg');
    if (!await lkgFile.exists()) return false;

    final dbFile = File(databasePath);
    await lkgFile.copy(dbFile.path);
    return true;
  }
}
