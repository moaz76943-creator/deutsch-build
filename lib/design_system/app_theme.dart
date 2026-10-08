import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_design_tokens.dart';
import 'app_typography.dart';

abstract final class DeutschAppTheme {
  static ThemeData light() {
    final colorScheme = const ColorScheme.light(
      primary: Color(0xFF2F6BFF),
      secondary: Color(0xFF16A085),
      tertiary: Color(0xFF8B5CF6),
      surface: Color(0xFFF7FAFF),
      error: Color(0xFFE11D48),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF0F172A),
    );

    return _buildTheme(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldColor: const Color(0xFFF4F8FF),
      cardColor: Colors.white,
      textColor: const Color(0xFF0F172A),
    );
  }

  static ThemeData dark() {
    final colorScheme = const ColorScheme.dark(
      primary: Color(0xFF5B8CFF),
      secondary: Color(0xFF2DD4BF),
      tertiary: Color(0xFFA78BFA),
      surface: Color(0xFF0E1728),
      error: Color(0xFFFB7185),
      onPrimary: Colors.white,
      onSecondary: Color(0xFF081325),
      onSurface: Color(0xFFF8FAFC),
    );

    return _buildTheme(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldColor: const Color(0xFF081325),
      cardColor: const Color(0xFF12203A),
      textColor: const Color(0xFFF8FAFC),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldColor,
    required Color cardColor,
    required Color textColor,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldColor,
      primaryColor: colorScheme.primary,
      fontFamily: 'Cairo',
    );

    return base.copyWith(
      cardColor: cardColor,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      dividerColor: Colors.white.withValues(alpha: brightness == Brightness.dark ? 0.12 : 0.08),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.title.copyWith(color: textColor),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.display.copyWith(color: textColor),
        displayMedium: AppTypography.display.copyWith(
          color: textColor,
          fontSize: 26,
        ),
        titleLarge: AppTypography.title.copyWith(color: textColor),
        titleMedium: AppTypography.title.copyWith(
          color: textColor,
          fontSize: 18,
        ),
        bodyLarge: AppTypography.body.copyWith(
          color: textColor,
          fontSize: 16,
        ),
        bodyMedium: AppTypography.body.copyWith(color: textColor),
        labelLarge: AppTypography.label.copyWith(
          color: textColor,
          fontSize: 14,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.88),
        hintStyle: AppTypography.body.copyWith(
          color: textColor.withValues(alpha: 0.55),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1.1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1.1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.4,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: AppTypography.title.copyWith(
            fontSize: 16,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: AppTypography.title.copyWith(fontSize: 16),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.darkSurface.withValues(
          alpha: brightness == Brightness.dark ? 0.90 : 0.82,
        ),
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: textColor.withValues(alpha: 0.55),
        selectedLabelStyle: AppTypography.label,
        unselectedLabelStyle: AppTypography.label.copyWith(
          fontWeight: FontWeight.w600,
        ),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusL),
        ),
      ),
    );
  }
}
