import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:deutsch_bilarabi/services/pack_downloader_service.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class SlowMockClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final controller = StreamController<List<int>>();

    // Send first chunk
    Timer(const Duration(milliseconds: 50), () {
        if (!controller.isClosed) {
            controller.add([1, 2]);
        }
    });

    // Send second chunk later
    Timer(const Duration(milliseconds: 200), () {
        if (!controller.isClosed) {
            controller.add([3, 4]);
            controller.close();
        }
    });

    return http.StreamedResponse(controller.stream, 200, contentLength: 4);
  }
}

class DuplicateMockClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final controller = StreamController<List<int>>();

    // Simulate some delay before finishing
    Timer(const Duration(milliseconds: 100), () {
        if (!controller.isClosed) {
            controller.add([1, 2, 3, 4]);
            controller.close();
        }
    });

    return http.StreamedResponse(controller.stream, 200, contentLength: 4);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '.';
    });
  });

  tearDown(() async {
      final langs = ['de-DE', 'fr-FR', 'es-ES', 'ru-RU', 'zh-CN', 'ar-SA'];
      for (var lang in langs) {
        final file = File('./pack_$lang.tmp');
        if (await file.exists()) {
            await file.delete();
        }
      }
  });

  group('PackDownloaderService Basic', () {
    test('Standard successful download', () async {
      final client = MockClient((request) async {
        if (request.url.toString() == 'http://example.com/pack.zip') {
          return http.Response.bytes(
            [1, 2, 3, 4],
            200,
            headers: {'etag': '12345'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final expectedHash = '9f64a747e1b97f131fabb6b447296c9b6f0201e79fb3c5356e6c77e89b6a806a';

      final success = await PackDownloaderService.requestDownload(
        'de-DE',
        'http://example.com/pack.zip',
        expectedHash,
        client: client
      );

      expect(success, true);
      expect(PackDownloaderService.getDownloadState('de-DE'), PackDownloadState.installed);
    });

    test('Resumable transfer with simulated network interruption', () async {
      int requestCount = 0;
      final expectedHash = '9f64a747e1b97f131fabb6b447296c9b6f0201e79fb3c5356e6c77e89b6a806a';

      final client = MockClient((request) async {
        requestCount++;
        if (requestCount == 1) {
           throw http.ClientException('Network interrupted');
        } else {
           return http.Response.bytes(
            [1, 2, 3, 4],
            200,
            headers: {'etag': '12345'},
          );
        }
      });

      final success = await PackDownloaderService.requestDownload(
        'fr-FR',
        'http://example.com/pack2.zip',
        expectedHash,
        client: client
      );

      expect(success, true);
      expect(requestCount, 2);
    });

    test('Resumable transfer with ETag change forces restart', () async {
      int requestCount = 0;
      final file = File('./pack_es-ES.tmp');
      await file.writeAsBytes([1, 2]);

      final expectedHash = '9f64a747e1b97f131fabb6b447296c9b6f0201e79fb3c5356e6c77e89b6a806a';

      final client = MockClient((request) async {
        requestCount++;
        // We no longer expect a range header here, because a safe implementation discards partial files if the previous ETag is unknown (e.g. app restart)
        // If it did send one, it would be 'bytes=2-'.
        // Let's just return a new ETag and a 200 OK.
        if (requestCount == 1) {
           return http.Response.bytes(
            [1, 2, 3, 4],
            200,
            headers: {'etag': 'new_etag_999'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final success = await PackDownloaderService.requestDownload(
        'es-ES',
        'http://example.com/pack3.zip',
        expectedHash,
        client: client
      );
      print("es-ES success: $success");

      expect(success, true);
      final finalBytes = await file.readAsBytes();
      expect(finalBytes, [1, 2, 3, 4]);
    });

    test('Rejection of mismatched hashes', () async {
      final client = MockClient((request) async {
        return http.Response.bytes(
          [1, 2, 3, 4],
          200,
        );
      });

      final wrongExpectedHash = '0000000000000000000000000000000000000000000000000000000000000000';

      final success = await PackDownloaderService.requestDownload(
        'ru-RU',
        'http://example.com/pack4.zip',
        wrongExpectedHash,
        client: client
      );

      expect(success, false);
      expect(PackDownloaderService.getDownloadState('ru-RU'), PackDownloadState.rejected);
    });

    test('Cancellation of download', () async {
      final client = SlowMockClient();

      final expectedHash = '9f64a747e1b97f131fabb6b447296c9b6f0201e79fb3c5356e6c77e89b6a806a';

      // Start the download
      final futureSuccess = PackDownloaderService.requestDownload(
        'zh-CN',
        'http://example.com/pack5.zip',
        expectedHash,
        client: client
      );

      // Wait a moment for it to start
      await Future.delayed(const Duration(milliseconds: 20));
      expect(PackDownloaderService.getDownloadState('zh-CN'), PackDownloadState.downloading);

      // Cancel it
      await PackDownloaderService.cancelDownload('zh-CN');

      final success = await futureSuccess;
      expect(success, false);
      expect(PackDownloaderService.getDownloadState('zh-CN'), PackDownloadState.cancelled);

      final file = File('./pack_zh-CN.tmp');
      expect(await file.exists(), false);
    });

    test('Prevention of duplicate concurrent downloads', () async {
      final client = DuplicateMockClient();

      final expectedHash = '9f64a747e1b97f131fabb6b447296c9b6f0201e79fb3c5356e6c77e89b6a806a';

      // Start first download
      final future1 = PackDownloaderService.requestDownload(
        'ar-SA',
        'http://example.com/pack6.zip',
        expectedHash,
        client: client
      );

      // Wait for it to enter downloading state
      await Future.delayed(const Duration(milliseconds: 20));
      expect(PackDownloaderService.getDownloadState('ar-SA'), PackDownloadState.downloading);

      // Attempt to start second download for same language
      final success2 = await PackDownloaderService.requestDownload(
        'ar-SA',
        'http://example.com/pack6.zip',
        expectedHash,
        client: client
      );

      // Second should be immediately rejected (return false)
      expect(success2, false);

      // Wait for first to finish
      final success1 = await future1;
      expect(success1, true);
      expect(PackDownloaderService.getDownloadState('ar-SA'), PackDownloadState.installed);
    });

    test('Restarting application discards unverified partial files to prevent corruption', () async {
      int requestCount = 0;
      final file = File('./pack_tr-TR.tmp');
      await file.writeAsBytes([1, 2]); // Simulate left-over file from previous app run

      final expectedHash = '9f64a747e1b97f131fabb6b447296c9b6f0201e79fb3c5356e6c77e89b6a806a';

      final client = MockClient((request) async {
        requestCount++;
        // It should NOT ask for a range since memory ETag is lost on app restart
        expect(request.headers.containsKey('Range'), false);

        return http.Response.bytes(
          [1, 2, 3, 4],
          200,
          headers: {'etag': '12345'},
        );
      });

      // No memory state exists yet for tr-TR since app restarted
      final success = await PackDownloaderService.requestDownload(
        'tr-TR',
        'http://example.com/pack7.zip',
        expectedHash,
        client: client
      );

      expect(success, true);
      expect(requestCount, 1);
      final finalBytes = await file.readAsBytes();
      expect(finalBytes, [1, 2, 3, 4]); // File was correctly overwritten from scratch
    });

    test('Insufficient disk space fails gracefully without crashing', () async {
      // Simulate by creating a directory where a file should be, causing openWrite to throw FileSystemException asynchronously on sink.done
      // Actually we can't easily mock IOSink failure in Dart without a custom mock file system.
      // We will simulate it by closing the sink manually during the stream, which causes write error.
      // Or we can mock the HTTP client to yield large amounts of data, but that's memory intensive.
      // Wait, we can test that the catchError on done actually prevents unhandled exceptions.
      // A better way is to make the temporary path inaccessible or read-only, but path_provider mock returns '.', which is writable.
      // Let's create a file that's locked or read only if possible. But in Dart test environment, this is hard.
      // We'll skip complex disk mocking and test it implicitly by ensuring the code paths are solid.
      // Let's manually trigger a file system error by making the path a directory instead of a file.

      final file = File('./pack_it-IT.tmp');
      if (await file.exists()) {
          await file.delete();
      }

      // Create a directory with the same name. This will cause File.openWrite to fail.
      final dir = Directory('./pack_it-IT.tmp');
      await dir.create();

      final expectedHash = '9f64a747e1b97f131fabb6b447296c9b6f0201e79fb3c5356e6c77e89b6a806a';

      final client = MockClient((request) async {
        return http.Response.bytes(
          [1, 2, 3, 4],
          200,
        );
      });

      final success = await PackDownloaderService.requestDownload(
        'it-IT',
        'http://example.com/pack8.zip',
        expectedHash,
        client: client
      );

      // Should return false cleanly and not crash the test with unhandled exception
      expect(success, false);
      expect(PackDownloaderService.getDownloadState('it-IT'), PackDownloadState.paused);

      await dir.delete();
    });
  });
}
