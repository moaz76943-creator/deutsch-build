import 'package:flutter/material.dart';

@immutable
final class SmartOrbPalette {
  const SmartOrbPalette({
    required this.core,
    required this.success,
    required this.guidance,
    required this.incorrect,
    required this.glassHighlight,
    required this.outline,
  });

  final Color core;
  final Color success;
  final Color guidance;
  final Color incorrect;
  final Color glassHighlight;
  final Color outline;
}

@immutable
final class SmartOrbThemeTokens {
  const SmartOrbThemeTokens({
    required this.palette,
    required this.pulsePeriod,
    required this.feedbackDuration,
    required this.shakeDuration,
    required this.glassBlurSigma,
    required this.reduceMotion,
  });

  final SmartOrbPalette palette;
  final Duration pulsePeriod;
  final Duration feedbackDuration;
  final Duration shakeDuration;
  final double glassBlurSigma;
  final bool reduceMotion;

  static SmartOrbThemeTokens of(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final media = MediaQuery.maybeOf(context);
    final isDark = theme.brightness == Brightness.dark;
    final highContrast = media?.highContrast ?? false;
    final reduceMotion = media?.disableAnimations ?? false;

    final core = _blend(
      isDark
          ? const Color(0xFF72E7FF)
          : const Color(0xFF1687B8),
      scheme.primary,
      0.42,
    );
    final success = _blend(
      isDark
          ? const Color(0xFF5DE08D)
          : const Color(0xFF168A50),
      scheme.primary,
      0.16,
    );
    final guidance = _blend(
      isDark
          ? const Color(0xFF77A8FF)
          : const Color(0xFF2F6FD4),
      scheme.secondary,
      0.18,
    );
    final incorrect = _blend(
      isDark
          ? const Color(0xFFFFB45E)
          : const Color(0xFFD96B16),
      scheme.tertiary,
      0.16,
    );

    return SmartOrbThemeTokens(
      palette: SmartOrbPalette(
        core: core,
        success: success,
        guidance: guidance,
        incorrect: incorrect,
        glassHighlight: scheme.surface,
        outline: highContrast
            ? scheme.onSurface
            : scheme.outlineVariant,
      ),
      pulsePeriod: const Duration(milliseconds: 1120),
      feedbackDuration: const Duration(milliseconds: 720),
      shakeDuration: const Duration(milliseconds: 460),
      glassBlurSigma: highContrast ? 0 : 8,
      reduceMotion: reduceMotion,
    );
  }

  static Color _blend(
    Color semantic,
    Color adaptive,
    double amount,
  ) =>
      Color.lerp(semantic, adaptive, amount)!;
}
