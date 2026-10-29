import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
<<<<<<< HEAD
import 'package:sqflite/sqflite.dart';
import 'storage_quarantine.dart';
<<<<<<< HEAD
import 'atomic_database_installer.dart';
=======
import '../database/crash_safe_snapshot_manager.dart';
import '../security/ed25519_signature_verifier.dart';

>>>>>>> origin/fix/security-reconciliation-and-audit-lane01-02

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
=======

/// بوابة الفحص الأمني للحزم لمنع دخول ملفات تالفة أو خبيثة
class PackAdmissionService {

  /// التحقق من سلامة الحزمة قبل اعتمادها (SHA-256)
  Future<bool> verifyAndAdmitPack(File stagedFile, String expectedHash) async {
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    try {
<<<<<<< HEAD
      if (!await stagedFile.exists()) {
        debugPrint("فشل التحقق: الملف غير موجود.");
=======
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
      debugPrint("خطأ أثناء فحص الحزمة: \$e");
      return false;
    }
  }
<<<<<<< HEAD

  /// التحقق من توقيع Ed25519 الرقمي للحزمة ومطابقته لسجل المفاتيح الموثوقة (Study 06)
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

  Future<bool> verifyPackIntegrity(File file, String expectedHash) async {
    try {
      // 0. فحص ترويسة SQLite الرسمية لمنع الملفات التالفة أو غير المتوافقة
      final isValidHeader = await CrashSafeSnapshotManager.verifySqliteHeader(file);
      if (!isValidHeader) {
        debugPrint('Pack validation failed: Invalid SQLite header signature.');
        return false;
      }

      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);

      if (digest.toString() != expectedHash) {
        debugPrint("Pack validation failed: hash mismatch.");
>>>>>>> origin/fix/security-reconciliation-and-audit-lane01-02
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

      // Verify SQLite integrity and schema
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

  Future<bool> verifySqliteIntegrity(String path) async {
    Database? db;
    try {
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
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
}
