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
      final isValidHeader = await verifySqliteHeader(file);
      if (!isValidHeader) {
        debugPrint('Pack validation failed: Invalid SQLite header signature.');
        return false;
      }

      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);

      if (digest.toString() != expectedHash) {
        debugPrint("Pack validation failed: hash mismatch.");
        return false;
      }
      return true;
    } catch (e) {
      debugPrint("خطأ أثناء فحص الحزمة: $e");
      return false;
    }
  }

  Future<bool> verifySqliteHeader(File file) async {
    try {
      final handle = await file.open(mode: FileMode.read);
      final headerBytes = await handle.read(16);
      await handle.close();

      // SQLite format 3\000
      final expectedHeader = [0x53, 0x51, 0x4c, 0x69, 0x74, 0x65, 0x20, 0x66, 0x6f, 0x72, 0x6d, 0x61, 0x74, 0x20, 0x33, 0x00];

      if (headerBytes.length != 16) return false;
      for (var i = 0; i < 16; i++) {
        if (headerBytes[i] != expectedHeader[i]) return false;
      }
      return true;
    } catch (e) {
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

      // Check language identity via pack_metadata table
      final packMetadataCheck = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='pack_metadata'");
      if (packMetadataCheck.isEmpty) {
        debugPrint("فشل التحقق: جدول pack_metadata غير موجود.");
        quarantine.isolateCorruptData(
          id: path,
          rawJson: '{"packMetadata": "missing"}',
          reason: 'pack_metadata table missing',
        );
        return false;
      }

      // Check languageCode column in pack_metadata
      final columnsInfo = await db.rawQuery("PRAGMA table_info(pack_metadata)");
      final hasLanguageCode = columnsInfo.any((col) => col['name'] == 'languageCode');
      if (!hasLanguageCode) {
         debugPrint("فشل التحقق: عمود languageCode غير موجود في جدول pack_metadata.");
         quarantine.isolateCorruptData(
          id: path,
          rawJson: '{"languageCode": "missing"}',
          reason: 'languageCode column missing in pack_metadata',
        );
        return false;
      }

      // Check row counts (at least one row in a core table, e.g. pack_metadata)
      final rowCountResult = await db.rawQuery("SELECT COUNT(*) as count FROM pack_metadata");
      final rowCount = Sqflite.firstIntValue(rowCountResult) ?? 0;
      if (rowCount == 0) {
         debugPrint("فشل التحقق: جدول pack_metadata فارغ.");
         quarantine.isolateCorruptData(
          id: path,
          rawJson: '{"packMetadataRowCount": "0"}',
          reason: 'pack_metadata table is empty',
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
}

class PackTrustRegistry {
  static bool isKeyTrusted(String hexKey) {
    // Basic placeholder implementation. Should be configured with actual trusted keys.
    return hexKey.isNotEmpty && hexKey != '0000000000000000000000000000000000000000000000000000000000000000';
  }

  static Uint8List? hexToBytes(String hexStr) {
    if (hexStr.length % 2 != 0) return null;
    final bytes = <int>[];
    for (var i = 0; i < hexStr.length; i += 2) {
      final byteHex = hexStr.substring(i, i + 2);
      final byteValue = int.tryParse(byteHex, radix: 16);
      if (byteValue == null) return null;
      bytes.add(byteValue);
    }
    return Uint8List.fromList(bytes);
  }
}
