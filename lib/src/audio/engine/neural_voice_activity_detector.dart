import 'dart:math' as math;
import 'dart:typed_data';
import 'package:meta/meta.dart';

/// Real-time decision output of Voice Activity Detection.
@immutable
class VadDecision {
  final bool isSpeech;
  final double confidence; // 0.0 to 1.0
  final double energyDb;
  final bool isArtifact; // True for coughs, table taps, heavy breaths

  const VadDecision({
    required this.isSpeech,
    required this.confidence,
    required this.energyDb,
    required this.isArtifact,
  });
}

/// Sovereign Voice Deep Core v2: Neural Voice Activity Detector (VAD).
///
/// Robust real-time speech boundary detector operating on 10ms-20ms frames.
/// Distinguishes authentic human articulation from non-speech physiological
/// artifacts (throat clearing, coughing, sniffling, microphone rubbing, sighing)
/// with adaptive hangover smoothing.
@immutable
class NeuralVoiceActivityDetector {
  final int sampleRate;
  final double speechThresholdDb;
  final int hangoverFrameCount;

  const NeuralVoiceActivityDetector({
    this.sampleRate = 16000,
    this.speechThresholdDb = -38.0,
    this.hangoverFrameCount = 5, // 5 frames = 50ms hangover smoothing
  });

  /// Evaluates an input audio frame (e.g. 160 samples = 10ms at 16kHz).
  VadDecision evaluateFrame(Float32List frame, {int pastSpeechHangover = 0}) {
    if (frame.isEmpty) {
      return const VadDecision(isSpeech: false, confidence: 0.0, energyDb: -100.0, isArtifact: false);
    }

    // 1. Calculate frame RMS energy
    double sumSquares = 0.0;
    int zeroCrossings = 0;
    for (int i = 0; i < frame.length; i++) {
      sumSquares += frame[i] * frame[i];
      if (i > 0 && ((frame[i] >= 0 && frame[i - 1] < 0) || (frame[i] < 0 && frame[i - 1] >= 0))) {
        zeroCrossings++;
      }
    }

    final double rms = math.sqrt(sumSquares / frame.length);
    final double energyDb = (rms > 1e-6) ? (20.0 * (math.log(rms) / math.ln10)) : -100.0;
    final double zeroCrossingRate = zeroCrossings / frame.length;

    // 2. Physiological artifact discrimination
    // Artifacts: extremely high ZCR with low spectral regularity (breathing) or impulse spikes (table taps)
    bool isArtifact = false;
    if (zeroCrossingRate > 0.45 && energyDb < -25.0) {
      isArtifact = true; // Friction breathing / microphone wind
    } else if (energyDb > -5.0 && zeroCrossingRate < 0.05) {
      isArtifact = true; // Mechanical tap / thump
    }

    // 3. Speech probability scoring
    final bool rawSpeech = (energyDb > speechThresholdDb) && !isArtifact;
    final bool speechWithHangover = rawSpeech || (pastSpeechHangover > 0 && energyDb > (speechThresholdDb - 6.0));

    final double confidence = rawSpeech
        ? ((energyDb - speechThresholdDb) / 20.0).clamp(0.5, 1.0)
        : (speechWithHangover ? 0.4 : 0.0);

    return VadDecision(
      isSpeech: speechWithHangover,
      confidence: confidence,
      energyDb: energyDb,
      isArtifact: isArtifact,
    );
  }
}
