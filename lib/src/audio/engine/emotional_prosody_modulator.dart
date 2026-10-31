import 'package:meta/meta.dart';

/// Pedagogical affective states tailored for optimal language acquisition.
enum PedagogicalAffectiveState {
  encouraging, // Upbeat, supportive, bright
  patientCalming, // Slower rate, softened glottal attack, relaxed pitch
  inquisitiveCurious, // Extended pitch excursions, rising cadence
  celebratoryProud, // High energy, crisp articulation, dynamic peaks
}

/// Modulated acoustic parameters to control vocal warmth and demeanor.
@immutable
class AffectiveAcousticParams {
  final double pitchShiftRatio; // F0 scale factor (e.g. 1.05 = +5%)
  final double speechRateMultiplier; // Rate factor (0.85 to 1.15)
  final double breathinessRatio; // Glottal aspiration noise
  final double dynamicRangeBoostDb; // Energy boost in dB

  const AffectiveAcousticParams({
    required this.pitchShiftRatio,
    required this.speechRateMultiplier,
    required this.breathinessRatio,
    required this.dynamicRangeBoostDb,
  });
}

/// Sovereign Voice Deep Core v2: Emotional Prosody & Affective Acoustic Modulator.
///
/// Modulates vocal warmth, patience, and encouraging pedagogical resonance
/// to reduce learner anxiety (Stephen Krashen's Affective Filter Hypothesis),
/// enhancing language acquisition across all 100 languages.
@immutable
class EmotionalProsodyModulator {
  const EmotionalProsodyModulator();

  /// Calculates affective acoustic parameter overrides for a target emotional tone.
  AffectiveAcousticParams calculateParameters(PedagogicalAffectiveState state) {
    switch (state) {
      case PedagogicalAffectiveState.encouraging:
        return const AffectiveAcousticParams(
          pitchShiftRatio: 1.06,
          speechRateMultiplier: 1.02,
          breathinessRatio: 0.05,
          dynamicRangeBoostDb: 1.5,
        );
      case PedagogicalAffectiveState.patientCalming:
        return const AffectiveAcousticParams(
          pitchShiftRatio: 0.96,
          speechRateMultiplier: 0.88, // 12% slower for clarity
          breathinessRatio: 0.08,
          dynamicRangeBoostDb: -1.0,
        );
      case PedagogicalAffectiveState.inquisitiveCurious:
        return const AffectiveAcousticParams(
          pitchShiftRatio: 1.12,
          speechRateMultiplier: 0.98,
          breathinessRatio: 0.04,
          dynamicRangeBoostDb: 0.5,
        );
      case PedagogicalAffectiveState.celebratoryProud:
        return const AffectiveAcousticParams(
          pitchShiftRatio: 1.15,
          speechRateMultiplier: 1.08,
          breathinessRatio: 0.02,
          dynamicRangeBoostDb: 2.8,
        );
    }
  }
}
