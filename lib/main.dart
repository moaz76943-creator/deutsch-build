import 'package:flutter/material.dart';
import 'features/onboarding/fast_onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint("[DBA][FLUTTER_ERROR] ${details.exceptionAsString()}");
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF0F172A),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Text(
              "CRASH REASON:\n\n${details.exceptionAsString()}\n\nSTACK TRACE:\n${details.stack}",
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
      home: const FastOnboardingScreen(),
    );
  }
}
