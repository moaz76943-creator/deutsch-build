import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/core/voice_cloning/dynamic_wsola_stretcher_v2.dart';

void main() {
  group('DynamicWsolaStretcherV2 Tests', () {
    const stretcher = DynamicWsolaStretcherV2();

    test('Slows down audio by 0.5x producing double duration waveform', () {
      final input = Int16List.fromList(List.generate(2048, (i) => ((i % 100) * 100) - 5000));
      final slowed = stretcher.timeStretchPcm(input, 0.5);

      expect(slowed.length, greaterThan(input.length));
      expect(slowed.length, closeTo(input.length * 2, 100));
    });

    test('Maintains unaltered sample output when speed is 1.0x', () {
      final input = Int16List.fromList([100, 200, 300, 400]);
      final output = stretcher.timeStretchPcm(input, 1.0);

      expect(output.length, equals(input.length));
      expect(output[0], equals(100));
    });
  });
}
