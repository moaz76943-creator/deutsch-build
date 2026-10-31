import 'dart:math' as math;
import 'package:meta/meta.dart';

/// Pitch command types for multi-language micro-prosody generation.
enum PitchCommandType {
  declarativeFall,
  interrogativeRise,
  tonalHighRegister,
  tonalLowRegister,
  tonalContourDipping,
  emphasisPeak,
}

/// A timed pitch command event along the utterance timeline.
@immutable
class PitchCommandEvent {
  final double timeSeconds;
  final double amplitudeHz;
  final PitchCommandType type;

  const PitchCommandEvent({
    required this.timeSeconds,
    required this.amplitudeHz,
    required this.type,
  });
}

/// Sovereign Voice Deep Core v2: Micro-Prosody Intonation Contour Generator.
///
/// Implements a continuous superposition intonation model (extended Fujisaki model)
/// to generate natural micro-prosodic fundamental frequency (F0) trajectories.
/// Harmonizes pitch contours across tonal (Chinese/Thai/Vietnamese), pitch-accent
/// (Japanese/Swedish/Norwegian), and stress-accent (Arabic/German/Russian/English) tongues.
@immutable
class MicroProsodyContourGenerator {
  final double baselineF0Hz; // Default speaker fundamental frequency
  final double phraseDecayRate;

  const MicroProsodyContourGenerator({
    this.baselineF0Hz = 120.0,
    this.phraseDecayRate = 0.15,
  });

  /// Generates a continuous F0 pitch curve over the given duration.
  List<double> generateContour({
    required double totalDurationSeconds,
    required List<PitchCommandEvent> commands,
    int stepRateHz = 100, // 100 steps per second (10ms resolution)
  }) {
    final int totalSteps = (totalDurationSeconds * stepRateHz).round();
    final contour = List<double>.filled(totalSteps, baselineF0Hz);

    for (int step = 0; step < totalSteps; step++) {
      final double t = step / stepRateHz;
      // 1. Asymptotic baseline phrase decline
      double f0 = baselineF0Hz * math.exp(-phraseDecayRate * t);

      // 2. Superposition of accent and tonal commands
      for (final cmd in commands) {
        final double dt = t - cmd.timeSeconds;
        if (dt >= 0 && dt < 0.6) {
          // Bell-shaped gamma distribution response
          final double response = (dt / 0.15) * math.exp(1.0 - (dt / 0.15));
          switch (cmd.type) {
            case PitchCommandType.emphasisPeak:
            case PitchCommandType.interrogativeRise:
            case PitchCommandType.tonalHighRegister:
              f0 += cmd.amplitudeHz * response;
              break;
            case PitchCommandType.declarativeFall:
            case PitchCommandType.tonalLowRegister:
              f0 -= cmd.amplitudeHz * response * 0.6;
              break;
            case PitchCommandType.tonalContourDipping:
              // Dipping tone: initial dip then sharp rise
              f0 += cmd.amplitudeHz * (dt < 0.2 ? -0.4 * response : 0.8 * response);
              break;
          }
        }
      }

      contour[step] = f0.clamp(60.0, 450.0);
    }

    return contour;
  }
}
