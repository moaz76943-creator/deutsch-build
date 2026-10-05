import 'dart:ui';

import 'package:flutter/material.dart';

class AdaptiveGlassSurface extends StatelessWidget {
  const AdaptiveGlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.blurSigma = 8,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final highContrast =
        MediaQuery.maybeOf(context)?.highContrast ?? false;
    final isDark = theme.brightness == Brightness.dark;

    final fillOpacity = highContrast
        ? (isDark ? 0.92 : 0.96)
        : (isDark ? 0.56 : 0.72);
    final borderOpacity = highContrast ? 1.0 : 0.72;
    final radius = BorderRadius.circular(borderRadius);
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(
          alpha: fillOpacity,
        ),
        borderRadius: radius,
        border: Border.all(
          color: scheme.outlineVariant.withValues(
            alpha: borderOpacity,
          ),
        ),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    final clipped = highContrast || blurSigma <= 0
        ? ClipRRect(
            borderRadius: radius,
            child: content,
          )
        : ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurSigma,
                sigmaY: blurSigma,
              ),
              child: content,
            ),
          );

    return RepaintBoundary(child: clipped);
  }
}
