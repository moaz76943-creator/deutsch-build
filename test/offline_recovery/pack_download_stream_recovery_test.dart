import 'dart:async';
import 'dart:io';

import 'package:deutsch_bilarabi/services/pack_downloader_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// These tests use the public bounded streaming decoder and do not download
/// content or mutate a real installed pack. The archive installer itself is
/// owned by Draft PR #55 and is not exposed on the staging base.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a valid archive stream is reconstructed exactly', () async {
    final payload = List<int>.generate(4096, (index) => index % 251);
    final compressed = gzip.encode(payload);
    final chunks = <List<int>>[];
    const chunkSize = 17;
    for (var i = 0; i < compressed.length; i += chunkSize) {
      final end = i + chunkSize < compressed.length
          ? i + chunkSize
          : compressed.length;
      chunks.add(compressed.sublist(i, end));
    }

    final decoded = await PackDownloaderService.decodeGzipEnvelope(
      Stream<List<int>>.fromIterable(chunks),
      maxExpandedBytes: payload.length,
    );
    expect(decoded, orderedEquals(payload));
  });

  test('an interrupted gzip stream cannot be accepted as complete',
      () async {
    final payload = List<int>.filled(8192, 65);
    final compressed = gzip.encode(payload);
    final cutoff = compressed.length ~/ 2;
    final interrupted = Stream<List<int>>.multi((controller) {
      controller.add(compressed.sublist(0, cutoff));
      controller.addError(StateError('simulated stream interruption'));
      controller.close();
    });

    await expectLater(
      PackDownloaderService.decodeGzipEnvelope(interrupted),
      throwsA(isA<StateError>()),
    );
  });

  test('truncated gzip payload is rejected instead of returning partial data',
      () async {
    final compressed = gzip.encode(List<int>.filled(8192, 42));
    // Remove the gzip checksum/trailer to simulate a truncated download.
    final truncated = compressed.sublist(0, compressed.length - 8);

    await expectLater(
      PackDownloaderService.decodeGzipEnvelope(
        Stream<List<int>>.value(truncated),
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('expanded-size boundary refuses a compressed bomb', () async {
    final compressed = gzip.encode(List<int>.filled(8192, 65));
    await expectLater(
      PackDownloaderService.decodeGzipEnvelope(
        Stream<List<int>>.value(compressed),
        maxExpandedBytes: 256,
      ),
      throwsStateError,
    );
  });

  test('decoder refuses a limit outside its fixed production ceiling',
      () async {
    final compressed = gzip.encode(<int>[1, 2, 3]);
    await expectLater(
      PackDownloaderService.decodeGzipEnvelope(
        Stream<List<int>>.value(compressed),
        maxExpandedBytes: PackDownloaderService.maxUncompressedPackBytes + 1,
      ),
      throwsRangeError,
    );
  });
}
