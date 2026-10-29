import 'package:flutter/material.dart';

/// AccessibleTouchTarget - Master Constitution Section 10 Compliant:
/// Enforces minimum 48x48dp touch targets per Android & Material Accessibility Guidelines,
/// and attaches explicit Semantics labels for TalkBack / VoiceOver screen readers.
class AccessibleTouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String semanticLabel;
  final String? semanticHint;
  final double minSize;

  const AccessibleTouchTarget({
    super.key,
    required this.child,
    required this.onTap,
    required this.semanticLabel,
    this.semanticHint,
    this.minSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticLabel,
      hint: semanticHint,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minSize,
            minHeight: minSize,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// AccessibleClampedText prevents extreme system font scales (>1.5x) from breaking layout
class AccessibleClampedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double maxScale;
  final TextOverflow overflow;
  final int? maxLines;

  const AccessibleClampedText(
    this.text, {
    super.key,
    this.style,
    this.maxScale = 1.5,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final clampedScaler = media.textScaler.clamp(
      minScaleFactor: 0.85,
      maxScaleFactor: maxScale,
    );

    return MediaQuery(
      data: media.copyWith(textScaler: clampedScaler),
      child: Text(
        text,
        style: style,
        overflow: overflow,
        maxLines: maxLines,
      ),
    );
  }
}
