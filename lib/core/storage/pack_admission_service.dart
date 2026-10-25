import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'storage_quarantine.dart';
import 'atomic_database_installer.dart';
import '../security/ed25519_signature_verifier.dart';

/// بوابة الفحص الأمني للحزم لمنع دخول ملفات تالفة أو خبيثة
class PackAdmissionService {
  final StorageQuarantine quarantine;
  final DatabaseFactory dbFactory;

  PackAdmissionService({
    required this.quarantine,
    required this.dbFactory,
  });

  /// التحقق من سلامة الحزمة قبل اعتمادها (SHA-256) والتحقق من SQLite
  Future<bool> verifyAndAdmitPack({
    required File stagedFile,
    required String expectedHash,
    required String targetPath,
    bool allowReplacement = false,
  }) async {
    try {
      if (!await stagedFile.exists()) {
        debugPrint("فشل التحقق: الملف غير موجود.");
        return false;
      }

      final length = await stagedFile.length();
      if (length == 0) {
        debugPrint("فشل التحقق: الملف فارغ.");
        return false;
      }

      // Reject targetPath hinting at learner progress
      if (targetPath.toLowerCase().contains('progress')) {
        debugPrint("فشل التحقق: مسار الحزمة يتعارض مع مسار تقدم المستخدم.");
        quarantine.isolateCorruptData(
          id: stagedFile.path,
          rawJson: '{"path": "$targetPath"}',
          reason: 'Attempted to overwrite progress database',
        );
        return false;
      }

      // Verify SHA-256
      final bytes = await stagedFile.readAsBytes();
      final digest = sha256.convert(bytes);

      if (digest.toString() != expectedHash) {
        debugPrint("فشل التحقق: Hash غير متطابق.");
        quarantine.isolateCorruptData(
          id: stagedFile.path,
          rawJson: '{"expected": "$expectedHash", "actual": "$digest"}',
          reason: 'SHA-256 hash mismatch',
        );
        return false;
      }

      // Verify SQLite integrity, schema, row counts, and language identity
      if (!await verifySqliteIntegrity(stagedFile.path)) {
        return false;
      }

      debugPrint("تم التحقق من الحزمة بنجاح. جاري النقل الذري...");

      final result = await AtomicDatabaseInstaller.installDatabaseAtomically(
        sourcePath: stagedFile.path,
        targetPath: targetPath,
        allowReplacement: allowReplacement,
      );

      return result.status == DatabaseInstallStatus.installed ||
          result.status == DatabaseInstallStatus.replaced;
    } catch (e) {
      debugPrint("خطأ أثناء فحص الحزمة: $e");
      return false;
    }
  }

  /// التحقق من توقيع Ed25519 الرقمي للحزمة ومطابقته لسجل المفاتيح الموثوقة
  Future<bool> verifyPackSignature({
    required File packFile,
    required String signatureHex,
    required String publicKeyHex,
  }) async {
    try {
      if (!PackTrustRegistry.isKeyTrusted(publicKeyHex)) {
        debugPrint('Pack signature validation failed: Public key is untrusted or insecure test vector.');
        return false;
      }

      final pubBytes = PackTrustRegistry.hexToBytes(publicKeyHex);
      final sigBytes = PackTrustRegistry.hexToBytes(signatureHex);
      if (pubBytes == null || sigBytes == null) {
        debugPrint('Pack signature validation failed: Malformed hex in key or signature.');
        return false;
      }

      final messageBytes = await packFile.readAsBytes();
      final isValid = Ed25519SignatureVerifier.verify(
        publicKeyBytes: pubBytes,
        messageBytes: messageBytes,
        signatureBytes: sigBytes,
      );

      if (!isValid) {
        debugPrint('Pack signature validation failed: Invalid cryptographic signature.');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Pack signature validation exception: $e');
      return false;
    }
  }

  Future<bool> verifySqliteIntegrity(String path) async {
    Database? db;
    try {
      // 0. فحص ترويسة SQLite الرسمية لمنع الملفات التالفة أو غير المتوافقة
      final file = File(path);
      final raf = await file.open(mode: FileMode.read);
      try {
        final header = await raf.read(16);
        if (header.length < 16 ||
            !String.fromCharCodes(header).startsWith('SQLite format 3')) {
          debugPrint('Pack validation failed: Invalid SQLite header signature.');
          quarantine.isolateCorruptData(
            id: path,
            rawJson: '{"error": "Invalid SQLite header"}',
            reason: 'Invalid SQLite header signature',
          );
          return false;
        }
      } finally {
        await raf.close();
      }

      db = await dbFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          readOnly: true,
        ),
      );

      // Check integrity
      final integrityCheck = await db.rawQuery('PRAGMA integrity_check');
      if (integrityCheck.isEmpty ||
          integrityCheck.first.values.first.toString().toLowerCase() != 'ok') {
        debugPrint("فشل التحقق: SQLite integrity_check فشل.");
        quarantine.isolateCorruptData(
          id: path,
          rawJson: '{"integrityCheck": "$integrityCheck"}',
          reason: 'SQLite integrity check failed',
        );
        return false;
      }

      // Check schema version
      final userVersion = await db.rawQuery('PRAGMA user_version');
      final version = Sqflite.firstIntValue(userVersion) ?? 0;
      if (version <= 0) {
        debugPrint("فشل التحقق: نسخة المخطط غير صالحة.");
        quarantine.isolateCorruptData(
          id: path,
          rawJson: '{"user_version": "$version"}',
          reason: 'Invalid schema version',
        );
        return false;
      }

      // Verify at least one table exists (excluding sqlite_ master tables)
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");
      if (tables.isEmpty) {
        debugPrint("فشل التحقق: لا توجد جداول بيانات.");
        quarantine.isolateCorruptData(
          id: path,
          rawJson: '{"tablesCount": "0"}',
          reason: 'No data tables found',
        );
        return false;
      }

      // Check language identity
      bool hasLanguageInfo = false;
      for (final table in tables) {
        final tableName = table['name'] as String;
        final columns = await db.rawQuery("PRAGMA table_info('$tableName')");
        final hasLanguageCol = columns.any((col) => col['name'] == 'language' || col['name'] == 'language_id' || col['name'] == 'lang');
        if (hasLanguageCol) {
          hasLanguageInfo = true;
          break;
        }
        if (tableName == 'metadata' || tableName == 'info' || tableName == 'data') {
            hasLanguageInfo = true;
            break;
        }
      }

      if (!hasLanguageInfo) {
        debugPrint("فشل التحقق: لا توجد معلومات لغة في الحزمة.");
        quarantine.isolateCorruptData(
          id: path,
          rawJson: '{"languageInfo": "missing"}',
          reason: 'Missing language identity',
        );
        return false;
      }

      // Row counts
      int totalRows = 0;
      for (final table in tables) {
        final tableName = table['name'] as String;
        final countResult = await db.rawQuery("SELECT COUNT(*) as count FROM '$tableName'");
        totalRows += (countResult.first['count'] as int?) ?? 0;
      }

      if (totalRows == 0) {
        debugPrint("فشل التحقق: الحزمة فارغة (صفر صفوف).");
        quarantine.isolateCorruptData(
          id: path,
          rawJson: '{"rowCount": "0"}',
          reason: 'Pack is empty (0 rows)',
        );
        return false;
      }

      return true;
    } catch (e) {
      debugPrint("فشل التحقق: تعذر قراءة كقاعدة بيانات SQLite - $e");
      quarantine.isolateCorruptData(
        id: path,
        rawJson: '{"error": "$e"}',
        reason: 'Failed to open or query SQLite database',
      );
      return false;
    } finally {
      await db?.close();
    }
  }
}
