import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/services/pack_downloader_service.dart';

// Mock MockHttpClient implementation
class MockHttpClient extends http.BaseClient {
  final Map<String, List<int>> resources;
  final Map<String, String> etags;
  final bool simulateNetworkFailure;
  int retryCount = 0;

  MockHttpClient({
    required this.resources,
    required this.etags,
    this.simulateNetworkFailure = false,
  });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (simulateNetworkFailure) {
      retryCount++;
      if (retryCount <= 3) { // Force retry to fail all attempts
        throw const SocketException("Network failed");
      }
    }

    final urlStr = request.url.toString();
    final resource = resources[urlStr];
    if (resource == null) {
      return http.StreamedResponse(Stream.value([]), 404);
    }

    final etag = etags[urlStr];
    int start = 0;
    int status = 200;

    if (request.headers.containsKey('Range')) {
      final rangeStr = request.headers['Range']!;
      if (rangeStr.startsWith('bytes=')) {
        start = int.parse(rangeStr.substring(6).split('-').first);
        if (start >= resource.length) {
          return http.StreamedResponse(Stream.value([]), 416);
        }
        status = 206;
      }
    }

    final chunk = resource.sublist(start);
    final stream = Stream.fromIterable([chunk]);
    final headers = <String, String>{};
    if (etag != null) {
      headers['etag'] = etag;
    }

    return http.StreamedResponse(stream, status, headers: headers);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationSupportDirectory') {
        return '.';
      }
      return null;
    });
  });

  setUp(() async {
    await PackDownloaderService.resetForTest();
    if (File('./fr.staged').existsSync()) File('./fr.staged').deleteSync();
    if (File('./fr.etag').existsSync()) File('./fr.etag').deleteSync();
  });

  tearDown(() async {
    await PackDownloaderService.resetForTest();
  });

  test('Requires explicit user intent', () async {
    expect(
      () => PackDownloaderService.requestDownload(
        languageCode: 'de',
        downloadUrl: 'http://test/pack',
        expectedHash: 'xyz',
        userIntent: false,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('Successful download and validation', () async {
    final bytes = utf8.encode('test dictionary data');
    final expectedHash = sha256.convert(bytes).toString();

    final client = MockHttpClient(
      resources: {'http://test/pack': bytes},
      etags: {'http://test/pack': 'etag123'},
    );
    PackDownloaderService.setHttpClientForTest(client);

    await PackDownloaderService.requestDownload(
      languageCode: 'fr',
      downloadUrl: 'http://test/pack',
      expectedHash: expectedHash,
      userIntent: true,
    );

    final isDownloaded = await PackDownloaderService.isPackDownloaded('fr');
    expect(isDownloaded, isTrue);
    expect(PackDownloaderService.getPackState('fr'), PackDownloadState.installed);
  });

  test('Rejected hash fails validation and cleans up', () async {
    final bytes = utf8.encode('bad dictionary data');
    final expectedHash = sha256.convert(utf8.encode('different')).toString();

    final client = MockHttpClient(
      resources: {'http://test/pack': bytes},
      etags: {'http://test/pack': 'etag123'},
    );
    PackDownloaderService.setHttpClientForTest(client);

    await PackDownloaderService.requestDownload(
      languageCode: 'ru',
      downloadUrl: 'http://test/pack',
      expectedHash: expectedHash,
      userIntent: true,
    );

    final isDownloaded = await PackDownloaderService.isPackDownloaded('ru');
    expect(isDownloaded, isFalse);
    expect(PackDownloaderService.getPackState('ru'), PackDownloadState.rejected);
  });

  test('Resumes download with same ETag', () async {
    final bytes = utf8.encode('test dictionary data');
    final expectedHash = sha256.convert(bytes).toString();

    // Simulate partial download
    File('./es.staged').writeAsBytesSync(bytes.sublist(0, 5));
    File('./es.etag').writeAsStringSync('etag123');

    final client = MockHttpClient(
      resources: {'http://test/pack': bytes},
      etags: {'http://test/pack': 'etag123'},
    );
    PackDownloaderService.setHttpClientForTest(client);

    await PackDownloaderService.requestDownload(
      languageCode: 'es',
      downloadUrl: 'http://test/pack',
      expectedHash: expectedHash,
      userIntent: true,
    );

    expect(PackDownloaderService.getPackState('es'), PackDownloadState.installed);
  });

  test('Restarts download with different ETag', () async {
    final bytes = utf8.encode('test dictionary data');
    final expectedHash = sha256.convert(bytes).toString();

    // Simulate partial download with old ETag
    File('./it.staged').writeAsBytesSync(bytes.sublist(0, 5));
    File('./it.etag').writeAsStringSync('old_etag');

    final client = MockHttpClient(
      resources: {'http://test/pack': bytes},
      etags: {'http://test/pack': 'new_etag'},
    );
    PackDownloaderService.setHttpClientForTest(client);

    await PackDownloaderService.requestDownload(
      languageCode: 'it',
      downloadUrl: 'http://test/pack',
      expectedHash: expectedHash,
      userIntent: true,
    );

    expect(PackDownloaderService.getPackState('it'), PackDownloadState.installed);
  });

  test('Network failure bounds retries and fails', () async {
    final bytes = utf8.encode('test dictionary data');
    final expectedHash = sha256.convert(bytes).toString();

    final client = MockHttpClient(
      resources: {'http://test/pack': bytes},
      etags: {'http://test/pack': 'etag123'},
      simulateNetworkFailure: true,
    );
    PackDownloaderService.setHttpClientForTest(client);

    await PackDownloaderService.requestDownload(
      languageCode: 'tr',
      downloadUrl: 'http://test/pack',
      expectedHash: expectedHash,
      userIntent: true,
    );

    expect(PackDownloaderService.getPackState('tr'), PackDownloadState.failed);
    expect(client.retryCount, 3); // Max retries
  });

  test('Cancellation cleans up temporary files', () async {
     // Start a download, cancel it quickly, check states.
     // In a mock test without real async streams, we might just mock the state or let the stream run but cancel before starting.
     // Let's pre-set state to cancelled and ensure it bails and cleans up.
     final bytes = utf8.encode('test dictionary data');
     final expectedHash = sha256.convert(bytes).toString();

     File('./zh.staged').writeAsBytesSync(bytes.sublist(0, 5));
     File('./zh.etag').writeAsStringSync('etag123');

     final client = MockHttpClient(
       resources: {'http://test/pack': bytes},
       etags: {'http://test/pack': 'etag123'},
     );
     PackDownloaderService.setHttpClientForTest(client);

     // We simulate cancellation by running requestDownload but immediately calling cancelDownload.
     final downloadFuture = PackDownloaderService.requestDownload(
       languageCode: 'zh',
       downloadUrl: 'http://test/pack',
       expectedHash: expectedHash,
       userIntent: true,
     );

     await PackDownloaderService.cancelDownload('zh');
     await downloadFuture;

     expect(PackDownloaderService.getPackState('zh'), PackDownloadState.cancelled);
     expect(File('./zh.staged').existsSync(), isFalse);
     expect(File('./zh.etag').existsSync(), isFalse);
  });
}
