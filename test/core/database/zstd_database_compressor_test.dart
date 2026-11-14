import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/database/zstd_database_compressor.dart';

void main() {
  group('ZstdDatabaseCompressor Tests', () {
    test('Calculates compression ratio and validates sha256 checksum', () {
      final sampleBytes = Uint8List.fromList(utf8.encode('Polyglot Embedded Core Database Test Payload'));
      final digest = sha256.convert(sampleBytes).toString();

      final metadata = DatabaseBundleMetadata(
        rawSizeBytes: sampleBytes.lengthInBytes,
        compressedSizeBytes: (sampleBytes.lengthInBytes * 0.4).round(),
        expectedSha256: digest,
        schemaVersion: 1,
      );

      final compressor = ZstdDatabaseCompressor(metadata: metadata);

      expect(compressor.compressionRatio, greaterThan(50.0));
      expect(compressor.verifyIntegrity(sampleBytes), isTrue);

      final corruptedBytes = Uint8List.fromList([...sampleBytes, 0xFF]);
      expect(compressor.verifyIntegrity(corruptedBytes), isFalse);
    });
  });
}
