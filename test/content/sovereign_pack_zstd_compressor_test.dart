import 'package:test/test.dart';
import '../../lib/src/content/sovereign_pack_zstd_compressor.dart';

void main() {
  group('SovereignPackZstdCompressor Unit Tests (L085)', () {
    const compressor = SovereignPackZstdCompressor(compressionLevel: 9);

    test('Achieves over 60% compression savings on raw 50MB SQLite language pack', () {
      final metrics = compressor.evaluateCompression(rawDatabaseSizeBytes: 52428800); // 50MB

      expect(metrics.isTargetRatioAchieved, isTrue);
      expect(metrics.compressionRatioPercent, greaterThanOrEqualTo(60.0));
      expect(metrics.compressedBytes, lessThan(metrics.uncompressedBytes));
      expect(metrics.decompressionSpeedMbPerSec, greaterThan(1000));
    });

    test('Handles zero size gracefully', () {
      final metrics = compressor.evaluateCompression(rawDatabaseSizeBytes: 0);
      expect(metrics.isTargetRatioAchieved, isFalse);
    });
  });
}
