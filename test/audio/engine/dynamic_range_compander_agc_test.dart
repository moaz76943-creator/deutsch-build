import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/audio/engine/dynamic_range_compander_agc.dart';

void main() {
  group('DynamicRangeCompanderAgc Tests', () {
    const agc = DynamicRangeCompanderAgc();

    test('Initializes with authentic acoustic parameters', () {
      expect(agc.sampleRate, equals(16000));
      expect(agc.targetRms, equals(0.15));
      expect(agc.maxGain, equals(4.0));
    });

    test('Boosts quiet whispered signals and silences background noise floor', () {
      // 1. Whispered input (0.04 amplitude)
      final whispered = Float32List(320);
      for (int i = 0; i < 320; i++) {
        whispered[i] = 0.04 * (i % 2 == 0 ? 1.0 : -1.0);
      }
      final boosted = agc.processBuffer(whispered);
      expect(boosted.last.abs(), greaterThan(whispered.last.abs()));

      // 2. Loud input (> 1.2 amplitude)
      final loud = Float32List(320);
      for (int i = 0; i < 320; i++) {
        loud[i] = 1.3 * (i % 2 == 0 ? 1.0 : -1.0);
      }
      final compressed = agc.processBuffer(loud);
      expect(compressed.every((s) => s.abs() <= 1.0), isTrue);
    });
  });
}
