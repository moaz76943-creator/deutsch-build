import 'package:deutsch_bilarabi/core/design/visual_contracts_theme/brightness_mode_controller.dart';
import 'package:deutsch_bilarabi/core/design/visual_contracts_theme/colors_typography_bridge.dart';
import 'package:deutsch_bilarabi/core/design/visual_contracts_theme/visual_theme_contracts.dart';
import 'package:deutsch_bilarabi/core/design/visual_contracts_theme/visual_theme_engine.dart';
import 'package:deutsch_bilarabi/design_system/app_colors.dart';
import 'package:deutsch_bilarabi/design_system/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VisualColorsTypographyBridge', () {
    test('delegates palette values to canonical AppColors', () {
      const colors = VisualColorContracts();

      expect(colors.primary(Brightness.light), AppColors.primary);
      expect(colors.primary(Brightness.dark), AppColors.primaryDark);
      expect(colors.secondary(Brightness.light), AppColors.secondary);
      expect(colors.secondary(Brightness.dark), AppColors.secondaryDark);
      expect(colors.background(Brightness.light), AppColors.lightBackground);
      expect(colors.background(Brightness.dark), AppColors.darkBackground);
      expect(colors.surface(Brightness.light), AppColors.lightSurface);
      expect(colors.surface(Brightness.dark), AppColors.darkSurface);
      expect(colors.articleDer, AppColors.articleDer);
      expect(colors.articleDie, AppColors.articleDie);
      expect(colors.articleDas, AppColors.articleDas);
    });

    test('delegates typography and language direction to canonical contracts', () {
      const typography = VisualTypographyContracts();

      expect(typography.display.fontSize, AppTypography.display.fontSize);
      expect(typography.title.fontWeight, AppTypography.title.fontWeight);
      expect(typography.body.height, AppTypography.body.height);
      expect(typography.label.fontSize, AppTypography.label.fontSize);
      expect(typography.directionFor('ar'), TextDirection.rtl);
      expect(typography.directionFor('de'), TextDirection.ltr);
    });
  });

  group('BrightnessModeController', () {
    test('system mode follows platform brightness', () {
      final controller = BrightnessModeController();

      expect(controller.mode, VisualThemeMode.system);
      expect(
        controller.effectiveBrightness(Brightness.light),
        Brightness.light,
      );
      expect(
        controller.effectiveBrightness(Brightness.dark),
        Brightness.dark,
      );
    });

    test('explicit mode overrides platform and toggle uses effective state', () {
      final controller = BrightnessModeController(
        initialMode: VisualThemeMode.light,
      );

      expect(
        controller.effectiveBrightness(Brightness.dark),
        Brightness.light,
      );

      controller.toggle(Brightness.dark);
      expect(controller.mode, VisualThemeMode.dark);
      controller.toggle(Brightness.light);
      expect(controller.mode, VisualThemeMode.light);
    });

    test('notifies only when mode actually changes', () {
      final controller = BrightnessModeController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.selectMode(VisualThemeMode.system);
      expect(notifications, 0);

      controller.selectMode(VisualThemeMode.dark);
      expect(notifications, 1);

      controller.selectMode(VisualThemeMode.dark);
      expect(notifications, 1);
    });
  });

  group('VisualThemeEngine', () {
    final light = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    );
    final dark = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
    );

    test('resolves injected canonical themes without rebuilding a second palette', () {
      final engine = VisualThemeEngine(
        themes: VisualThemeBundle(light: light, dark: dark),
      );

      expect(engine.themeMode, ThemeMode.system);
      expect(engine.resolve(Brightness.light).theme, same(light));
      expect(engine.resolve(Brightness.dark).theme, same(dark));

      engine.selectMode(VisualThemeMode.dark);
      final snapshot = engine.resolve(Brightness.light);
      expect(snapshot.mode, VisualThemeMode.dark);
      expect(snapshot.effectiveBrightness, Brightness.dark);
      expect(snapshot.theme, same(dark));
    });

    test('exposes canonical color and typography bridges', () {
      final engine = VisualThemeEngine(
        themes: VisualThemeBundle(light: light, dark: dark),
      );

      expect(engine.colors.primary(Brightness.light), AppColors.primary);
      expect(engine.typography.directionFor('ar-JO'), TextDirection.rtl);
    });

    test('can be driven directly by ThemeMode values', () {
      final engine = VisualThemeEngine(
        themes: VisualThemeBundle(light: light, dark: dark),
      );

      engine.selectThemeMode(ThemeMode.light);
      expect(engine.mode, VisualThemeMode.light);

      engine.selectThemeMode(ThemeMode.dark);
      expect(engine.mode, VisualThemeMode.dark);

      engine.selectThemeMode(ThemeMode.system);
      expect(engine.mode, VisualThemeMode.system);
    });
  });
}
