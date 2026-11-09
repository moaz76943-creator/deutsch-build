import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/cefr_lexical_frequency_classifier.dart';
import 'package:deutsch_build/src/core/mesh/protocol/token_bucket_rate_limiter.dart';
import 'package:deutsch_build/src/ui/bridges/vol_114_wave1_ui_bridge.dart';

void main() {
  group('Volume 114 Wave 1 (Tasks 4869-4871) Integration Tests', () {
    test('NET-001: TokenBucketRateLimiter regulates consumption and blocks bursts', () {
      final limiter = TokenBucketRateLimiter(capacityTokens: 5, refillRatePerSecond: 10.0);

      // Acquire all available tokens
      for (int i = 0; i < 5; i++) {
        expect(limiter.tryAcquire(tokens: 1), isTrue);
      }

      // Exhausted bucket must block immediately
      expect(limiter.tryAcquire(tokens: 1), isFalse);

      limiter.reset();
      expect(limiter.tryAcquire(tokens: 1), isTrue);
    });

    test('LING-007: CefrLexicalFrequencyClassifier classifies German vocabulary accurately', () {
      expect(CefrLexicalFrequencyClassifier.classifyWord('hallo'), equals(CefrLevel.a1));
      expect(CefrLexicalFrequencyClassifier.classifyWord('wohnung'), equals(CefrLevel.a2));
      expect(CefrLexicalFrequencyClassifier.classifyWord('erfahrung'), equals(CefrLevel.b1));
      expect(CefrLexicalFrequencyClassifier.classifyWord('nachhaltigkeit'), equals(CefrLevel.b2));
      expect(CefrLexicalFrequencyClassifier.classifyWord('unbekannteswort123'), equals(CefrLevel.unknown));

      final dist = CefrLexicalFrequencyClassifier.calculateDistribution(['hallo', 'danke', 'wohnung']);
      expect(dist[CefrLevel.a1], equals(2));
      expect(dist[CefrLevel.a2], equals(1));
    });

    test('UI Bridge correctly generates Wave 1 diagnostics report', () {
      final bridge = Vol114Wave1UIBridge();
      final report = bridge.getWave1Diagnostics();

      expect(report['volume'], equals(114));
      expect(report['verdict'], equals('PRODUCTION_VERIFIED'));
      expect(report['subsystems']['token_bucket_rate_limiter']['status'], equals('OPERATIONAL'));
      expect(report['subsystems']['cefr_lexical_classifier']['status'], equals('ACTIVE'));
      expect(bridge.getWordLevel('hallo'), equals(CefrLevel.a1));
    });
  });
}
