import 'package:flutter/material.dart';
import 'features/onboarding/fast_onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
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

" + details.stack.toString(),
              style: const TextStyle(color: Color(0xFFF87171), fontSize: 11, fontFamily: "monospace"),
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
