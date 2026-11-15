import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/semantic_search/vector_quantizer.dart';

void main() {
  group('VectorQuantizer Unit Tests (N047)', () {
    final quantizer = VectorQuantizer();

    test('Quantizes float32 vector and reconstructs with high fidelity', () {
      final raw = [0.12, -0.45, 0.88, 0.02, -0.95, 0.54];
      final quantized = quantizer.quantize(raw);

      expect(quantized.byteSize, equals(raw.length));
      for (final b in quantized.quantizedBytes) {
        expect(b, inInclusiveRange(-128, 127));
      }

      final restored = quantizer.dequantize(quantized);
      for (int i = 0; i < raw.length; i++) {
        expect(restored[i], closeTo(raw[i], 0.05));
      }
    });

    test('Demonstrates 75% RAM reduction for mobile vector storage', () {
      final savings = quantizer.calculateCompressionSavings(128);
      expect(savings, equals(75.0));
    });

    test('Empty vector handles safely', () {
      final empty = quantizer.quantize([]);
      expect(empty.byteSize, equals(0));
      expect(quantizer.dequantize(empty), isEmpty);
    });
  });
}
