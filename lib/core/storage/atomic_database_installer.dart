import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;

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
  /// Orphaned temps older than this are treated as crashed-install debris and
  /// swept before the next install. A younger temp can belong to a live
  /// concurrent install and must never be deleted from under it.
  static const Duration staleTempAge = Duration(minutes: 15);

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

    // T65: the staging name must be unique per install. A fixed
    // '$targetPath.tmp' let two concurrent installs (or a crashed install and
    // a fresh one) clobber or delete each other's partial output.
    final tempFile = File(_uniqueTempPath(targetPath));

    try {
      // Crash-safe cleanup: sweep orphaned temps left by a process death.
      // Best-effort; a sweep failure must not block a valid install.
      await _sweepStaleTemps(targetPath);

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return const DatabaseInstallResult(
          DatabaseInstallStatus.failed,
          'الملف المصدر غير موجود',
        );
      }

      await sourceFile.copy(tempFile.path);

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
      // This is a same-directory rename, so it is atomic on the same
      // filesystem. It will overwrite the targetFile if it exists, fulfilling
      // atomic replacement. If this fails, the original targetFile is untouched.
      await tempFile.rename(targetPath);

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

  /// Unique staging path in the target's own directory, so the final rename is
  /// a same-filesystem atomic move. Timestamp + pid + a secure-random token
  /// make collisions and predictable-path pre-creation infeasible.
  static String _uniqueTempPath(String targetPath) {
    final secure = Random.secure();
    final token = StringBuffer();
    for (var index = 0; index < 8; index++) {
      token.write(secure.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return '$targetPath.tmp.${DateTime.now().microsecondsSinceEpoch}_${pid}_$token';
  }

  /// Remove `$targetPath.tmp.*` temps left behind by a crashed install.
  /// Only regular files older than [staleTempAge] are touched; symlinks,
  /// directories and younger files are left alone, so a live concurrent
  /// install is never deleted from under itself. Best-effort: errors are
  /// swallowed.
  static Future<void> _sweepStaleTemps(String targetPath) async {
    try {
      final dir = Directory(p.dirname(targetPath));
      if (!await dir.exists()) {
        return;
      }
      final prefix = '${p.basename(targetPath)}.tmp.';
      final cutoff = DateTime.now().subtract(staleTempAge);
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is! File) {
          continue; // never touch directories or symlinks
        }
        if (!p.basename(entity.path).startsWith(prefix)) {
          continue;
        }
        try {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoff)) {
            await entity.delete();
          }
        } catch (_) {
          // Ignore individual entries we cannot stat or delete.
        }
      }
    } catch (_) {
      // Best-effort sweep; never block a valid install on cleanup failure.
    }
  }
}
