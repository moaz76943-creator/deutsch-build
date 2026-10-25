// ignore_for_file: unused_import
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../core/storage/pack_admission_service.dart';
import '../core/storage/storage_quarantine.dart';
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
  static final Map<String, PackDownloadState> _downloadStates = {};
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

        final request = http.Request('GET', Uri.parse(url));
        request.headers.addAll(headers);

        late http.StreamedResponse response;
        try {
          response = await httpClient.send(request);
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

        _activeSubscriptions[languageCode] = response.stream.listen((chunk) {
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

        final success = await completer.future;
        _activeSubscriptions.remove(languageCode);
        _activeCompleters.remove(languageCode);

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
}
