import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

typedef PackDownloadProgress = void Function(double progress);

class PackDownloaderService {
  static const String defaultManifestUrl =
      'https://raw.githubusercontent.com/moaz76943-creator/-offline-packs-store/main/manifest.json';
  static const String _bundleFormat = 'json-gzip-v1';
  static const int maxUncompressedPackBytes = 64 * 1024 * 1024;

  /// Decode gzip incrementally; reject oversized payloads before retaining
  /// the chunk. The limit applies to the expanded JSON envelope (including
  /// embedded Base64), not merely the compressed download size.
  ///
  /// [maxExpandedBytes] may be reduced for isolated boundary tests but never
  /// increased beyond the production 64 MiB ceiling.
  static Future<Uint8List> decodeGzipEnvelope(
    Stream<List<int>> compressedChunks, {
    int maxExpandedBytes = maxUncompressedPackBytes,
  }) async {
    if (maxExpandedBytes < 1 ||
        maxExpandedBytes > maxUncompressedPackBytes) {
      throw RangeError.range(
        maxExpandedBytes, 1, maxUncompressedPackBytes, 'maxExpandedBytes',
      );
    }
    final expanded = BytesBuilder(copy: false);
    var expandedBytes = 0;
    await for (final chunk in compressedChunks.transform(gzip.decoder)) {
      // Subtraction avoids overflow even for a malicious length.
      if (chunk.length > maxExpandedBytes - expandedBytes) {
        throw StateError(
          'Uncompressed pack envelope exceeds the '
          '${maxExpandedBytes} byte limit (64 MiB maximum)',
        );
      }
      expanded.add(chunk);
      expandedBytes += chunk.length;
    }
    return expanded.takeBytes();
  }

  static final Map<String, http.Client> _activeClients = <String, http.Client>{};
  static final Set<String> _cancelledDownloads = <String>{};

  static Future<bool> downloadPack(
    String languageCode, {
    PackDownloadProgress? onProgress,
    String? manifestUrl,
  }) async {
    final code = _normalizeLanguageCode(languageCode);
    if (code == 'de') {
      onProgress?.call(1.0);
      return true;
    }
    if (_activeClients.containsKey(code)) {
      return false;
    }

    final client = http.Client();
    _activeClients[code] = client;
    _cancelledDownloads.remove(code);

    try {
      final manifestUri = Uri.parse(manifestUrl ?? defaultManifestUrl);
      final manifest = await _fetchManifest(client, manifestUri);
      final descriptor = _PackDescriptor.fromManifest(
        manifest,
        code,
        manifestUri,
      );
      if (descriptor.bundleFormat != _bundleFormat) {
        throw const FormatException('Unsupported pack bundle format');
      }

      final packsDir = await _packsDirectory();
      final downloadsDir = Directory(path.join(packsDir.path, '.downloads'));
      await downloadsDir.create(recursive: true);
      final archive = File(path.join(downloadsDir.path, '$code.pack.gz.part'));

      await _downloadArchive(
        client: client,
        uri: descriptor.archiveUri,
        destination: archive,
        expectedSizeBytes: descriptor.archiveSizeBytes,
        expectedSha256: descriptor.sha256,
        onProgress: onProgress,
      );
      if (_cancelledDownloads.contains(code)) {
        return false;
      }

      final archiveDigest = await _sha256File(archive);
      if (!_constantTimeHexEquals(archiveDigest, descriptor.sha256)) {
        throw StateError('Archive SHA-256 verification failed for $code');
      }

      final sqliteBytes = await _extractSqliteBytes(archive, descriptor);
      if (descriptor.contentSha256 != null) {
        final contentDigest = sha256.convert(sqliteBytes).toString();
        if (!_constantTimeHexEquals(contentDigest, descriptor.contentSha256!)) {
          throw StateError('SQLite SHA-256 verification failed for $code');
        }
      }

      final staged = File(path.join(packsDir.path, '.$code.sqlite.installing'));
      if (await staged.exists()) {
        await staged.delete();
      }
      await staged.writeAsBytes(sqliteBytes, flush: true);
      await _verifySqlitePackage(staged, code);

      await DatabaseService.instance.closeContentDb(code);
      final target = File(path.join(packsDir.path, '$code.sqlite'));
      await _replaceAtomically(staged, target);

      final installedDigest = await _sha256File(target);
      if (descriptor.contentSha256 != null &&
          !_constantTimeHexEquals(installedDigest, descriptor.contentSha256!)) {
        throw StateError('Installed SQLite checksum changed for $code');
      }

      await _upsertRegistryRecord(
        code,
        <String, dynamic>{
          'languageCode': code,
          'packId': descriptor.id,
          'version': descriptor.version,
          'contractVersion': descriptor.contractVersion,
          'bundleFormat': descriptor.bundleFormat,
          'archiveSha256': descriptor.sha256,
          'contentSha256': descriptor.contentSha256 ?? installedDigest,
          'installedSizeBytes': await target.length(),
          'installedPath': target.path,
          'installedAt': DateTime.now().toUtc().toIso8601String(),
        },
      );

      if (await archive.exists()) {
        await archive.delete();
      }
      onProgress?.call(1.0);
      return true;
    } catch (_) {
      return false;
    } finally {
      if (identical(_activeClients[code], client)) {
        _activeClients.remove(code);
      }
      client.close();
      _cancelledDownloads.remove(code);
    }
  }

  static Future<bool> isPackDownloaded(String languageCode) async {
    final code = _normalizeLanguageCode(languageCode);
    if (code == 'de') {
      return true;
    }
    final packsDir = await _packsDirectory();
    return File(path.join(packsDir.path, '$code.sqlite')).exists();
  }

  static Future<List<Map<String, dynamic>>> getInstalledPacks() async {
    final registry = await _readRegistry();
    final rawPacks = registry['packs'];
    if (rawPacks is! Map) {
      return <Map<String, dynamic>>[];
    }

    final output = <Map<String, dynamic>>[];
    for (final entry in rawPacks.entries) {
      if (entry.key is! String || entry.value is! Map) {
        continue;
      }
      final record = Map<String, dynamic>.from(entry.value as Map);
      final installedPath = record['installedPath'];
      if (installedPath is String && await File(installedPath).exists()) {
        output.add(record);
      }
    }
    output.sort(
      (a, b) => (a['languageCode'] as String? ?? '')
          .compareTo(b['languageCode'] as String? ?? ''),
    );
    return output;
  }

  static Future<bool> deletePack(String languageCode) async {
    final code = _normalizeLanguageCode(languageCode);
    if (code == 'de') {
      return false;
    }

    await cancelDownload(code);
    await DatabaseService.instance.closeContentDb(code);

    final packsDir = await _packsDirectory();
    final target = File(path.join(packsDir.path, '$code.sqlite'));
    if (await target.exists()) {
      await target.delete();
    }

    final downloadsDir = Directory(path.join(packsDir.path, '.downloads'));
    final partial = File(path.join(downloadsDir.path, '$code.pack.gz.part'));
    if (await partial.exists()) {
      await partial.delete();
    }

    await _removeRegistryRecord(code);
    return true;
  }

  static Future<void> cancelDownload(String languageCode) async {
    final code = _normalizeLanguageCode(languageCode);
    _cancelledDownloads.add(code);
    _activeClients.remove(code)?.close();
  }

  static Future<Map<String, dynamic>> _fetchManifest(
    http.Client client,
    Uri manifestUri,
  ) async {
    if (manifestUri.scheme != 'https') {
      throw const FormatException('Pack manifest must use HTTPS');
    }
    final response = await client.get(manifestUri);
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'Manifest request failed with HTTP ${response.statusCode}',
        uri: manifestUri,
      );
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map) {
      throw const FormatException('Pack manifest root must be an object');
    }
    return Map<String, dynamic>.from(decoded);
  }

  static Future<void> _downloadArchive({
    required http.Client client,
    required Uri uri,
    required File destination,
    required int? expectedSizeBytes,
    required String expectedSha256,
    PackDownloadProgress? onProgress,
  }) async {
    if (uri.scheme != 'https') {
      throw const FormatException('Pack archive must use HTTPS');
    }
    await destination.parent.create(recursive: true);

    if (await destination.exists()) {
      final existingLength = await destination.length();
      if (expectedSizeBytes != null && existingLength > expectedSizeBytes) {
        await destination.delete();
      } else if (expectedSizeBytes != null &&
          existingLength == expectedSizeBytes) {
        final digest = await _sha256File(destination);
        if (_constantTimeHexEquals(digest, expectedSha256)) {
          onProgress?.call(1.0);
          return;
        }
        await destination.delete();
      }
    }

    for (var attempt = 0; attempt < 2; attempt++) {
      final existingBytes =
          await destination.exists() ? await destination.length() : 0;
      final request = http.Request('GET', uri);
      if (existingBytes > 0) {
        request.headers[HttpHeaders.rangeHeader] = 'bytes=$existingBytes-';
      }

      final response = await client.send(request);
      if (response.statusCode == HttpStatus.requestedRangeNotSatisfiable &&
          existingBytes > 0 &&
          attempt == 0) {
        await destination.delete();
        continue;
      }
      if (response.statusCode != HttpStatus.ok &&
          response.statusCode != HttpStatus.partialContent) {
        throw HttpException(
          'Pack download failed with HTTP ${response.statusCode}',
          uri: uri,
        );
      }

      final append = existingBytes > 0 &&
          response.statusCode == HttpStatus.partialContent;
      final startingBytes = append ? existingBytes : 0;
      final totalBytes = _resolveTotalBytes(
        response.headers,
        startingBytes,
        response.contentLength,
        expectedSizeBytes,
      );
      final sink = destination.openWrite(
        mode: append ? FileMode.append : FileMode.write,
      );
      var receivedBytes = startingBytes;
      try {
        await for (final chunk in response.stream) {
          sink.add(chunk);
          receivedBytes += chunk.length;
          if (totalBytes != null && totalBytes > 0) {
            onProgress?.call(
              (receivedBytes / totalBytes).clamp(0.0, 1.0).toDouble(),
            );
          }
        }
        await sink.flush();
      } finally {
        await sink.close();
      }

      final finalSize = await destination.length();
      if (expectedSizeBytes != null && finalSize != expectedSizeBytes) {
        throw StateError(
          'Pack archive size mismatch: expected $expectedSizeBytes, got $finalSize',
        );
      }
      return;
    }
  }

  static int? _resolveTotalBytes(
    Map<String, String> headers,
    int startingBytes,
    int? responseLength,
    int? expectedSizeBytes,
  ) {
    final contentRange = headers[HttpHeaders.contentRangeHeader];
    if (contentRange != null) {
      final match = RegExp(r'^bytes\s+\d+-\d+/(\d+|\*)$').firstMatch(contentRange);
      if (match != null && match.group(1) != '*') {
        return int.tryParse(match.group(1)!);
      }
    }
    if (expectedSizeBytes != null && expectedSizeBytes > 0) {
      return expectedSizeBytes;
    }
    if (responseLength != null && responseLength >= 0) {
      return startingBytes + responseLength;
    }
    return null;
  }

  static Future<List<int>> _extractSqliteBytes(
    File archive,
    _PackDescriptor descriptor,
  ) async {
    // Never materialize the compressed file in RAM. Stop expansion at 64 MiB
    // before JSON or Base64 decoding can amplify memory consumption further.
    final decompressed = await decodeGzipEnvelope(archive.openRead());
    final decoded = jsonDecode(utf8.decode(decompressed));
    if (decoded is! Map) {
      throw const FormatException('Pack envelope must be an object');
    }
    final envelope = Map<String, dynamic>.from(decoded);

    if (envelope['packId'] != descriptor.id) {
      throw const FormatException('Pack envelope id does not match manifest');
    }
    final envelopeContract = envelope['contractVersion'];
    if (envelopeContract is String &&
        descriptor.contractVersion.isNotEmpty &&
        envelopeContract != descriptor.contractVersion) {
      throw const FormatException('Pack contract version mismatch');
    }

    final rawFiles = envelope['files'];
    if (rawFiles is! List) {
      throw const FormatException('Pack envelope files must be an array');
    }

    final encodedFiles = <String, String>{};
    for (final rawFile in rawFiles) {
      if (rawFile is! Map) {
        throw const FormatException('Pack file entry must be an object');
      }
      final item = Map<String, dynamic>.from(rawFile);
      final filePath = item['path'];
      final contentBase64 = item['contentBase64'];
      if (filePath is! String || contentBase64 is! String) {
        throw const FormatException('Pack file entry is malformed');
      }
      _validateEnvelopePath(filePath);
      if (encodedFiles.containsKey(filePath)) {
        throw const FormatException('Pack contains duplicate file paths');
      }
      encodedFiles[filePath] = contentBase64;
    }

    const requiredPaths = <String>{
      'content/content.json',
      'content/content.sqlite',
      'metadata/pack.json',
    };
    if (!encodedFiles.keys.toSet().containsAll(requiredPaths)) {
      throw const FormatException('Pack envelope is missing required files');
    }

    final sqliteEncoded = encodedFiles['content/content.sqlite']!;
    try {
      return base64Decode(sqliteEncoded);
    } on FormatException {
      throw const FormatException('SQLite payload is not valid Base64');
    }
  }

  static void _validateEnvelopePath(String value) {
    if (value.isEmpty ||
        value.startsWith('/') ||
        value.startsWith('\\') ||
        value.contains('..') ||
        value.contains('\\')) {
      throw const FormatException('Unsafe pack envelope path');
    }
  }

  static Future<void> _verifySqlitePackage(File file, String languageCode) async {
    final raf = await file.open(mode: FileMode.read);
    try {
      final header = await raf.read(16);
      if (header.length < 16 ||
          !String.fromCharCodes(header).startsWith('SQLite format 3')) {
        throw const FormatException('Extracted content is not a SQLite database');
      }
    } finally {
      await raf.close();
    }

    final db = await openDatabase(
      file.path,
      readOnly: true,
      singleInstance: false,
    );
    try {
      final integrityRows = await db.rawQuery('PRAGMA integrity_check');
      if (integrityRows.isEmpty ||
          integrityRows.first.values.isEmpty ||
          integrityRows.first.values.first.toString().toLowerCase() != 'ok') {
        throw StateError('SQLite integrity_check failed');
      }

      final schemaRows = await db.rawQuery('''
        SELECT name, type
        FROM sqlite_master
        WHERE name IN ('metadata', 'lexicon', 'concepts', 'grammar', 'lexemes', 'examples')
      ''');
      final names = schemaRows
          .map((row) => row['name'])
          .whereType<String>()
          .toSet();
      const requiredNames = <String>{
        'metadata',
        'lexicon',
        'concepts',
        'grammar',
        'lexemes',
        'examples',
      };
      if (!names.containsAll(requiredNames)) {
        throw StateError('SQLite pack does not satisfy the universal schema contract');
      }

      final languageRows = await db.rawQuery(
        "SELECT value FROM metadata WHERE key = 'languageCode' LIMIT 1",
      );
      if (languageRows.isEmpty ||
          languageRows.first['value']?.toString().toLowerCase() != languageCode) {
        throw StateError('SQLite language metadata does not match requested language');
      }
    } finally {
      await db.close();
    }
  }

  static Future<void> _replaceAtomically(File staged, File target) async {
    final backup = File('${target.path}.bak');
    if (await backup.exists()) {
      await backup.delete();
    }

    final hadTarget = await target.exists();
    if (hadTarget) {
      await target.rename(backup.path);
    }
    try {
      await staged.rename(target.path);
      if (await backup.exists()) {
        await backup.delete();
      }
    } catch (_) {
      if (await staged.exists()) {
        await staged.delete();
      }
      if (await backup.exists() && !await target.exists()) {
        await backup.rename(target.path);
      }
      rethrow;
    }
  }

  static Future<Directory> _packsDirectory() async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory(path.join(root.path, 'packs'));
    await directory.create(recursive: true);
    return directory;
  }

  static Future<File> _registryFile() async {
    final directory = await _packsDirectory();
    return File(path.join(directory.path, 'registry.json'));
  }

  static Future<Map<String, dynamic>> _readRegistry() async {
    final file = await _registryFile();
    if (!await file.exists()) {
      return <String, dynamic>{'schemaVersion': 1, 'packs': <String, dynamic>{}};
    }
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map) {
        final registry = Map<String, dynamic>.from(decoded);
        if (registry['packs'] is Map) {
          return registry;
        }
      }
    } catch (_) {}
    return <String, dynamic>{'schemaVersion': 1, 'packs': <String, dynamic>{}};
  }

  static Future<void> _upsertRegistryRecord(
    String languageCode,
    Map<String, dynamic> record,
  ) async {
    final registry = await _readRegistry();
    final packs = Map<String, dynamic>.from(
      registry['packs'] as Map? ?? <String, dynamic>{},
    );
    packs[languageCode] = record;
    registry['schemaVersion'] = 1;
    registry['packs'] = packs;
    await _writeRegistry(registry);
  }

  static Future<void> _removeRegistryRecord(String languageCode) async {
    final registry = await _readRegistry();
    final packs = Map<String, dynamic>.from(
      registry['packs'] as Map? ?? <String, dynamic>{},
    );
    packs.remove(languageCode);
    registry['schemaVersion'] = 1;
    registry['packs'] = packs;
    await _writeRegistry(registry);
  }

  static Future<void> _writeRegistry(Map<String, dynamic> registry) async {
    final file = await _registryFile();
    final staged = File('${file.path}.tmp');
    await staged.writeAsString(jsonEncode(registry), flush: true);
    await _replaceAtomically(staged, file);
  }

  static Future<String> _sha256File(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  static bool _constantTimeHexEquals(String left, String right) {
    final a = left.toLowerCase();
    final b = right.toLowerCase();
    if (a.length != b.length) {
      return false;
    }
    var difference = 0;
    for (var index = 0; index < a.length; index++) {
      difference |= a.codeUnitAt(index) ^ b.codeUnitAt(index);
    }
    return difference == 0;
  }

  static String _normalizeLanguageCode(String value) {
    final normalized = value.trim().toLowerCase().replaceAll('_', '-');
    if (!RegExp(r'^[a-z]{2,3}(?:-[a-z0-9]{2,8})*$').hasMatch(normalized)) {
      throw ArgumentError.value(value, 'languageCode', 'Invalid language code');
    }
    return normalized.split('-').first == 'de' ? 'de' : normalized;
  }
}

class _PackDescriptor {
  final String id;
  final String languageCode;
  final String version;
  final String contractVersion;
  final String bundleFormat;
  final Uri archiveUri;
  final String sha256;
  final String? contentSha256;
  final int? archiveSizeBytes;

  const _PackDescriptor({
    required this.id,
    required this.languageCode,
    required this.version,
    required this.contractVersion,
    required this.bundleFormat,
    required this.archiveUri,
    required this.sha256,
    required this.contentSha256,
    required this.archiveSizeBytes,
  });

  factory _PackDescriptor.fromManifest(
    Map<String, dynamic> manifest,
    String languageCode,
    Uri manifestUri,
  ) {
    Map<String, dynamic>? entry;

    final packs = manifest['packs'];
    if (packs is List) {
      for (final raw in packs) {
        if (raw is! Map) {
          continue;
        }
        final candidate = Map<String, dynamic>.from(raw);
        final code = candidate['languageCode']?.toString().toLowerCase();
        final id = candidate['id']?.toString().toLowerCase();
        if (code == languageCode || id == languageCode) {
          entry = candidate;
          break;
        }
      }
    }

    final languages = manifest['languages'];
    if (entry == null && languages is List) {
      for (final raw in languages) {
        if (raw is! Map) {
          continue;
        }
        final candidate = Map<String, dynamic>.from(raw);
        final code = candidate['code']?.toString().toLowerCase();
        if (code == languageCode) {
          entry = candidate;
          break;
        }
      }
    }

    if (entry == null) {
      throw StateError('No pack is published for language $languageCode');
    }

    final id = (entry['id'] ?? entry['pack_id'] ?? languageCode).toString();
    final code = (entry['languageCode'] ?? entry['code'] ?? languageCode)
        .toString()
        .toLowerCase();
    final bundleFormat = (entry['bundleFormat'] ?? PackDownloaderService._bundleFormat).toString();
    final version = (entry['version'] ??
            manifest['store_version'] ??
            manifest['version'] ??
            'unknown')
        .toString();
    final contractVersion = (entry['contractVersion'] ?? '1.0.0').toString();

    final archiveValue = entry['archiveUrl'] ??
        entry['pack_url'] ??
        entry['file_url'];
    Uri archiveUri;
    if (archiveValue != null) {
      archiveUri = Uri.parse(archiveValue.toString());
    } else {
      final fileName = entry['pack_file'];
      if (fileName is! String || fileName.isEmpty) {
        throw const FormatException('Manifest pack URL is missing');
      }
      archiveUri = manifestUri.resolve('packs/$fileName');
    }
    if (archiveUri.scheme != 'https') {
      throw const FormatException('Manifest pack URL must use HTTPS');
    }

    final archiveSha = entry['sha256']?.toString().toLowerCase();
    if (archiveSha == null ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(archiveSha)) {
      throw const FormatException('Manifest pack SHA-256 is missing or invalid');
    }

    final rawContentSha = entry['contentSha256']?.toString().toLowerCase();
    final contentSha = rawContentSha != null && rawContentSha.isNotEmpty
        ? rawContentSha
        : null;
    if (contentSha != null &&
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(contentSha)) {
      throw const FormatException('Manifest content SHA-256 is invalid');
    }

    final rawSize = entry['archiveSizeBytes'] ?? entry['size_bytes'];
    final archiveSize = rawSize is num
        ? rawSize.toInt()
        : rawSize == null
            ? null
            : int.tryParse(rawSize.toString());

    return _PackDescriptor(
      id: id,
      languageCode: code,
      version: version,
      contractVersion: contractVersion,
      bundleFormat: bundleFormat,
      archiveUri: archiveUri,
      sha256: archiveSha,
      contentSha256: contentSha,
      archiveSizeBytes: archiveSize,
    );
  }
}
