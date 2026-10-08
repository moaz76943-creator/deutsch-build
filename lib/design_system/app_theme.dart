import 'package:flutter/material.dart';

class AppTypography {
  static const TextStyle display = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  static const TextStyle title = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static const TextStyle body = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0B1F4D),
      fontFamily: 'Cairo',
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF38BDF8),
        secondary: Color(0xFFF39C6B),
        surface: Color(0xFF1E3A8A), // تم إصلاح background إلى surface
      ),
    );
  }
}
