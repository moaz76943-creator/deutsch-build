import 'package:flutter/material.dart';
import 'universal_script_shaper.dart';

/// Engine responsible for font-family fallback resolution and vertical line metrics.
class UniversalMultiScriptTypographyEngine {
  const UniversalMultiScriptTypographyEngine();

  /// Resolves the optimal font family chain for a detected script.
  String resolveFontFamily(ScriptType script) {
    switch (script) {
      case ScriptType.arabicPersianUrdu:
        return 'NotoSansArabic';
      case ScriptType.cyrillic:
        return 'NotoSansCyrillic';
      case ScriptType.cjk:
        return 'NotoSansCJK';
      case ScriptType.latin:
      case ScriptType.unknown:
        return 'NotoSansLatin';
    }
  }

  /// Constructs an adaptive TextStyle with normalized line-height across script boundaries.
  TextStyle getAdaptiveStyle({
    required String text,
    double fontSize = 16.0,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    final script = UniversalScriptShaper.detectScript(text);
    final fontFamily = resolveFontFamily(script);

    // CJK and Arabic scripts require slightly higher vertical line clearance
    final double normalizedHeight = (script == ScriptType.cjk || script == ScriptType.arabicPersianUrdu)
        ? 1.45
        : 1.25;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: fontFamily,
      height: normalizedHeight,
      color: color,
    );
  }

  /// Creates a safely shaped bidirectional RichText element with isolated tokens.
  Widget buildSafeBidiText({
    required String leadText,
    required String foreignToken,
    required String trailText,
    TextStyle? baseStyle,
  }) {
    final effectiveStyle = baseStyle ?? const TextStyle(fontSize: 16);
    final isolatedToken = UniversalScriptShaper.isolateToken(foreignToken);

    final isOverallRtl = UniversalScriptShaper.isRtlText(leadText);

    return Directionality(
      textDirection: isOverallRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: leadText, style: effectiveStyle),
            const TextSpan(text: ' '),
            TextSpan(
              text: isolatedToken,
              style: effectiveStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ' '),
            TextSpan(text: trailText, style: effectiveStyle),
          ],
        ),
      ),
    );
  }
}
