import 'package:flutter/material.dart';

/// سياسة إدارة سرعة الحركة وملاءمة إمكانية الوصول
class ReducedMotionPolicy {
  static Duration getAdaptiveDuration({
    required Duration standardDuration,
    required BuildContext context,
  }) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final disableAnimations = mediaQuery?.disableAnimations ?? false;
    if (disableAnimations) {
      return Duration.zero;
    }
    return standardDuration;
  }
}
