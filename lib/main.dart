import 'package:flutter/material.dart';
import 'features/onboarding/fast_onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF1E293B),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Text(
              "CRASH DETECTED:

" + details.exceptionAsString() + "

STACK TRACE:
" + details.stack.toString(),
              style: const TextStyle(color: Color(0xFFF87171), fontSize: 12, fontFamily: "monospace"),
            ),
          ),
        ),
      ),
    );
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFFFFFFFF),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Text(
              "CRASH REASON:
" + details.exceptionAsString() + "

STACK TRACE:
" + details.stack.toString(),
              style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 13, fontFamily: "monospace"),
            ),
          ),
        ),
      ),
    );
  };

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
