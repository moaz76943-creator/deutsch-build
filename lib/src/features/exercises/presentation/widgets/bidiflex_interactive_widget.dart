import 'package:flutter/material.dart';

/// Segment of a bidirectional sentence or interactive exercise item.
class BidiSegment {
  final String text;
  final TextDirection direction;
  final bool isInteractiveSlot;
  final String? slotKey;
  final TextStyle? customStyle;

  const BidiSegment({
    required this.text,
    this.direction = TextDirection.ltr,
    this.isInteractiveSlot = false,
    this.slotKey,
    this.customStyle,
  });

  /// Factory helper for German target fragments (LTR)
  factory BidiSegment.german(String text, {bool isSlot = false, String? key}) {
    return BidiSegment(
      text: text,
      direction: TextDirection.ltr,
      isInteractiveSlot: isSlot,
      slotKey: key,
    );
  }

  /// Factory helper for Arabic instruction fragments (RTL)
  factory BidiSegment.arabic(String text) {
    return BidiSegment(
      text: text,
      direction: TextDirection.rtl,
    );
  }
}

/// Adaptive bidirectional interactive layout widget for exercises.
/// Safely renders mixed German (LTR) and Arabic (RTL) content with interactive slots
/// ensuring zero layout overflows across various device form factors.
class BidiFlexInteractiveWidget extends StatelessWidget {
  final List<BidiSegment> segments;
  final Widget Function(BuildContext context, BidiSegment segment)? slotBuilder;
  final TextDirection baseDirection;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;

  const BidiFlexInteractiveWidget({
    super.key,
    required this.segments,
    this.slotBuilder,
    this.baseDirection = TextDirection.rtl,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.alignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 16);

    return Directionality(
      textDirection: baseDirection,
      child: Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        alignment: alignment,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: segments.map((segment) {
          if (segment.isInteractiveSlot && slotBuilder != null) {
            return Semantics(
              label: 'Interactive slot ${segment.slotKey ?? segment.text}',
              child: slotBuilder!(context, segment),
            );
          }

          return Directionality(
            textDirection: segment.direction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: segment.direction == TextDirection.ltr
                  ? BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    )
                  : null,
              child: Text(
                segment.text,
                style: segment.customStyle ??
                    defaultStyle.copyWith(
                      fontWeight: segment.direction == TextDirection.ltr
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
