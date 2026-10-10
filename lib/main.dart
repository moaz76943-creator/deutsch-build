import 'package:flutter/material.dart';
import 'features/onboarding/fast_onboarding_screen.dart';

void main() {
  runApp(const DeutschApp());
}

class DeutschApp extends StatelessWidget {
  const DeutschApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deutsch بالعربي',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
      ),
      // توجيه التطبيق لشاشة البداية السريعة
      home: const FastOnboardingScreen(),
    );
  }
}
