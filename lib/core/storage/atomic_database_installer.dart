import 'dart:io';

enum DatabaseInstallStatus { installed, alreadyExists, corrupted, failed, rejected }

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
    Future<bool> Function(File file)? verifier,
    Future<void> Function(File file, String reason)? onQuarantine,
  }) async {
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

      if (verifier != null) {
        final isValid = await verifier(tempFile);
        if (!isValid) {
          if (onQuarantine != null) {
             await onQuarantine(tempFile, 'Validation failed during atomic install');
          } else {
             if (await tempFile.exists()) await tempFile.delete();
          }
          return const DatabaseInstallResult(
            DatabaseInstallStatus.rejected,
            'Verification failed',
          );
        }
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
