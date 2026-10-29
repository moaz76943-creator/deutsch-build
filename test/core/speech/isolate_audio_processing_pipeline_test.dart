import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/core/speech/isolate_audio_processing_pipeline.dart';

void main() {
  group('IsolateAudioProcessingPipeline Tests', () {
    late IsolateAudioProcessingPipeline pipeline;

    setUp(() {
      pipeline = IsolateAudioProcessingPipeline();
    });

    tearDown(() {
      pipeline.dispose();
    });

    test('Offloads MFCC extraction asynchronously without blocking', () async {
      final samplePcm = Int16List(16000); // 1 second buffer
      for (int i = 0; i < samplePcm.length; i++) {
        samplePcm[i] = (i % 100) * 10;
      }

      final response = await pipeline.processAudioAsync(samplePcm);

      expect(response.totalFrames, greaterThan(0));
      expect(response.mfccFrames, isNotEmpty);
      expect(response.processingLatency.inMilliseconds, lessThan(1000));
    });
  });
}
