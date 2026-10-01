import 'package:flutter/material.dart';

class NeuroAccessibilityMode extends InheritedWidget {
  final bool isEnabled;

  const NeuroAccessibilityMode({
    super.key,
    required this.isEnabled,
    required super.child,
  });

  static NeuroAccessibilityMode? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NeuroAccessibilityMode>();
  }

  static bool of(BuildContext context) {
    final result = maybeOf(context);
    return result?.isEnabled ?? false;
  }

  @override
  bool updateShouldNotify(NeuroAccessibilityMode oldWidget) =>
      isEnabled != oldWidget.isEnabled;
}

extension NeuroAccessibilityThemeExtension on ThemeData {
  ThemeData applyNeuroAccessibility() {
    return copyWith(
      textTheme: textTheme.copyWith(
        bodyLarge: textTheme.bodyLarge?.copyWith(
          letterSpacing: 1.5,
          height: 1.8,
          // Optional: use a dyslexia-friendly font family if available,
          // or fallback to a clean sans-serif.
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          letterSpacing: 1.5,
          height: 1.8,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(letterSpacing: 1.2),
      ),
    );
  }
}
