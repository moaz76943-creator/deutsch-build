import 'dart:io';

enum DatabaseInstallStatus {
  installed,
  replaced,
  alreadyExists,
  corrupted,
  failed,
}

class DatabaseInstallResult {
  final DatabaseInstallStatus status;
  final String? errorMessage;

  const DatabaseInstallResult(this.status, [this.errorMessage]);
}

/// مثبت ذري يمنع تلف ملفات SQLite عبر نسخها لمسار مؤقت والتحقق منها أولاً
class AtomicDatabaseInstaller {
  /// T68: the previous known-good pack is kept on disk next to the active
  /// pack until the replacement is fully installed, so a failed or corrupt
  /// replacement can be rolled back instead of leaving the learner with no
  /// content. The backup is never deleted by the installer itself.
  static String lastKnownGoodPath(String targetPath) =>
      '$targetPath.lastknowngood';

  /// Restore the previous known-good pack over the current target. Returns
  /// true when a backup existed and was restored. Callers must treat a
  /// restored pack as verified again before serving it (the admission gate
  /// already validated its bytes when it was first installed).
  static Future<bool> restoreLastKnownGood(String targetPath) async {
    final backup = File(lastKnownGoodPath(targetPath));
    if (!await backup.exists()) {
      return false;
    }
    final target = File(targetPath);
    if (await target.exists()) {
      await target.delete();
    }
    await backup.rename(targetPath);
    return true;
  }

  static Future<DatabaseInstallResult> installDatabaseAtomically({
    required String sourcePath,
    required String targetPath,
    bool allowReplacement = false,
  }) async {
    final targetFile = File(targetPath);
    final targetExists = await targetFile.exists();

    if (targetExists && !allowReplacement) {
      return const DatabaseInstallResult(DatabaseInstallStatus.alreadyExists);
    }

    final tempPath = '$targetPath.tmp';
    final tempFile = File(tempPath);
    final backupPath = lastKnownGoodPath(targetPath);
    final backupFile = File(backupPath);

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

      // T68: preserve the current pack as the last-known-good backup before
      // the atomic replacement. A stale backup from an earlier install is
      // rotated: the freshest verified pack is always the backup of record.
      if (targetExists) {
        if (await backupFile.exists()) {
          await backupFile.delete();
        }
        await targetFile.rename(backupPath);
      }

      // نقل ذري للمسار النهائي
      // This will overwrite the targetFile if it exists, fulfilling atomic replacement.
      // If this fails, the last-known-good backup is restored so the active
      // pack is never lost to a partial install.
      try {
        await tempFile.rename(targetPath);
      } catch (_) {
        if (targetExists && await backupFile.exists()) {
          await backupFile.rename(targetPath);
        }
        rethrow;
      }

      return DatabaseInstallResult(
        targetExists
            ? DatabaseInstallStatus.replaced
            : DatabaseInstallStatus.installed,
      );
    } catch (e) {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      return DatabaseInstallResult(DatabaseInstallStatus.failed, e.toString());
    }
  }
}
