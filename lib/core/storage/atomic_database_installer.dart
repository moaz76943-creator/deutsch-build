import 'dart:io';

<<<<<<< HEAD
enum DatabaseInstallStatus {
  installed,
  replaced,
  alreadyExists,
  corrupted,
  failed
}
=======
enum DatabaseInstallStatus { installed, alreadyExists, corrupted, failed }
>>>>>>> origin/staging/v2-full-platform-1792367411258400957

class DatabaseInstallResult {
  final DatabaseInstallStatus status;
  final String? errorMessage;

  const DatabaseInstallResult(this.status, [this.errorMessage]);
}

/// مثبت ذري يمنع تلف ملفات SQLite عبر نسخها لمسار مؤقت والتحقق منها أولاً
class AtomicDatabaseInstaller {
  static Future<DatabaseInstallResult> installDatabaseAtomically({
    required String sourcePath,
    required String targetPath,
<<<<<<< HEAD
    bool allowReplacement = false,
  }) async {
    final targetFile = File(targetPath);
    final targetExists = await targetFile.exists();

    if (targetExists && !allowReplacement) {
=======
  }) async {
    final targetFile = File(targetPath);
    if (await targetFile.exists()) {
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
      return const DatabaseInstallResult(DatabaseInstallStatus.alreadyExists);
    }

    final tempPath = '$targetPath.tmp';
    final tempFile = File(tempPath);

    try {
      // Clean up orphaned .tmp files before copying
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return const DatabaseInstallResult(
          DatabaseInstallStatus.failed,
          'الملف المصدر غير موجود',
        );
      }

      await sourceFile.copy(tempPath);

      // التحقق الذري من حجم الملف
      final length = await tempFile.length();
      if (length <= 0) {
        if (await tempFile.exists()) await tempFile.delete();
        return const DatabaseInstallResult(
          DatabaseInstallStatus.corrupted,
          'حجم الملف المنسوخ فارغ',
        );
      }

      // نقل ذري للمسار النهائي
      // This will overwrite the targetFile if it exists, fulfilling atomic replacement.
      // If this fails, the original targetFile is untouched.
      await tempFile.rename(targetPath);

      return DatabaseInstallResult(targetExists
          ? DatabaseInstallStatus.replaced
          : DatabaseInstallStatus.installed);
    } catch (e) {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      return DatabaseInstallResult(
        DatabaseInstallStatus.failed,
        e.toString(),
      );
    }
  }
}
