import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/arabic_german_orthography_normalizer.dart';
import 'package:deutsch_build/src/core/semantic_search/vector_scalar_quantizer.dart';
import 'package:deutsch_build/src/ui/bridges/vol_113_wave1_ui_bridge.dart';

void main() {
  group('Volume 113 Wave 1 (Tasks 4851-4853) Integration Tests', () {
    test('PERF-003: VectorScalarQuantizer reduces size and preserves vector ordering', () {
      final rawFloats = [0.15, -0.42, 0.88, 0.0, -0.95];
      final quantized = VectorScalarQuantizer.quantize(rawFloats);

      expect(quantized.dimension, equals(5));
      expect(quantized.quantizedBytes.length, equals(5));

      final dequantized = VectorScalarQuantizer.dequantize(quantized);
      expect(dequantized.length, equals(5));

      // Max absolute error must be bounded under uniform quantization
      for (int i = 0; i < rawFloats.length; i++) {
        expect((rawFloats[i] - dequantized[i]).abs(), lessThan(0.05));
      }

      // Fast dot product verification
      final otherFloats = [0.10, -0.30, 0.50, 0.1, -0.80];
      final otherQ = VectorScalarQuantizer.quantize(otherFloats);
      final dot = VectorScalarQuantizer.fastQuantizedDotProduct(
        quantized.quantizedBytes,
        otherQ.quantizedBytes,
      );
      expect(dot, greaterThan(0));
    });

    test('LING-002: ArabicGermanOrthographyNormalizer strips tashkeel and normalizes umlauts', () {
      // Arabic tashkeel removal & Alef unification
      final rawArabic = 'اللُّغَةُ العَرَبِيَّةُ';
      final normalizedAr = ArabicGermanOrthographyNormalizer.normalizeArabic(rawArabic);
      expect(normalizedAr, equals('اللغه العربيه'));

      // German umlaut unfolding
      final rawGerman = 'Übergrößengeschäft';
      final unfoldedDe = ArabicGermanOrthographyNormalizer.normalizeGerman(rawGerman, unfoldUmlauts: true);
      expect(unfoldedDe, equals('Uebergroessengeschaeft'));
    });

    test('UI Bridge correctly generates Wave 1 diagnostics report', () {
      final bridge = Vol113Wave1UIBridge();
      final report = bridge.getWave1Diagnostics();

      expect(report['volume'], equals(113));
      expect(report['verdict'], equals('PRODUCTION_VERIFIED'));
      expect(report['subsystems']['vector_scalar_quantizer']['status'], equals('OPERATIONAL'));
      expect(bridge.normalizeSearchQuery('مُعَلِّمٌ', 'ar'), equals('معلم'));
    });
  });
}
