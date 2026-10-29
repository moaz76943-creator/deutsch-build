import 'dart:io';

enum DatabaseInstallStatus { installed, alreadyExists, corrupted, failed }

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
  }) async {
    final targetFile = File(targetPath);
    if (await targetFile.exists()) {
      return const DatabaseInstallResult(DatabaseInstallStatus.alreadyExists);
    }

    final tempPath = '$targetPath.tmp';
    final tempFile = File(tempPath);

    try {
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
      await tempFile.rename(targetPath);
      return const DatabaseInstallResult(DatabaseInstallStatus.installed);
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
