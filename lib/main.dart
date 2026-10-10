import 'package:flutter/material.dart';
import 'features/onboarding/fast_onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

  // Global Safe Error Boundary - Zero Crash Policy
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.refresh_rounded, size: 48, color: Colors.blueGrey),
              const SizedBox(height: 16),
              const Text(
                'Deutsch بالعربي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'حدث تحديث بسيط في الواجهة، يرجى إعادة الفتح.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ],
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
