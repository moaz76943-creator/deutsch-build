import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/design_system/app_theme.dart';

void main() {
  test('light and dark entrypoint themes use the same Cairo typography', () {
    final light = AppTheme.lightTheme;
    final dark = AppTheme.darkTheme;

    expect(light.useMaterial3, isTrue);
    expect(dark.useMaterial3, isTrue);
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
    expect(light.textTheme.bodyMedium?.fontFamily, 'Cairo');
    expect(dark.textTheme.bodyMedium?.fontFamily, 'Cairo');
  });

  test('both themes preserve their expected readable surfaces', () {
    expect(
      AppTheme.lightTheme.scaffoldBackgroundColor,
      const Color(0xFFF8FAFC),
    );
    expect(
      AppTheme.darkTheme.scaffoldBackgroundColor,
      const Color(0xFF0B1F4D),
    );
  });
}
