import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'atomic_database_installer.dart';
import 'storage_quarantine.dart';


/// بوابة الفحص الأمني للحزم لمنع دخول ملفات تالفة أو خبيثة
class PackAdmissionService {
  final StorageQuarantine quarantine;
  
  PackAdmissionService({required this.quarantine});

  /// التحقق من سلامة الحزمة قبل اعتمادها (SHA-256)
  static Future<bool> verifyAndAdmitPack(File stagedFile, String expectedHash) async {
    try {
      final bytes = await stagedFile.readAsBytes();
      final digest = sha256.convert(bytes);
      
      if (digest.toString() == expectedHash) {
        debugPrint("تم التحقق من الحزمة بنجاح. جاري النقل الذري...");
        // النقل الذري (Atomic Rename) يتم هنا في التنفيذ الفعلي
        return true;
      }
      debugPrint("فشل التحقق: الحزمة تالفة أو غير موثوقة.");
      return false;
    } catch (e) {
      debugPrint("خطأ أثناء فحص الحزمة: ${e}");
      return false;
    }
  }

  Future<bool> verifyPackIntegrity(File file, String expectedHash) async {
    try {
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);

      if (digest.toString() != expectedHash) {
        debugPrint("Pack validation failed: hash mismatch.");
        return false;
      }

      // SQLite Integrity Checks
      Database? db;
      try {
        db = await openDatabase(file.path, readOnly: true);

        // 1. PRAGMA integrity_check
        final integrityCheck = await db.rawQuery('PRAGMA integrity_check;');
        if (integrityCheck.isEmpty || integrityCheck.first.values.first.toString().toLowerCase() != 'ok') {
          debugPrint("Pack validation failed: PRAGMA integrity_check failed.");
          return false;
        }

        // 2. Schema version
        final userVersion = await db.rawQuery('PRAGMA user_version;');
        final version = Sqflite.firstIntValue(userVersion);
        if (version == null || version <= 0) {
          debugPrint("Pack validation failed: Invalid schema version.");
          return false;
        }

        // 3. Language identity check (needs to have at least one profile)
        final profilesResult = await db.query('language_profiles', limit: 1);
        if (profilesResult.isEmpty) {
           debugPrint("Pack validation failed: Missing language identity.");
           return false;
        }

        // 4. Row counts check (lexemes)
        final lexemesCountResult = await db.rawQuery('SELECT COUNT(*) FROM lexemes;');
        final count = Sqflite.firstIntValue(lexemesCountResult);
        if (count == null || count <= 0) {
           debugPrint("Pack validation failed: No lexemes found.");
           return false;
        }

        return true;
      } catch (e) {
         debugPrint("Pack validation failed: SQLite error - ${e}");
         return false;
      } finally {
        if (db != null) {
          await db.close();
        }
      }

    } catch (e) {
      debugPrint("Pack validation failed with exception: ${e}");
      return false;
    }
  }

  Future<DatabaseInstallResult> installPack({
    required String sourcePath,
    required String targetPath,
    required String expectedHash,
    required String quarantineDir,
  }) async {
    return await AtomicDatabaseInstaller.installDatabaseAtomically(
      sourcePath: sourcePath,
      targetPath: targetPath,
      verifier: (file) async {
        return await verifyPackIntegrity(file, expectedHash);
      },
      onQuarantine: (file, reason) async {
        await quarantine.isolateCorruptFile(file, reason, quarantineDir);
      }
    );
  }
}
