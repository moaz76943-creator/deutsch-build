import 'package:flutter/material.dart';

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
        surface: Color(0xFF1E3A8A),
      ),
    );
  }
}
