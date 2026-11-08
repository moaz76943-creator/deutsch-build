import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as path;

import 'package:deutsch_bilarabi/services/pack_downloader_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('j015_tests_');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationSupportDirectory') {
          return tempDir.path;
        }
        return null;
      },
    );
  });

  tearDown(() async {
    await PackDownloaderService.cancelDownload('de');
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('J015 - Optional Language Pack Acquisition & Resume', () {
    test('requestDownload handles failed connection', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final result = await PackDownloaderService.requestDownload(
        'de',
        'http://example.com/pack.sqlite',
        'fakehash',
        client: mockClient,
      );

      expect(result, isFalse);
      expect(
        PackDownloaderService.getDownloadState('de'),
        PackDownloadState.rejected,
      );
    });

    test('requestDownload handles changed ETag and restarts', () async {
      int requestCount = 0;
      final file = File(path.join(tempDir.path, 'pack_de.tmp'));
      await file.writeAsString('existing content');

      final mockClient = MockClient((request) async {
        requestCount++;
        if (requestCount == 1) {
           return http.Response('Some partial content', 200, headers: {'etag': 'new-etag'});
        } else {
           return http.Response('error', 500);
        }
      });

      await PackDownloaderService.requestDownload(
        'de',
        'http://example.com/pack.sqlite',
        'fakehash',
        client: mockClient,
      );

      expect(PackDownloaderService.getDownloadState('de'), PackDownloadState.paused);
    });

    test('cancelDownload stops operation and cleans up', () async {
      final completer = Completer<void>();
      final mockClient = MockClient((request) async {
         await completer.future;
         return http.Response('Too late', 200);
      });

      final future = PackDownloaderService.requestDownload(
        'de',
        'http://example.com/pack.sqlite',
        'fakehash',
        client: mockClient,
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(PackDownloaderService.getDownloadState('de'), PackDownloadState.downloading);

      await PackDownloaderService.cancelDownload('de');
      completer.complete();

      final result = await future;
      expect(result, isFalse);
      expect(PackDownloaderService.getDownloadState('de'), PackDownloadState.cancelled);

      final file = File(path.join(tempDir.path, 'pack_de.tmp'));
      expect(await file.exists(), isFalse);
    });
  });
}
