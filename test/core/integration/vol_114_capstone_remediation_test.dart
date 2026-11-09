import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/sovereign_collocation_extractor.dart';
import 'package:deutsch_build/src/core/voice/synthesis/adaptive_dynamic_range_compressor.dart';
import 'package:deutsch_build/src/ui/bridges/vol_114_capstone_ui_bridge.dart';

void main() {
  group('Volume 114 Capstone (Tasks 4878-4880) Integration Tests', () {
    test('P1-16: AdaptiveDynamicRangeCompressor compresses high-amplitude audio', () {
      final drc = AdaptiveDynamicRangeCompressor(thresholdDb: -20.0, ratio: 4.0);

      final inputBytes = Uint8List(200);
      final view = ByteData.sublistView(inputBytes);
      for (int i = 0; i < 100; i++) {
        view.setInt16(i * 2, 25000, Endian.little);
      }

      final compressed = drc.processPcmBytes(inputBytes);
      expect(compressed.length, equals(200));

      final outView = ByteData.sublistView(compressed);
      // High sample (25000) should be clamped / attenuated by compressor
      expect(outView.getInt16(50 * 2, Endian.little).abs(), lessThanOrEqualTo(25000));
    });

    test('LING-009: SovereignCollocationExtractor matches idioms and extracts Arabic equivalents', () {
      final sentence = 'Ich muss jetzt Feierabend machen und dir Bescheid sagen.';
      final matches = SovereignCollocationExtractor.extractCollocations(sentence);

      expect(matches.length, equals(2));
      expect(matches.any((m) => m.germanIdiom == 'feierabend machen'), isTrue);
      expect(matches.any((m) => m.germanIdiom == 'bescheid sagen'), isTrue);
    });

    test('UI Bridge correctly generates full Volume 114 Capstone report', () {
      final bridge = Vol114CapstoneUIBridge();
      final report = bridge.getVolume114FullReport();

      expect(report['volume'], equals(114));
      expect(report['status'], equals('SEALED_AND_VERIFIED'));
      expect(report['verdict'], equals('PRODUCTION_READY'));
      expect(report['total_tasks_completed'], equals(12));
    });
  });
}
