import 'package:flutter/material.dart';

class AppTheme {
  // الألوان الأساسية للتطبيق
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color accentColor = Color(0xFFFFB300);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color darkTextColor = Color(0xFF212121);

  // النمط العام للواجهات (ThemeData)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
