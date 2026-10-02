import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/ui_v35/theme/app_design_system.dart';

void main() {
  test('visual foundation uses a deterministic Material 3 light theme', () {
    final first = AppDesignSystem.light();
    final second = AppDesignSystem.light();

    expect(first.useMaterial3, isTrue);
    expect(first.colorScheme.primary, AppPalette.primary);
    expect(first.colorScheme.primary, second.colorScheme.primary);
    expect(first.scaffoldBackgroundColor, AppPalette.lightBackground);
    expect(first.cardTheme.color, AppPalette.lightSurface);

    final shape = first.cardTheme.shape;
    expect(shape, isA<RoundedRectangleBorder>());
    final rounded = shape! as RoundedRectangleBorder;
    expect(rounded.borderRadius, BorderRadius.circular(20));
  });

  test('dark theme keeps the same fixed design language', () {
    final theme = AppDesignSystem.dark();

    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AppPalette.darkBackground);
    expect(theme.cardTheme.color, AppPalette.darkSurface);
    expect(theme.colorScheme.primary, AppPalette.primaryDark);
  });
}
