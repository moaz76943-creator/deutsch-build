import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/speech/mfcc_feature_extractor.dart';

void main() {
  group('MfccFeatureExtractor Tests', () {
    const extractor = MfccFeatureExtractor();

    test('Applies pre-emphasis filter accurately', () {
      final input = Int16List.fromList([1000, 2000, 3000]);
      final filtered = extractor.applyPreEmphasis(input, alpha: 0.97);

      expect(filtered[0], equals(1000.0));
      expect(filtered[1], closeTo(2000 - 0.97 * 1000, 0.01));
    });

    test('Extracts 13 MFCC coefficients per frame from speech audio buffer', () {
      final samplePcm = Int16List(16000); // 1 second of audio (16kHz)
      for (int i = 0; i < samplePcm.length; i++) {
        samplePcm[i] = (i % 200) * 10;
      }

      final features = extractor.extractFeatures(samplePcm);
      expect(features, isNotEmpty);
      expect(features.first.length, equals(13));
    });
  });
}
