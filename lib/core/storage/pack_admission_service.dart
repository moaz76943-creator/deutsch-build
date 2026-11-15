import 'dart:io';
import 'dart:isolate';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'storage_quarantine.dart';
import 'atomic_database_installer.dart';
import '../../services/database_service.dart';

/// بوابة الفحص الأمني للحزم لمنع دخول ملفات تالفة أو خبيثة
class PackAdmissionService {
  final StorageQuarantine quarantine;
  final DatabaseFactory dbFactory;

  PackAdmissionService({
    required this.quarantine,
    required this.dbFactory,
  });

  /// A manifest-bound SHA-256 digest is exactly 64 hex characters.
  static final RegExp _safeDigest = RegExp(r'^[a-fA-F0-9]{64}$');

  /// التحقق من سلامة الحزمة قبل اعتمادها (SHA-256) والتحقق من SQLite
  Future<bool> verifyAndAdmitPack({
    required File stagedFile,
    required String expectedHash,
    required String targetPath,
    required String languageCode,
    bool allowReplacement = false,
  }) async {
    try {
      // T64: reject a malformed caller-claimed digest before touching the
      // staged file; only a manifest-shaped SHA-256 hex digest is admissible.
      if (!_safeDigest.hasMatch(expectedHash)) {
        debugPrint("فشل التحقق: بصمة غير صالحة (ليست SHA-256 hex).");
        return false;
      }
      if (!RegExp(r'^[a-z]{2,3}$').hasMatch(languageCode)) {
        return false;
      }
      if (!await stagedFile.exists()) {
        debugPrint("فشل التحقق: الملف غير موجود.");
        return false;
      }

      final length = await stagedFile.length();
      if (length == 0) {
        debugPrint("فشل التحقق: الملف فارغ.");
        return false;
      }

      if (targetPath.toLowerCase().contains('progress')) {
        debugPrint("فشل التحقق: مسار الحزمة يتعارض مع مسار تقدم المستخدم.");
        quarantine.isolateCorruptData(
          id: stagedFile.path,
          rawJson: '{"path": "$targetPath"}',
          reason: 'Attempted to overwrite progress database',
        );
        return false;
      }

      // Stream the digest in a worker. Large SQLite packs must not be read
      // into the Flutter UI isolate or buffered as a single Uint8List.
      final stagedPath = stagedFile.path;
      final digest = await Isolate.run(
        () async => (await sha256.bind(
          File(stagedPath).openRead(),
        ).first).toString(),
      );

      if (digest != expectedHash.toLowerCase()) {
        debugPrint("فشل التحقق: Hash غير متطابق.");
        quarantine.isolateCorruptData(
          id: stagedFile.path,
          rawJson: '{"expected": "$expectedHash", "actual": "$digest"}',
          reason: 'SHA-256 hash mismatch',
        );
        return false;
      }

      // Verify SQLite integrity and schema
      if (!await _verifySqliteIntegrity(stagedFile.path, languageCode)) {
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

  Future<bool> _verifySqliteIntegrity(String path, String languageCode) async {
    Database? db;
    try {
      db = await dbFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          readOnly: true,
        ),
      );

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

      // SQLite integrity_check does not detect orphaned foreign keys.
      // Reject the candidate before the atomic installer can replace a
      // previously verified pack or expose inconsistent lexical relations.
      final foreignKeyViolations =
          await db.rawQuery('PRAGMA foreign_key_check');
      if (foreignKeyViolations.isNotEmpty) {
        debugPrint('فشل التحقق: SQLite foreign_key_check فشل.');
        quarantine.isolateCorruptData(
          id: path,
          rawJson: '{"foreign_key_violations": ${foreignKeyViolations.length}}',
          reason: 'SQLite foreign key check failed',
        );
        return false;
      }

      // Check schema version
      final userVersion = await db.rawQuery('PRAGMA user_version');
      final version = Sqflite.firstIntValue(userVersion) ?? 0;
      if (version != 2) {
        debugPrint("فشل التحقق: نسخة المخطط غير صالحة.");
        quarantine.isolateCorruptData(
          id: path,
          rawJson: '{"user_version": "$version"}',
          reason: 'Invalid schema version',
        );
        return false;
      }

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

      // Do not publish a SQLite file that the actual content reader rejects.
      // This shared verifier checks the v2 tables, metadata language identity,
      // lexicon ownership, FTS5 and foreign-key consistency.
      await DatabaseService.instance.verifyUniversalSchema(db, languageCode);
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
