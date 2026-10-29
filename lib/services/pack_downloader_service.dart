import 'dart:convert';
import 'dart:isolate';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
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
  static const int maxCompressedPackBytes = 48 * 1024 * 1024;
  static const int maxSqliteBytes = 32 * 1024 * 1024;
  static const String blockedSourceStatus = 'BLOCKED_SOURCE';
  static final Map<String, String> _statuses = <String, String>{};

  static String? downloadStatus(String code) =>
      _statuses[_normalizeLanguageCode(code)];

  @visibleForTesting
  static bool isApprovedPackUriForTesting(Uri uri) => _approvedUri(uri);

  @visibleForTesting
  static bool hasPublishedPackForTesting(
    Map<String, dynamic> manifest, String code,
  ) {
    try {
      _PackDescriptor.fromManifest(
        manifest, _normalizeLanguageCode(code), Uri.parse(defaultManifestUrl),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

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
    if (_activeClients.containsKey(code)) return false;
    if (code == 'de') {
      try {
        await DatabaseService.instance.getContentDb(code);
        _statuses[code] = 'INSTALLED_BUNDLED';
        onProgress?.call(1.0);
        return true;
      } catch (_) {
        _statuses[code] = blockedSourceStatus;
        return false;
      }
    }
    final client = http.Client();
    _activeClients[code] = client;
    _cancelledDownloads.remove(code);
    try {
      final manifestUri = Uri.parse(manifestUrl ?? defaultManifestUrl);
      final manifest = await _fetchManifest(client, manifestUri);
      if (manifest['packs'] is! List ||
          (manifest['packs'] as List).isEmpty) {
        _statuses[code] = blockedSourceStatus;
        return false;
      }
      final descriptor = _PackDescriptor.fromManifest(
        manifest, code, manifestUri,
      );
      final packsDir = await _packsDirectory();
      final downloads = Directory(path.join(packsDir.path, '.downloads'));
      await downloads.create(recursive: true);
      final archive = File(path.join(downloads.path, '$code.pack.gz.part'));
      await _downloadArchive(
        client: client, uri: descriptor.archiveUri,
        destination: archive, expectedSizeBytes: descriptor.archiveSizeBytes,
        expectedSha256: descriptor.sha256, onProgress: onProgress,
      );
      if (_cancelledDownloads.contains(code)) {
        _statuses[code] = 'CANCELLED';
        return false;
      }
      await _installVerifiedArchive(code, descriptor, archive, packsDir);
      _statuses[code] = 'INSTALLED';
      try {
        if (await archive.exists()) await archive.delete();
      } catch (_) {}
      onProgress?.call(1.0);
      return true;
    } catch (error) {
      _statuses[code] = error.toString().contains('BLOCKED_SOURCE')
          ? blockedSourceStatus
          : _cancelledDownloads.contains(code)
          ? 'CANCELLED'
          : (_statuses[code] == blockedSourceStatus
              ? blockedSourceStatus : 'FAILED');
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
      try {
        await DatabaseService.instance.getContentDb(code);
        return true;
      } catch (_) {
        return false;
      }
    }
    final packsDir = await _packsDirectory();
    final file = File(path.join(packsDir.path, '$code.sqlite'));
    if (!await file.exists()) return false;
    final installed = await getInstalledPacks();
    return installed.any((record) =>
        record['languageCode'] == code && record['installedPath'] == file.path);
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
    // Do not delete a file while a concurrent transaction may commit it.
    if (_activeClients.containsKey(code)) return false;
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
    // Keep ownership until the active request finishes its finally block.
    _activeClients[code]?.close();
  }

  static bool _approvedUri(Uri uri) {
    if (uri.scheme != 'https' || uri.userInfo.isNotEmpty ||
        uri.hasQuery || uri.hasFragment ||
        (uri.hasPort && uri.port != 443) ||
        uri.pathSegments.any((part) =>
            part.isEmpty || part == '..' || part == '.')) {
      return false;
    }
    final raw = RegExp(
      r'^/moaz76943-creator/-offline-packs-store/'
      r'(main|[0-9a-f]{40})/(manifest\.json|packs/[a-zA-Z0-9._/-]+)$',
    );
    final cdn = RegExp(
      r'^/gh/moaz76943-creator/-offline-packs-store@'
      r'(main|[0-9a-f]{40})/packs/[a-zA-Z0-9._/-]+$',
    );
    return (uri.host == 'raw.githubusercontent.com' &&
            raw.hasMatch(uri.path)) ||
        (uri.host == 'cdn.jsdelivr.net' && cdn.hasMatch(uri.path));
  }

  static Future<http.StreamedResponse> _approvedGet(
    http.Client client, Uri uri, {
    Map<String, String> headers = const <String, String>{},
  }) async {
    var current = uri;
    for (var redirect = 0; redirect <= 3; redirect++) {
      if (!_approvedUri(current)) {
        throw const FormatException('Unapproved HTTPS pack origin or redirect');
      }
      final request = http.Request('GET', current)..followRedirects = false;
      request.headers.addAll(headers);
      final response = await client.send(request)
          .timeout(const Duration(seconds: 25));
      if (<int>{301, 302, 303, 307, 308}.contains(response.statusCode)) {
        final location = response.headers[HttpHeaders.locationHeader];
        await response.stream.listen(null).cancel();
        if (location == null || redirect == 3) {
          throw const FormatException('Unsafe or excessive pack redirect');
        }
        current = current.resolve(location);
        continue;
      }
      return response;
    }
    throw const FormatException('Too many redirects');
  }

  static Future<Map<String, dynamic>> _fetchManifest(
    http.Client client, Uri manifestUri,
  ) async {
    final response = await _approvedGet(client, manifestUri);
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('Manifest HTTP ' + response.statusCode.toString(),
          uri: manifestUri);
    }
    const maxManifestBytes = 2 * 1024 * 1024;
    final bytes = BytesBuilder(copy: false);
    var received = 0;
    await for (final chunk in response.stream) {
      if (chunk.length > maxManifestBytes - received) {
        throw StateError('Manifest size exceeds bounded limit');
      }
      bytes.add(chunk);
      received += chunk.length;
    }
    final decoded = jsonDecode(utf8.decode(bytes.takeBytes()));
    if (decoded is! Map) {
      throw const FormatException('Pack manifest root must be an object');
    }
    final result = Map<String, dynamic>.from(decoded);
    if (result['schemaVersion'] != '2.0.0') {
      throw const FormatException('Unsupported manifest schema');
    }
    return result;
  }

  static Future<void> _downloadArchive({
    required http.Client client,
    required Uri uri,
    required File destination,
    required int expectedSizeBytes,
    required String expectedSha256,
    PackDownloadProgress? onProgress,
  }) async {
    if (expectedSizeBytes < 1 || expectedSizeBytes > maxCompressedPackBytes) {
      throw const FormatException('Archive exceeds storage budget');
    }
    await destination.parent.create(recursive: true);
    if (await destination.exists()) {
      final size = await destination.length();
      if (size > expectedSizeBytes) {
        await destination.delete();
      } else if (size == expectedSizeBytes) {
        if (_constantTimeHexEquals(
            await _sha256File(destination), expectedSha256)) return;
        await destination.delete();
      }
    }

    for (var attempt = 0; attempt < 2; attempt++) {
      final existing = await destination.exists()
          ? await destination.length() : 0;
      final response = await _approvedGet(client, uri, headers:
          existing > 0
              ? <String, String>{HttpHeaders.rangeHeader: 'bytes=$existing-'}
              : const <String, String>{});
      if (response.statusCode == HttpStatus.requestedRangeNotSatisfiable &&
          existing > 0 && attempt == 0) {
        await destination.delete();
        continue;
      }
      if (response.statusCode != HttpStatus.ok &&
          response.statusCode != HttpStatus.partialContent) {
        throw HttpException('Archive HTTP ' + response.statusCode.toString(),
            uri: uri);
      }
      if (response.statusCode == HttpStatus.partialContent) {
        final range = response.headers[HttpHeaders.contentRangeHeader];
        if (existing == 0 || range == null ||
            !range.startsWith('bytes $existing-')) {
          throw const FormatException('Mismatched resume content range');
        }
      }
      final append = existing > 0 &&
          response.statusCode == HttpStatus.partialContent;
      final offset = append ? existing : 0;
      final total = _resolveTotalBytes(response.headers, offset,
          response.contentLength, expectedSizeBytes);
      if (total != expectedSizeBytes) {
        throw const FormatException('Inconsistent manifest download size');
      }
      final sink = destination.openWrite(
          mode: append ? FileMode.append : FileMode.write);
      var received = offset;
      try {
        await for (final chunk in response.stream) {
          if (chunk.length > expectedSizeBytes - received ||
              chunk.length > maxCompressedPackBytes - received) {
            throw StateError('Compressed archive exceeded size limit');
          }
          sink.add(chunk);
          received += chunk.length;
          onProgress?.call(
              (received / expectedSizeBytes).clamp(0.0, 0.95).toDouble());
        }
        await sink.flush();
      } finally {
        await sink.close();
      }
      if (await destination.length() != expectedSizeBytes ||
          !_constantTimeHexEquals(
              await _sha256File(destination), expectedSha256)) {
        await destination.delete();
        throw StateError('Downloaded archive SHA-256 or size mismatch');
      }
      return;
    }
    throw StateError('Download retry exhausted');
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

  static Future<Uint8List> _extractSqliteBytes(
    File archive, _PackDescriptor descriptor,
  ) {
    // Expansion, JSON parsing and Base64 decoding do not block UI frames.
    // The isolate returns at most 32 MiB of SQLite bytes.
    final sourcePath = archive.path;
    return Isolate.run(() async {
      final expanded = await decodeGzipEnvelope(File(sourcePath).openRead());
      final decoded = jsonDecode(utf8.decode(expanded));
      if (decoded is! Map) {
        throw const FormatException('Envelope must be a JSON object');
      }
      final envelope = Map<String, dynamic>.from(decoded);
      if (envelope['packId'] != descriptor.id ||
          envelope['languageCode'] != descriptor.languageCode ||
          envelope['version'] != descriptor.version ||
          envelope['contractVersion'] != descriptor.contractVersion) {
        throw const FormatException('Envelope identity or version mismatch');
      }
      final rawFiles = envelope['files'];
      if (rawFiles is! List || rawFiles.length != 3) {
        throw const FormatException('Exactly three envelope files required');
      }
      final files = <String, String>{};
      for (final raw in rawFiles) {
        if (raw is! Map) {
          throw const FormatException('Malformed pack file entry');
        }
        final item = Map<String, dynamic>.from(raw);
        final name = item['path'];
        final encoded = item['contentBase64'];
        if (name is! String || encoded is! String ||
            files.containsKey(name)) {
          throw const FormatException('Duplicate or malformed pack file');
        }
        _validateEnvelopePath(name);
        files[name] = encoded;
      }
      const expected = <String>{
        'content/content.json', 'content/content.sqlite',
        'metadata/pack.json',
      };
      if (!files.keys.toSet().containsAll(expected) ||
          files.keys.toSet().difference(expected).isNotEmpty) {
        throw const FormatException('Mandatory envelope files missing');
      }

      Map<String, dynamic> metadata(String name) {
        final encoded = files[name]!;
        if (encoded.length > 1024 * 1024) {
          throw const FormatException('Envelope metadata too large');
        }
        final decoded = jsonDecode(utf8.decode(base64Decode(encoded)));
        if (decoded is! Map) {
          throw const FormatException('Invalid envelope metadata JSON');
        }
        return Map<String, dynamic>.from(decoded);
      }
      final contents = metadata('content/content.json');
      final pack = metadata('metadata/pack.json');
      if (contents['languageCode'] != descriptor.languageCode ||
          contents['version'] != descriptor.version ||
          pack['languageCode'] != descriptor.languageCode ||
          pack['version'] != descriptor.version ||
          pack['contractVersion'] != descriptor.contractVersion) {
        throw const FormatException('Pack metadata mismatch');
      }
      final encodedSqlite = files['content/content.sqlite']!;
      if (encodedSqlite.length > ((maxSqliteBytes + 2) ~/ 3) * 4) {
        throw const FormatException('SQLite Base64 exceeds size budget');
      }
      final sqlite = base64Decode(encodedSqlite);
      if (sqlite.isEmpty || sqlite.length > maxSqliteBytes) {
        throw const FormatException('SQLite payload exceeds size budget');
      }
      return sqlite;
    });
  }

  static void _validateEnvelopePath(String value) {
    if (value.startsWith('/') || value.contains('\\') ||
        value.split('/').any((part) =>
            part.isEmpty || part == '.' || part == '..')) {
      throw const FormatException('Unsafe envelope path');
    }
  }

  static Future<void> _verifySqlitePackage(
    File file, String languageCode,
  ) async {
    if (await file.length() > maxSqliteBytes) {
      throw const FormatException('SQLite exceeds maximum size');
    }
    final raf = await file.open(mode: FileMode.read);
    try {
      final header = await raf.read(16);
      if (header.length < 16 ||
          !String.fromCharCodes(header).startsWith('SQLite format 3')) {
        throw const FormatException('Missing SQLite header');
      }
    } finally {
      await raf.close();
    }

    final db = await openDatabase(
        file.path, readOnly: true, singleInstance: false);
    try {
      final integrity = await db.rawQuery('PRAGMA integrity_check');
      if (integrity.length != 1 ||
          integrity.first.values.first.toString().toLowerCase() != 'ok') {
        throw StateError('SQLite integrity check failed');
      }
      // Route 15 is the single schema admission authority.
      await DatabaseService.instance.verifyUniversalSchema(db, languageCode);
      final fts = await db.rawQuery(
        "SELECT sql FROM sqlite_master WHERE name='lexicon_fts' "
        "AND type='table' LIMIT 1",
      );
      if (fts.isEmpty ||
          !fts.first['sql'].toString().toLowerCase().contains('using fts5')) {
        throw StateError('FTS5 virtual table unavailable');
      }
      await db.rawQuery(
        'SELECT rowid FROM lexicon_fts WHERE lexicon_fts MATCH ? LIMIT 1',
        <Object?>['ws14nevermatches'],
      );
    } finally {
      await db.close();
    }
  }

  static Future<void> _installVerifiedArchive(
    String code, _PackDescriptor descriptor,
    File archive, Directory packsDir,
  ) async {
    if (await archive.length() != descriptor.archiveSizeBytes ||
        !_constantTimeHexEquals(
            await _sha256File(archive), descriptor.sha256)) {
      throw StateError('Staged archive fails size or SHA-256 check');
    }
    final sqlite = await _extractSqliteBytes(archive, descriptor);
    if (!_constantTimeHexEquals(
        sha256.convert(sqlite).toString(), descriptor.contentSha256)) {
      throw StateError('SQLite content SHA-256 mismatch');
    }
    final staged = File(path.join(packsDir.path, '.$code.sqlite.installing'));
    if (await staged.exists()) await staged.delete();
    try {
      await staged.writeAsBytes(sqlite, flush: true);
      await _verifySqlitePackage(staged, code);
      if (_cancelledDownloads.contains(code)) {
        throw StateError('Pack install cancelled before commit');
      }
      final target = File(path.join(packsDir.path, '$code.sqlite'));
      final backup = File(target.path + '.bak');
      // Close readers before touching a previously mounted content pack.
      await DatabaseService.instance.closeContentDb(code);
      // On restart after an interrupted update, prefer the prior pack.
      if (await backup.exists()) {
        final registry = await _readRegistry(packsDir);
        final packs = registry['packs'];
        final installed = packs is Map ? packs[code] : null;
        final activeSha = installed is Map ? installed['contentSha256'] : null;
        final isCommitted = await target.exists() &&
            activeSha is String &&
            _constantTimeHexEquals(await _sha256File(target), activeSha);
        if (isCommitted) {
          // Registry and new target agree; an obsolete backup may be removed.
          await backup.delete();
        } else {
          // Incomplete replacement: return to the last known good file.
          if (await target.exists()) await target.delete();
          await backup.rename(target.path);
        }
      }
      final hadPrevious = await target.exists();
      if (hadPrevious) await target.rename(backup.path);
      try {
        await staged.rename(target.path);
        if (_cancelledDownloads.contains(code)) {
          throw StateError('Pack install cancelled during commit');
        }
        await _upsertRegistryRecord(code, <String, dynamic>{
          'languageCode': code,
          'packId': descriptor.id,
          'version': descriptor.version,
          'contractVersion': descriptor.contractVersion,
          'bundleFormat': descriptor.bundleFormat,
          'archiveSha256': descriptor.sha256,
          'contentSha256': descriptor.contentSha256,
          'installedSizeBytes': await target.length(),
          'installedPath': target.path,
          'installedAt': DateTime.now().toUtc().toIso8601String(),
        }, packsDir);
      } catch (_) {
        if (await target.exists()) await target.delete();
        if (hadPrevious && await backup.exists()) {
          await backup.rename(target.path);
        }
        rethrow;
      }
      if (await backup.exists()) {
        try {
          await backup.delete();
        } catch (_) {
          // Keeping a backup is safer than failing an already committed pack.
        }
      }
    } finally {
      if (await staged.exists()) await staged.delete();
    }
  }

  @visibleForTesting
  static Future<bool> installArchiveFixtureForTesting({
    required String languageCode,
    required Map<String, dynamic> manifest,
    required File archive,
    required Directory packsDirectory,
  }) async {
    final code = _normalizeLanguageCode(languageCode);
    try {
      final descriptor = _PackDescriptor.fromManifest(
        manifest, code, Uri.parse(defaultManifestUrl),
      );
      await _installVerifiedArchive(code, descriptor, archive, packsDirectory);
      return true;
    } catch (_) {
      return false;
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
        try {
          await backup.delete();
        } catch (_) {
          // A committed registry should not be rolled back by cleanup failure.
        }
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

  static Future<File> _registryFile([Directory? root]) async {
    final directory = root ?? await _packsDirectory();
    return File(path.join(directory.path, 'registry.json'));
  }

  static Future<Map<String, dynamic>> _readRegistry([Directory? root]) async {
    final file = await _registryFile(root);
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
    Map<String, dynamic> record, [Directory? root]
  ) async {
    final registry = await _readRegistry(root);
    final packs = Map<String, dynamic>.from(
      registry['packs'] as Map? ?? <String, dynamic>{},
    );
    packs[languageCode] = record;
    registry['schemaVersion'] = 1;
    registry['packs'] = packs;
    await _writeRegistry(registry, root);
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

  static Future<void> _writeRegistry(Map<String, dynamic> registry, [Directory? root]) async {
    final file = await _registryFile(root);
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
  final String contentSha256;
  final int archiveSizeBytes;

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
    if (manifest['schemaVersion'] != '2.0.0') {
      throw const FormatException('Unsupported manifest schema');
    }
    final entries = manifest['packs'];
    if (entries is! List) {
      throw const FormatException('Missing production pack list');
    }
    Map<String, dynamic>? entry;
    for (final raw in entries) {
      if (raw is! Map) continue;
      final current = Map<String, dynamic>.from(raw);
      if (current['languageCode'] == languageCode) {
        if (entry != null) {
          throw const FormatException('Duplicate published language');
        }
        entry = current;
      }
    }
    if (entry == null) {
      throw StateError('BLOCKED_SOURCE: no production pack for language');
    }
    // Registration, archive existence, source approval and production
    // acceptance are separate gates. Never use legacy languages[] entries.
    if (entry['production_ready'] != true ||
        entry['pack_verified'] != true ||
        entry['content_available'] != true) {
      throw StateError('BLOCKED_SOURCE: source approval incomplete');
    }
    final id = entry['id'];
    final code = entry['languageCode'];
    final version = entry['version'];
    final contract = entry['contractVersion'];
    final format = entry['bundleFormat'];
    if (id is! String || id.isEmpty || code != languageCode ||
        version is! String ||
        !RegExp(r'^[0-9]+\.[0-9]+\.[0-9]+$').hasMatch(version) ||
        contract != '1.0.0' ||
        format != PackDownloaderService._bundleFormat) {
      throw const FormatException('Invalid SQLite v2 manifest identity');
    }
    final source = entry['archiveUrl'];
    if (source is! String) {
      throw const FormatException('Missing archive URL');
    }
    final uri = Uri.parse(source);
    if (!PackDownloaderService._approvedUri(uri)) {
      throw const FormatException('Pack URL origin is not approved');
    }
    final archiveSha = entry['sha256'];
    final contentSha = entry['contentSha256'];
    if (archiveSha is! String ||
        !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(archiveSha) ||
        contentSha is! String ||
        !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(contentSha)) {
      throw const FormatException('Manifest is missing SHA-256 values');
    }
    final size = entry['archiveSizeBytes'];
    if (size is! int || size < 1 ||
        size > PackDownloaderService.maxCompressedPackBytes) {
      throw const FormatException('Invalid bounded archive size');
    }
    return _PackDescriptor(
      id: id, languageCode: code as String, version: version,
      contractVersion: contract as String, bundleFormat: format as String,
      archiveUri: uri, sha256: archiveSha.toLowerCase(),
      contentSha256: contentSha.toLowerCase(),
      archiveSizeBytes: size,
    );
  }
}
