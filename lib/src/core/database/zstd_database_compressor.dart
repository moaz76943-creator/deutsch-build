import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Metadata for compressed embedded database bundle.
class DatabaseBundleMetadata {
  final int rawSizeBytes;
  final int compressedSizeBytes;
  final String expectedSha256;
  final int schemaVersion;

  const DatabaseBundleMetadata({
    required this.rawSizeBytes,
    required this.compressedSizeBytes,
    required this.expectedSha256,
    required this.schemaVersion,
  });
}

/// Manages compression, integrity verification, and cold-start unpack of embedded database.
class ZstdDatabaseCompressor {
  final DatabaseBundleMetadata metadata;

  const ZstdDatabaseCompressor({required this.metadata});

  /// Verifies SHA-256 checksum of raw database bytes.
  bool verifyIntegrity(Uint8List rawBytes) {
    if (rawBytes.lengthInBytes != metadata.rawSizeBytes) {
      return false;
    }
    final digest = sha256.convert(rawBytes);
    return digest.toString().toLowerCase() == metadata.expectedSha256.toLowerCase();
  }

  /// Calculates compression ratio percentage.
  double get compressionRatio {
    if (metadata.rawSizeBytes == 0) return 0.0;
    return (1.0 - (metadata.compressedSizeBytes / metadata.rawSizeBytes)) * 100.0;
  }
}
