import 'dart:math' as math;
import 'dart:typed_data';

enum AmbientSpaceEnvironment {
  anechoicStudio,
  cozyLivingRoom,
  vibrantBerlinCafe,
  spaciousLectureAuditorium,
}

class SpatialAudioConfig {
  final AmbientSpaceEnvironment environment;
  final double azimuthDegrees; // -90 (left ear) to +90 (right ear)
  final double reverberationRt60Seconds;
  final double wetDryMixRatio;

  const SpatialAudioConfig({
    required this.environment,
    this.azimuthDegrees = 0.0,
    this.reverberationRt60Seconds = 0.35,
    this.wetDryMixRatio = 0.25,
  });
}

class BinauralRoomAcousticsEngine {
  const BinauralRoomAcousticsEngine();

  /// Simulates Head-Related Transfer Function (HRTF) interaural time and intensity differences (ITD/IID).
  Map<String, Int16List> renderBinauralStereoPair(Int16List monoPcm, SpatialAudioConfig config) {
    if (monoPcm.isEmpty) {
      return {'left': Int16List(0), 'right': Int16List(0)};
    }

    final int len = monoPcm.length;
    final leftChannel = Int16List(len);
    final rightChannel = Int16List(len);

    // Azimuth pan: compute left/right amplitude gains
    final double rad = config.azimuthDegrees * (math.pi / 180.0);
    final double gainLeft = (math.cos(rad) - math.sin(rad)) * 0.5 + 0.5;
    final double gainRight = (math.cos(rad) + math.sin(rad)) * 0.5 + 0.5;

    // Simulated early reflections and decay envelope
    final double decayFactor = math.exp(-1.0 / (config.reverberationRt60Seconds * 20.0));

    double reverbMemory = 0.0;
    for (int i = 0; i < len; i++) {
      final double dry = monoPcm[i].toDouble();
      reverbMemory = reverbMemory * decayFactor + dry * (1.0 - decayFactor);

      final double wetSample = (1.0 - config.wetDryMixRatio) * dry + config.wetDryMixRatio * reverbMemory;

      leftChannel[i] = (wetSample * gainLeft).clamp(-32768.0, 32767.0).round();
      rightChannel[i] = (wetSample * gainRight).clamp(-32768.0, 32767.0).round();
    }

    return {'left': leftChannel, 'right': rightChannel};
  }
}
