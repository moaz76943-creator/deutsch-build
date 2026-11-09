import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/sovereign_translation_memory_aligner.dart';
import 'package:deutsch_build/src/core/mesh/protocol/merkle_range_state_rebalancer.dart';
import 'package:deutsch_build/src/ui/bridges/vol_113_wave4_ui_bridge.dart';

void main() {
  group('Volume 113 Wave 4 (Tasks 4860-4862) Integration Tests', () {
    test('ARCH-009: MerkleRangeStateRebalancer computes bucket hashes and pinpoints mismatches', () {
      final nodeA = MerkleRangeStateRebalancer(totalBuckets: 16);
      final nodeB = MerkleRangeStateRebalancer(totalBuckets: 16);

      nodeA.addKey('vocab_lesson_1');
      nodeA.addKey('vocab_lesson_2');

      nodeB.addKey('vocab_lesson_1');
      // nodeB is missing vocab_lesson_2

      final summaryA = nodeA.getSummaryHashes();
      final summaryB = nodeB.getSummaryHashes();

      final mismatched = nodeA.identifyMismatchedBucketIndices(summaryB);
      expect(mismatched.isNotEmpty, isTrue);
      expect(mismatched.length, lessThanOrEqualTo(2));
    });

    test('LING-004: SovereignTranslationMemoryAligner fuzzy matches German sentences', () {
      final tm = SovereignTranslationMemoryAligner();

      tm.addTranslationPair('Guten Morgen, wie geht es Ihnen?', 'صباح الخير، كيف حالكم؟');
      tm.addTranslationPair('Ich lerne Deutsch.', 'أنا أتعلم الألمانية.');

      expect(tm.unitCount, equals(2));

      // Slight typo/variation match
      final match = tm.findClosestMatch('Guten Morgen, wie geht es dir?', minThreshold: 0.60);
      expect(match, isNotNull);
      expect(match!.targetArabic, equals('صباح الخير، كيف حالكم؟'));

      // Low similarity query should return null
      final noMatch = tm.findClosestMatch('Das Wetter ist heute schoen.', minThreshold: 0.80);
      expect(noMatch, isNull);
    });

    test('UI Bridge correctly generates Wave 4 diagnostics report', () {
      final bridge = Vol113Wave4UIBridge();
      final report = bridge.getWave4Diagnostics();

      expect(report['volume'], equals(113));
      expect(report['verdict'], equals('PRODUCTION_VERIFIED'));
      expect(report['subsystems']['merkle_range_rebalancer']['status'], equals('OPERATIONAL'));
      expect(report['subsystems']['translation_memory_aligner']['status'], equals('ACTIVE'));
    });
  });
}
