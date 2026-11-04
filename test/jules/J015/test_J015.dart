import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:deutsch_bilarabi/services/pack_downloader_service.dart';

/// Regression tests against the current requestDownload API. In particular,
/// text or checksum-valid non-SQLite bytes are never installed as content.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory support;

  setUpAll(() async {
    support = await Directory.systemTemp.createTemp('j015_pack_guard_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async {
        if (call.method == 'getApplicationSupportDirectory') {
          return support.path;
        }
        return null;
      },
    );
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
    if (await support.exists()) await support.delete(recursive: true);
  });

  test('Legacy download without a URL cannot claim success', () async {
    expect(await PackDownloaderService.downloadPack('fr'), isFalse);
    expect(PackDownloaderService.getDownloadState('fr'), isNull);
  });

  test('An unknown archive is not reported as usable content', () async {
    expect(await PackDownloaderService.isPackDownloaded('nl'), isFalse);
  });

  test('Empty language ID cannot trigger a download', () async {
    await expectLater(
      PackDownloaderService.requestDownload(
        '', 'https://example.invalid/pack', '0000000000000000000000000000000000000000000000000000000000000000',
      ),
      throwsArgumentError,
    );
  });

  test('Parent path traversal is rejected before any file creation',
      () async {
    const malicious = '../user_progress';
    await expectLater(
      PackDownloaderService.requestDownload(
        malicious, 'https://example.invalid/pack', '0000000000000000000000000000000000000000000000000000000000000000',
      ),
      throwsArgumentError,
    );
    expect(PackDownloaderService.getDownloadState(malicious), isNull);
  });

  test('Whitespace and dotted language names are rejected', () async {
    for (final code in <String>[' fr', 'fr/../de', 'de.sqlite']) {
      await expectLater(
        PackDownloaderService.requestDownload(
          code, 'https://example.invalid/pack', '0000000000000000000000000000000000000000000000000000000000000000',
        ),
        throwsArgumentError,
      );
      expect(PackDownloaderService.getDownloadState(code), isNull);
    }
  });

  test('A matching SHA-256 of text is not a valid SQLite pack', () async {
    final data = <int>[1, 2, 3, 4];
    final hash = sha256.convert(data).toString();
    final client = MockClient((_) async => http.Response.bytes(data, 200));

    final success = await PackDownloaderService.requestDownload(
      'nl', 'https://example.invalid/nl', hash, client: client,
    );
    expect(success, isFalse);
    expect(PackDownloaderService.getDownloadState('nl'),
        PackDownloadState.rejected);
    expect(await PackDownloaderService.isPackDownloaded('nl'), isFalse);
  });

  test('Mismatched SHA-256 does not produce an installed pack', () async {
    final client = MockClient((_) async =>
        http.Response.bytes(<int>[1, 2, 3, 4], 200));

    final result = await PackDownloaderService.requestDownload(
      'pl', 'https://example.invalid/pl', '0000000000000000000000000000000000000000000000000000000000000000', client: client,
    );
    expect(result, isFalse);
    expect(PackDownloaderService.getDownloadState('pl'),
        PackDownloadState.rejected);
  });

  test('A valid BCP-47 region identifier is not a pack admission', () async {
    final data = <int>[1, 2, 3, 4];
    final hash = sha256.convert(data).toString();
    final client = MockClient((_) async => http.Response.bytes(data, 200));

    final success = await PackDownloaderService.requestDownload(
      'nl-NL', 'https://example.invalid/nl-NL', hash, client: client,
    );
    expect(success, isFalse);
    expect(PackDownloaderService.getDownloadState('nl-NL'),
        PackDownloadState.rejected);
  });
}
