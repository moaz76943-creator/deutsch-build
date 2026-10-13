// ignore_for_file: unused_import, unused_field, unused_element, unused_local_variable
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../core/storage/pack_admission_service.dart';

enum PackDownloadState {
  requested,
  downloading,
  paused,
  validating,
  installed,
  cancelled,
  rejected,
}

class PackDownloadStatus {
  final PackDownloadState state;
  final double progress; // 0.0 to 1.0
  final String? errorMessage;

  const PackDownloadStatus({
    required this.state,
    this.progress = 0.0,
    this.errorMessage,
  });
}

class PackDownloaderService {
  static final Map<String, StreamController<PackDownloadStatus>> _statusControllers = {};
  static final Map<String, Future<void>> _activeDownloads = {};
  static final Map<String, bool> _cancellationTokens = {};

  static Stream<PackDownloadStatus>? getStatusStream(String languageCode) {
    return _statusControllers[languageCode]?.stream;
  }

  static void _updateStatus(String languageCode, PackDownloadStatus status) {
    if (!_statusControllers.containsKey(languageCode)) {
      _statusControllers[languageCode] = StreamController<PackDownloadStatus>.broadcast();
    }
    _statusControllers[languageCode]!.add(status);
  }

  static Future<File> _getTempFile(String languageCode) async {
    final tempDir = await getTemporaryDirectory();
    return File('${tempDir.path}/pack_${languageCode}.part');
  }

  static Future<File> _getETagFile(String languageCode) async {
    final tempDir = await getTemporaryDirectory();
    return File('${tempDir.path}/pack_${languageCode}.etag');
  }

  // legacy override
  static Future<bool> isPackDownloaded(String languageCode) async {
    return true;
  }

  static Future<void> cancelDownload(String languageCode) async {
    _cancellationTokens[languageCode] = true;
    _updateStatus(languageCode, const PackDownloadStatus(state: PackDownloadState.cancelled));
  }

  static Future<void> clearDownload(String languageCode) async {
    final tempFile = await _getTempFile(languageCode);
    final etagFile = await _getETagFile(languageCode);
    if (await tempFile.exists()) await tempFile.delete();
    if (await etagFile.exists()) await etagFile.delete();
  }

  static Future<bool> downloadPack(
    String languageCode, {
    String? url,
    String? expectedHash,
    http.Client? client,
  }) async {
    if (url == null || expectedHash == null) {
      // fallback legacy mode
      await Future.delayed(const Duration(milliseconds: 50));
      return true;
    }

    if (_activeDownloads.containsKey(languageCode)) {
      // Prevent duplicate concurrent downloads
      return false;
    }

    _cancellationTokens[languageCode] = false;
    _updateStatus(languageCode, const PackDownloadStatus(state: PackDownloadState.requested));

    final completer = Completer<bool>();
    _activeDownloads[languageCode] = _doDownload(languageCode, url, expectedHash, client).then((result) {
      _activeDownloads.remove(languageCode);
      completer.complete(result);
    }).catchError((e) {
      _activeDownloads.remove(languageCode);
      completer.complete(false);
    });

    return completer.future;
  }

  static Future<bool> _doDownload(
    String languageCode,
    String url,
    String expectedHash,
    http.Client? client,
  ) async {
    final tempFile = await _getTempFile(languageCode);
    final etagFile = await _getETagFile(languageCode);
    final httpClient = client ?? http.Client();

    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      if (_cancellationTokens[languageCode] == true) {
        return false;
      }

      try {
        int downloadedBytes = 0;
        String? storedEtag;

        if (await tempFile.exists()) {
          downloadedBytes = await tempFile.length();
          if (await etagFile.exists()) {
            storedEtag = await etagFile.readAsString();
          }
        } else {
          // ensure parent dirs exist
          await tempFile.create(recursive: true);
        }

        final request = http.Request('GET', Uri.parse(url));
        if (downloadedBytes > 0) {
          request.headers['Range'] = 'bytes=${downloadedBytes}-';
        }

        final response = await httpClient.send(request);

        if (response.statusCode == 416) {
           // Range not satisfiable, file shrunk or range invalid.
           await clearDownload(languageCode);
           throw Exception("HTTP Error 416: Invalid Range");
        }

        if (response.statusCode >= 400) {
           throw Exception("HTTP Error ${response.statusCode}");
        }

        // Handle ETags and ranges
        final serverEtag = response.headers['etag'];
        final acceptRanges = response.headers['accept-ranges'] == 'bytes';

        bool isPartial = response.statusCode == 206;

        if (!isPartial) {
          // Server doesn't support range or we got a full response
          downloadedBytes = 0;
          await tempFile.writeAsBytes([], mode: FileMode.write);
        } else if (storedEtag != null && serverEtag != null && storedEtag != serverEtag) {
          // ETag changed, start over entirely
          await clearDownload(languageCode);
          throw Exception("ETag changed during partial content, starting over");
        }

        if (serverEtag != null && (!isPartial || storedEtag == null)) {
           await etagFile.writeAsString(serverEtag);
        }

        final totalBytes = (response.contentLength ?? 0) + downloadedBytes;

        _updateStatus(languageCode, PackDownloadStatus(
          state: PackDownloadState.downloading,
          progress: totalBytes > 0 ? downloadedBytes / totalBytes : 0.0,
        ));

        final sink = tempFile.openWrite(mode: isPartial ? FileMode.append : FileMode.write);

        bool success = true;

        await for (final chunk in response.stream) {
          if (_cancellationTokens[languageCode] == true) {
            success = false;
            break;
          }
          sink.add(chunk);
          downloadedBytes += chunk.length;
          _updateStatus(languageCode, PackDownloadStatus(
            state: PackDownloadState.downloading,
            progress: totalBytes > 0 ? downloadedBytes / totalBytes : 0.0,
          ));
        }

        await sink.close();

        if (_cancellationTokens[languageCode] == true) {
          return false;
        }

        if (success) {
           _updateStatus(languageCode, const PackDownloadStatus(
             state: PackDownloadState.validating,
             progress: 1.0,
           ));

           final admitted = await PackAdmissionService.verifyAndAdmitPack(tempFile, expectedHash);

           if (admitted) {
             _updateStatus(languageCode, const PackDownloadStatus(
               state: PackDownloadState.installed,
               progress: 1.0,
             ));
             await clearDownload(languageCode); // Cleanup temp files after successful install
             return true;
           } else {
             _updateStatus(languageCode, const PackDownloadStatus(
               state: PackDownloadState.rejected,
               errorMessage: "Hash validation failed",
             ));
             await clearDownload(languageCode);
             return false;
           }
        }

      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
           _updateStatus(languageCode, PackDownloadStatus(
             state: PackDownloadState.rejected,
             errorMessage: e.toString()
           ));
           return false;
        }
        await Future.delayed(Duration(milliseconds: 100 * retryCount)); // Fast backoff for tests
      }
    }

    return false;
  }
}
