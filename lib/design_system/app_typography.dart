import 'package:flutter/material.dart';

class AppTypography {
  static const TextStyle display = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  static const TextStyle title = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  static const TextStyle h1 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const TextStyle h2 = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const TextStyle body = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
  static const TextStyle caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w300);
}

class AppGradients {
  static const LinearGradient purpleCard = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
  );
}
