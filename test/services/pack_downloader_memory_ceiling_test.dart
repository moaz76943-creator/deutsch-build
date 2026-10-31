import 'dart:convert';
import 'dart:io';

import 'package:deutsch_bilarabi/services/pack_downloader_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('streams gzip across chunks up to the exact expanded limit', () async {
    final original = utf8.encode('123456789');
    final compressed = gzip.encode(original);
    final bytes = await PackDownloaderService.decodeGzipEnvelope(
      Stream<List<int>>.fromIterable(<List<int>>[
        compressed.sublist(0, 3),
        compressed.sublist(3),
      ]),
      maxExpandedBytes: original.length,
    );
    expect(bytes, original);
  });

  test('rejects expanded payload before it breaches the cap', () async {
    final compressed = gzip.encode(utf8.encode('123456789'));
    await expectLater(
      PackDownloaderService.decodeGzipEnvelope(
        Stream<List<int>>.value(compressed),
        maxExpandedBytes: 8,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('prevents callers from raising the production 64 MiB ceiling', () async {
    expect(PackDownloaderService.maxUncompressedPackBytes, 64 * 1024 * 1024);
    await expectLater(
      PackDownloaderService.decodeGzipEnvelope(
        const Stream<List<int>>.empty(),
        maxExpandedBytes: PackDownloaderService.maxUncompressedPackBytes + 1,
      ),
      throwsRangeError,
    );
  });
}
