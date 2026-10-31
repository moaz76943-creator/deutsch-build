/// Master Constitution Section 02, 07 & 10 Compliant:
/// FeatureReadinessGate evaluates language pair capability sets
/// (Vocabulary, Audio, Grammar, Placement, SRS) and dynamically
/// provides graceful fallback states without throwing unhandled exceptions.
class PairCapabilities {
  final String pairId;
  final bool hasVocabulary;
  final bool hasAudioPronunciation;
  final bool hasGrammarModules;
  final bool hasPlacementAssessment;
  final bool hasSpacedRepetition;

  const PairCapabilities({
    required this.pairId,
    this.hasVocabulary = true,
    this.hasAudioPronunciation = false,
    this.hasGrammarModules = false,
    this.hasPlacementAssessment = false,
    this.hasSpacedRepetition = true,
  });
}

class FeatureReadinessGate {
  final Map<String, PairCapabilities> _capabilitiesRegistry;

  const FeatureReadinessGate(this._capabilitiesRegistry);

  /// Resolves capability set for any language pair, falling back to core vocabulary
  PairCapabilities getCapabilities(String pairId) {
    if (_capabilitiesRegistry.containsKey(pairId)) {
      return _capabilitiesRegistry[pairId]!;
    }

    // Default fallback: core vocabulary and SRS always enabled offline
    return PairCapabilities(
      pairId: pairId,
      hasVocabulary: true,
      hasAudioPronunciation: false,
      hasGrammarModules: false,
      hasPlacementAssessment: false,
      hasSpacedRepetition: true,
    );
  }

  /// Determines if an interactive feature can be triggered or needs a disabled tooltip
  bool isFeatureAvailable(String pairId, String featureKey) {
    final cap = getCapabilities(pairId);
    switch (featureKey.toLowerCase()) {
      case 'audio':
      case 'tts':
        return cap.hasAudioPronunciation;
      case 'grammar':
        return cap.hasGrammarModules;
      case 'placement':
        return cap.hasPlacementAssessment;
      case 'srs':
        return cap.hasSpacedRepetition;
      case 'vocabulary':
      default:
        return cap.hasVocabulary;
    }
  }
}
