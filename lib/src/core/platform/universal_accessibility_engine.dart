class AccessibilitySettings {
  final double fontScaleFactor; // 1.0x to 2.0x (200% WCAG benchmark)
  final bool highContrastEnabled;
  final bool reduceMotionEnabled;
  final bool screenReaderActive;

  const AccessibilitySettings({
    this.fontScaleFactor = 1.0,
    this.highContrastEnabled = false,
    this.reduceMotionEnabled = false,
    this.screenReaderActive = false,
  });

  Map<String, dynamic> toJson() => {
    'fontScaleFactor': fontScaleFactor,
    'highContrastEnabled': highContrastEnabled,
    'reduceMotionEnabled': reduceMotionEnabled,
    'screenReaderActive': screenReaderActive,
  };
}

class UniversalAccessibilityEngine {
  const UniversalAccessibilityEngine();

  /// Generates screen reader semantic readout string for a flashcard.
  String generateFlashcardSemanticLabel({
    required String frontTerm,
    required String backMeaning,
    required String partOfSpeech,
    required String phoneticIpa,
    required bool isFlipped,
  }) {
    if (!isFlipped) {
      return 'Vokabelkarte Vorderseite: $frontTerm, Wortart: $partOfSpeech, Aussprache: $phoneticIpa. Doppeltippen zum Umdrehen.';
    } else {
      return 'Vokabelkarte Rückseite: Bedeutung auf Deutsch oder Arabisch: $backMeaning. Wählen Sie Ihren Erinnerungsgrad.';
    }
  }

  /// Calculates safe layout padding when large dynamic font sizes (up to 200%) are active.
  double computeDynamicPadding(double basePadding, double fontScale) {
    if (fontScale > 1.5) {
      // Reduce layout padding slightly to give text maximum bounding area without clipping
      return basePadding * 0.75;
    }
    return basePadding;
  }

  /// Determines whether physical 3D card rotation animations should be bypassed for vestibular health.
  bool shouldBypassMotionAnimations(AccessibilitySettings settings) {
    return settings.reduceMotionEnabled;
  }

  /// Validates WCAG AAA compliance standards.
  bool verifyWcagAaaCompliance({
    required double contrastRatio,
    required double maxSupportedFontScale,
    required bool hasSemanticTreeLabels,
  }) {
    // WCAG AAA requires >= 7.0:1 contrast, at least 200% font scale, and complete semantic tree
    return contrastRatio >= 7.0 && maxSupportedFontScale >= 2.0 && hasSemanticTreeLabels;
  }
}
