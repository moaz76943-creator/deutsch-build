import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

class SecurityException implements Exception {
  final String message;
  const SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}

class DecompressionBombException extends SecurityException {
  const DecompressionBombException(super.message);
}

class ZipSlipException extends SecurityException {
  const ZipSlipException(super.message);
}

class SecureArchiveExtractionResult {
  final int totalEntriesExtracted;
  final int totalBytesExtracted;
  final String destinationDirectory;
  final List<String> extractedRelativePaths;

  const SecureArchiveExtractionResult({
    required this.totalEntriesExtracted,
    required this.totalBytesExtracted,
    required this.destinationDirectory,
    required this.extractedRelativePaths,
  });
}

/// محرك فك ضغط الأرشيفات الآمن والحماية من ثغرات مسارات Zip Slip وقنابل الضغط (Study 42)
/// يوفر استخراجاً ذرياً مع الحفاظ على آخر حالة سليمة (Last-Known-Good) عند أي خطأ
class SecureArchiveExtractor {
  static const int defaultMaxExpandedTotalBytes = 128 * 1024 * 1024; // 128 MiB
  static const int defaultMaxSingleEntryBytes = 64 * 1024 * 1024;     // 64 MiB
  static const int defaultMaxEntryCount = 10000;
  static const int defaultMaxExpansionRatio = 100;

  /// POSIX file-type mask and symlink type value from st_mode.
  static const int _fileTypeMask = 0xF000;
  static const int _symbolicLinkType = 0xA000;

  /// فحص مسار الدخول والتأكد من عدم وجود Zip Slip
  static void validateEntryPath(String entryName, Directory destinationDir) {
    if (entryName.isEmpty) {
      throw const ZipSlipException('Archive entry path is empty');
    }

    if (entryName.contains('\x00')) {
      throw const ZipSlipException('Archive entry path contains null character');
    }

    if (entryName.startsWith('/') ||
        entryName.startsWith('\\') ||
        RegExp(r'^[a-zA-Z]:').hasMatch(entryName)) {
      throw ZipSlipException('Archive entry uses absolute path: $entryName');
    }

    final normalized = p.normalize(entryName);
    if (normalized.startsWith('..') ||
        normalized.contains('/../') ||
        normalized.contains(r'\..\')) {
      throw ZipSlipException('Archive entry contains path traversal: $entryName');
    }

    final destinationCanonical = p.canonicalize(destinationDir.path);
    final targetCanonical = p.canonicalize(p.join(destinationCanonical, normalized));

    if (!p.isWithin(destinationCanonical, targetCanonical) &&
        targetCanonical != destinationCanonical) {
      throw ZipSlipException('Zip Slip breach: $entryName resolves outside $destinationCanonical');
    }
  }

  /// فحص نوع الدخول: يرفض الروابط الرمزية والأجهزة والأنواع غير العادية
  ///
  /// Even though the current ZIP decoder materialises entries as regular
  /// files, an archive that declares a symlink can be re-extracted by another
  /// tool later and escape the sandbox. Reject the type at the boundary.
  static void validateEntryType(ArchiveEntry entry) {
    final fileType = entry.mode & _fileTypeMask;
    if (fileType == _symbolicLinkType) {
      throw ZipSlipException('Archive entry is an unsafe symbolic link: ${entry.name}');
    }
    if (!entry.isFile && !entry.name.endsWith('/')) {
      throw ZipSlipException('Archive entry is neither a regular file nor a directory: ${entry.name}');
    }
  }

  /// فك ضغط آمن من مصفوفة بايتات للأرشيف (Zip) مع حماية القنابل والاستخراج الذري
  static Future<SecureArchiveExtractionResult> extractZipBytes({
    required Uint8List zipBytes,
    required Directory destinationDir,
    int maxTotalBytes = defaultMaxExpandedTotalBytes,
    int maxSingleBytes = defaultMaxSingleEntryBytes,
    int maxEntries = defaultMaxEntryCount,
    int maxExpansionRatio = defaultMaxExpansionRatio,
  }) async {
    final archive = ZipDecoder().decodeBytes(zipBytes, verify: true);
    return await _extractArchiveInternal(
      archive: archive,
      compressedSizeBytes: zipBytes.length,
      destinationDir: destinationDir,
      maxTotalBytes: maxTotalBytes,
      maxSingleBytes: maxSingleBytes,
      maxEntries: maxEntries,
      maxExpansionRatio: maxExpansionRatio,
    );
  }

  /// فك ضغط آمن من ملف أرشيف
  static Future<SecureArchiveExtractionResult> extractZipFile({
    required File zipFile,
    required Directory destinationDir,
    int maxTotalBytes = defaultMaxExpandedTotalBytes,
    int maxSingleBytes = defaultMaxSingleEntryBytes,
    int maxEntries = defaultMaxEntryCount,
    int maxExpansionRatio = defaultMaxExpansionRatio,
  }) async {
    final bytes = await zipFile.readAsBytes();
    return await extractZipBytes(
      zipBytes: bytes,
      destinationDir: destinationDir,
      maxTotalBytes: maxTotalBytes,
      maxSingleBytes: maxSingleBytes,
      maxEntries: maxEntries,
      maxExpansionRatio: maxExpansionRatio,
    );
  }

  static Future<SecureArchiveExtractionResult> _extractArchiveInternal({
    required Archive archive,
    required int compressedSizeBytes,
    required Directory destinationDir,
    required int maxTotalBytes,
    required int maxSingleBytes,
    required int maxEntries,
    required int maxExpansionRatio,
  }) async {
    if (archive.length > maxEntries) {
      throw DecompressionBombException(
        'Archive exceeds maximum entry count: ${archive.length} > $maxEntries',
      );
    }

    await destinationDir.create(recursive: true);

    // استخدام دليل عزل مرحلي (Staging directory) لضمان الذرية وحفظ Last-Known-Good
    // A unique staging name prevents two concurrent extractions from sharing,
    // or deleting, each other's partial output.
    final stagingDirName = '.staging_${DateTime.now().microsecondsSinceEpoch}_'
        '${archive.length}_${_randomToken()}';
    final stagingDir = Directory(p.join(destinationDir.path, stagingDirName));
    await stagingDir.create(recursive: true);

    var totalExtractedBytes = 0;
    final extractedPaths = <String>[];
    final seenPaths = <String>{};

    try {
      for (final entry in archive) {
        validateEntryPath(entry.name, stagingDir);
        validateEntryType(entry);

        if (!entry.isFile) {
          final dirPath = p.join(stagingDir.path, entry.name);
          await Directory(dirPath).create(recursive: true);
          continue;
        }

        final entryContent = entry.content as List<int>;
        final entrySize = entryContent.length;

        // Duplicate names would silently overwrite earlier content inside the
        // archive, so the extracted bytes would not match the manifest hash.
        final normalizedEntry = p.normalize(entry.name);
        if (!seenPaths.add(normalizedEntry)) {
          throw ZipSlipException('Archive contains a duplicate entry: $normalizedEntry');
        }

        if (entrySize > maxSingleBytes) {
          throw DecompressionBombException(
            'Single archive entry exceeds limit: ${entry.name} ($entrySize bytes > $maxSingleBytes)',
          );
        }

        totalExtractedBytes += entrySize;
        if (totalExtractedBytes > maxTotalBytes) {
          throw DecompressionBombException(
            'Total uncompressed bytes exceed limit ($totalExtractedBytes > $maxTotalBytes)',
          );
        }

        // فحص نسبة تضخم الأرشيف (Expansion Ratio Guard)
        if (compressedSizeBytes > 1024 * 1024 &&
            totalExtractedBytes > (compressedSizeBytes * maxExpansionRatio)) {
          throw DecompressionBombException(
            'Decompression bomb detected: expansion ratio exceeds $maxExpansionRatio:1',
          );
        }

        final filePath = p.join(stagingDir.path, entry.name);
        final parentDir = Directory(p.dirname(filePath));
        if (!await parentDir.exists()) {
          await parentDir.create(recursive: true);
        }

        final file = File(filePath);
        await file.writeAsBytes(entryContent, flush: true);
        extractedPaths.add(p.normalize(entry.name));
      }

      // بعد اكتمال الفحص بنجاح تام، نقل الملفات من الدليل المرحلي إلى الوجهة النهائية
      for (final relPath in extractedPaths) {
        final stagedFile = File(p.join(stagingDir.path, relPath));
        final targetFile = File(p.join(destinationDir.path, relPath));

        final targetParent = Directory(p.dirname(targetFile.path));
        if (!await targetParent.exists()) {
          await targetParent.create(recursive: true);
        }

        if (await stagedFile.exists()) {
          await stagedFile.rename(targetFile.path);
        }
      }

      return SecureArchiveExtractionResult(
        totalEntriesExtracted: extractedPaths.length,
        totalBytesExtracted: totalExtractedBytes,
        destinationDirectory: destinationDir.path,
        extractedRelativePaths: extractedPaths,
      );
    } catch (e) {
      // تنظيف الدليل المرحلي فوراً عند حدوث أي خطأ لحفظ Last-Known-Good
      if (await stagingDir.exists()) {
        try {
          await stagingDir.delete(recursive: true);
        } catch (_) {}
      }
      rethrow;
    } finally {
      if (await stagingDir.exists()) {
        try {
          await stagingDir.delete(recursive: true);
        } catch (_) {}
      }
    }
  }

  /// رمز عشوائي آمن لدليل العزل المرحلي
  static String _randomToken() {
    final secure = Random.secure();
    final buffer = StringBuffer();
    for (var index = 0; index < 8; index++) {
      buffer.write(secure.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
