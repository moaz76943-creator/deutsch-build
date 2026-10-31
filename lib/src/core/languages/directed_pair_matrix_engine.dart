import 'declarative_language_profile.dart';
import 'directed_pair_config.dart';

/// Manages asymmetric directed language pairs across the 100-language matrix.
/// Computes cognitive friction and interference areas between any source and target.
class DirectedPairMatrixEngine {
  final Map<String, DirectedPairConfig> _cachedPairs = {};

  DirectedPairMatrixEngine();

  /// Computes or retrieves asymmetric configuration for source -> target pair.
  DirectedPairConfig getOrCreatePairConfig(LanguageProfile source, LanguageProfile target) {
    final pairKey = '${source.isoCode.toLowerCase()}_${target.isoCode.toLowerCase()}';
    if (_cachedPairs.containsKey(pairKey)) {
      return _cachedPairs[pairKey]!;
    }

    final config = _calculateAsymmetricConfig(source, target);
    _cachedPairs[pairKey] = config;
    return config;
  }

  /// Calculates linguistic friction based on structural divergence.
  DirectedPairConfig _calculateAsymmetricConfig(LanguageProfile s, LanguageProfile t) {
    double friction = 0.5; // Base friction
    final interference = <String>[];

    // Directionality friction
    final isBidi = s.isRtl != t.isRtl;
    if (isBidi) {
      friction += 0.4;
      interference.add('Bi-directional (RTL/LTR) Script Transition');
    }

    // Typology friction (e.g. SVO to SOV or VSO)
    if (s.typology != t.typology) {
      friction += 0.5;
      interference.add('Word Order Inversion (${s.typology} -> ${t.typology})');
    }

    // Case System Expansion
    if (t.casesCount > s.casesCount) {
      friction += 0.6;
      interference.add('Case Morphology Expansion (+${t.casesCount - s.casesCount} cases)');
    }

    // Gender System Mismatch
    if (t.genders.length > s.genders.length) {
      friction += 0.4;
      interference.add('Grammatical Gender System Expansion');
    }

    // Morphology Typology (Fusional vs Agglutinative)
    if (s.morphologyType != t.morphologyType) {
      friction += 0.5;
      interference.add('Morphological Paradigm Shift (${s.morphologyType} -> ${t.morphologyType})');
    }

    return DirectedPairConfig(
      sourceIso: s.isoCode,
      targetIso: t.isoCode,
      cognitiveFrictionScore: double.parse(friction.clamp(0.1, 3.0).toStringAsFixed(2)),
      primaryInterferenceAreas: interference,
      requiresBidiFlipping: isBidi,
    );
  }

  int get cachedPairsCount => _cachedPairs.length;
}
