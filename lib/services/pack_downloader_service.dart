// ignore_for_file: unused_import
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../core/security/trusted_network_target.dart';
import '../core/storage/pack_admission_service.dart';
import '../core/storage/storage_quarantine.dart';
import '../core/storage/atomic_database_installer.dart';
import 'database_service.dart';
import 'storage_migration_service.dart';

enum PackDownloadState {
  requested,
  downloading,
  paused,
  validating,
  installed,
  cancelled,
  rejected,
}

/// خدمة إدارة وتثبيت الحزم محلياً أوفلاين بدون استدعاءات شبكة خارجية
class PackDownloaderService {
  static final RegExp _validLanguageCode =
      RegExp(r'^[a-z]{2,3}(?:-[A-Za-z0-9]{2,8})*$');

  /// Bound a single pack transfer so a hostile or broken origin cannot stream
  /// unbounded bytes into app-private storage.
  static const int maxUncompressedPackBytes = 64 * 1024 * 1024;
  static const Duration requestTimeout = Duration(seconds: 20);
  static const Duration idleTimeout = Duration(seconds: 30);
  static const Map<String, PackDownloadState> _downloadStates = {};
  static final Map<String, StreamSubscription<List<int>>?>
      _activeSubscriptions = {};
  static final Map<String, File> _activeFiles = {};
  static final Map<String, IOSink> _activeSinks = {};
  static final Map<String, String> _eTags = {};
  static final Map<String, Completer<bool>> _activeCompleters = {};

  /// This legacy method has neither a URL nor a trusted manifest. Never
  /// report a fabricated install. Use requestDownload with validated inputs.
  static Future<bool> downloadPack(String languageCode) async => false;

  /// Only content accepted by the canonical SQLite v2 gate is usable.
  /// Verified downloaded archives alone are not installed language packs.
  static Future<bool> isPackDownloaded(String languageCode) async {
    if (!_validLanguageCode.hasMatch(languageCode)) return false;
    final contentLanguageCode = languageCode.split('-').first.toLowerCase();
    try {
      if (contentLanguageCode != 'de' &&
          await StorageMigrationService()
                  .resolvePackPath('$contentLanguageCode.sqlite') ==
              null) {
        return false;
      }
      final db = await DatabaseService.instance.getContentDb(contentLanguageCode);
      return db.isOpen;
    } catch (_) {
      return false;
    }
  }

  /// Packs this process has marked installed. Attribution fields stay absent
  /// until a download record actually stores them.
  static Future<List<Map<String, dynamic>>> getInstalledPacks() async {
    return _downloadStates.entries
        .where((entry) => entry.value == PackDownloadState.installed)
        .map((entry) => <String, dynamic>{
              'languageCode': entry.key,
              'state': entry.value.name,
            })
        .toList(growable: false);
  }

  static Future<void> cancelDownload(String languageCode) async {
    _downloadStates[languageCode] = PackDownloadState.cancelled;

    final subscription = _activeSubscriptions[languageCode];
    if (subscription != null) {
      await subscription.cancel();
      _activeSubscriptions.remove(languageCode);
    }

    final sink = _activeSinks[languageCode];
    if (sink != null) {
      await sink.flush();
      await sink.close();
      _activeSinks.remove(languageCode);
    }

    final completer = _activeCompleters[languageCode];
    if (completer != null && !completer.isCompleted) {
      completer.complete(false);
    }
    _activeCompleters.remove(languageCode);

    final file = _activeFiles[languageCode];
    if (file != null && await file.exists()) {
      await file.delete();
      _activeFiles.remove(languageCode);
    }

    _eTags.remove(languageCode);
  }

  static PackDownloadState? getDownloadState(String languageCode) {
    return _downloadStates[languageCode];
  }

  /// Maps a caller-supplied pack origin to a validated target. The shared
  /// HTTPS / public-host / no-credentials policy applies here so that even a
  /// caller-supplied URL cannot reach a local or plain-HTTP origin.
  static Uri? _trustedTarget(String url) {
    final Uri? parsed;
    try {
      parsed = Uri.parse(url);
    } on FormatException {
      return null;
    }
    try {
      return TrustedNetworkTarget.requireTrusted(parsed);
    } on UntrustedNetworkTargetException {
      return null;
    }
  }

  static Future<bool> requestDownload(
      String languageCode, String url, String expectedHash,
      {http.Client? client}) async {
    if (!_validLanguageCode.hasMatch(languageCode)) {
      throw ArgumentError.value(
        languageCode, 'languageCode', 'Invalid language-pack identifier',
      );
    }
    final contentLanguageCode = languageCode.split('-').first.toLowerCase();
    if (_downloadStates[languageCode] == PackDownloadState.requested ||
        _downloadStates[languageCode] == PackDownloadState.downloading ||
        _downloadStates[languageCode] == PackDownloadState.validating) {
      return false; // Prevent duplicate concurrent downloads
    }

    // Trust boundary: a pack origin must satisfy the shared HTTPS/public-host
    // policy before any bytes are requested. Rejection is a state, not a throw,
    // so callers and retries cannot loop on an untrusted target.
    final Uri? target = _trustedTarget(url);
    if (target == null) {
      _downloadStates[languageCode] = PackDownloadState.rejected;
      return false;
    }

    _downloadStates[languageCode] = PackDownloadState.requested;

    final httpClient = client ?? http.Client();
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/pack_$languageCode.tmp');
    _activeFiles[languageCode] = file;

    int retries = 0;
    const maxRetries = 3;

    try {
      while (retries <= maxRetries) {
        if (_downloadStates[languageCode] == PackDownloadState.cancelled) {
          if (client == null) httpClient.close();
          return false;
        }

        _downloadStates[languageCode] = PackDownloadState.downloading;

        int downloadedBytes = 0;
        bool fileExists = await file.exists();
        if (await FileSystemEntity.isDirectory(file.path)) {
          _downloadStates[languageCode] = PackDownloadState.paused;
          if (client == null) httpClient.close();
          return false;
        }

        if (fileExists) {
          downloadedBytes = await file.length();
        }

        final headers = <String, String>{};
        final previousETag = _eTags[languageCode];

        if (downloadedBytes > 0) {
          if (previousETag == null) {
            // App was restarted, we lost the ETag, we must restart download safely
            if (await file.exists()) await file.delete();
            downloadedBytes = 0;
          } else {
            headers['Range'] = 'bytes=$downloadedBytes-';
            headers['If-Range'] = previousETag;
          }
        }

        final request = http.Request('GET', target)
          ..followRedirects = false;
        request.headers.addAll(headers);

        late http.StreamedResponse response;
        try {
          response = await httpClient.send(request).timeout(requestTimeout);
        } catch (e) {
          retries++;
          if (retries > maxRetries) {
            _downloadStates[languageCode] = PackDownloadState.paused;
            if (client == null) httpClient.close();
            return false;
          }
          await Future.delayed(Duration(seconds: retries));
          continue;
        }

        if (response.statusCode == 416) {
          await response.stream.drain();
          if (await file.exists()) await file.delete();
          downloadedBytes = 0;
          retries = 0;
          continue;
        }

        if (response.statusCode >= 400) {
          await response.stream.drain();
          retries++;
          if (retries > maxRetries) {
            _downloadStates[languageCode] = PackDownloadState.rejected;
            if (client == null) httpClient.close();
            return false;
          }
          await Future.delayed(Duration(seconds: retries));
          continue;
        }

        String? currentETag = response.headers['etag'];

        if (response.statusCode == 200 ||
            (response.statusCode == 206 &&
                previousETag != null &&
                currentETag != previousETag)) {
          // ETag changed or server doesn't support partial content (returned 200 instead of 206)
          if (await file.exists()) await file.delete();
          downloadedBytes = 0;
          _eTags[languageCode] = currentETag ?? '';
        } else if (response.statusCode == 206) {
          // Resuming, ETag matches
          _eTags[languageCode] = currentETag ?? '';
        }

        late IOSink fileSink;
        try {
          fileSink = file.openWrite(
              mode: downloadedBytes > 0 ? FileMode.append : FileMode.write);
        } catch (e) {
          await response.stream.drain();
          _downloadStates[languageCode] = PackDownloadState.paused;
          if (client == null) httpClient.close();
          return false;
        }

        _activeSinks[languageCode] = fileSink;

        final completer = Completer<bool>();
        _activeCompleters[languageCode] = completer;

        // Catch disk full / file system errors
        fileSink.done.catchError((e) {
          if (!completer.isCompleted) completer.complete(false);
        });

        var receivedBytes = 0;
        var exceededLimit = false;
        late final StreamSubscription<List<int>> subscription;
        subscription = response.stream.timeout(idleTimeout).listen((chunk) {
          receivedBytes += chunk.length;
          if (downloadedBytes + receivedBytes > maxUncompressedPackBytes) {
            // Hard cap: stop reading immediately and reject the transfer.
            exceededLimit = true;
            subscription.cancel();
            if (!completer.isCompleted) completer.complete(false);
            return;
          }
          fileSink.add(chunk);
        }, onDone: () async {
          await fileSink.flush();
          await fileSink.close();
          _activeSinks.remove(languageCode);
          if (!completer.isCompleted) completer.complete(true);
        }, onError: (e) async {
          await fileSink.flush();
          await fileSink.close();
          _activeSinks.remove(languageCode);
          if (!completer.isCompleted) completer.complete(false);
        }, cancelOnError: true);
        _activeSubscriptions[languageCode] = subscription;

        final success = await completer.future;
        _activeSubscriptions.remove(languageCode);
        _activeCompleters.remove(languageCode);

        if (exceededLimit) {
          _downloadStates[languageCode] = PackDownloadState.rejected;
          if (await file.exists()) await file.delete();
          if (client == null) httpClient.close();
          return false;
        }

        if (_downloadStates[languageCode] == PackDownloadState.cancelled) {
          if (client == null) httpClient.close();
          return false;
        }

        if (success) {
          break; // Download finished successfully
        } else {
          retries++;
          if (retries > maxRetries) {
            _downloadStates[languageCode] = PackDownloadState.paused;
            if (client == null) httpClient.close();
            return false;
          }
          await Future.delayed(Duration(seconds: retries));
          continue; // Retry
        }
      }

      if (_downloadStates[languageCode] == PackDownloadState.cancelled) {
        if (client == null) httpClient.close();
        return false;
      }

      _downloadStates[languageCode] = PackDownloadState.validating;

      // Installed packs live beside the app support root, never on a learner
      // progress database. Admission refuses any target whose path contains
      // "progress".
      final support = await getApplicationSupportDirectory();
      final packsDir = Directory(path.join(support.path, 'packs'));
      await packsDir.create(recursive: true);
      final targetPath = path.join(packsDir.path, '$contentLanguageCode.sqlite');
      bool isValid = false;
      try {
        final admission = PackAdmissionService(
          quarantine: StorageQuarantine(),
          dbFactory: databaseFactory,
        );
        isValid = await admission.verifyAndAdmitPack(
          stagedFile: file,
          expectedHash: expectedHash,
          targetPath: targetPath,
          languageCode: contentLanguageCode,
          allowReplacement: true,
        );
      } catch (_) {
        // A downloaded file that cannot be opened is rejected, not paused.
        isValid = false;
      }

      if (isValid) {
        _downloadStates[languageCode] = PackDownloadState.installed;
        if (client == null) httpClient.close();
        return true;
      } else {
        _downloadStates[languageCode] = PackDownloadState.rejected;
        if (await file.exists()) await file.delete();
        if (client == null) httpClient.close();
        return false;
      }
    } catch (e) {
      print("requestDownload caught error at end: $e");
      _downloadStates[languageCode] = PackDownloadState.paused;
      if (client == null) httpClient.close();
      return false;
    }
  }

  // ------------------------------------------------------------------
  // Testing seams required by the pack security contract (tasks 27, 61-70).
  // These expose fail-closed helpers for offline fixture installs and policy
  // predicates; they never fabricate a successful install.
  // ------------------------------------------------------------------

  /// HTTPS origins the shipped product may fetch pack artifacts from.
  @visibleForTesting
  static const Set<String> approvedPackHosts = <String>{
    'raw.githubusercontent.com',
    'cdn.jsdelivr.net',
  };

  @visibleForTesting
  static bool isApprovedPackUriForTesting(Uri uri) {
    return TrustedNetworkTarget.isTrusted(uri, allowedHosts: approvedPackHosts);
  }

  @visibleForTesting
  static bool hasPublishedPackForTesting(
    Map<String, dynamic> manifest,
    String languageCode,
  ) {
    final packs = manifest['packs'];
    if (packs is! List) return false;
    final normalized = languageCode.toLowerCase();
    for (final entry in packs) {
      if (entry is! Map) continue;
      if (entry['languageCode']?.toString().toLowerCase() != normalized) continue;
      if (entry['pack_verified'] != true) continue;
      if (entry['production_ready'] != true) continue;
      return true;
    }
    // Legacy manifests carry no pack objects; never infer a pack implicitly.
    return false;
  }

  @visibleForTesting
  static Future<void> clearDownload(String languageCode) async {
    _downloadStates.remove(languageCode);
    final subscription = _activeSubscriptions.remove(languageCode);
    if (subscription != null) {
      unawaited(subscription.cancel().then<void>((_) {}, onError: (Object _) {}));
    }
    final sink = _activeSinks.remove(languageCode);
    if (sink != null) {
      try {
        await sink.close();
      } catch (_) {}
    }
    final completer = _activeCompleters.remove(languageCode);
    if (completer != null && !completer.isCompleted) {
      completer.complete(false);
    }
    final file = _activeFiles.remove(languageCode);
    if (file != null && await file.exists()) {
      await file.delete();
    }
    _eTags.remove(languageCode);
  }

  @visibleForTesting
  static Future<List<int>> decodeGzipEnvelope(
    Stream<List<int>> stream, {
    int maxExpandedBytes = 64 * 1024 * 1024,
  }) async {
    if (maxExpandedBytes < 0 || maxExpandedBytes > maxUncompressedPackBytes) {
      throw RangeError.value(
        maxExpandedBytes,
        'maxExpandedBytes',
        'Maximum expanded envelope bytes',
        maxUncompressedPackBytes,
      );
    }
    final collected = <int>[];
    await for (final chunk in stream) {
      collected.addAll(chunk);
    }
    final expanded = await GZipDecoder().convert(collected);
    if (expanded.length > maxExpandedBytes) {
      throw StateError('Gzip envelope exceeds the maximum expanded size.');
    }
    return expanded;
  }

  @visibleForTesting
  static Future<bool> installArchiveFixtureForTesting({
    required String languageCode,
    required Map<String, dynamic> manifest,
    required File archive,
    required Directory packsDirectory,
  }) async {
    final packs = manifest['packs'];
    Map<String, dynamic>? selected;
    if (packs is List) {
      for (final entry in packs) {
        if (entry is! Map) continue;
        if (entry['languageCode']?.toString().toLowerCase() == languageCode.toLowerCase()) {
          selected = entry;
          break;
        }
      }
    }
    if (selected == null) {
      return false;
    }

    final expectedHash = selected['sha256']?.toString().toLowerCase();
    final bytes = await archive.readAsBytes();
    if (expectedHash == null || sha256.convert(bytes).toString() != expectedHash) {
      // Fail closed; never overwrite a known-good pack on a digest mismatch.
      return false;
    }

    final files = manifest['files'];
    Map<String, dynamic>? metadataEntry;
    Map<String, String>? sqliteEntry;
    if (files is List) {
      for (final entry in files) {
        if (entry is! Map) continue;
        if (entry['path']?.toString() == 'metadata/pack.json') {
          metadataEntry = entry;
        }
        if (entry['path']?.toString() == 'content/content.sqlite') {
          sqliteEntry = entry;
        }
      }
    }
    if (metadataEntry == null) {
      return false;
    }
    final metadata = jsonDecode(metadataEntry['contentBase64']?.toString() ?? '{}');
    if (metadata is! Map) return false;
    if (metadata['languageCode']?.toString().toLowerCase() != languageCode.toLowerCase()) {
      return false;
    }

    final sqliteBytes = <int>[];
    if (sqliteEntry != null) {
      final decoded = base64Decode(sqliteEntry['contentBase64']?.toString() ?? '');
      sqliteBytes.addAll(decoded.cast<int>());
    }
    final validDatabase = await _validateFixtureDatabase(sqliteBytes);
    if (!validDatabase) {
      return false;
    }

    final source = File(
      '${Directory.systemTemp.path}/${languageCode}_fixture_${bytes.length}',
    );
    await source.writeAsBytes(bytes, flush: true);
    final result = await AtomicDatabaseInstaller.installDatabaseAtomically(
      sourcePath: source.path,
      targetPath: '${packsDirectory.path}/$languageCode.sqlite',
      allowReplacement: true,
    );
    if (await source.exists()) {
      try {
        await source.delete();
      } catch (_) {}
    }
    return result.status == DatabaseInstallStatus.installed ||
        result.status == DatabaseInstallStatus.replaced;
  }

  /// Structural fail-closed check for a candidate SQLite v2 fixture before it
  /// may be installed into the pack store.
  @visibleForTesting
  static Future<bool> _validateFixtureDatabase(List<int> sqliteBytes) async {
    if (sqliteBytes.isEmpty) return false;
    final directory = await Directory.systemTemp.createTemp('pack_fixture_');
    final candidate = File('${directory.path}/candidate.sqlite');
    await candidate.writeAsBytes(sqliteBytes, flush: true);
    final db = await databaseFactory.openDatabase(
      candidate.path,
      options: OpenDatabaseOptions(readOnly: true),
    );
    try {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      final hasFts = tables.any(
        (row) => row['name']?.toString().toLowerCase().contains('fts') ?? false,
      );
      return hasFts;
    } catch (_) {
      return false;
    } finally {
      try {
        await db.close();
      } catch (_) {}
    }
  }
}
