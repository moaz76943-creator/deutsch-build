enum SpeechRatePreset {
  slow(0.75),
  normal(1.0);

  const SpeechRatePreset(this.rate);

  final double rate;
}

final class LearningPreferences {
  const LearningPreferences({
    this.speechRatePreset = SpeechRatePreset.normal,
    this.textScaleFactor = 1.0,
    this.showAutomaticTranslation = true,
  }) : assert(textScaleFactor >= minimumTextScale),
       assert(textScaleFactor <= maximumTextScale);

  static const double minimumTextScale = 0.85;
  static const double maximumTextScale = 1.30;
  static const double textScaleStep = 0.05;

  final SpeechRatePreset speechRatePreset;
  final double textScaleFactor;
  final bool showAutomaticTranslation;

  double get speechRate => speechRatePreset.rate;

  factory LearningPreferences.normalized({
    double? speechRate,
    double? textScaleFactor,
    bool? showAutomaticTranslation,
  }) {
    return LearningPreferences(
      speechRatePreset: _normalizeSpeechRate(speechRate),
      textScaleFactor: normalizeTextScale(textScaleFactor ?? 1.0),
      showAutomaticTranslation: showAutomaticTranslation ?? true,
    );
  }

  LearningPreferences copyWith({
    SpeechRatePreset? speechRatePreset,
    double? textScaleFactor,
    bool? showAutomaticTranslation,
  }) {
    return LearningPreferences(
      speechRatePreset: speechRatePreset ?? this.speechRatePreset,
      textScaleFactor: textScaleFactor == null
          ? this.textScaleFactor
          : normalizeTextScale(textScaleFactor),
      showAutomaticTranslation:
          showAutomaticTranslation ?? this.showAutomaticTranslation,
    );
  }

  static double normalizeTextScale(double value) {
    final clamped = value.clamp(minimumTextScale, maximumTextScale).toDouble();
    final steps = ((clamped - minimumTextScale) / textScaleStep).round();
    final snapped = minimumTextScale + (steps * textScaleStep);
    return (snapped * 100).round() / 100.0;
  }

  static SpeechRatePreset _normalizeSpeechRate(double? value) {
    if (value == null) return SpeechRatePreset.normal;
    const midpoint = (0.75 + 1.0) / 2;
    return value <= midpoint
        ? SpeechRatePreset.slow
        : SpeechRatePreset.normal;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningPreferences &&
          other.speechRatePreset == speechRatePreset &&
          other.textScaleFactor == textScaleFactor &&
          other.showAutomaticTranslation == showAutomaticTranslation;

  @override
  int get hashCode => Object.hash(
        speechRatePreset,
        textScaleFactor,
        showAutomaticTranslation,
      );
}
