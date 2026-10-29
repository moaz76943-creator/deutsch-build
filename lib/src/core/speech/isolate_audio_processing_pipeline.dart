import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'mfcc_feature_extractor.dart';

/// Request payload offloaded to the background audio isolate.
class AudioProcessingRequest {
  final Int16List pcmSamples;
  final int sampleRate;

  const AudioProcessingRequest({
    required this.pcmSamples,
    required this.sampleRate,
  });
}

/// Extracted acoustic frame features computed in background isolate.
class AudioProcessingResponse {
  final int totalFrames;
  final List<Float32List> mfccFrames;
  final Duration processingLatency;

  const AudioProcessingResponse({
    required this.totalFrames,
    required this.mfccFrames,
    required this.processingLatency,
  });
}

// Top-level compute worker
AudioProcessingResponse _isolateAudioWorker(AudioProcessingRequest request) {
  final stopwatch = Stopwatch()..start();
  final extractor = MfccFeatureExtractor(sampleRate: request.sampleRate);
  final frames = extractor.extractFeatures(request.pcmSamples);
  stopwatch.stop();

  return AudioProcessingResponse(
    totalFrames: frames.length,
    mfccFrames: frames,
    processingLatency: stopwatch.elapsed,
  );
}

/// Dispatches heavy acoustic extraction tasks to background isolates.
class IsolateAudioProcessingPipeline {
  bool _isDisposed = false;

  IsolateAudioProcessingPipeline();

  /// Asynchronously processes audio samples off the UI thread.
  Future<AudioProcessingResponse> processAudioAsync(
    Int16List pcmData, {
    int sampleRate = 16000,
  }) async {
    if (_isDisposed) {
      throw StateError('Pipeline is disposed');
    }

    final request = AudioProcessingRequest(
      pcmSamples: pcmData,
      sampleRate: sampleRate,
    );

    return await compute(_isolateAudioWorker, request);
  }

  void dispose() {
    _isDisposed = true;
  }
}
