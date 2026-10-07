import 'package:flutter/material.dart';
import 'ui/language_selector_screen.dart';

void main() {
  runApp(const DeutschBilarabiApp());
}

class DeutschBilarabiApp extends StatelessWidget {
  const DeutschBilarabiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LanguageSelectorScreen(),
    );
  }
}
