import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:deutsch_bilarabi/services/pack_downloader_service.dart';
import 'package:deutsch_bilarabi/services/language_pack_manager.dart';

class StreamMockClient extends http.BaseClient {
  final Future<http.StreamedResponse> Function(http.BaseRequest request) handler;
  StreamMockClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return handler(request);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getTemporaryDirectory') {
        return Directory.systemTemp.path;
      }
      return null;
    });
  });

  http.Client createMockClient({
    required List<int> fileBytes,
    required String etag,
    bool supportRanges = true,
    int? failOnByte,
    bool changeEtagOnResume = false,
  }) {
    int requestCount = 0;
    return StreamMockClient((request) async {
      requestCount++;
      String currentEtag = (changeEtagOnResume && requestCount > 1) ? "${etag}_changed" : etag;

      final rangeHeader = request.headers['Range'];
      int start = 0;
      if (rangeHeader != null && supportRanges) {
        final match = RegExp(r'bytes=(\d+)-').firstMatch(rangeHeader);
        if (match != null) {
          start = int.parse(match.group(1)!);
        }
      }

      final bodyBytes = fileBytes.sublist(start);
      final headers = {
        'etag': currentEtag,
        'content-length': '${bodyBytes.length}',
      };
      if (supportRanges) {
        headers['accept-ranges'] = 'bytes';
      }

      int statusCode = (start > 0 && supportRanges) ? 206 : 200;

      if (failOnByte != null && start <= failOnByte && failOnByte < fileBytes.length) {
         int yieldCount = failOnByte - start;
         final streamController = StreamController<List<int>>();
         streamController.add(bodyBytes.sublist(0, yieldCount));
         streamController.addError(Exception("Simulated network failure"));
         streamController.close();
         return http.StreamedResponse(streamController.stream, statusCode, headers: headers, contentLength: bodyBytes.length);
      }

      final streamController = StreamController<List<int>>();
      streamController.add(bodyBytes);
      streamController.close();
      return http.StreamedResponse(streamController.stream, statusCode, headers: headers, contentLength: bodyBytes.length);
    });
  }

  group('PackDownloaderService Tests', () {
    final testData = utf8.encode("Hello German Dictionary Pack! This needs to be a bit longer to test chunks properly.");
    final testHash = sha256.convert(testData).toString();

    setUp(() async {
       await PackDownloaderService.clearDownload('de-DE');
    });

    test('Successful full download and validation', () async {
      final client = createMockClient(fileBytes: testData, etag: '"12345"');

      final future = LanguagePackManager.acquirePack('de-DE', 'http://example.com/pack', testHash, client: client);

      final result = await future;

      expect(result, isTrue);
    });

    test('Rejected on invalid hash', () async {
      final client = createMockClient(fileBytes: testData, etag: '"12345"');
      final result = await LanguagePackManager.acquirePack('de-DE', 'http://example.com/pack', "invalid_hash", client: client);
      expect(result, isFalse);
    });

    test('Resumes download successfully', () async {
      int reqCount = 0;
      final retryClient = StreamMockClient((req) async {
        reqCount++;
        if (reqCount == 1) {
           final streamController = StreamController<List<int>>();
           streamController.add(testData.sublist(0, 10)); // send 10 bytes
           streamController.addError(Exception("Network error"));
           streamController.close();
           return http.StreamedResponse(streamController.stream, 200, headers: {'etag': '"123"', 'accept-ranges': 'bytes'});
        } else {
           final rangeHeader = req.headers['Range'];
           final streamController = StreamController<List<int>>();
           streamController.add(testData.sublist(10));
           streamController.close();
           return http.StreamedResponse(streamController.stream, 206, headers: {'etag': '"123"', 'accept-ranges': 'bytes'});
        }
      });

      final result = await LanguagePackManager.acquirePack('de-DE', 'http://example.com/pack', testHash, client: retryClient);
      expect(result, isTrue);
    });

    test('Restarts download if ETag changes', () async {
      int reqCount = 0;
      final retryClient = StreamMockClient((req) async {
        reqCount++;
        if (reqCount == 1) {
           final streamController = StreamController<List<int>>();
           streamController.add(testData.sublist(0, 10)); // send 10 bytes
           streamController.addError(Exception("Network error"));
           streamController.close();
           return http.StreamedResponse(streamController.stream, 200, headers: {'etag': '"123"', 'accept-ranges': 'bytes'});
        } else {
           // Provide different ETag to simulate change
           if (req.headers.containsKey('Range')) {
              // Return 206 to trigger the etag check exception
              final streamController = StreamController<List<int>>();
              streamController.add(testData.sublist(10));
              streamController.close();
              return http.StreamedResponse(streamController.stream, 206, headers: {'etag': '"456"', 'accept-ranges': 'bytes'});
           } else {
              // Now we restart from 0
              final streamController = StreamController<List<int>>();
              streamController.add(testData);
              streamController.close();
              return http.StreamedResponse(streamController.stream, 200, headers: {'etag': '"456"', 'accept-ranges': 'bytes'});
           }
        }
      });

      final result = await LanguagePackManager.acquirePack('de-DE', 'http://example.com/pack', testHash, client: retryClient);
      expect(result, isTrue);
    });

    test('Prevents concurrent duplicate downloads', () async {
      final client = createMockClient(fileBytes: testData, etag: '"123"');
      final future1 = LanguagePackManager.acquirePack('de-DE', 'http://example.com/pack', testHash, client: client);
      final future2 = LanguagePackManager.acquirePack('de-DE', 'http://example.com/pack', testHash, client: client);

      final res2 = await future2;
      expect(res2, isFalse);

      final res1 = await future1;
      expect(res1, isTrue);
    });

    test('Cancellation stops the download', () async {
      final streamController = StreamController<List<int>>();
      final client = StreamMockClient((req) async {
         return http.StreamedResponse(streamController.stream, 200, headers: {'etag': '"123"', 'content-length': '100'});
      });

      final future = LanguagePackManager.acquirePack('de-DE', 'http://example.com/pack', testHash, client: client);

      await Future.delayed(const Duration(milliseconds: 50));
      await PackDownloaderService.cancelDownload('de-DE');

      streamController.add([1, 2, 3]);

      final result = await future;
      expect(result, isFalse);

      streamController.close();
    });

    test('Handles 416 Invalid Range', () async {
      int reqCount = 0;
      final retryClient = StreamMockClient((req) async {
        reqCount++;
        if (reqCount == 1) {
           final streamController = StreamController<List<int>>();
           streamController.add(testData.sublist(0, 10)); // send 10 bytes
           streamController.addError(Exception("Network error"));
           streamController.close();
           return http.StreamedResponse(streamController.stream, 200, headers: {'etag': '"123"', 'accept-ranges': 'bytes'});
        } else {
           if (req.headers.containsKey('Range')) {
              // Simulate server rejecting range (e.g. file got smaller)
              final streamController = StreamController<List<int>>();
              streamController.close();
              return http.StreamedResponse(streamController.stream, 416, headers: {});
           } else {
              // Retry without range
              final streamController = StreamController<List<int>>();
              streamController.add(testData);
              streamController.close();
              return http.StreamedResponse(streamController.stream, 200, headers: {'etag': '"456"', 'accept-ranges': 'bytes'});
           }
        }
      });

      final result = await LanguagePackManager.acquirePack('de-DE', 'http://example.com/pack', testHash, client: retryClient);
      expect(result, isTrue);
    });
  });
}
