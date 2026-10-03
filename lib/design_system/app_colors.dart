import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF365AA8);
  static const Color primaryDark = Color(0xFFAFC6FF);
  static const Color secondary = Color(0xFF147D73);
  static const Color secondaryDark = Color(0xFF86D5CC);
  static const Color tertiary = Color(0xFFB7791F);
  static const Color tertiaryDark = Color(0xFFFFC86A);

  static const Color lightBackground = Color(0xFFFFFBF5);
  static const Color lightSurface = Color(0xFFFFFEFC);
  static const Color darkBackground = Color(0xFF12151A);
  static const Color darkSurface = Color(0xFF1B1F25);

  static const Color articleDer = Color(0xFF2563EB);
  static const Color articleDie = Color(0xFFD94662);
  static const Color articleDas = Color(0xFF0F8B7D);
  static const Color articleOther = Color(0xFF7C3AED);

  static const Color streak = Color(0xFFFF7A00);
  static const Color xp = Color(0xFFFFC43D);
  static const Color achievement = Color(0xFF8B5CF6);
  static const Color mastery = Color(0xFF18B981);

  static const Color glassLightStart = Color(0xE6FFFFFF);
  static const Color glassLightEnd = Color(0x66FFFFFF);
  static const Color glassDarkStart = Color(0x521B1F25);
  static const Color glassDarkEnd = Color(0x2412151A);
  static const Color glassBorderLight = Color(0x52FFFFFF);
  static const Color glassBorderDark = Color(0x3DFFFFFF);

  static const LinearGradient glassLightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[glassLightStart, glassLightEnd],
  );

  static const LinearGradient glassDarkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[glassDarkStart, glassDarkEnd],
  );
}
