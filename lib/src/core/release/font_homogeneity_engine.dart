enum ScriptType {
  latin,
  arabicBidi,
  cyrillic,
  devanagari,
  eastAsianTonal,
}

class ViewportSpec {
  final String deviceLabel;
  final double widthDp;
  final double heightDp;
  final double devicePixelRatio;

  const ViewportSpec({
    required this.deviceLabel,
    required this.widthDp,
    required this.heightDp,
    required this.devicePixelRatio,
  });
}

class FontMetricsRule {
  final ScriptType script;
  final double recommendedLineHeightMultiplier;
  final double minAscenderDescenderPaddingDp;

  const FontMetricsRule({
    required this.script,
    required this.recommendedLineHeightMultiplier,
    required this.minAscenderDescenderPaddingDp,
  });
}

class FontHomogeneityEngine {
  static const Map<ScriptType, FontMetricsRule> _scriptRules = {
    ScriptType.arabicBidi: FontMetricsRule(
      script: ScriptType.arabicBidi,
      recommendedLineHeightMultiplier: 1.60, // Extra headroom for Arabic diacritics/tashkeel
      minAscenderDescenderPaddingDp: 6.0,
    ),
    ScriptType.devanagari: FontMetricsRule(
      script: ScriptType.devanagari,
      recommendedLineHeightMultiplier: 1.55, // Headroom for matras and shirorekha
      minAscenderDescenderPaddingDp: 5.0,
    ),
    ScriptType.latin: FontMetricsRule(
      script: ScriptType.latin,
      recommendedLineHeightMultiplier: 1.35,
      minAscenderDescenderPaddingDp: 3.0,
    ),
    ScriptType.cyrillic: FontMetricsRule(
      script: ScriptType.cyrillic,
      recommendedLineHeightMultiplier: 1.35,
      minAscenderDescenderPaddingDp: 3.0,
    ),
    ScriptType.eastAsianTonal: FontMetricsRule(
      script: ScriptType.eastAsianTonal,
      recommendedLineHeightMultiplier: 1.45,
      minAscenderDescenderPaddingDp: 4.0,
    ),
  };

  const FontHomogeneityEngine();

  /// Calculates safe line height and vertical padding to prevent glyph clipping.
  double calculateSafeLineHeightDp(double fontSize, ScriptType script) {
    final rule = _scriptRules[script] ?? _scriptRules[ScriptType.latin]!;
    return fontSize * rule.recommendedLineHeightMultiplier;
  }

  /// Evaluates whether text length and font scale will cause overflow on compact screen viewports.
  bool willTextFitViewport({
    required String text,
    required double fontSize,
    required ViewportSpec viewport,
    int maxLines = 2,
  }) {
    // Average character width estimate in DP for standard mobile typography
    final double estimatedCharWidth = fontSize * 0.52;
    final double estimatedTextWidth = text.length * estimatedCharWidth;
    final double maxAvailableWidth = (viewport.widthDp - 32.0) * maxLines; // 16dp horizontal padding

    return estimatedTextWidth <= maxAvailableWidth;
  }
}
